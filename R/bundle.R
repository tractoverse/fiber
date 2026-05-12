# ---- S7 class: bundle -------------------------------------------------------

#' The bundle S7 class
#'
#' A [bundle] is an ordered collection of [streamline] objects representing a
#' tractogram or white-matter bundle.  It stores two compartments:
#' - `@streamlines` — a list of [streamline] objects.
#' - `@bundle_data` — a named list of bundle-level metadata (arbitrary R
#'   objects, e.g. the affine transform used during tracking).
#'
#' Use the [new_bundle()] constructor to create instances.
#'
#' @param streamlines A list of [streamline] objects.
#' @param bundle_data A named list of bundle-level metadata.
#'
#' @export
bundle <- S7::new_class(
  name = "bundle",
  package = "riot",
  properties = list(
    streamlines = S7::class_list,
    bundle_data = S7::class_list
  ),
  validator = function(self) {
    bad <- !vapply(
      self@streamlines,
      function(x) S7::S7_inherits(x, streamline),
      logical(1L)
    )
    if (any(bad)) {
      return("All elements of @streamlines must be <riot::streamline> objects.")
    }
    NULL
  }
)

# ---- constructor ------------------------------------------------------------

#' Create a bundle object
#'
#' A convenience constructor that wraps the [bundle] S7 class.
#'
#' @param streamlines A list of [streamline] objects.
#' @param bundle_data A named list of bundle-level metadata.  Defaults to an
#'   empty list.
#'
#' @return An object of class [bundle].
#' @export
#' @seealso [new_streamline()]
new_bundle <- function(streamlines, bundle_data = list()) {
  bundle(streamlines = streamlines, bundle_data = bundle_data)
}

# ---- predicate --------------------------------------------------------------

#' Check whether an object is a bundle
#'
#' @param x An object.
#' @return `TRUE` if `x` is of class [bundle], otherwise `FALSE`.
#' @export
is_bundle <- function(x) S7::S7_inherits(x, bundle)

# ---- format / print ---------------------------------------------------------

S7::method(format, bundle) <- function(x, ...) {
  n <- length(x@streamlines)
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

S7::method(length, bundle) <- function(x) length(x@streamlines)

S7::method(`[[`, bundle) <- function(x, i, ...) x@streamlines[[i]]

S7::method(`[`, bundle) <- function(x, i, j, ..., drop = TRUE) {
  new_bundle(x@streamlines[i], bundle_data = x@bundle_data)
}
