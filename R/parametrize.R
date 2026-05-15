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
#' #' # reparametrize a single streamline to 10 points
#' pts <- matrix(runif(30), ncol = 3)
#' colnames(pts) <- c("X", "Y", "Z")
#' sl <- new_streamline(points = pts)
#' sl_reparam <- reparametrize(sl, n_points = 10)
#' # reparametrize a bundle to the mean number of points across its streamlines
#' sl1 <- new_streamline(points = pts)
#' pts2 <- matrix(runif(60), ncol = 3)
#' colnames(pts2) <- c("X", "Y", "Z")
#' sl2 <- new_streamline(points = pts2)
#' bundle <- new_bundle(streamlines = list(sl1, sl2))
#' bundle_reparam <- reparametrize(bundle)
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
#' @returns A [streamline] reparametrized onto the new grid.
#' @seealso [reparametrize()]
#' @name reparametrize-fiber-streamline-method
#' @aliases reparametrize,fiber::streamline-method
#' @usage NULL
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

  new_pd <- lapply(x@point_data, function(v) .approx1(s, v, s_new))

  new_streamline(
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
#' @returns A [bundle] reparametrized onto the new grid.
#' @seealso [reparametrize()]
#' @name reparametrize-fiber-bundle-method
#' @aliases reparametrize,fiber::bundle-method
#' @usage NULL
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
  new_bundle(streamlines = new_sls, bundle_data = x@bundle_data)
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
  new_bundle(streamlines = sls, bundle_data = bd)
}
