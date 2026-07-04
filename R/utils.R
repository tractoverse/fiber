# ---- internal helpers -------------------------------------------------------

# Null-coalescing operator
`%||%` <- function(x, y) if (is.null(x)) y else x

# Euclidean distance between two length-3 numeric vectors
.dist3 <- function(p, q) sqrt(sum((p - q)^2L))

# Interpolate a numeric vector y measured at abscissa s onto new abscissa s_new
.approx1 <- function(s, y, s_new) stats::approx(s, y, xout = s_new)$y

# Compute cumulative arc-length abscissa for an n x 3 coordinate matrix.
# Returns a numeric vector of length n with s[1] == 0.
.arc_length <- function(pts) {
  diffs <- diff(pts)
  seg_len <- sqrt(rowSums(diffs^2L))
  c(0, cumsum(seg_len))
}

# Extract the n x 3 coordinate matrix from a streamline's @points slot.
.get_coords <- function(sl) sl@points

# ---- internal: lift streamline_data -----------------------------------------

# Gather @streamline_data keys that are present in *all* streamlines and
# collect them into vectors of length S.
.lift_streamline_data <- function(streamlines) {
  if (length(streamlines) == 0L) {
    return(list(lifted = list(), streamlines = streamlines))
  }
  # Find keys present in every streamline
  all_keys <- lapply(streamlines, function(sl) sl@streamline_attributes)
  common_keys <- Reduce(intersect, all_keys)
  if (length(common_keys) == 0L) {
    return(list(lifted = list(), streamlines = streamlines))
  }
  # Build a named list of length-S vectors
  lifted <- vector("list", length(common_keys))
  names(lifted) <- common_keys
  for (k in common_keys) {
    lifted[[k]] <- unname(vapply(
      streamlines,
      function(sl) sl@streamline_data[[k]],
      FUN.VALUE = streamlines[[1L]]@streamline_data[[k]]
    ))
  }
  # Remove common keys from individual streamlines
  for (i in seq_along(streamlines)) {
    for (k in common_keys) {
      streamlines[[i]]@streamline_data[[k]] <- NULL
    }
  }
  # Return both the lifted list and the modified streamlines
  list(lifted = lifted, streamlines = streamlines)
}

# ---- internal: lift bundle_data ---------------------------------------------

# Gather @bundle_data keys that are present in *all* bundles and are scalars,
# then collect them into vectors of length B.
.lift_bundle_data <- function(bundles) {
  if (length(bundles) == 0L) {
    return(list(lifted = list(), bundles = bundles))
  }
  # Find keys present in every bundle
  all_keys <- lapply(bundles, function(b) b@bundle_attributes)
  common_keys <- Reduce(intersect, all_keys)
  if (length(common_keys) == 0L) {
    return(list(lifted = list(), bundles = bundles))
  }
  # Build a named list of length-B vectors
  lifted <- vector("list", length(common_keys))
  names(lifted) <- common_keys
  for (k in common_keys) {
    lifted[[k]] <- unname(vapply(
      bundles,
      function(b) b@bundle_data[[k]],
      FUN.VALUE = bundles[[1L]]@bundle_data[[k]]
    ))
  }
  # Remove common keys from individual bundles
  for (i in seq_along(bundles)) {
    for (k in common_keys) {
      bundles[[i]]@bundle_data[[k]] <- NULL
    }
  }
  # Return both the lifted list and the modified bundles
  list(lifted = lifted, bundles = bundles)
}

.convert_bundle_subset <- function(i, x) {
  if (is.character(i)) {
    cli::cli_abort(
      "You cannot subset a bundle with character values because named streamlines are not allowed."
    )
  }

  pos <- as.integer(i)

  if (max(abs(pos)) > x@n_streamlines) {
    cli::cli_abort(
      "The subset contain elements outside the range of the original bundle."
    )
  }

  pos
}

.convert_bundle_set_subset <- function(i, x) {
  pos <- if (is.character(i)) {
    if (!("id_from_input_names" %in% x@bundle_attributes)) {
      cli::cli_abort(
        "You cannot subset with character values if {.val id_from_input_names} is not part of the {.var @bundle_attributes}."
      )
    }
    if (!all(i %in% x@bundle_data$id_from_input_names)) {
      cli::cli_abort(
        "At least one of the subset character values is not present in {.var @bundle_data$id_from_input_names}."
      )
    }
    match(i, x@bundle_data$id_from_input_names)
  } else {
    as.integer(i)
  }

  if (max(abs(pos)) > x@n_bundles) {
    cli::cli_abort(
      "The subset contain elements outside the range of the original bundle set."
    )
  }

  pos
}
