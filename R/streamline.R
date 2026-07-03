# ---- S7 class: streamline ---------------------------------------------------

#' Streamline S7 class
#'
#' @description
#' A `streamline` represents a single fibre tract. It stores three data
#' compartments:
#'
#' - `@points` — a \eqn{P \times 3} numeric matrix with column names `"X"`,
#'   `"Y"`, and `"Z"` holding the 3-D coordinates of the \eqn{P} points along
#'   the tract.
#' - `@point_data` — a named list of numeric vectors, each of length \eqn{P},
#'   holding additional per-point scalar attributes (e.g. fractional
#'   anisotropy). Coordinates are **not** stored here.
#' - `@streamline_data` — a named list of scalars (length-1 values of any
#'   type) holding per-streamline attributes (e.g. a tract-level weight or
#'   mean FA, or a character label).
#'
#' @param points A \eqn{P \times 3} numeric matrix with column names `"X"`,
#'   `"Y"`, and `"Z"` giving the 3-D coordinates of the streamline points.
#' @param point_data A named list of numeric vectors, each of length \eqn{P},
#'   holding additional per-point attributes. Must **not** include `"X"`,
#'   `"Y"`, or `"Z"` (those live in `@points`).
#' @param streamline_data A named list of per-streamline scalars (length-1,
#'   any type).
#' @prop n_points An integer scalar giving the number of points in the
#'   streamline (read-only).
#' @prop point_attributes A character vector of the names of the per-point
#'   attributes stored in `@point_data` (read-only).
#' @prop streamline_attributes A character vector of the names of the
#'   per-streamline attributes (read-only).
#'
#' @returns A `streamline` S7 object.
#' @section Methods for standard generics:
#' The following methods are defined for `streamline` objects:
#' - `format(x, ...)`: Returns a cli-formatted string describing the
#'   streamline object.
#' - `print(x, ...)`: Prints the formatted string to the console and
#'   invisibly returns `x`.
#' @export
#' @examples
#' # Create a streamline with 5 points and some attributes
#' sl <- streamline(
#'   points = cbind(
#'     X = c(0, 1, 1, 1, 0),
#'     Y = c(0, 0, 1, 1, 1),
#'     Z = c(0, 0, 0, 1, 1)
#'   ),
#'   point_data = list(FA = c(0.5, 0.6, 0.7, 0.8, 0.9)),
#'   streamline_data = list(mean_FA = 0.7, label = "CST")
#' )
#' sl@n_points         # 5
#' sl@point_attributes # "FA"
#' sl@streamline_attributes # c("mean_FA", "label")
#'
#' # format() and print() methods
#' format(sl)
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
      getter = function(self) names(self@point_data) %||% character(0L)
    ),
    streamline_attributes = S7::new_property(
      class = S7::class_character,
      getter = function(self) names(self@streamline_data) %||% character(0L)
    )
  ),
  validator = function(self) {
    pts <- self@points
    # @points must be a numeric matrix with 3 columns named X, Y, Z
    if (!is.numeric(pts) || !is.matrix(pts)) {
      return("@points must be a numeric matrix.")
    }
    if (ncol(pts) != 3L) {
      return(cli::format_inline(
        "@points must have exactly 3 columns (X, Y, Z); got {ncol(pts)}."
      ))
    }
    if (!identical(colnames(pts), c("X", "Y", "Z"))) {
      return(cli::format_inline(
        "@points column names must be c(\"X\", \"Y\", \"Z\"); \\
         got {.val {colnames(pts)}}."
      ))
    }
    p <- nrow(pts)
    # @point_data entries must be numeric vectors of length P
    for (nm in names(self@point_data)) {
      v <- self@point_data[[nm]]
      if (!is.numeric(v)) {
        return(cli::format_inline(
          "@point_data[[\"{nm}\"]] must be a numeric vector."
        ))
      }
      if (length(v) != p) {
        return(cli::format_inline(
          "@point_data[[\"{nm}\"]] must be a numeric vector of length \\
           {p} (same as nrow(@points))."
        ))
      }
    }
    # @streamline_data entries must be scalars (length 1, any type)
    for (nm in names(self@streamline_data)) {
      if (length(self@streamline_data[[nm]]) != 1L) {
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
#' sl <- streamline(points = cbind(X = 1:5, Y = 1:5, Z = 1:5))
#' is_streamline(sl) # TRUE
#' is_streamline(42) # FALSE
is_streamline <- function(x) S7::S7_inherits(x, streamline)

# ---- format / print ---------------------------------------------------------

S7::method(format, streamline) <- function(x, ...) {
  n <- x@n_points
  pd <- x@point_attributes
  sld <- x@streamline_attributes
  pd_str <- if (length(pd) > 0L) {
    "Point attributes: {.val {pd}}"
  } else {
    "Point attributes: {.emph none}"
  }
  sld_str <- if (length(sld) > 0L) {
    "Streamline attributes: {.val {sld}}"
  } else {
    "Streamline attributes: {.emph none}"
  }
  cli::cli_fmt(
    {
      cli::cli_h2("Object of class {.fn fiber::streamline} with {n} point{?s}.")
      cli::cli_bullets(c("*" = pd_str, "*" = sld_str))
    },
    collapse = TRUE
  )
}

S7::method(print, streamline) <- function(x, ...) {
  cat(format(x, ...), "\n")
  invisible(x)
}
