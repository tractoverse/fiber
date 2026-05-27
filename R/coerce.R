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
#' pts <- matrix(runif(15), ncol = 3, dimnames = list(NULL, c("X", "Y", "Z")))
#' sl <- streamline(points = pts)
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
#'   `maxangle`) are stored in `@bundle_data`.
#'
#' @param x An object to coerce.
#' @param ... Additional arguments (currently unused).
#' @returns A [bundle] object.
#' @seealso [as_streamline()], [as_dwifiber()]
#' @export
#' @examples
#' pts <- matrix(runif(15), ncol = 3, dimnames = list(NULL, c("X", "Y", "Z")))
#' sl <- streamline(points = pts)
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
#' `minfa`, `maxangle`, `ddim`, `ddim0`, `voxelext`, `orientation`, `rotation`,
#' `level`, and `source` are transferred to the corresponding `dwiFiber` / `dwi`
#' slots when present. MRI-acquisition metadata that cannot be recovered from a
#' `fiber` object (gradient directions, b-values, etc.) are filled with neutral
#' placeholders.
#'
#' @param x A [streamline] or [bundle] object.
#' @param ... Additional arguments (currently unused).
#' @returns An S4 object of class `dwiFiber` (from \pkg{dti}).
#' @seealso [as_streamline()], [as_bundle()]
#' @export
#' @examples
#' if (requireNamespace("dti", quietly = TRUE)) {
#'   pts <- matrix(runif(15), ncol = 3, dimnames = list(NULL, c("X", "Y", "Z")))
#'   sl  <- streamline(points = pts)
#'   b   <- bundle(streamlines = list(sl))
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

# ---- internal helpers -------------------------------------------------------

# Convert a dwiFiber S4 object to a fiber::bundle.
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
    colnames(pts) <- c("X", "Y", "Z")
    dirs <- fibers_mat[rows, 4:6, drop = FALSE]
    colnames(dirs) <- NULL
    streamlines[[i]] <- streamline(
      points = pts,
      point_data = list(
        direction_x = dirs[, 1],
        direction_y = dirs[, 2],
        direction_z = dirs[, 3]
      )
    )
  }

  bundle(
    streamlines = streamlines,
    bundle_data = list(
      method = x@method,
      minfa = x@minfa,
      maxangle = x@maxangle,
      ddim = x@ddim,
      ddim0 = x@ddim0,
      voxelext = x@voxelext,
      orientation = x@orientation,
      rotation = x@rotation,
      level = x@level,
      source = x@source
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
.bundle_to_dwifiber <- function(x) {
  n_fibers <- x@n_streamlines
  fibers_list <- vector("list", n_fibers)
  startind <- integer(n_fibers)
  row_cursor <- 1L
  bd <- x@bundle_data

  for (i in seq_len(n_fibers)) {
    sl <- x@streamlines[[i]]
    pts <- sl@points[, c("X", "Y", "Z"), drop = FALSE]
    n_pts <- nrow(pts)
    dirs <- if (
      all(
        c("direction_x", "direction_y", "direction_z") %in% sl@point_attributes
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

  methods::new(
    "dwiFiber",
    fibers = fibers_mat,
    startind = as.integer(startind),
    roimask = as.raw(0), # placeholder; dwiFiber requires a roimask slot but we have no equivalent data to fill it with
    method = as.character(bd[["method"]] %||% "unknown"),
    minfa = as.numeric(bd[["minfa"]] %||% 0),
    maxangle = as.numeric(bd[["maxangle"]] %||% 0),
    # dwi superclass slots — filled with neutral placeholders when absent
    call = as.list(call("as_dwifiber")),
    gradient = bd[["gradient"]] %||% matrix(0, nrow = 3L, ncol = 0L),
    bvalue = bd[["bvalue"]] %||% numeric(0L),
    btb = bd[["btb"]] %||% matrix(0, nrow = 6L, ncol = 0L),
    mask = bd[["mask"]] %||% array(FALSE, dim = c(0L, 0L, 0L)),
    ngrad = bd[["ngrad"]] %||% 0L,
    s0ind = bd[["s0ind"]] %||% integer(0L),
    replind = bd[["replind"]] %||% integer(0L),
    ddim = as.integer(bd[["ddim"]] %||% c(0L, 0L, 0L)),
    ddim0 = as.integer(bd[["ddim0"]] %||% c(0L, 0L, 0L)),
    xind = as.integer(bd[["xind"]] %||% integer(0L)),
    yind = as.integer(bd[["yind"]] %||% integer(0L)),
    zind = as.integer(bd[["zind"]] %||% integer(0L)),
    voxelext = as.numeric(bd[["voxelext"]] %||% c(1, 1, 1)),
    level = as.numeric(bd[["level"]] %||% 0),
    orientation = as.integer(bd[["orientation"]] %||% c(0L, 2L, 5L)),
    rotation = bd[["rotation"]] %||% diag(3),
    source = as.character(bd[["source"]] %||% "")
  )
}
