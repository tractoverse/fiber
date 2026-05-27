#' @include streamline.R bundle.R
NULL

# ---- shape descriptors computers ---------------------------------------

#' Euclidean length of a streamline
#'
#' `get_euclidean_length()` is a function that computes the Euclidean
#' (straight-line) distance of a [streamline] object.
#'
#' @param x A [streamline] object.
#' @returns A non-negative numeric scalar.
#' @export
#' @examples
#' pts <- matrix(runif(30), ncol = 3)
#' colnames(pts) <- c("X", "Y", "Z")
#' sl <- streamline(points = pts)
#' get_euclidean_length(sl)
get_euclidean_length <- function(x) {
  if (!is_streamline(x)) {
    cli::cli_abort("{.arg x} must be a {.cls fiber::streamline} object.")
  }
  pts <- x@points
  n <- nrow(pts)
  .dist3(pts[1L, ], pts[n, ])
}

#' Curvilinear length of a streamline
#'
#' `get_curvilinear_length()` is a function that computes the total arc-length of a
#' [streamline] object as the sum of Euclidean segment lengths between
#' consecutive points.
#'
#' @param x A [streamline] object.
#' @returns A non-negative numeric scalar.
#' @export
#' @examples
#' pts <- matrix(runif(30), ncol = 3)
#' colnames(pts) <- c("X", "Y", "Z")
#' sl <- streamline(points = pts)
#' get_curvilinear_length(sl)
get_curvilinear_length <- function(x) {
  if (!is_streamline(x)) {
    cli::cli_abort("{.arg x} must be a {.cls fiber::streamline} object.")
  }
  pts <- x@points
  s <- .arc_length(pts)
  s[length(s)]
}

#' Sinuosity of a streamline
#'
#' `get_sinuosity()` is a function that computes the ratio of curvilinear
#' length to Euclidean length for a [streamline] object, with a value of
#' 1 indicating a perfectly straight streamline and larger values indicating
#' greater curviness.
#'
#' @param x A [streamline] object.
#' @returns A numeric scalar \eqn{\ge 1}.
#' @export
#' @examples
#' pts <- matrix(runif(30), ncol = 3)
#' colnames(pts) <- c("X", "Y", "Z")
#' sl <- streamline(points = pts)
#' get_sinuosity(sl)
get_sinuosity <- function(x) {
  if (!is_streamline(x)) {
    cli::cli_abort("{.arg x} must be a {.cls fiber::streamline} object.")
  }
  get_curvilinear_length(x) / get_euclidean_length(x)
}

#' Curvature of a streamline
#'
#' `get_curvature()` is function that computes the curvature of a
#' [streamline] object. The curvature \eqn{\kappa(s)} at each point
#' along the arc-length abscissa is computed using cubic smoothing
#' splines (3 degrees of freedom per component).
#'
#' @param x A [streamline] object.
#' @returns A non-negative numeric vector of length `x@n_points` giving the
#'   curvature \eqn{\kappa(s)} at each sampled point along the streamline.
#'   Higher values indicate sharper bending at that location.
#' @export
#' @examples
#' pts <- matrix(runif(30), ncol = 3)
#' colnames(pts) <- c("X", "Y", "Z")
#' sl <- streamline(points = pts)
#' get_curvature(sl)
get_curvature <- function(x) {
  if (!is_streamline(x)) {
    cli::cli_abort("{.arg x} must be a {.cls fiber::streamline} object.")
  }
  pts <- x@points
  s <- .arc_length(pts)

  ssx <- stats::smooth.spline(s, pts[, "X"], df = 3L)
  ssy <- stats::smooth.spline(s, pts[, "Y"], df = 3L)
  ssz <- stats::smooth.spline(s, pts[, "Z"], df = 3L)

  dx <- stats::predict(ssx, s, 1L)$y
  dy <- stats::predict(ssy, s, 1L)$y
  dz <- stats::predict(ssz, s, 1L)$y
  d2x <- stats::predict(ssx, s, 2L)$y
  d2y <- stats::predict(ssy, s, 2L)$y
  d2z <- stats::predict(ssz, s, 2L)$y

  num <- (d2z * dy - d2y * dz)^2L +
    (d2x * dz - d2z * dx)^2L +
    (d2y * dx - d2x * dy)^2L
  denom <- (dx^2L + dy^2L + dz^2L)^3L
  sqrt(num / denom)
}

#' Torsion of a streamline
#'
#' `get_torsion()` is function that computes the torsion of a
#' [streamline] object. The torsion \eqn{\tau(s)} at each point
#' along the arc-length abscissa is computed using cubic smoothing
#' splines (4 degrees of freedom per component).
#'
#' @param x A [streamline] object.
#' @returns A numeric vector of length `x@n_points` giving the torsion
#'   \eqn{\tau(s)} at each sampled point along the streamline. Positive values
#'   indicate right-handed twisting; negative values indicate left-handed
#'   twisting; zero indicates a planar curve at that location.
#' @export
#' @examples
#' pts <- matrix(runif(30), ncol = 3)
#' colnames(pts) <- c("X", "Y", "Z")
#' sl <- streamline(points = pts)
#' get_torsion(sl)
get_torsion <- function(x) {
  if (!is_streamline(x)) {
    cli::cli_abort("{.arg x} must be a {.cls fiber::streamline} object.")
  }
  pts <- x@points
  s <- .arc_length(pts)

  ssx <- stats::smooth.spline(s, pts[, "X"], df = 4L)
  ssy <- stats::smooth.spline(s, pts[, "Y"], df = 4L)
  ssz <- stats::smooth.spline(s, pts[, "Z"], df = 4L)

  dx <- stats::predict(ssx, s, 1L)$y
  dy <- stats::predict(ssy, s, 1L)$y
  dz <- stats::predict(ssz, s, 1L)$y
  d2x <- stats::predict(ssx, s, 2L)$y
  d2y <- stats::predict(ssy, s, 2L)$y
  d2z <- stats::predict(ssz, s, 2L)$y
  d3x <- stats::predict(ssx, s, 3L)$y
  d3y <- stats::predict(ssy, s, 3L)$y
  d3z <- stats::predict(ssz, s, 3L)$y

  num <- d3x *
    (dy * d2z - d2y * dz) +
    d3y * (d2x * dz - dx * d2z) +
    d3z * (dx * d2y - d2x * dy)
  denom <- (dy * d2z - d2y * dz)^2L +
    (d2x * dz - dx * d2z)^2L +
    (dx * d2y - d2x * dy)^2L
  num / denom
}

# ---- generic: add_shape_descriptors ----------------------------------------

#' Adds shape descriptors to a streamline or bundle
#'
#' @description
#' `add_shape_descriptors()` is an S7 generic that computes a number of shape
#' descriptors for each [streamline] object and stores them in the
#' `@streamline_data` or `@point_data` slots as appropriate, with methods
#' available for the following classes:
#'
#' `r doclisting::methods_list("add_shape_descriptors")`
#'
#' This function provides a convenient way to compute shape descriptors and
#' attach them to [streamline] or [bundle] objects. See the documentation for
#' each individual shape descriptor function (e.g. `get_euclidean_length()`,
#' `get_curvilinear_length()`, `get_sinuosity()`, `get_curvature()`,
#' `get_torsion()`) for more details on how each descriptor is computed.
#'
#' @param x A [streamline] or [bundle] object.
#' @param descriptors A character vector of shape descriptors to add. Defaults
#' to all available descriptors: `c("euclidean_length", "curvilinear_length",
#' "sinuosity", "curvature", "torsion")`.
#' @returns An object of the same class as `x` with the specified shape descriptors
#' added to the `@streamline_data` or `@point_data` slots of each streamline.
#' @export
#' @examples
#' # add multiple shape descriptors to a single streamline
#' pts <- matrix(runif(30), ncol = 3)
#' colnames(pts) <- c("X", "Y", "Z")
#' sl <- streamline(points = pts)
#' sl <- add_shape_descriptors(
#'   sl,
#'   descriptors = c("euclidean_length", "curvilinear_length", "sinuosity")
#' )
#' # add multiple shape descriptors to a bundle
#' sl1 <- streamline(points = pts)
#' pts2 <- matrix(runif(60), ncol = 3)
#' colnames(pts2) <- c("X", "Y", "Z")
#' sl2 <- streamline(points = pts2)
#' b <- bundle(streamlines = list(sl1, sl2))
#' b <- add_shape_descriptors(
#'   b,
#'   descriptors = c("euclidean_length", "curvilinear_length", "sinuosity")
#' )
add_shape_descriptors <- S7::new_generic(
  "add_shape_descriptors",
  "x",
  function(
    x,
    descriptors = c(
      "euclidean_length",
      "curvilinear_length",
      "sinuosity",
      "curvature",
      "torsion"
    )
  ) {
    S7::S7_dispatch()
  }
)

# --- method: streamline -----------------------------------------------------

#' [add_shape_descriptors()] method for `streamline` objects
#'
#' Adds multiple shape descriptors to a single [streamline] object.
#'
#' @param x A [streamline] object.
#' @inheritParams add_shape_descriptors
#' @returns A [streamline] with the specified shape descriptors added to the
#' `@streamline_data` or `@point_data` slots as appropriate.
#' @seealso [add_shape_descriptors()]
#' @name add_shape_descriptors-fiber-streamline-method
#' @aliases add_shape_descriptors,fiber::streamline-method
#' @usage NULL
S7::method(add_shape_descriptors, streamline) <- function(
  x,
  descriptors = c(
    "euclidean_length",
    "curvilinear_length",
    "sinuosity",
    "curvature",
    "torsion"
  )
) {
  for (desc in descriptors) {
    if (desc == "euclidean_length") {
      x@streamline_data$euclidean_length <- get_euclidean_length(x)
    } else if (desc == "curvilinear_length") {
      x@streamline_data$curvilinear_length <- get_curvilinear_length(x)
    } else if (desc == "sinuosity") {
      x@streamline_data$sinuosity <- get_sinuosity(x)
    } else if (desc == "curvature") {
      x@point_data$curvature <- get_curvature(x)
    } else if (desc == "torsion") {
      x@point_data$torsion <- get_torsion(x)
    } else {
      warning(
        cli::format_inline(
          "Unknown shape descriptor: {.val {desc}}. Currently available ",
          "descriptors are: {.val euclidean_length}, {.val curvilinear_length}, ",
          "{.val sinuosity}, {.val curvature}, and {.val torsion}."
        ),
        call. = FALSE
      )
    }
  }
  x
}

# --- method: bundle ---------------------------------------------------------

#' [add_shape_descriptors()] method for `bundle` objects
#'
#' Adds multiple shape descriptors to every [streamline] inside a [bundle].
#'
#' @param x A [bundle] object.
#' @inheritParams add_shape_descriptors
#' @returns A [bundle] with the specified shape descriptors added to the
#' `@streamline_data` or `@point_data` slots of each streamline as appropriate.
#' @seealso [add_shape_descriptors()]
#' @name add_shape_descriptors-fiber-bundle-method
#' @aliases add_shape_descriptors,fiber::bundle-method
#' @usage NULL
S7::method(add_shape_descriptors, bundle) <- function(
  x,
  descriptors = c(
    "euclidean_length",
    "curvilinear_length",
    "sinuosity",
    "curvature",
    "torsion"
  )
) {
  x@streamlines <- lapply(
    x@streamlines,
    add_shape_descriptors,
    descriptors = descriptors
  )
  x
}

# ---- generic: compute_hausdorff_distance ---------------------------------

#' Computes the Hausdorff distance between streamlines
#'
#' @description
#' `compute_hausdorff_distance()` is an S7 generic that computes the symmetric
#' Hausdorff distance between [streamline] objects based on their 3-D
#' coordinate matrices, with methods available for the following classes:
#'
#' `r doclisting::methods_list("compute_hausdorff_distance")`
#'
#' The four dispatch cases are:
#'
#' - **`streamline` + `streamline`**: returns a single numeric scalar — the
#'   symmetric Hausdorff distance between the two streamlines.
#' - **`bundle` + missing**: returns a symmetric numeric distance matrix of
#'   dimension \eqn{n \times n}, where \eqn{n} is the number of streamlines in
#'   the bundle, giving all pairwise Hausdorff distances.
#' - **`bundle` + `streamline`**: returns a numeric vector of length \eqn{n}
#'   giving the Hausdorff distance from `y` to each streamline in `x`.
#' - **`bundle` + `bundle`**: returns a symmetric numeric distance matrix of
#'   dimension \eqn{(n_x + n_y) \times (n_x + n_y)}, treating the
#'   concatenation of all streamlines from `x` and `y` as one collection.
#'
#' @param x A [streamline] or [bundle] object.
#' @param y A [streamline] or [bundle] object, or `NULL` (default). When `NULL`
#'   and `x` is a [bundle], the pairwise distance matrix within `x` is
#'   returned.
#' @returns
#'   - A non-negative numeric scalar when both `x` and `y` are [streamline]s.
#'   - A [`dist`][stats::dist] object of size \eqn{n} when `x` is a [bundle]
#'     and `y` is `NULL` or a [bundle] (use [as.matrix()] to expand to a full
#'     \eqn{n \times n} matrix).
#'   - A numeric vector of length \eqn{n} when `x` is a [bundle] and `y` is
#'     a [streamline].
#' @export
#' @examples
#' pts1 <- matrix(runif(30), ncol = 3)
#' colnames(pts1) <- c("X", "Y", "Z")
#' sl1 <- streamline(points = pts1)
#' pts2 <- matrix(runif(30), ncol = 3)
#' colnames(pts2) <- c("X", "Y", "Z")
#' sl2 <- streamline(points = pts2)
#'
#' # streamline x streamline -> scalar
#' compute_hausdorff_distance(sl1, sl2)
#'
#' # bundle x missing -> pairwise dist object
#' b <- bundle(streamlines = list(sl1, sl2))
#' compute_hausdorff_distance(b)
#' as.matrix(compute_hausdorff_distance(b))
#'
#' # bundle x streamline -> vector
#' compute_hausdorff_distance(b, sl1)
#'
#' # bundle x bundle -> combined pairwise matrix
#' b2 <- bundle(streamlines = list(sl2))
#' compute_hausdorff_distance(b, b2)
compute_hausdorff_distance <- S7::new_generic(
  "compute_hausdorff_distance",
  "x",
  function(x, y = NULL) {
    S7::S7_dispatch()
  }
)

# --- method: streamline x streamline ----------------------------------------

#' [compute_hausdorff_distance()] method for two `streamline` objects
#'
#' @param x A [streamline] object.
#' @param y A [streamline] object.
#' @returns A non-negative numeric scalar equal to
#'   \eqn{\max(d_H(x \to y),\, d_H(y \to x))}, where
#'   \eqn{d_H(A \to B) = \max_{a \in A} \min_{b \in B} \|a - b\|_2} is the
#'   directed Hausdorff distance. The core computation is performed in C++
#'   via `hausdorff_distance_cpp()`.
#' @seealso [compute_hausdorff_distance()]
#' @name compute_hausdorff_distance-fiber-streamline-method
#' @aliases compute_hausdorff_distance,fiber::streamline-method
#' @usage NULL
#' @examples
#' pts1 <- matrix(runif(30), ncol = 3)
#' colnames(pts1) <- c("X", "Y", "Z")
#' pts2 <- matrix(runif(30), ncol = 3)
#' colnames(pts2) <- c("X", "Y", "Z")
#' sl1 <- streamline(points = pts1)
#' sl2 <- streamline(points = pts2)
#' compute_hausdorff_distance(sl1, sl2)
S7::method(compute_hausdorff_distance, streamline) <- function(x, y = NULL) {
  if (!is_streamline(y)) {
    cli::cli_abort(c(
      "{.arg y} must be a {.cls fiber::streamline} object when {.arg x} is a
      {.cls fiber::streamline}.",
      "i" = "To compute pairwise distances within a bundle, pass a
      {.cls fiber::bundle} as {.arg x} and omit {.arg y}."
    ))
  }
  xyz_cols <- c("X", "Y", "Z")
  mat_x <- x@points[, xyz_cols, drop = FALSE]
  mat_y <- y@points[, xyz_cols, drop = FALSE]
  hausdorff_distance_cpp(mat_x, mat_y)
}

# --- method: bundle ---------------------------------------------------------

#' [compute_hausdorff_distance()] method for `bundle` objects
#'
#' Dispatches to one of three behaviours depending on `y`:
#'
#' - `y = NULL`: pairwise distances within `x` as a [`dist`][stats::dist]
#'   object of size \eqn{n}, computed in C++ via a single linear loop.
#' - `y` is a [streamline]: numeric vector of distances from `y` to each
#'   streamline in `x`.
#' - `y` is a [bundle]: [`dist`][stats::dist] object for the concatenation
#'   of all streamlines from `x` and `y`.
#'
#' @param x A [bundle] object.
#' @param y `NULL`, a [streamline], or a [bundle].
#' @returns
#'   - A [`dist`][stats::dist] object of size `x@n_streamlines` when `y` is
#'     `NULL` or a [bundle]. The lower triangle stores all pairwise symmetric
#'     Hausdorff distances (computed in C++). Use [as.matrix()] to obtain the
#'     full \eqn{n \times n} matrix.
#'   - A numeric vector of length `x@n_streamlines` when `y` is a [streamline].
#' @seealso [compute_hausdorff_distance()]
#' @name compute_hausdorff_distance-fiber-bundle-method
#' @aliases compute_hausdorff_distance,fiber::bundle-method
#' @usage NULL
#' @examples
#' pts1 <- matrix(runif(30), ncol = 3)
#' colnames(pts1) <- c("X", "Y", "Z")
#' pts2 <- matrix(runif(30), ncol = 3)
#' colnames(pts2) <- c("X", "Y", "Z")
#' sl1 <- streamline(points = pts1)
#' sl2 <- streamline(points = pts2)
#' b <- bundle(streamlines = list(sl1, sl2))
#'
#' # pairwise dist object (size 2)
#' compute_hausdorff_distance(b)
#' as.matrix(compute_hausdorff_distance(b))
#'
#' # distances from sl1 to each streamline in b
#' compute_hausdorff_distance(b, sl1)
S7::method(compute_hausdorff_distance, bundle) <- function(x, y = NULL) {
  xyz_cols <- c("X", "Y", "Z")
  if (is.null(y)) {
    # --- bundle x missing: dist object via C++ single-loop ------------------
    sls <- x@streamlines
    n <- length(sls)
    mats <- lapply(sls, function(sl) sl@points[, xyz_cols, drop = FALSE])
    dv <- pairwise_hausdorff_cpp(mats)
    structure(
      dv,
      class = "dist",
      Size = n,
      Diag = FALSE,
      Upper = FALSE,
      method = "hausdorff"
    )
  } else if (is_streamline(y)) {
    # --- bundle x streamline: vector of distances ---------------------------
    mat_y <- y@points[, xyz_cols, drop = FALSE]
    vapply(
      x@streamlines,
      function(sl) {
        hausdorff_distance_cpp(
          sl@points[, xyz_cols, drop = FALSE],
          mat_y
        )
      },
      numeric(1L)
    )
  } else if (is_bundle(y)) {
    # --- bundle x bundle: combined dist object ------------------------------
    combined <- bind_bundles(x, y)
    compute_hausdorff_distance(combined)
  } else {
    cli::cli_abort(c(
      "{.arg y} must be {.code NULL}, a {.cls fiber::streamline}, or a
      {.cls fiber::bundle} when {.arg x} is a {.cls fiber::bundle}.",
      "x" = "Got {.obj_type_friendly {y}} instead."
    ))
  }
}

# --- catch-all method: unsupported x types ----------------------------------

#' [compute_hausdorff_distance()] catch-all method
#'
#' @usage NULL
#' @returns Does not return a value; always throws an error for unsupported
#'   input types.
S7::method(compute_hausdorff_distance, S7::class_any) <- function(x, y = NULL) {
  cli::cli_abort(c(
    "{.arg x} must be a {.cls fiber::streamline} or {.cls fiber::bundle}
    object.",
    "x" = "Got {.obj_type_friendly {x}} instead.",
    "i" = "Supported combinations are: {.cls streamline} + {.cls streamline},
    {.cls bundle} (no {.arg y}), {.cls bundle} + {.cls streamline}, and
    {.cls bundle} + {.cls bundle}."
  ))
}
