# ---- S7 class: bundle_set ---------------------------------------------------

#' Bundle set S7 class
#'
#' @description
#' A `bundle_set` is a collection of [bundle] objects, designed for
#' multi-subject or multi-session studies where each element represents one
#' subject's (or session's) tractogram. It stores three compartments:
#'
#' - `@bundles` — a list of [bundle] objects (names are optional).
#' - `@bundle_data` — a named list of per-bundle vectors (any type), each of
#'   length \eqn{B} (the number of bundles). Values common to all bundles may
#'   be lifted here automatically from the individual bundles' `@bundle_data`
#'   slots at construction time.
#' - `@set_data` — a named list of scalars (length-1 values, any type)
#'   holding set-level metadata.
#'
#' @param bundles A list of [bundle] objects (may be named or unnamed).
#' @param bundle_data A named list of per-bundle vectors of length B. If not
#'   supplied, any `@bundle_data` keys common to **all** bundles are lifted
#'   automatically.
#' @param set_data A named list of set-level scalar metadata.
#' @prop n_bundles An integer scalar giving the number of bundles in the set
#'   (read-only).
#' @prop bundle_attributes A character vector of the names of the per-bundle
#'   attributes stored at the set level (read-only).
#' @prop set_attributes A character vector of the names of the set-level
#'   attributes (read-only).
#'
#' @returns A `bundle_set` S7 object.
#' @section Methods for standard generics:
#' The following methods are defined for `bundle_set` objects:
#' - `format(x, ...)`: Returns a styled character string.
#' - `print(x, ...)`: Prints the formatted string to the console and
#'   invisibly returns `x`.
#' - `length(x)`: Returns the number of bundles.
#' - `x[[i]]`: Extracts the `i`-th (or named) [bundle] from the set, with
#'   set-level `@bundle_data` pushed back into the bundle.
#' - `x[i]`: Returns a new [bundle_set] containing only the selected bundles,
#'   with `@set_data` and the subset of `@bundle_data` preserved.
#' @export
#' @examples
#' sl <- streamline(points = cbind(X = 1:5, Y = 1:5, Z = 1:5))
#' b1 <- bundle(
#'   streamlines = list(sl),
#'   bundle_data = list(subject = "sub-01")
#' )
#' b2 <- bundle(
#'   streamlines = list(sl),
#'   bundle_data = list(subject = "sub-02")
#' )
#' # subject is common across bundles and lifted to bundle_set@bundle_data
#' bs <- bundle_set(bundles = list("sub-01" = b1, "sub-02" = b2))
#' bs@n_bundles          # 2
#' bs@bundle_attributes  # "subject"
#' bs@bundle_data$subject  # c("sub-01", "sub-02")
bundle_set <- S7::new_class(
  name = "bundle_set",
  package = "fiber",
  properties = list(
    bundles = S7::class_list,
    bundle_data = S7::class_list,
    set_data = S7::class_list,
    n_bundles = S7::new_property(
      class = S7::class_integer,
      getter = function(self) length(self@bundles)
    ),
    bundle_attributes = S7::new_property(
      class = S7::class_character,
      getter = function(self) names(self@bundle_data) %||% character(0L)
    ),
    set_attributes = S7::new_property(
      class = S7::class_character,
      getter = function(self) names(self@set_data) %||% character(0L)
    )
  ),
  validator = function(self) {
    # If elements of @bundles are named, ensure there is no duplicate
    if (length(names(self@bundles)) > 0) {
      if (length(names(self@bundles)) != length(unique(names(self@bundles)))) {
        return(cli::format_inline(
          "Some bundles are named with duplicate names."
        ))
      }
    }
    # All elements of @bundles must be bundle objects
    bad <- !vapply(
      self@bundles,
      function(x) S7::S7_inherits(x, bundle),
      logical(1L)
    )
    if (any(bad)) {
      return("All elements of @bundles must be <fiber::bundle> objects.")
    }
    b <- length(self@bundles)
    # @bundle_data entries must be vectors of length n_bundles
    for (nm in names(self@bundle_data)) {
      if (length(self@bundle_data[[nm]]) != b) {
        return(cli::format_inline(
          "@bundle_data[[\"{nm}\"]] must be a vector of length \\
             {b} (one entry per bundle)."
        ))
      }
    }
    # @set_data entries must be scalars
    for (nm in names(self@set_data)) {
      if (length(self@set_data[[nm]]) != 1L) {
        return(cli::format_inline(
          "@set_data[[\"{nm}\"]] must be a scalar (length 1)."
        ))
      }
    }
    NULL
  },
  constructor = function(
    bundles = list(),
    bundle_data = list(),
    set_data = list()
  ) {
    lifted_data <- .lift_bundle_data(bundles)
    bundles <- lifted_data$bundles
    lifted_data <- lifted_data$lifted
    if (length(lifted_data) > 0) {
      nms <- names(lifted_data)
      for (nm in nms) {
        if (length(bundle_data) > 0) {
          if (nm %in% names(bundle_data)) {
            next
          }
        }
        bundle_data[[nm]] <- lifted_data[[nm]]
      }
    }
    bundle_names <- names(bundles)
    if (!is.null(bundle_names)) {
      bundle_data$id_from_input_names <- bundle_names
      bundles <- unname(bundles)
    }
    S7::new_object(
      S7::S7_object(),
      bundles = bundles,
      bundle_data = bundle_data,
      set_data = set_data
    )
  }
)

# ---- predicate --------------------------------------------------------------

#' Test whether an object is a bundle_set
#'
#' @param x An object.
#' @returns `TRUE` if `x` is of class [bundle_set], otherwise `FALSE`.
#' @export
#' @examples
#' sl <- streamline(points = cbind(X = 1:5, Y = 1:5, Z = 1:5))
#' b <- bundle(streamlines = list(sl))
#' bs <- bundle_set(bundles = list(b))
#' is_bundle_set(bs)  # TRUE
#' is_bundle_set(b)   # FALSE
is_bundle_set <- function(x) S7::S7_inherits(x, bundle_set)

# ---- format / print ---------------------------------------------------------

S7::method(format, bundle_set) <- function(x, ...) {
  n <- x@n_bundles
  if (n == 0L) {
    return(cli::cli_fmt(
      {
        cli::cli_h2("Object of class {.fn fiber::bundle_set} with no bundle.")
      },
      collapse = TRUE
    ))
  }

  n_sls <- vapply(x@bundles, function(b) b@n_streamlines, integer(1L))

  # Retrieve point attributes
  pd_keys <- unique(unlist(lapply(x@bundles, function(b) {
    unique(unlist(lapply(b@streamlines, function(s) {
      s@point_attributes
    })))
  })))

  # Retrieve streamline attributes
  sd_keys <- unique(unlist(lapply(x@bundles, function(b) {
    union(
      b@streamline_attributes,
      unique(unlist(lapply(b@streamlines, function(s) {
        s@streamline_attributes
      })))
    )
  })))

  # Retrieve bundle attributes
  bd_keys <- union(
    x@bundle_attributes,
    unique(unlist(lapply(x@bundles, function(b) b@bundle_attributes)))
  )

  # Retrieve set attributes
  setd_keys <- x@set_attributes

  pd_str <- if (length(pd_keys) > 0L) {
    "Point attributes: {.val {pd_keys}}"
  } else {
    "Point attributes: {.emph none}"
  }

  sd_str <- if (length(sd_keys) > 0L) {
    "Streamline attributes: {.val {sd_keys}}"
  } else {
    "Streamline attributes: {.emph none}"
  }

  bd_str <- if (length(bd_keys) > 0L) {
    "Bundle attributes: {.val {bd_keys}}"
  } else {
    "Bundle attributes: {.emph none}"
  }

  setd_str <- if (length(setd_keys) > 0L) {
    "Set attributes: {.val {setd_keys}}"
  } else {
    "Set attributes: {.emph none}"
  }

  # Retrieve range of number of streamlines across bundles
  n_streamlines_distr <- vapply(
    x@bundles,
    function(b) b@n_streamlines,
    integer(1L)
  )
  n_streamlines_range <- paste0(
    min(n_streamlines_distr),
    "\u2013",
    max(n_streamlines_distr)
  )
  cli::cli_fmt(
    {
      cli::cli_h2(
        "Object of class {.fn fiber::bundle_set} with {n} bundle{?s} and [{n_streamlines_range}] streamlines per bundle."
      )
      cli::cli_bullets(c(
        "*" = pd_str,
        "*" = sd_str,
        "*" = bd_str,
        "*" = setd_str
      ))
    },
    collapse = TRUE
  )
}

S7::method(print, bundle_set) <- function(x, ...) {
  cat(format(x, ...), "\n")
  invisible(x)
}

# ---- length / indexing ----------------------------------------------

S7::method(length, bundle_set) <- function(x) x@n_bundles

S7::method(`[[`, bundle_set) <- function(x, i, ...) {
  # Resolve to a numeric position so we can index the unnamed data vectors
  pos <- .convert_bundle_set_subset(i, x)

  b <- x@bundles[[pos]]
  # Push bundle-set-level bundle_data[pos] back into the bundle
  for (k in x@bundle_attributes) {
    b@bundle_data[[k]] <- x@bundle_data[[k]][[pos]]
  }
  b
}

S7::method(`[`, bundle_set) <- function(x, i, j, ..., drop = TRUE) {
  # Resolve to numeric positions for indexing the unnamed data vectors
  pos <- .convert_bundle_set_subset(i, x)

  bundles <- x@bundles[pos]
  bundle_data <- lapply(x@bundle_data, function(v) unname(v[pos]))

  bundle_set(
    bundles = bundles,
    bundle_data = bundle_data,
    set_data = x@set_data
  )
}
