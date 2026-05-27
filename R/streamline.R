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
#' @param points A numeric matrix with columns `"X"`, `"Y"`, and `"Z"`.
#' @param point_data A named list of per-point numeric vectors.
#' @param streamline_data A named list of per-streamline numeric scalars.
#' @prop n_points An integer scalar giving the number of points in the streamline (read-only).
#' @prop point_attributes A character vector of the names of the per-point attributes (read-only).
#' @prop streamline_attributes A character vector of the names of the per-streamline attributes (read-only).
#'
#' @returns A `streamline` S7 object.
#' @section Methods for standard generics:
#' The following methods are defined for `streamline` objects:
#' - `format(x, ...)`: Returns a compact character string such as
#'   `<streamline [10 pts] | point: FA>`.
#' - `print(x, ...)`: Prints the formatted string to the console and
#'   invisibly returns `x`.
#' @export
#' @examples
#' # Create a streamline with 5 points and some attributes
#' sl <- streamline(
#'   points = matrix(
#'     c(0, 0, 0,
#'       1, 0, 0,
#'       1, 1, 0,
#'       1, 1, 1,
#'       0, 1, 1),
#'     ncol = 3,
#'     byrow = TRUE,
#'     dimnames = list(NULL, c("X", "Y", "Z"))
#'   ),
#'   point_data = list(FA = c(0.5, 0.6, 0.7, 0.8, 0.9)),
#'   streamline_data = list(mean_FA = 0.7)
#' )
#' sl@n_points  # 5
#' sl@point_attributes  # "FA"
#' sl@streamline_attributes  # "mean_FA"
#'
#' # format() and print() methods
#' format(sl)  # "<streamline [5 pts] | point: FA | streamline: mean_FA>"
#' print(sl)
streamline <- S7::new_class(
  name = "streamline",
  package = "fiber",
  properties = list(
    points = S7::class_any,
    point_data = S7::class_list,
    streamline_data = S7::class_list,
    n_points = S7::new_property(
      class = S7::class_integer,
      getter = function(self) nrow(self@points)
    ),
    point_attributes = S7::new_property(
      class = S7::class_character,
      getter = function(self) names(self@point_data)
    ),
    streamline_attributes = S7::new_property(
      class = S7::class_character,
      getter = function(self) names(self@streamline_data)
    )
  ),
  validator = function(self) {
    if (!is.matrix(self@points) || !is.numeric(self@points)) {
      return("@points must be a numeric matrix.")
    }
    cn <- colnames(self@points)
    if (is.null(cn) || !all(c("X", "Y", "Z") %in% cn)) {
      return("@points must have column names including 'X', 'Y', and 'Z'.")
    }
    n_pts <- self@n_points
    for (nm in self@point_attributes) {
      v <- self@point_data[[nm]]
      if (length(v) != n_pts) {
        return(cli::format_inline(
          "@point_data[[\"{nm}\"]] must be a vector of length {n_pts}."
        ))
      }
    }
    for (nm in self@streamline_attributes) {
      v <- self@streamline_data[[nm]]
      if (length(v) != 1L) {
        return(cli::format_inline(
          "@streamline_data[[\"{nm}\"]] must be a scalar (length 1)."
        ))
      }
    }
    NULL
  }
)

# ---- predicate --------------------------------------------------------------

#' Test whether an object is a streamline
#'
#' @param x An object.
#' @returns `TRUE` if `x` is of class [streamline], otherwise `FALSE`.
#' @export
#' @examples
#' pts <- matrix(runif(15), ncol = 3, dimnames = list(NULL, c("X", "Y", "Z")))
#' sl <- streamline(points = pts)
#' is_streamline(sl)     # TRUE
#' is_streamline(42)     # FALSE
is_streamline <- function(x) S7::S7_inherits(x, streamline)

# ---- helper: number of points -----------------------------------------------

#' Number of points in a streamline
#'
#' @param x A [streamline] object.
#' @returns An integer scalar giving the number of points.
#' @keywords internal
n_points <- function(x) x@n_points

# ---- format / print ---------------------------------------------------------

S7::method(format, streamline) <- function(x, ...) {
  pd <- x@point_attributes
  sld <- x@streamline_attributes
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
  paste0("<streamline [", x@n_points, " pts]", pd_str, sld_str, ">")
}

S7::method(print, streamline) <- function(x, ...) {
  cat(format(x, ...), "\n")
  invisible(x)
}
