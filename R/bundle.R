# ---- S7 class: bundle -------------------------------------------------------

#' Bundle S7 class
#'
#' @description
#' A `bundle` is an ordered collection of [streamline] objects representing a
#' tractogram or white-matter bundle. It stores three compartments:
#'
#' - `@streamlines` — a list of [streamline] objects.
#' - `@streamline_data` — a named list of per-streamline vectors (any type),
#'   each of length \eqn{S} (the number of streamlines). Values common to all
#'   streamlines may be lifted here automatically from the individual
#'   streamlines' `@streamline_data` slots at construction time.
#' - `@bundle_data` — a named list of scalars (length-1 values, any type)
#'   holding bundle-level metadata.
#'
#' @param streamlines A list of [streamline] objects.
#' @param streamline_data A named list of per-streamline vectors of length S.
#'   If not supplied, any `@streamline_data` keys common to **all** streamlines
#'   are lifted automatically.
#' @param bundle_data A named list of bundle-level scalar metadata.
#' @prop n_streamlines An integer scalar giving the number of streamlines in
#'   the bundle (read-only).
#' @prop streamline_attributes A character vector of the names of the
#'   per-streamline attributes stored at the bundle level (read-only).
#' @prop bundle_attributes A character vector of the names of the bundle-level
#'   attributes (read-only).
#'
#' @returns A `bundle` S7 object.
#' @section Methods for standard generics:
#' The following methods are defined for `bundle` objects:
#' - `format(x, ...)`: Returns a cli-formatted string describing the bundle
#'   object.
#' - `print(x, ...)`: Prints the formatted string to the console and
#'   invisibly returns `x`.
#' - `length(x)`: Returns the number of streamlines (equivalent to
#'   `x@n_streamlines`).
#' - `x[[i]]`: Extracts the `i`-th [streamline] from the bundle, with
#'   bundle-level `@streamline_data` pushed back into the streamline.
#' - `x[i]`: Returns a new [bundle] containing only the selected streamlines,
#'   with `@bundle_data` and the subset of `@streamline_data` preserved.
#' @export
#' @examples
#' sl1 <- streamline(
#'   points = cbind(X = 0:4, Y = 0:4, Z = 0:4),
#'   streamline_data = list(mean_FA = 0.6, label = "CST")
#' )
#' sl2 <- streamline(
#'   points = cbind(X = 1:3, Y = 1:3, Z = 1:3),
#'   streamline_data = list(mean_FA = 0.7, label = "CST")
#' )
#' # mean_FA and label are common to both streamlines and are lifted
#' b <- bundle(streamlines = list(sl1, sl2))
#' b@n_streamlines  # 2
#' b@streamline_attributes  # c("mean_FA", "label")
#' b@streamline_data$mean_FA  # c(0.6, 0.7)
#'
#' # Subsetting pushes streamline_data back down
#' b[[1]]@streamline_data$mean_FA  # 0.6
#' b[1]@streamline_data$mean_FA    # c(0.6)
bundle <- S7::new_class(
  name = "bundle",
  package = "fiber",
  properties = list(
    streamlines = S7::class_list,
    streamline_data = S7::class_list,
    bundle_data = S7::class_list,
    n_streamlines = S7::new_property(
      class = S7::class_integer,
      getter = function(self) length(self@streamlines)
    ),
    streamline_attributes = S7::new_property(
      class = S7::class_character,
      getter = function(self) names(self@streamline_data) %||% character(0L)
    ),
    bundle_attributes = S7::new_property(
      class = S7::class_character,
      getter = function(self) names(self@bundle_data) %||% character(0L)
    )
  ),
  validator = function(self) {
    # If elements of @streamlines are named, ensure there is no duplicate
    if (length(names(self@streamlines)) > 0) {
      if (
        length(names(self@streamlines)) !=
          length(unique(names(self@streamlines)))
      ) {
        return(cli::format_inline(
          "Some streamlines are named with duplicate names."
        ))
      }
    }
    # All elements of @streamlines must be streamline objects
    bad <- !vapply(self@streamlines, is_streamline, logical(1L))
    if (any(bad)) {
      return(
        cli::format_inline(
          "All elements of {.var @streamlines} must be {.fn fiber::streamline} objects."
        )
      )
    }
    n <- length(self@streamlines)
    # @streamline_data entries must be vectors of length n_streamlines
    for (nm in names(self@streamline_data)) {
      if (length(self@streamline_data[[nm]]) != n) {
        return(cli::format_inline(
          "@streamline_data[[\"{nm}\"]] must be a vector of length \\
             {n} (one entry per streamline)."
        ))
      }
    }
    # @bundle_data entries must be scalars (length 1)
    for (nm in names(self@bundle_data)) {
      if (length(self@bundle_data[[nm]]) != 1L) {
        return(cli::format_inline(
          "@bundle_data[[\"{nm}\"]] must be a scalar (length 1)."
        ))
      }
    }
    NULL
  },
  # Constructor with automatic lifting
  constructor = function(
    streamlines = list(),
    streamline_data = list(),
    bundle_data = list()
  ) {
    lifted_data <- .lift_streamline_data(streamlines)
    streamlines <- lifted_data$streamlines
    lifted_data <- lifted_data$lifted
    if (length(lifted_data) > 0) {
      nms <- names(lifted_data)
      for (nm in nms) {
        if (length(streamline_data) > 0) {
          if (nm %in% names(streamline_data)) {
            next
          }
        }
        streamline_data[[nm]] <- lifted_data[[nm]]
      }
    }
    S7::new_object(
      S7::S7_object(),
      streamlines = streamlines,
      streamline_data = streamline_data,
      bundle_data = bundle_data
    )
  }
)

# ---- predicate --------------------------------------------------------------

#' Test whether an object is a bundle
#'
#' @param x An object.
#' @returns `TRUE` if `x` is of class [bundle], otherwise `FALSE`.
#' @export
#' @examples
#' sl <- streamline(points = cbind(X = 1:5, Y = 1:5, Z = 1:5))
#' b <- bundle(streamlines = list(sl))
#' is_bundle(b)   # TRUE
#' is_bundle(sl)  # FALSE
is_bundle <- function(x) S7::S7_inherits(x, bundle)

# ---- format / print ---------------------------------------------------------

S7::method(format, bundle) <- function(x, ...) {
  n <- x@n_streamlines
  if (n == 0L) {
    return(cli::cli_fmt(
      {
        cli::cli_h2("Object of class {.fn fiber::bundle} with no streamline.")
      },
      collapse = TRUE
    ))
  }

  # Retrieve point attributes
  pd_keys <- unique(unlist(lapply(x@streamlines, function(sl) {
    sl@point_attributes
  })))
  # Retrieve streamline attributes
  sd_keys <- union(
    x@streamline_attributes,
    unique(unlist(lapply(x@streamlines, function(sl) sl@streamline_attributes)))
  )
  # Retrieve bundle attributes
  bd_keys <- x@bundle_attributes

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

  # Retrieve range of number of points across streamlines
  n_points_distr <- vapply(x@streamlines, function(sl) sl@n_points, integer(1L))
  n_points_range <- paste0(min(n_points_distr), "\u2013", max(n_points_distr))
  cli::cli_fmt(
    {
      cli::cli_h2(
        "Object of class {.fn fiber::bundle} with {n} streamlines{?s} and [{n_points_range}] points per streamline."
      )
      cli::cli_bullets(c("*" = pd_str, "*" = sd_str, "*" = bd_str))
    },
    collapse = TRUE
  )
}

S7::method(print, bundle) <- function(x, ...) {
  cat(format(x, ...), "\n")
  invisible(x)
}

# ---- length / indexing ------------------------------------------------------

S7::method(length, bundle) <- function(x) x@n_streamlines

S7::method(`[[`, bundle) <- function(x, i, ...) {
  # Resolve to a numeric position so we can index the unnamed data vectors
  pos <- .convert_bundle_subset(i, x)

  sl <- x@streamlines[[pos]]
  # Push bundle-level streamline_data[pos] back into the streamline
  for (k in x@streamline_attributes) {
    sl@streamline_data[[k]] <- x@streamline_data[[k]][[pos]]
  }
  sl
}

S7::method(`[`, bundle) <- function(x, i, j, ..., drop = TRUE) {
  # Resolve to numeric positions for indexing the unnamed data vectors
  pos <- .convert_bundle_subset(i, x)

  streamlines <- x@streamlines[pos]
  streamline_data <- lapply(x@streamline_data, function(v) unname(v[pos]))

  bundle(
    streamlines = streamlines,
    streamline_data = streamline_data,
    bundle_data = x@bundle_data
  )
}
