# ---- S7 class: streamline ---------------------------------------------------

#' Streamline S7 class
#'
#' @description
#' A `streamline` represents a single fibre tract. It stores three data
#' compartments that mirror the conceptual levels found in tractography file
#' formats:
#'
#' - `@points` — an \eqn{n \times 3} numeric matrix whose columns are named
#'   `"X"`, `"Y"`, and `"Z"`, holding the ordered 3-D coordinates of the
#'   \eqn{n} points along the tract.
#' - `@point_data` — a named list of numeric vectors, each of length \eqn{n},
#'   holding per-point scalar attributes (e.g. fractional anisotropy sampled
#'   at every point).
#' - `@streamline_data` — a named list of numeric scalars (length-1 vectors)
#'   holding per-streamline attributes (e.g. a tract-level weight or mean FA).
#'
#' Use the [new_streamline()] constructor to create instances. Properties are
#' accessed with the `@` operator: `sl@points`, `sl@point_data`,
#' `sl@streamline_data`.
#'
#' @param points A numeric matrix with columns `"X"`, `"Y"`, and `"Z"`.
#' @param point_data A named list of per-point numeric vectors.
#' @param streamline_data A named list of per-streamline numeric scalars.
#'
#' @returns A `streamline` S7 object.
#' @export
streamline <- S7::new_class(
  name = "streamline",
  package = "fiber",
  properties = list(
    points = S7::class_any,
    point_data = S7::class_list,
    streamline_data = S7::class_list
  ),
  validator = function(self) {
    if (!is.matrix(self@points) || !is.numeric(self@points)) {
      return("@points must be a numeric matrix.")
    }
    cn <- colnames(self@points)
    if (is.null(cn) || !all(c("X", "Y", "Z") %in% cn)) {
      return("@points must have column names including 'X', 'Y', and 'Z'.")
    }
    n_pts <- nrow(self@points)
    for (nm in names(self@point_data)) {
      v <- self@point_data[[nm]]
      if (!is.numeric(v) || length(v) != n_pts) {
        return(sprintf(
          "@point_data[[\"%s\"]] must be a numeric vector of length %d.",
          nm,
          n_pts
        ))
      }
    }
    for (nm in names(self@streamline_data)) {
      v <- self@streamline_data[[nm]]
      if (!is.numeric(v) || length(v) != 1L) {
        return(sprintf(
          "@streamline_data[[\"%s\"]] must be a numeric scalar (length 1).",
          nm
        ))
      }
    }
    NULL
  }
)

# ---- constructor ------------------------------------------------------------

#' Create a streamline object
#'
#' A convenience constructor that wraps the [streamline] S7 class.
#'
#' @param points A numeric matrix with at least three columns named `"X"`,
#'   `"Y"`, and `"Z"`. Rows correspond to ordered points along the tract.
#' @param point_data A named list of numeric vectors, each of length
#'   `nrow(points)`, holding per-point scalar attributes. Defaults to an
#'   empty list.
#' @param streamline_data A named list of numeric scalars (length-1 vectors)
#'   holding per-streamline attributes. Defaults to an empty list.
#'
#' @returns An object of class [streamline].
#' @seealso [new_bundle()]
#' @export
new_streamline <- function(
  points,
  point_data = list(),
  streamline_data = list()
) {
  streamline(
    points = points,
    point_data = point_data,
    streamline_data = streamline_data
  )
}

# ---- predicate --------------------------------------------------------------

#' Test whether an object is a streamline
#'
#' @param x An object.
#' @returns `TRUE` if `x` is of class [streamline], otherwise `FALSE`.
#' @export
is_streamline <- function(x) S7::S7_inherits(x, streamline)

# ---- helper: number of points -----------------------------------------------

#' Number of points in a streamline
#'
#' @param x A [streamline] object.
#' @returns An integer scalar giving the number of points.
#' @keywords internal
n_points <- function(x) nrow(x@points)

# ---- format / print ---------------------------------------------------------

#' @rdname streamline
#' @usage NULL
S7::method(format, streamline) <- function(x, ...) {
  pd <- names(x@point_data)
  sld <- names(x@streamline_data)
  pd_str <- if (length(pd) > 0L) {
    paste0(" | point: ", paste(pd, collapse = ", "))
  } else {
    ""
  }
  sld_str <- if (length(sld) > 0L) {
    paste0(" | streamline: ", paste(sld, collapse = ", "))
  } else {
    ""
  }
  paste0("<streamline [", n_points(x), " pts]", pd_str, sld_str, ">")
}

#' @rdname streamline
#' @usage NULL
S7::method(print, streamline) <- function(x, ...) {
  cat(format(x, ...), "\n")
  invisible(x)
}
