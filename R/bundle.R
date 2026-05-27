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

# ---- S7 class: bundle_set ---------------------------------------------------

#' Bundle set S7 class
#'
#' @description
#' A `bundle_set` is a **named collection of [bundle] objects**, designed for
#' multi-subject or multi-session studies where each element represents one
#' subject's (or session's) tractogram. It stores two compartments:
#'
#' - `@bundles` — a *named* list of [bundle] objects. Names typically encode
#'   subject or session identifiers (e.g. `"sub-01"`, `"sub-02"`).
#' - `@set_data` — a named list of set-level metadata (arbitrary R objects,
#'   e.g. study name, atlas used, acquisition protocol).
#'
#' @param bundles A named list of [bundle] objects.
#' @param set_data A named list of set-level metadata.
#' @prop n_bundles An integer scalar giving the number of bundles in the set
#'   (read-only).
#' @prop bundle_names A character vector of the names of the bundles
#'   (read-only).
#' @prop set_attributes A character vector of the names of the set-level
#'   attributes (read-only).
#'
#' @returns A `bundle_set` S7 object.
#' @section Methods for standard generics:
#' The following methods are defined for `bundle_set` objects:
#' - `format(x, ...)`: Returns a compact character string.
#' - `print(x, ...)`: Prints the formatted string to the console and
#'   invisibly returns `x`.
#' - `length(x)`: Returns the number of bundles.
#' - `x[[i]]`: Extracts the `i`-th (or named) [bundle] from the set.
#' - `x[i]`: Returns a new [bundle_set] containing only the selected bundles,
#'   preserving `@set_data`.
#' - `names(x)`: Returns the names of the bundles.
#' @export
#' @examples
#' pts <- matrix(runif(15), ncol = 3, dimnames = list(NULL, c("X", "Y", "Z")))
#' b1 <- bundle(streamlines = list(streamline(points = pts)),
#'              bundle_data = list(subject = "sub-01"))
#' b2 <- bundle(streamlines = list(streamline(points = pts)),
#'              bundle_data = list(subject = "sub-02"))
#' bs <- bundle_set(bundles = list("sub-01" = b1, "sub-02" = b2))
#' bs@n_bundles      # 2
#' bs@bundle_names   # c("sub-01", "sub-02")
#' bs[["sub-01"]]    # first bundle
bundle_set <- S7::new_class(
  name = "bundle_set",
  package = "fiber",
  properties = list(
    bundles = S7::class_list,
    set_data = S7::class_list,
    n_bundles = S7::new_property(
      class = S7::class_integer,
      getter = function(self) length(self@bundles)
    ),
    bundle_names = S7::new_property(
      class = S7::class_character,
      getter = function(self) names(self@bundles) %||% character(0L)
    ),
    set_attributes = S7::new_property(
      class = S7::class_character,
      getter = function(self) names(self@set_data)
    )
  ),
  validator = function(self) {
    bad <- !vapply(
      self@bundles,
      function(x) S7::S7_inherits(x, bundle),
      logical(1L)
    )
    if (any(bad)) {
      return("All elements of @bundles must be <fiber::bundle> objects.")
    }
    if (length(self@bundles) > 0L && is.null(names(self@bundles))) {
      return("@bundles must be a named list.")
    }
    NULL
  }
)

# ---- predicate --------------------------------------------------------------

#' Test whether an object is a bundle_set
#'
#' @param x An object.
#' @returns `TRUE` if `x` is of class [bundle_set], otherwise `FALSE`.
#' @export
#' @examples
#' pts <- matrix(runif(15), ncol = 3, dimnames = list(NULL, c("X", "Y", "Z")))
#' b <- bundle(streamlines = list(streamline(points = pts)))
#' bs <- bundle_set(bundles = list("sub-01" = b))
#' is_bundle_set(bs)  # TRUE
#' is_bundle_set(b)   # FALSE
is_bundle_set <- function(x) S7::S7_inherits(x, bundle_set)

# ---- format / print ---------------------------------------------------------

S7::method(format, bundle_set) <- function(x, ...) {
  n <- x@n_bundles
  if (n == 0L) {
    return("<bundle_set [0 bundles]>")
  }
  nms <- x@bundle_names
  nm_preview <- if (n <= 3L) {
    paste(nms, collapse = ", ")
  } else {
    paste0(paste(nms[1:3], collapse = ", "), ", \u2026 (", n - 3L, " more)")
  }
  sd_keys <- names(x@set_data)
  sd_str <- if (length(sd_keys) > 0L) {
    paste0(" | set: ", paste(sd_keys, collapse = ", "))
  } else {
    ""
  }
  n_sls <- vapply(x@bundles, function(b) b@n_streamlines, integer(1L))
  paste0(
    "<bundle_set [",
    n,
    " bundles | ",
    min(n_sls),
    "\u2013",
    max(n_sls),
    " streamlines/bundle]: ",
    nm_preview,
    sd_str,
    ">"
  )
}

S7::method(print, bundle_set) <- function(x, ...) {
  cat(format(x, ...), "\n")
  invisible(x)
}

# ---- length / names / indexing ----------------------------------------------

S7::method(length, bundle_set) <- function(x) x@n_bundles

S7::method(names, bundle_set) <- function(x) x@bundle_names

S7::method(`[[`, bundle_set) <- function(x, i, ...) x@bundles[[i]]

S7::method(`[`, bundle_set) <- function(x, i, j, ..., drop = TRUE) {
  bundle_set(bundles = x@bundles[i], set_data = x@set_data)
}
