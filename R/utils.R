# ---- internal helpers -------------------------------------------------------

# Euclidean distance between two length-3 numeric vectors
.dist3 <- function(p, q) sqrt(sum((p - q)^2L))

# One-directional Hausdorff component: for each point in mat_a (n x 3),
# find the distance to the nearest point in mat_b (m x 3), then take the max.
.directed_hausdorff <- function(mat_a, mat_b) {
  max(apply(mat_a, 1L, function(p) {
    min(apply(mat_b, 1L, function(q) .dist3(p, q)))
  }))
}

# Interpolate a numeric vector y measured at abscissa s onto new abscissa s_new
.approx1 <- function(s, y, s_new) stats::approx(s, y, xout = s_new)$y

# Compute cumulative arc-length abscissa for an n x 3 coordinate matrix.
# Returns a numeric vector of length n with s[1] == 0.
.arc_length <- function(pts) {
  diffs <- diff(pts)
  seg_len <- sqrt(rowSums(diffs^2L))
  c(0, cumsum(seg_len))
}
