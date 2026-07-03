#' @include streamline.R bundle.R
NULL

# ---- as_streamline ----------------------------------------------------------

#' Coerce an object to a streamline
#'
#' `as_streamline()` converts a supported object into a [streamline].
#'
#' Currently supported input classes:
#' - [streamline]: returned unchanged.
#' - `dwiFiber` (from \pkg{dti}): the object must contain **exactly one**
#'   fiber. For multi-fiber objects use [as_bundle()] instead.
#'
#' @param x An object to coerce.
#' @param ... Additional arguments (currently unused).
#' @returns A [streamline] object.
#' @seealso [as_bundle()], [as_dwifiber()]
#' @export
#' @examples
#' sl <- streamline(points = cbind(X = runif(5), Y = runif(5), Z = runif(5)))
#' identical(as_streamline(sl), sl)  # TRUE — identity coercion
as_streamline <- S7::new_generic("as_streamline", "x")

# --- method: streamline (identity) ------------------------------------------

#' [as_streamline()] method for `streamline` objects
#'
#' @param x A [streamline] object.
#' @param ... Additional arguments (currently unused).
#' @returns `x` unchanged.
#' @seealso [as_streamline()]
#' @name as_streamline-fiber-streamline-method
#' @aliases as_streamline,fiber::streamline-method
#' @usage NULL
S7::method(as_streamline, streamline) <- function(x, ...) x

# --- method: bundle ----------------------------------------------------------

#' [as_streamline()] method for `bundle` objects
#'
#' @param x A [bundle] object containing exactly one streamline.
#' @param ... Additional arguments (currently unused).
#' @returns The sole [streamline] inside `x`.
#' @seealso [as_streamline()]
#' @name as_streamline-fiber-bundle-method
#' @aliases as_streamline,fiber::bundle-method
#' @usage NULL
S7::method(as_streamline, bundle) <- function(x, ...) {
  if (x@n_streamlines != 1L) {
    cli::cli_abort(c(
      "Cannot coerce a {.cls bundle} with {x@n_streamlines} streamlines \\
       to a single {.cls streamline}.",
      "i" = "Use {.code x[[i]]} to extract a specific streamline."
    ))
  }
  x[[1L]]
}

# --- method: class_any (handles dwiFiber + unknown classes) -----------------

S7::method(as_streamline, S7::class_any) <- function(x, ...) {
  if (inherits(x, "dwiFiber")) {
    b <- .dwifiber_to_bundle(x)
    if (b@n_streamlines != 1L) {
      cli::cli_abort(c(
        "Cannot coerce a {.cls dwiFiber} with {b@n_streamlines} fibers \\
         to a single {.cls streamline}.",
        "i" = "Use {.fn as_bundle} instead."
      ))
    }
    return(b[[1L]])
  }
  cli::cli_abort(
    "Don't know how to coerce an object of class {.cls {class(x)[1L]}} \\
     to a {.cls streamline}."
  )
}

# ---- as_bundle --------------------------------------------------------------

#' Coerce an object to a bundle
#'
#' `as_bundle()` converts a supported object into a [bundle].
#'
#' Currently supported input classes:
#' - [streamline]: wrapped in a single-element [bundle] (lossless).
#' - [bundle]: returned unchanged.
#' - `dwiFiber` (from \pkg{dti}): each fiber becomes a [streamline]. The
#'   per-point direction vectors (columns 4–6 of `@fibers`) are stored as
#'   `@point_data$direction_x`, `@point_data$direction_y`, and
#'   `@point_data$direction_z`. Tracking metadata (`method`, `minfa`,
#'   `maxangle`) are stored as scalars in `@bundle_data`. Vector metadata
#'   (`ddim`, `ddim0`, `voxelext`, `orientation`) are stored as individual
#'   scalar entries (e.g. `voxelext_1`, `voxelext_2`, `voxelext_3`).
#'
#' @param x An object to coerce.
#' @param ... Additional arguments (currently unused).
#' @returns A [bundle] object.
#' @seealso [as_streamline()], [as_dwifiber()]
#' @export
#' @examples
#' sl <- streamline(points = cbind(X = runif(5), Y = runif(5), Z = runif(5)))
#' b  <- as_bundle(sl)
#' b@n_streamlines  # 1
as_bundle <- S7::new_generic("as_bundle", "x")

# --- method: streamline (wrap) -----------------------------------------------

#' [as_bundle()] method for `streamline` objects
#'
#' @param x A [streamline] object.
#' @param ... Additional arguments (currently unused).
#' @returns A [bundle] containing `x` as its sole streamline.
#' @seealso [as_bundle()]
#' @name as_bundle-fiber-streamline-method
#' @aliases as_bundle,fiber::streamline-method
#' @usage NULL
S7::method(as_bundle, streamline) <- function(x, ...) {
  bundle(streamlines = list(x))
}

# --- method: bundle (identity) -----------------------------------------------

#' [as_bundle()] method for `bundle` objects
#'
#' @param x A [bundle] object.
#' @param ... Additional arguments (currently unused).
#' @returns `x` unchanged.
#' @seealso [as_bundle()]
#' @name as_bundle-fiber-bundle-method
#' @aliases as_bundle,fiber::bundle-method
#' @usage NULL
S7::method(as_bundle, bundle) <- function(x, ...) x

# --- method: class_any (handles dwiFiber + unknown classes) ------------------

S7::method(as_bundle, S7::class_any) <- function(x, ...) {
  if (inherits(x, "dwiFiber")) {
    return(.dwifiber_to_bundle(x))
  }
  cli::cli_abort(
    "Don't know how to coerce an object of class {.cls {class(x)[1L]}} \\
     to a {.cls bundle}."
  )
}

# ---- as_dwifiber ------------------------------------------------------------

#' Coerce a streamline or bundle to a `dwiFiber` object
#'
#' `as_dwifiber()` converts a [streamline] or [bundle] to the S4 class
#' `dwiFiber` from the \pkg{dti} package.
#'
#' Per-point direction vectors are taken from `@point_data$direction_x`,
#' `@point_data$direction_y`, and `@point_data$direction_z` when
#' present; otherwise they are estimated via finite differences of the
#' coordinates (forward difference at the first point, backward difference at
#' the last, central differences in between), then unit-normalised.
#'
#' Bundle-level metadata stored in `@bundle_data` under the keys `method`,
#' `minfa`, `maxangle`, `level`, and `source` are transferred to the
#' corresponding `dwiFiber` slots when present. Vector-valued fields such as
#' `ddim`, `ddim0`, `voxelext`, and `orientation` must be stored as individual
#' scalars (e.g. `ddim_1`, `ddim_2`, `ddim_3`) and are reconstructed into
#' vectors for the `dwiFiber` object.
#'
#' @param x A [streamline] or [bundle] object.
#' @param ... Additional arguments (currently unused).
#' @returns An S4 object of class `dwiFiber` (from \pkg{dti}).
#' @seealso [as_streamline()], [as_bundle()]
#' @export
#' @examples
#' if (requireNamespace("dti", quietly = TRUE)) {
#'   sl <- streamline(points = cbind(X = runif(5), Y = runif(5), Z = runif(5)))
#'   b  <- bundle(streamlines = list(sl))
#'   dfi <- as_dwifiber(b)
#'   class(dfi)  # "dwiFiber"
#' }
as_dwifiber <- S7::new_generic("as_dwifiber", "x")

# --- method: streamline ------------------------------------------------------

#' [as_dwifiber()] method for `streamline` objects
#'
#' @param x A [streamline] object.
#' @param ... Additional arguments (currently unused).
#' @returns An S4 `dwiFiber` object.
#' @seealso [as_dwifiber()]
#' @name as_dwifiber-fiber-streamline-method
#' @aliases as_dwifiber,fiber::streamline-method
#' @usage NULL
S7::method(as_dwifiber, streamline) <- function(x, ...) {
  as_dwifiber(bundle(streamlines = list(x)), ...)
}

# --- method: bundle ----------------------------------------------------------

#' [as_dwifiber()] method for `bundle` objects
#'
#' @param x A [bundle] object.
#' @param ... Additional arguments (currently unused).
#' @returns An S4 `dwiFiber` object.
#' @seealso [as_dwifiber()]
#' @name as_dwifiber-fiber-bundle-method
#' @aliases as_dwifiber,fiber::bundle-method
#' @usage NULL
S7::method(as_dwifiber, bundle) <- function(x, ...) {
  if (!requireNamespace("dti", quietly = TRUE)) {
    cli::cli_abort(c(
      "Package {.pkg dti} is required to create a {.cls dwiFiber} object.",
      "i" = "Install it with {.code install.packages(\"dti\")}."
    ))
  }
  .bundle_to_dwifiber(x)
}

# ---- as_bundle_set ----------------------------------------------------------

#' Coerce an object to a bundle_set
#'
#' `as_bundle_set()` converts a supported object into a [bundle_set].
#'
#' Currently supported input classes:
#' - [bundle_set]: returned unchanged.
#' - [bundle]: wrapped in a single-element [bundle_set]. An optional `name`
#'   argument sets the element name (defaults to `NULL`, producing an unnamed
#'   single-element set).
#'
#' @param x An object to coerce.
#' @param ... Additional arguments passed to methods (e.g. `name` for bundles).
#' @returns A [bundle_set] object.
#' @seealso [bundle_set()], [bind_bundle_sets()]
#' @export
#' @examples
#' sl <- streamline(points = cbind(X = runif(5), Y = runif(5), Z = runif(5)))
#' b <- bundle(streamlines = list(sl))
#' bs <- as_bundle_set(b, name = "sub-01")
#' bs@n_bundles  # 1
as_bundle_set <- S7::new_generic("as_bundle_set", "x")

S7::method(as_bundle_set, bundle_set) <- function(x, ...) x

S7::method(as_bundle_set, bundle) <- function(x, ..., name = NULL) {
  bs <- list(x)
  if (!is.null(name)) {
    names(bs) <- name
  }
  bundle_set(bundles = bs)
}

S7::method(as_bundle_set, S7::class_any) <- function(x, ...) {
  cli::cli_abort(
    "Don't know how to coerce an object of class {.cls {class(x)[1L]}} \\
     to a {.cls bundle_set}."
  )
}

# ---- internal helpers -------------------------------------------------------

# Convert a dwiFiber S4 object to a fiber::bundle.
# Coordinates go into @points as a Px3 matrix (colnames X, Y, Z).
# Direction vectors go into @point_data.
# Vector-valued dwiFiber fields (ddim, ddim0, voxelext, orientation) are
# expanded into individual scalar entries in @bundle_data.
.dwifiber_to_bundle <- function(x) {
  fibers_mat <- x@fibers
  startind <- x@startind
  n_fibers <- length(startind)
  n_rows <- nrow(fibers_mat)
  endind <- c(startind[-1L] - 1L, n_rows)

  streamlines <- vector("list", n_fibers)
  for (i in seq_len(n_fibers)) {
    rows <- seq.int(startind[i], endind[i])
    pts <- fibers_mat[rows, 1:3, drop = FALSE]
    dirs <- fibers_mat[rows, 4:6, drop = FALSE]
    coord_mat <- matrix(
      c(pts[, 1], pts[, 2], pts[, 3]),
      ncol = 3L,
      dimnames = list(NULL, c("X", "Y", "Z"))
    )
    streamlines[[i]] <- streamline(
      points = coord_mat,
      point_data = list(
        direction_x = dirs[, 1],
        direction_y = dirs[, 2],
        direction_z = dirs[, 3]
      )
    )
  }

  # Split vector-valued metadata into individual scalar entries
  ddim <- as.integer(x@ddim)
  ddim0 <- as.integer(x@ddim0)
  vext <- as.numeric(x@voxelext)
  orient <- as.integer(x@orientation)

  bundle(
    streamlines = streamlines,
    bundle_data = list(
      method = x@method,
      minfa = x@minfa,
      maxangle = x@maxangle,
      level = x@level,
      source = x@source,
      ddim_1 = ddim[1L],
      ddim_2 = ddim[2L],
      ddim_3 = ddim[3L],
      ddim0_1 = ddim0[1L],
      ddim0_2 = ddim0[2L],
      ddim0_3 = ddim0[3L],
      voxelext_1 = vext[1L],
      voxelext_2 = vext[2L],
      voxelext_3 = vext[3L],
      orientation_1 = orient[1L],
      orientation_2 = orient[2L],
      orientation_3 = orient[3L]
    )
  )
}

# Estimate unit-normalised tangent directions from a coordinate matrix using
# forward/central/backward finite differences.
.compute_directions <- function(pts) {
  n <- nrow(pts)
  dirs <- matrix(0, nrow = n, ncol = 3L)
  if (n == 1L) {
    return(dirs)
  }
  dirs[1L, ] <- pts[2L, ] - pts[1L, ] # forward
  dirs[n, ] <- pts[n, ] - pts[n - 1L, ] # backward
  if (n > 2L) {
    dirs[2L:(n - 1L), ] <- pts[3L:n, ] - pts[1L:(n - 2L), ] # central
  }
  norms <- sqrt(rowSums(dirs^2L))
  norms[norms == 0] <- 1
  dirs / norms
}

# Convert a fiber::bundle to a dwiFiber S4 object.
# Coordinates are extracted from @points (Px3 matrix).
# Scalar bundle_data entries for ddim, voxelext etc. are reconstructed
# into the appropriate vectors.
.bundle_to_dwifiber <- function(x) {
  n_fibers <- x@n_streamlines
  fibers_list <- vector("list", n_fibers)
  startind <- integer(n_fibers)
  row_cursor <- 1L
  bd <- x@bundle_data

  for (i in seq_len(n_fibers)) {
    sl <- x@streamlines[[i]]
    pts <- .get_coords(sl)
    n_pts <- nrow(pts)
    dirs <- if (
      all(
        c("direction_x", "direction_y", "direction_z") %in% names(sl@point_data)
      )
    ) {
      cbind(
        sl@point_data[["direction_x"]],
        sl@point_data[["direction_y"]],
        sl@point_data[["direction_z"]]
      )
    } else {
      .compute_directions(pts)
    }
    fibers_list[[i]] <- cbind(pts, dirs)
    startind[i] <- row_cursor
    row_cursor <- row_cursor + n_pts
  }

  fibers_mat <- do.call(rbind, fibers_list)
  colnames(fibers_mat) <- c("x", "y", "z", "dx", "dy", "dz")

  # Reconstruct vector-valued fields from individual scalar bundle_data entries
  ddim <- as.integer(c(
    bd[["ddim_1"]] %||% 0L,
    bd[["ddim_2"]] %||% 0L,
    bd[["ddim_3"]] %||% 0L
  ))
  ddim0 <- as.integer(c(
    bd[["ddim0_1"]] %||% 0L,
    bd[["ddim0_2"]] %||% 0L,
    bd[["ddim0_3"]] %||% 0L
  ))
  voxelext <- as.numeric(c(
    bd[["voxelext_1"]] %||% 1,
    bd[["voxelext_2"]] %||% 1,
    bd[["voxelext_3"]] %||% 1
  ))
  orientation <- as.integer(c(
    bd[["orientation_1"]] %||% 0L,
    bd[["orientation_2"]] %||% 2L,
    bd[["orientation_3"]] %||% 5L
  ))

  methods::new(
    "dwiFiber",
    fibers = fibers_mat,
    startind = as.integer(startind),
    roimask = as.raw(0),
    method = as.character(bd[["method"]] %||% "unknown"),
    minfa = as.numeric(bd[["minfa"]] %||% 0),
    maxangle = as.numeric(bd[["maxangle"]] %||% 0),
    call = as.list(call("as_dwifiber")),
    gradient = bd[["gradient"]] %||% matrix(0, nrow = 3L, ncol = 0L),
    bvalue = bd[["bvalue"]] %||% numeric(0L),
    btb = bd[["btb"]] %||% matrix(0, nrow = 6L, ncol = 0L),
    mask = bd[["mask"]] %||% array(FALSE, dim = c(0L, 0L, 0L)),
    ngrad = bd[["ngrad"]] %||% 0L,
    s0ind = bd[["s0ind"]] %||% integer(0L),
    replind = bd[["replind"]] %||% integer(0L),
    ddim = ddim,
    ddim0 = ddim0,
    xind = as.integer(bd[["xind"]] %||% integer(0L)),
    yind = as.integer(bd[["yind"]] %||% integer(0L)),
    zind = as.integer(bd[["zind"]] %||% integer(0L)),
    voxelext = voxelext,
    level = as.numeric(bd[["level"]] %||% 0),
    orientation = orientation,
    rotation = bd[["rotation"]] %||% diag(3),
    source = as.character(bd[["source"]] %||% "")
  )
}
