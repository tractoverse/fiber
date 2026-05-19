# ---- S7 class: bundle -------------------------------------------------------

#' Bundle S7 class
#'
#' @description
#' A `bundle` is an ordered collection of [streamline] objects representing a
#' tractogram or white-matter bundle. It stores two compartments:
#'
#' - `@streamlines` — a list of [streamline] objects.
#' - `@bundle_data` — a named list of bundle-level metadata (arbitrary R
#'   objects, e.g. the affine transform used during tracking).
#'
#' @param streamlines A list of [streamline] objects.
#' @param bundle_data A named list of bundle-level metadata.
#' @prop n_streamlines An integer scalar giving the number of streamlines in the bundle (read-only).
#' @prop bundle_attributes A character vector of the names of the bundle-level attributes (read-only).
#'
#' @returns A `bundle` S7 object.
#' @section Methods for standard generics:
#' The following methods are defined for `bundle` objects:
#' - `format(x, ...)`: Returns a compact character string such as
#'   `<bundle [2 streamlines | 10–20 pts/streamline]>`.
#' - `print(x, ...)`: Prints the formatted string to the console and
#'   invisibly returns `x`.
#' - `length(x)`: Returns the number of streamlines (equivalent to
#'   `x@n_streamlines`).
#' - `x[[i]]`: Extracts the `i`-th [streamline] from the bundle.
#' - `x[i]`: Returns a new [bundle] containing only the selected
#'   streamlines, preserving `@bundle_data`.
#' @export
#' @examples
#' pts <- matrix(runif(15), ncol = 3, dimnames = list(NULL, c("X", "Y", "Z")))
#' sl <- streamline(points = pts)
#' b <- bundle(streamlines = list(sl))
#' b@n_streamlines  # 1
#' b@bundle_attributes  # NULL (no bundle-level attributes)
#'
#' # bundle_data is stored
#' b2 <- bundle(
#'   streamlines = list(sl),
#'   bundle_data = list(subject = "sub-01")
#' )
#' b2@bundle_data$subject  # "sub-01"
#'
#' # format(), print(), length() and indexing methods
#' format(b2)
#' print(b2)
#' length(b2)   # 1
#' b2[[1]]      # first streamline
#'
#' # subsetting preserves bundle_data
#' pts2 <- matrix(runif(15), ncol = 3, dimnames = list(NULL, c("X", "Y", "Z")))
#' sl2 <- streamline(points = pts2)
#' b3 <- bundle(streamlines = list(sl, sl2), bundle_data = list(subject = "sub-01"))
#' b3[1]@n_streamlines  # 1, bundle_data preserved
bundle <- S7::new_class(
  name = "bundle",
  package = "fiber",
  properties = list(
    streamlines = S7::class_list,
    bundle_data = S7::class_list,
    n_streamlines = S7::new_property(
      class = S7::class_integer,
      getter = function(self) length(self@streamlines)
    ),
    bundle_attributes = S7::new_property(
      class = S7::class_character,
      getter = function(self) names(self@bundle_data)
    )
  ),
  validator = function(self) {
    bad <- !vapply(
      self@streamlines,
      function(x) S7::S7_inherits(x, streamline),
      logical(1L)
    )
    if (any(bad)) {
      return(
        "All elements of @streamlines must be <fiber::streamline> objects."
      )
    }
    NULL
  }
)

# ---- predicate --------------------------------------------------------------

#' Test whether an object is a bundle
#'
#' @param x An object.
#' @returns `TRUE` if `x` is of class [bundle], otherwise `FALSE`.
#' @export
#' @examples
#' pts <- matrix(runif(15), ncol = 3, dimnames = list(NULL, c("X", "Y", "Z")))
#' sl <- streamline(points = pts)
#' b <- bundle(streamlines = list(sl))
#' is_bundle(b)   # TRUE
#' is_bundle(sl)  # FALSE
is_bundle <- function(x) S7::S7_inherits(x, bundle)

# ---- format / print ---------------------------------------------------------

S7::method(format, bundle) <- function(x, ...) {
  n <- x@n_streamlines
  if (n == 0L) {
    return("<bundle [0 streamlines]>")
  }
  npts <- vapply(x@streamlines, n_points, integer(1L))
  pd_keys <- unique(unlist(lapply(x@streamlines, function(s) {
    names(s@point_data)
  })))
  sld_keys <- unique(unlist(lapply(x@streamlines, function(s) {
    names(s@streamline_data)
  })))
  bd_keys <- names(x@bundle_data)
  pd_str <- if (length(pd_keys) > 0L) {
    paste0(" | point: ", paste(pd_keys, collapse = ", "))
  } else {
    ""
  }
  sld_str <- if (length(sld_keys) > 0L) {
    paste0(" | streamline: ", paste(sld_keys, collapse = ", "))
  } else {
    ""
  }
  bd_str <- if (length(bd_keys) > 0L) {
    paste0(" | bundle: ", paste(bd_keys, collapse = ", "))
  } else {
    ""
  }
  paste0(
    "<bundle [",
    n,
    " streamlines | ",
    min(npts),
    "\u2013",
    max(npts),
    " pts/streamline]",
    pd_str,
    sld_str,
    bd_str,
    ">"
  )
}

S7::method(print, bundle) <- function(x, ...) {
  cat(format(x, ...), "\n")
  invisible(x)
}

# ---- length / indexing for bundle -------------------------------------------

S7::method(length, bundle) <- function(x) x@n_streamlines

S7::method(`[[`, bundle) <- function(x, i, ...) x@streamlines[[i]]

S7::method(`[`, bundle) <- function(x, i, j, ..., drop = TRUE) {
  bundle(streamlines = x@streamlines[i], bundle_data = x@bundle_data)
}
