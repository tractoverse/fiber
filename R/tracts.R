#' Tract Constructor
#'
#' \code{tract} is the constructor for objects of class \code{tract}.
#'
#' @param ... A set of name-value pairs. Arguments are evaluated sequentially,
#'   so you can refer to previously created variables. To be a valid tract, the
#'   set should contain at least the fields \code{name} with the name of the
#'   tract, \code{case} with the identifier of the subject to which the tract
#'   belongs, \code{scan} to identify repeated measures for the same subject,
#'   \code{side} with the hemisphere to which the tract belongs and
#'   \code{data} with the list of \code{streamline}s composing the tract.
#'
#' @return A \code{\link{tract}}.
#' @export
#'
#' @examples
#' tr <- tract(name = "CST", case = "H018947", scan = "01", side = "L",
#'   data = list())
tract <- function(...) {
  as_tract(tibble::lst(...))
}

#' Tract Coercion
#'
#' \code{as_tract} coerces an input \code{list} into a \code{tract}.
#'
#' @param x Input list.
#' @param validate A boolean specifying whether the class of the input object
#'   should be checked (default: \code{TRUE}).
#'
#' @return A \code{\link{tract}}.
#' @export
#'
#' @examples
#' file <- system.file("extdata", "Case001_CST_Left.csv", package = "fdatractography")
#' cst_left <- read_tract(file)
#' tr <- as_tract(cst_left)
as_tract <- function(x, validate = TRUE, biomarkers = "None") {
  UseMethod("as_tract", x)
}

#' @export
#' @rdname as_tract
as_tract.list <- function(x, validate = TRUE) {
  if (validate) {
    if (!is.list(x))
      stop("Input should be a list.")

    if (length(x) != 4)
      stop("Input list should contain exactly 4 fields")

    if (!all(c("PatientId", "ScanId", "TractName", "Streamlines") %in% names(x)))
      stop("Input list should contain fields PatientId, ScanId, TractName and Streamlinees.")

    if (!is.character(x$PatientId) || length(x$PatientId) != 1)
      stop("The PatientId field should be of type character and of length 1")

    if (!is.character(x$ScanId) || length(x$ScanId) != 1)
      stop("The ScanId field should be of type character and of length 1")

    if (!is.character(x$TractName) || length(x$TractName) != 1)
      stop("The TractName field should be of type character and of length 1")

    if (!is.list(x$Streamlines))
      stop("The Streamlines field should be a list.")

    all_streamline <- TRUE
    for (i in seq_along(x$Streamlines)) {
      str <- x$Streamlines[[i]]
      if (!is_streamline(str)) {
        all_streamline <- FALSE
        break()
      }
    }

    if (!all_streamline)
      stop("The Streamlines field should contain only streamline objects.")
  }

  class(x) <- c("tract", class(x))
  x
}

#' @export
#' @rdname as_tract
as_tract.tbl_df <- function(x, validate = TRUE, biomarkers = "None") {
  x %>%
    as.list() %>%
    as_tract(validate, biomarkers)
}

#' Tract Format Verification
#'
#' \code{is_tract} check whether an input R object is of class \code{tract}.
#'
#' @param object An input R object.
#'
#' @return A boolean which is \code{TRUE} if the input object is of class
#'  \code{tract} and \code{FALSE} otherwise.
#' @export
#'
#' @examples
#' file <- system.file("extdata", "Case001_CST_Left.csv", package = "fdatractography")
#' cst_left <- read_tract(file)
#' is_tract(cst_left)
is_tract <- function(object) {
  "tract" %in% class(object)
}

is.tract <- is_tract

#' Tract Combination
#'
#' @param ... A set of \code{\link{tract}}s.
#'
#' @return A \code{\link[tibble]{tibble}} with the following 5 variables:
#'   \code{name} with the name of the tract, \code{case} with the identifier of
#'   the subject to which the tract belongs, \code{scan} with the identifier of
#'   the repeated measure for a given subject, \code{side} with the hemisphere
#'   to which the tract belongs and \code{data} with the list of
#'   \code{streamline}s composing the tract.
#' @export
#'
#' @examples
#' file <- system.file("extdata", "Case001_CST_Left.csv", package = "fdatractography")
#' cst_left <- read_tract(file)
#' file <- system.file("extdata", "Case001_CST_Right.csv", package = "fdatractography")
#' cst_right <- read_tract(file)
#' bind_tracts(cst_left, cst_right)
bind_tracts <- function(...) {
  res <- dplyr::bind_rows(...)
  as_tract(res)
}

#' Tract Reparametrization
#'
#' @param tract A \code{\link{tract}}.
#' @param grid Uniform grid for the curvilinear abscissa (default: \code{0L}
#'   which uses the average number of points across streamlines defining the
#'   tract). Can be specificed either as an integer in which case the abscissa
#'   range of each streamline is used and abscissa is uniformly resampled within
#'   this range or as a numeric vector that will be taken as the new common
#'   abscissa for all streamlines.
#' @param validate A boolean specifying whether to check that first input is
#'   indeed a \code{\link{tract}}. should be checked (default: \code{TRUE}).
#'
#' @return A \code{\link{tract}} reparametrized according to the input grid.
#' @export
#'
#' @examples
#' file <- system.file("extdata", "Case001_CST_Left.csv", package = "fdatractography")
#' cst_left <- read_tract(file)
#' reparametrize_tract(cst_left)
reparametrize_tract <- function(tract, ..., grid = 0L, validate = TRUE) {
  if (validate) {
    if (!is_tract(tract))
      stop("First input should be a tract object.")
  }

  biomarkers <- dplyr::quos(...)
  print(biomarkers)
  biomarker_names <- biomarkers %>%
    purrr::map(dplyr::quo_name)
  print(biomarker_names)
  l <- list()
  for (i in seq_along(biomarkers)) {
    l[[i]] <- dplyr::quo(!!(biomarker_names[[i]]) := approx(.data$s, .data[[!!(biomarker_names[[i]])]], xout = s)$y)
  }

  print(l)

  if (length(grid) == 1L) {
    if (grid == 0L) {
      grid <- tract$data %>%
        purrr::map_int(nrow) %>%
        mean() %>%
        round()
    }

    tract$data <- tract$data %>%
      purrr::map(dplyr::do, streamline(
        s = modelr::seq_range(.$s, n = grid),
        x = approx(.$s, .$x, xout = s)$y,
        y = approx(.$s, .$y, xout = s)$y,
        z = approx(.$s, .$z, xout = s)$y,
        !!!l,
        validate = FALSE
      ))
  } else {
    if (length(grid) == 0L) {
      grid_length <- tract$data %>%
        purrr::map_int(nrow) %>%
        mean() %>%
        round()
      s_min <- tract$data %>%
        purrr::map(pull, s) %>%
        purrr::map_dbl(min) %>%
        max()
      s_max <- tract$data %>%
        purrr::map(pull, s) %>%
        purrr::map_dbl(max) %>%
        min()
      grid <- seq(s_min, s_max, length.out = grid_length)
    }

    tract$data <- tract$data %>%
      purrr::map(dplyr::do, streamline(
        s = grid,
        x = approx(.$s, .$x, xout = s)$y,
        y = approx(.$s, .$y, xout = s)$y,
        z = approx(.$s, .$z, xout = s)$y,
        !!!l,
        validate = FALSE
      ))
  }

  tract
}
