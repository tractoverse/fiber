# ---- bind_bundles ------------------------------------------------------------

#' Combine streamlines and/or bundles into a single bundle
#'
#' Accepts any mix of [streamline] and [bundle] objects. All streamlines are
#' collected into a flat list and wrapped in a new [bundle]. `bundle_data`
#' from the first [bundle] argument (if any) is preserved; pass your own via
#' the `bundle_data` argument to override. Similarly for `streamline_data`.
#'
#' @param ... One or more [streamline] or [bundle] objects.
#' @param streamline_data A named list of per-streamline vectors to attach to
#'   the resulting [bundle]. Defaults to the `@streamline_data` of the first
#'   [bundle] input if one is present.
#' @param bundle_data A named list of bundle-level scalar metadata to attach to
#'   the resulting [bundle]. Defaults to an empty list (or the `bundle_data` of
#'   the first [bundle] input if one is present and `bundle_data` is not
#'   supplied).
#' @returns A [bundle] containing all input streamlines.
#' @export
#' @examples
#' sl1 <- streamline(points = cbind(X = runif(5), Y = runif(5), Z = runif(5)))
#' sl2 <- streamline(points = cbind(X = runif(5), Y = runif(5), Z = runif(5)))
#' b1 <- bundle(streamlines = list(sl1))
#' b2 <- bundle(streamlines = list(sl2))
#'
#' # combine two bundles
#' b_all <- bind_bundles(b1, b2)
#' b_all@n_streamlines  # 2
#'
#' # mix a bundle and a loose streamline
#' b_mixed <- bind_bundles(b1, sl2)
#' b_mixed@n_streamlines  # 2
bind_bundles <- function(..., streamline_data = NULL, bundle_data = NULL) {
  inputs <- list(...)
  if (length(inputs) == 0L) {
    cli::cli_abort("At least one argument is required.")
  }

  all_streamlines <- list()
  all_streamline_data <- list()
  first_bd <- list()
  found_bundle <- FALSE

  all_streamline_data_attrs <- if (is.null(streamline_data)) {
    character()
  } else {
    names(streamline_data)
  }
  if (is.null(streamline_data)) {
    # Form it by lifting @streamline_data from inputs
    for (i in seq_along(inputs)) {
      obj <- inputs[[i]]
      if (is_streamline(obj) || is_bundle(obj)) {
        all_streamline_data_attrs <- c(
          all_streamline_data_attrs,
          obj@streamline_attributes
        )
      } else {
        cli::cli_abort(
          "Each argument must be a {.cls fiber::streamline} or a \\
         {.cls fiber::bundle}."
        )
      }
    }
  }
  all_streamline_data_attrs <- unique(all_streamline_data_attrs)

  for (obj in inputs) {
    if (is_streamline(obj)) {
      all_streamlines <- c(all_streamlines, list(obj))
      cur_streamline_data_attrs <- obj@streamline_attributes
      for (all_nm in cur_streamline_data_attrs) {
        if (all_nm %in% cur_streamline_data_attrs) {
          all_streamline_data[[all_nm]] <- c(
            all_streamline_data[[all_nm]],
            obj@streamline_data[[all_nm]]
          )
        } else {
          all_streamline_data[[all_nm]] <- c(all_streamline_data[[all_nm]], NA)
        }
      }
    } else if (is_bundle(obj)) {
      all_streamlines <- c(all_streamlines, obj@streamlines)
      cur_streamline_data_attrs <- obj@streamline_attributes
      for (all_nm in cur_streamline_data_attrs) {
        if (all_nm %in% cur_streamline_data_attrs) {
          all_streamline_data[[all_nm]] <- c(
            all_streamline_data[[all_nm]],
            obj@streamline_data[[all_nm]]
          )
        } else {
          all_streamline_data[[all_nm]] <- c(
            all_streamline_data[[all_nm]],
            rep(NA, obj@n_streamlines)
          )
        }
      }
      if (!found_bundle) {
        first_bd <- obj@bundle_data
        found_bundle <- TRUE
      }
    } else {
      cli::cli_abort(
        "Each argument must be a {.cls fiber::streamline} or {.cls fiber::bundle}."
      )
    }
  }

  sd <- if (!is.null(streamline_data)) streamline_data else all_streamline_data
  bd <- if (!is.null(bundle_data)) bundle_data else first_bd
  bundle(streamlines = all_streamlines, streamline_data = sd, bundle_data = bd)
}

# ---- bind_bundle_sets -------------------------------------------------------

#' Combine bundles and/or bundle_sets into a single bundle_set
#'
#' Accepts any mix of [bundle] objects or [bundle_set] objects. All bundles are
#' collected into a flat list and wrapped in a new [bundle_set]. Bare [bundle]
#' arguments may optionally be named; unnamed bundles are included without a
#' name label.
#'
#' @param ... [bundle] objects or [bundle_set] objects to combine. Named bare
#'   [bundle] arguments will carry their name into the resulting set.
#' @param bundle_data A named list of per-bundle vectors to attach to the
#'   resulting [bundle_set]. Defaults to the `@bundle_data` of the first
#'   [bundle_set] input if present.
#' @param set_data A named list of set-level scalar metadata to attach to the
#'   resulting [bundle_set]. Defaults to the `set_data` of the first
#'   [bundle_set] input (if present) or an empty list.
#' @returns A [bundle_set] containing all input bundles.
#' @export
#' @examples
#' sl <- streamline(points = cbind(X = runif(5), Y = runif(5), Z = runif(5)))
#' b1 <- bundle(streamlines = list(sl))
#' b2 <- bundle(streamlines = list(sl))
#'
#' # two named bare bundles
#' bs <- bind_bundle_sets("sub-01" = b1, "sub-02" = b2)
#' bs@n_bundles   # 2
#' bs@bundle_data$if_from_input_list  # c("sub-01", "sub-02")
#'
#' # combine two bundle_sets
#' bs1 <- bundle_set(list("sub-01" = b1))
#' bs2 <- bundle_set(list("sub-02" = b2))
#' bs_all <- bind_bundle_sets(bs1, bs2)
#' bs_all@n_bundles  # 2
bind_bundle_sets <- function(..., bundle_data = NULL, set_data = NULL) {
  inputs <- list(...)
  if (length(inputs) == 0L) {
    cli::cli_abort("At least one argument is required.")
  }

  all_bundles <- list()
  all_bundle_data <- list()
  first_sd <- list()
  found_set <- FALSE

  all_bundle_data_attrs <- if (is.null(bundle_data)) {
    character()
  } else {
    names(bundle_data)
  }
  if (is.null(bundle_data)) {
    # Form it by lifting @bundle_data from inputs
    for (i in seq_along(inputs)) {
      obj <- inputs[[i]]
      if (is_bundle(obj) || is_bundle_set(obj)) {
        all_bundle_data_attrs <- c(all_bundle_data_attrs, obj@bundle_attributes)
      } else {
        cli::cli_abort(
          "Each argument must be a {.cls fiber::bundle} or a \\
         {.cls fiber::bundle_set}."
        )
      }
    }
  }
  all_bundle_data_attrs <- unique(all_bundle_data_attrs)

  for (i in seq_along(inputs)) {
    obj <- inputs[[i]]
    if (is_bundle(obj)) {
      all_bundles <- c(all_bundles, list(obj))
      cur_bundle_data_attrs <- obj@bundle_attributes
      for (all_nm in all_bundle_data_attrs) {
        if (all_nm %in% cur_bundle_data_attrs) {
          all_bundle_data[[all_nm]] <- c(
            all_bundle_data[[all_nm]],
            obj@bundle_data[[all_nm]]
          )
        } else {
          all_bundle_data[[all_nm]] <- c(all_bundle_data[[all_nm]], NA)
        }
      }
    } else if (is_bundle_set(obj)) {
      new_bds <- obj@bundles
      if (length(new_bds) > 0L) {
        all_bundles <- c(all_bundles, new_bds)
        cur_bundle_data_attrs <- obj@bundle_attributes
        for (all_nm in all_bundle_data_attrs) {
          if (all_nm %in% cur_bundle_data_attrs) {
            all_bundle_data[[all_nm]] <- c(
              all_bundle_data[[all_nm]],
              obj@bundle_data[[all_nm]]
            )
          } else {
            all_bundle_data[[all_nm]] <- c(
              all_bundle_data[[all_nm]],
              rep(NA, obj@n_bundles)
            )
          }
        }
      }
      if (!found_set) {
        first_sd <- obj@set_data
        found_set <- TRUE
      }
    } else {
      cli::cli_abort(
        "Each argument must be a {.cls fiber::bundle} or a \\
         {.cls fiber::bundle_set}."
      )
    }
  }

  bd <- if (!is.null(bundle_data)) bundle_data else all_bundle_data
  sd <- if (!is.null(set_data)) set_data else first_sd
  bundle_set(bundles = all_bundles, bundle_data = bd, set_data = sd)
}
