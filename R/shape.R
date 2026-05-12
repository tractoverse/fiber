#' @include streamline.R
NULL

# ---- shape descriptors for streamline ---------------------------------------

#' Euclidean length of a streamline
#'
#' The Euclidean (straight-line) distance between the two endpoints.
#'
#' @param x A [streamline] object.
#' @return A non-negative numeric scalar.
#' @export
get_euclidean_length <- S7::new_generic("get_euclidean_length", "x", function(x) {
  S7::S7_dispatch()
})

S7::method(get_euclidean_length, streamline) <- function(x) {
  pts <- x@points
  n <- nrow(pts)
  .dist3(pts[1L, ], pts[n, ])
}

#' Curvilinear length of a streamline
#'
#' The total arc-length of the streamline computed as the sum of
#' Euclidean segment lengths between consecutive points.
#'
#' @param x A [streamline] object.
#' @return A non-negative numeric scalar.
#' @export
get_curvilinear_length <- S7::new_generic("get_curvilinear_length", "x", function(x) {
  S7::S7_dispatch()
})

S7::method(get_curvilinear_length, streamline) <- function(x) {
  s <- .arc_length(x@points)
  s[length(s)]
}

#' Sinuosity of a streamline
#'
#' The ratio of curvilinear length to Euclidean length.  A value of 1
#' indicates a perfectly straight streamline; larger values indicate
#' greater curviness.
#'
#' @param x A [streamline] object.
#' @return A numeric scalar \eqn{\ge 1}.
#' @export
get_sinuosity <- S7::new_generic("get_sinuosity", "x", function(x) {
  S7::S7_dispatch()
})

S7::method(get_sinuosity, streamline) <- function(x) {
  get_curvilinear_length(x) / get_euclidean_length(x)
}

#' Curvature of a streamline
#'
#' Computes the curvature \eqn{\kappa(s)} at each point along the arc-length
#' abscissa using cubic smoothing splines (3 degrees of freedom per component).
#'
#' @param x A [streamline] object.
#' @param scalar One of `"mean"`, `"sd"`, `"max"`, or `NULL` (default).
#'   When `NULL` the full profile is returned as a data frame with columns
#'   `s` and `curvature`.
#' @return Either a `data.frame` (when `scalar = NULL`) or a single numeric
#'   value.
#' @export
get_curvature <- S7::new_generic("get_curvature", "x", function(x, scalar = NULL) {
  S7::S7_dispatch()
})

S7::method(get_curvature, streamline) <- function(x, scalar = NULL) {
  pts <- x@points
  s <- .arc_length(pts)

  ssx <- stats::smooth.spline(s, pts[, "X"], df = 3L)
  ssy <- stats::smooth.spline(s, pts[, "Y"], df = 3L)
  ssz <- stats::smooth.spline(s, pts[, "Z"], df = 3L)

  dx  <- stats::predict(ssx, s, 1L)$y
  dy  <- stats::predict(ssy, s, 1L)$y
  dz  <- stats::predict(ssz, s, 1L)$y
  d2x <- stats::predict(ssx, s, 2L)$y
  d2y <- stats::predict(ssy, s, 2L)$y
  d2z <- stats::predict(ssz, s, 2L)$y

  num   <- (d2z * dy - d2y * dz)^2L +
           (d2x * dz - d2z * dx)^2L +
           (d2y * dx - d2x * dy)^2L
  denom <- (dx^2L + dy^2L + dz^2L)^3L
  k <- sqrt(num / denom)

  if (is.null(scalar)) {
    return(data.frame(s = s, curvature = k))
  }
  scalar <- match.arg(scalar, c("mean", "sd", "max"))
  switch(scalar, mean = mean(k), sd = stats::sd(k), max = max(k))
}

#' Torsion of a streamline
#'
#' Computes the torsion \eqn{\tau(s)} at each point along the arc-length
#' abscissa using cubic smoothing splines (4 degrees of freedom per component).
#'
#' @param x A [streamline] object.
#' @param scalar One of `"mean"`, `"sd"`, `"max"`, or `NULL` (default).
#'   When `NULL` the full profile is returned as a data frame with columns
#'   `s` and `torsion`.
#' @return Either a `data.frame` (when `scalar = NULL`) or a single numeric
#'   value.
#' @export
get_torsion <- S7::new_generic("get_torsion", "x", function(x, scalar = NULL) {
  S7::S7_dispatch()
})

S7::method(get_torsion, streamline) <- function(x, scalar = NULL) {
  pts <- x@points
  s <- .arc_length(pts)

  ssx <- stats::smooth.spline(s, pts[, "X"], df = 4L)
  ssy <- stats::smooth.spline(s, pts[, "Y"], df = 4L)
  ssz <- stats::smooth.spline(s, pts[, "Z"], df = 4L)

  dx  <- stats::predict(ssx, s, 1L)$y
  dy  <- stats::predict(ssy, s, 1L)$y
  dz  <- stats::predict(ssz, s, 1L)$y
  d2x <- stats::predict(ssx, s, 2L)$y
  d2y <- stats::predict(ssy, s, 2L)$y
  d2z <- stats::predict(ssz, s, 2L)$y
  d3x <- stats::predict(ssx, s, 3L)$y
  d3y <- stats::predict(ssy, s, 3L)$y
  d3z <- stats::predict(ssz, s, 3L)$y

  num   <- d3x * (dy * d2z - d2y * dz) +
           d3y * (d2x * dz - dx * d2z) +
           d3z * (dx * d2y - d2x * dy)
  denom <- (dy * d2z - d2y * dz)^2L +
           (d2x * dz - dx * d2z)^2L +
           (dx * d2y - d2x * dy)^2L
  tau <- num / denom

  if (is.null(scalar)) {
    return(data.frame(s = s, torsion = tau))
  }
  scalar <- match.arg(scalar, c("mean", "sd", "max"))
  switch(scalar, mean = mean(tau), sd = stats::sd(tau), max = max(tau))
}

# ---- Hausdorff distance between streamlines ---------------------------------

#' Hausdorff distance between two streamlines
#'
#' Computes the symmetric Hausdorff distance between two [streamline] objects
#' based on their 3-D coordinate matrices.
#'
#' @param x A [streamline] object.
#' @param y A [streamline] object.
#' @return A non-negative numeric scalar.
#' @export
get_hausdorff_distance <- S7::new_generic("get_hausdorff_distance", "x", function(x, y) {
  S7::S7_dispatch()
})

S7::method(get_hausdorff_distance, streamline) <- function(x, y) {
  if (!is_streamline(y)) {
    cli::cli_abort("{.arg y} must be a {.cls fiber::streamline} object.")
  }
  xyz_cols <- c("X", "Y", "Z")
  mat_x <- x@points[, xyz_cols, drop = FALSE]
  mat_y <- y@points[, xyz_cols, drop = FALSE]
  max(
    .directed_hausdorff(mat_x, mat_y),
    .directed_hausdorff(mat_y, mat_x)
  )
}
