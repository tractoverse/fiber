#' @include bundle.R streamline.R
NULL

# ---- reparametrize ----------------------------------------------------------

#' Reparametrize a streamline or bundle onto a uniform arc-length grid
#'
#' @description
#' `reparametrize()` is an S7 generic that resamples the 3-D coordinates (and
#' any `@point_data` attributes) of a tractography object onto a uniform
#' arc-length grid using linear interpolation, with methods available for the
#' following classes:
#'
#' `r doclisting::methods_list("reparametrize")`
#'
#' @param x A [streamline] or [bundle] object.
#' @param n_points Number of equally-spaced arc-length points to use.
#'
#'   - For a single [streamline], defaults to `nrow(x@points)`.
#'   - For a [bundle], defaults to the rounded mean number of points across
#'     all streamlines.
#'
#'   Pass `NULL` to use these defaults explicitly.
#' @returns An object of the same class as `x` reparametrized onto the new
#'   grid.
#' @export
#' @examples
#' # reparametrize a single streamline to 10 points
#' pts <- matrix(runif(30), ncol = 3)
#' colnames(pts) <- c("X", "Y", "Z")
#' sl <- streamline(points = pts)
#' sl_reparam <- reparametrize(sl, n_points = 10)
#' # reparametrize a bundle to the mean number of points across its streamlines
#' sl1 <- streamline(points = pts)
#' pts2 <- matrix(runif(60), ncol = 3)
#' colnames(pts2) <- c("X", "Y", "Z")
#' sl2 <- streamline(points = pts2)
#' b <- bundle(streamlines = list(sl1, sl2))
#' bundle_reparam <- reparametrize(b)
reparametrize <- S7::new_generic(
  "reparametrize",
  "x",
  function(x, n_points = NULL) {
    S7::S7_dispatch()
  }
)

# ---- method: streamline -----------------------------------------------------

#' [reparametrize()] method for `streamline` objects
#'
#' Resamples a single [streamline] onto a uniform arc-length grid. See
#' [reparametrize()] for the full parameter documentation.
#'
#' @param x A [streamline] object.
#' @inheritParams reparametrize
#' @returns A [streamline] reparametrized onto the new grid. The returned
#'   object has the same class as the input but with `@points` resampled to
#'   exactly `n_points` rows and all `@point_data` vectors resampled
#'   correspondingly via linear interpolation.
#' @seealso [reparametrize()]
#' @name reparametrize-fiber-streamline-method
#' @aliases reparametrize,fiber::streamline-method
#' @usage NULL
#' @examples
#' pts <- matrix(runif(30), ncol = 3)
#' colnames(pts) <- c("X", "Y", "Z")
#' sl <- streamline(points = pts, point_data = list(FA = runif(10)))
#' sl_reparam <- reparametrize(sl, n_points = 20)
#' sl_reparam@n_points  # 20
S7::method(reparametrize, streamline) <- function(x, n_points = NULL) {
  pts <- x@points
  s <- .arc_length(pts)
  n <- if (is.null(n_points)) nrow(pts) else as.integer(n_points)

  if (n < 2L) {
    cli::cli_abort("{.arg n_points} must be at least 2.")
  }

  s_new <- seq(s[1L], s[length(s)], length.out = n)

  new_pts <- cbind(
    X = .approx1(s, pts[, "X"], s_new),
    Y = .approx1(s, pts[, "Y"], s_new),
    Z = .approx1(s, pts[, "Z"], s_new)
  )
  # preserve any extra columns beyond X, Y, Z
  extra_cols <- setdiff(colnames(pts), c("X", "Y", "Z"))
  if (length(extra_cols) > 0L) {
    extra <- vapply(
      extra_cols,
      function(col) {
        .approx1(s, pts[, col], s_new)
      },
      numeric(n)
    )
    new_pts <- cbind(new_pts, extra)
  }

  # Only numeric point_data can be interpolated; non-numeric entries are
  # dropped with a warning because they have no natural interpolant.
  new_pd <- list()
  for (nm in names(x@point_data)) {
    v <- x@point_data[[nm]]
    if (is.numeric(v)) {
      new_pd[[nm]] <- .approx1(s, v, s_new)
    } else {
      cli::cli_warn(c(
        "!" = "Non-numeric {.field @point_data} attribute {.val {nm}} \\
               cannot be interpolated and will be dropped.",
        "i" = "Only numeric per-point attributes are preserved by \\
               {.fn reparametrize}."
      ))
    }
  }

  streamline(
    points = new_pts,
    point_data = new_pd,
    streamline_data = x@streamline_data
  )
}

# ---- method: bundle ---------------------------------------------------------

#' [reparametrize()] method for `bundle` objects
#'
#' Resamples every [streamline] inside a [bundle] onto a common uniform
#' arc-length grid. See [reparametrize()] for the full parameter documentation.
#'
#' @param x A [bundle] object.
#' @inheritParams reparametrize
#' @returns A [bundle] reparametrized onto the new grid. Every streamline in the
#'   returned bundle has exactly `n_points` rows in `@points` (defaulting to
#'   the rounded mean number of points across all streamlines when `n_points`
#'   is `NULL`).
#' @seealso [reparametrize()]
#' @name reparametrize-fiber-bundle-method
#' @aliases reparametrize,fiber::bundle-method
#' @usage NULL
#' @examples
#' pts1 <- matrix(runif(30), ncol = 3)
#' colnames(pts1) <- c("X", "Y", "Z")
#' pts2 <- matrix(runif(60), ncol = 3)
#' colnames(pts2) <- c("X", "Y", "Z")
#' b <- bundle(streamlines = list(streamline(points = pts1),
#'                                 streamline(points = pts2)))
#' b_reparam <- reparametrize(b, n_points = 15)
#' b_reparam[[1]]@n_points  # 15
#' b_reparam[[2]]@n_points  # 15
S7::method(reparametrize, bundle) <- function(x, n_points = NULL) {
  if (length(x@streamlines) == 0L) {
    return(x)
  }

  n <- if (is.null(n_points)) {
    round(mean(vapply(
      x@streamlines,
      function(sl) nrow(sl@points),
      integer(1L)
    )))
  } else {
    as.integer(n_points)
  }

  new_sls <- lapply(x@streamlines, reparametrize, n_points = n)
  bundle(streamlines = new_sls, bundle_data = x@bundle_data)
}

# ---- bind_bundles ------------------------------------------------------------

#' Combine streamlines and/or bundles into a single bundle
#'
#' Accepts any mix of [streamline] and [bundle] objects. All streamlines are
#' collected into a flat list and wrapped in a new [bundle]. `bundle_data`
#' from the first [bundle] argument (if any) is preserved; pass your own via
#' the `bundle_data` argument to override.
#'
#' @param ... One or more [streamline] or [bundle] objects.
#' @param bundle_data A named list of bundle-level metadata to attach to the
#'   resulting [bundle]. Defaults to an empty list (or the `bundle_data` of
#'   the first [bundle] input if one is present and `bundle_data` is not
#'   supplied).
#' @returns A [bundle] containing all input streamlines.
#' @export
#' @examples
#' pts <- matrix(runif(15), ncol = 3, dimnames = list(NULL, c("X", "Y", "Z")))
#' sl1 <- streamline(points = pts)
#' sl2 <- streamline(points = pts)
#' b1 <- bundle(streamlines = list(sl1))
#' b2 <- bundle(streamlines = list(sl2))
#'
#' # combine two bundles
#' b_all <- bind_bundles(b1, b2)
#' b_all@n_streamlines  # 2
#'
#' # mix a bundle and a loose streamline
#' b_mixed <- bind_bundles(b1, sl2)
#' b_mixed@n_streamlines  # 2
bind_bundles <- function(..., bundle_data = NULL) {
  inputs <- list(...)
  if (length(inputs) == 0L) {
    cli::cli_abort("At least one argument is required.")
  }

  sls <- list()
  first_bd <- list()
  found_bundle <- FALSE

  for (obj in inputs) {
    if (is_streamline(obj)) {
      sls <- c(sls, list(obj))
    } else if (is_bundle(obj)) {
      sls <- c(sls, obj@streamlines)
      if (!found_bundle) {
        first_bd <- obj@bundle_data
        found_bundle <- TRUE
      }
    } else {
      cli::cli_abort(
        "Each argument must be a {.cls fiber::streamline} or {.cls fiber::bundle}."
      )
    }
  }

  bd <- if (!is.null(bundle_data)) bundle_data else first_bd
  bundle(streamlines = sls, bundle_data = bd)
}

# ---- as_bundle_set ----------------------------------------------------------

#' Coerce an object to a bundle_set
#'
#' `as_bundle_set()` converts a supported object into a [bundle_set].
#'
#' Currently supported input classes:
#' - [bundle_set]: returned unchanged.
#' - [bundle]: wrapped in a single-element [bundle_set]. An optional `name`
#'   argument sets the element name (defaults to `"bundle_1"`).
#'
#' @param x An object to coerce.
#' @param ... Additional arguments passed to methods (e.g. `name` for bundles).
#' @returns A [bundle_set] object.
#' @seealso [bundle_set()], [bind_bundle_sets()]
#' @export
#' @examples
#' pts <- matrix(runif(15), ncol = 3, dimnames = list(NULL, c("X", "Y", "Z")))
#' b <- bundle(streamlines = list(streamline(points = pts)))
#' bs <- as_bundle_set(b, name = "sub-01")
#' bs@n_bundles  # 1
as_bundle_set <- S7::new_generic("as_bundle_set", "x")

S7::method(as_bundle_set, bundle_set) <- function(x, ...) x

S7::method(as_bundle_set, bundle) <- function(x, ..., name = "bundle_1") {
  nms <- list(x)
  names(nms) <- name
  bundle_set(bundles = nms)
}

S7::method(as_bundle_set, S7::class_any) <- function(x, ...) {
  cli::cli_abort(
    "Don't know how to coerce an object of class {.cls {class(x)[1L]}} \\
     to a {.cls bundle_set}."
  )
}

# ---- bind_bundle_sets -------------------------------------------------------

#' Combine bundles and/or bundle_sets into a single bundle_set
#'
#' Accepts any mix of named [bundle] objects (passed as `name = bundle`) or
#' [bundle_set] objects. All bundles are collected into a flat named list and
#' wrapped in a new [bundle_set].
#'
#' @param ... Named [bundle] objects or [bundle_set] objects to combine. Each
#'   bare [bundle] argument must be **named** so that its label in the
#'   resulting set is unambiguous.
#' @param set_data A named list of set-level metadata to attach to the
#'   resulting [bundle_set]. Defaults to the `set_data` of the first
#'   [bundle_set] input (if present) or an empty list.
#' @returns A [bundle_set] containing all input bundles.
#' @export
#' @examples
#' pts <- matrix(runif(15), ncol = 3, dimnames = list(NULL, c("X", "Y", "Z")))
#' b1 <- bundle(streamlines = list(streamline(points = pts)))
#' b2 <- bundle(streamlines = list(streamline(points = pts)))
#'
#' # two named bare bundles
#' bs <- bind_bundle_sets("sub-01" = b1, "sub-02" = b2)
#' bs@n_bundles   # 2
#' bs@bundle_names  # c("sub-01", "sub-02")
#'
#' # combine two bundle_sets
#' bs1 <- bundle_set(list("sub-01" = b1))
#' bs2 <- bundle_set(list("sub-02" = b2))
#' bs_all <- bind_bundle_sets(bs1, bs2)
#' bs_all@n_bundles  # 2
bind_bundle_sets <- function(..., set_data = NULL) {
  inputs <- list(...)
  if (length(inputs) == 0L) {
    cli::cli_abort("At least one argument is required.")
  }

  nms <- names(inputs)
  all_bundles <- list()
  first_sd <- list()
  found_set <- FALSE

  for (i in seq_along(inputs)) {
    obj <- inputs[[i]]
    nm <- if (!is.null(nms)) nms[[i]] else ""
    if (is_bundle(obj)) {
      if (is.null(nm) || nm == "") {
        cli::cli_abort(c(
          "Bare {.cls fiber::bundle} arguments must be named.",
          "i" = "Use {.code bind_bundle_sets(\"sub-01\" = b1, \"sub-02\" = b2)}."
        ))
      }
      all_bundles[[nm]] <- obj
    } else if (is_bundle_set(obj)) {
      new_bds <- obj@bundles
      if (length(new_bds) > 0L) {
        dups <- intersect(names(all_bundles), names(new_bds))
        if (length(dups) > 0L) {
          cli::cli_abort(c(
            "Duplicate bundle name{?s}: {.val {dups}}.",
            "i" = "Each bundle in a {.cls bundle_set} must have a unique name."
          ))
        }
        all_bundles <- c(all_bundles, new_bds)
      }
      if (!found_set) {
        first_sd <- obj@set_data
        found_set <- TRUE
      }
    } else {
      cli::cli_abort(
        "Each argument must be a named {.cls fiber::bundle} or a \\
         {.cls fiber::bundle_set}."
      )
    }
  }

  sd <- if (!is.null(set_data)) set_data else first_sd
  bundle_set(bundles = all_bundles, set_data = sd)
}
