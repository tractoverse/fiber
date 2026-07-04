#' @include bundle.R streamline.R
NULL

# ---- reparametrize ----------------------------------------------------------

#' Reparametrize a streamline or bundle onto a uniform arc-length grid
#'
#' @description
#' `reparametrize()` is an S7 generic that resamples the 3-D coordinates (and
#' any numeric `@point_data` attributes) of a tractography object onto a
#' uniform arc-length grid using linear interpolation, with methods available
#' for the following classes:
#'
#' `r doclisting::methods_list("reparametrize")`
#'
#' @param x A [streamline] or [bundle] object.
#' @param n_points Number of equally-spaced arc-length points to use.
#'
#'   - For a single [streamline], defaults to `x@n_points`.
#'   - For a [bundle], defaults to the rounded mean number of points across
#'     all streamlines.
#'
#'   Pass `NULL` to use these defaults explicitly.
#' @returns An object of the same class as `x` reparametrized onto the new
#'   grid.
#' @export
#' @examples
#' # reparametrize a single streamline to 10 points
#' sl <- streamline(points = cbind(X = runif(5), Y = runif(5), Z = runif(5)))
#' sl_reparam <- reparametrize(sl, n_points = 10)
#' # reparametrize a bundle to the mean number of points across its streamlines
#' sl1 <- streamline(points = cbind(X = runif(5), Y = runif(5), Z = runif(5)))
#' sl2 <- streamline(points = cbind(X = runif(10), Y = runif(10), Z = runif(10)))
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
#'   object has `@points` resampled to exactly `n_points` rows via linear
#'   interpolation, and any numeric `@point_data` entries likewise resampled.
#'   Non-numeric `@point_data` entries are dropped with a warning.
#'   `@streamline_data` is preserved unchanged.
#' @seealso [reparametrize()]
#' @name reparametrize-fiber-streamline-method
#' @aliases reparametrize,fiber::streamline-method
#' @usage NULL
#' @examples
#' sl <- streamline(
#'   points = cbind(X = runif(10), Y = runif(10), Z = runif(10)),
#'   point_data = list(FA = runif(10))
#' )
#' sl_reparam <- reparametrize(sl, n_points = 20)
#' sl_reparam@n_points  # 20
S7::method(reparametrize, streamline) <- function(x, n_points = NULL) {
  pts <- x@points
  s <- .arc_length(pts)
  n <- if (is.null(n_points)) x@n_points else as.integer(n_points)

  if (n < 2L) {
    cli::cli_abort("{.arg n_points} must be at least 2.")
  }

  s_new <- seq(s[1L], s[length(s)], length.out = n)

  # Interpolate the coordinate matrix (@points)
  new_pts <- matrix(
    c(
      .approx1(s, pts[, "X"], s_new),
      .approx1(s, pts[, "Y"], s_new),
      .approx1(s, pts[, "Z"], s_new)
    ),
    ncol = 3L,
    dimnames = list(NULL, c("X", "Y", "Z"))
  )

  # Interpolate numeric @point_data entries
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
#' @returns A [bundle] reparametrized onto the new grid. Every streamline in
#'   the returned bundle has exactly `n_points` rows in `@points` (defaulting
#'   to the rounded mean number of points across all streamlines when
#'   `n_points` is `NULL`). `@streamline_data` and `@bundle_data` are
#'   preserved unchanged.
#' @seealso [reparametrize()]
#' @name reparametrize-fiber-bundle-method
#' @aliases reparametrize,fiber::bundle-method
#' @usage NULL
#' @examples
#' sl1 <- streamline(points = cbind(X = runif(5), Y = runif(5), Z = runif(5)))
#' sl2 <- streamline(points = cbind(X = runif(10), Y = runif(10), Z = runif(10)))
#' b <- bundle(streamlines = list(sl1, sl2))
#' b_reparam <- reparametrize(b, n_points = 8)
#' b_reparam[[1]]@n_points  # 8
#' b_reparam[[2]]@n_points  # 8
S7::method(reparametrize, bundle) <- function(x, n_points = NULL) {
  if (length(x@streamlines) == 0L) {
    return(x)
  }

  n <- if (is.null(n_points)) {
    round(mean(vapply(x@streamlines, function(sl) sl@n_points, integer(1L))))
  } else {
    as.integer(n_points)
  }

  new_sls <- lapply(x@streamlines, reparametrize, n_points = n)
  bundle(
    streamlines = new_sls,
    streamline_data = x@streamline_data,
    bundle_data = x@bundle_data
  )
}
