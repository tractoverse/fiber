library(fiber)

set.seed(42)
n <- 10L
make_sl <- function(n = 10L) {
  streamline(
    points = cbind(
      X = runif(n),
      Y = runif(n),
      Z = runif(n)
    )
  )
}
sl1 <- make_sl()
sl2 <- make_sl()
b <- bundle(streamlines = list(sl1, sl2))

not_sl <- list(1, 2, 3)

# ---- get_euclidean_length ---------------------------------------------------

el <- get_euclidean_length(sl1)
expect_true(is.numeric(el) && length(el) == 1L && el >= 0)
expect_error(get_euclidean_length(not_sl))

# ---- get_curvilinear_length -------------------------------------------------

cl <- get_curvilinear_length(sl1)
expect_true(is.numeric(cl) && length(cl) == 1L && cl >= 0)
expect_error(get_curvilinear_length(not_sl))

# curvilinear >= euclidean
expect_true(cl >= el)

# ---- get_sinuosity ----------------------------------------------------------

sin_val <- get_sinuosity(sl1)
expect_true(is.numeric(sin_val) && sin_val >= 1)
expect_error(get_sinuosity(not_sl))

# ---- get_curvature ----------------------------------------------------------

curv <- get_curvature(sl1)
expect_equal(length(curv), sl1@n_points)
expect_true(all(curv >= 0))
expect_error(get_curvature(not_sl))

# ---- get_torsion ------------------------------------------------------------

tors <- get_torsion(sl1)
expect_equal(length(tors), sl1@n_points)
expect_true(is.numeric(tors))
expect_error(get_torsion(not_sl))

# ---- add_shape_descriptors: streamline --------------------------------------

sl_desc <- add_shape_descriptors(
  sl1,
  descriptors = c("euclidean_length", "curvilinear_length", "sinuosity")
)
expect_true(is_streamline(sl_desc))
expect_true(!is.null(sl_desc@streamline_data$euclidean_length))
expect_true(!is.null(sl_desc@streamline_data$curvilinear_length))
expect_true(!is.null(sl_desc@streamline_data$sinuosity))

# curvature and torsion go into point_data
sl_desc2 <- add_shape_descriptors(sl1, descriptors = c("curvature", "torsion"))
expect_equal(length(sl_desc2@point_data$curvature), sl1@n_points)
expect_equal(length(sl_desc2@point_data$torsion), sl1@n_points)

# unknown descriptor emits a warning
expect_warning(add_shape_descriptors(sl1, descriptors = "unknown_desc"))

# ---- add_shape_descriptors: bundle ------------------------------------------

b_desc <- add_shape_descriptors(
  b,
  descriptors = c("euclidean_length", "curvilinear_length", "sinuosity")
)
expect_true(is_bundle(b_desc))
# Scalar descriptors are stored in bundle@streamline_data as length-S vectors
expect_equal(length(b_desc@streamline_data$euclidean_length), 2L)
expect_equal(length(b_desc@streamline_data$curvilinear_length), 2L)
# [[ push-down makes them accessible on individual streamlines
expect_true(!is.null(b_desc[[1L]]@streamline_data$euclidean_length))
expect_true(!is.null(b_desc[[2L]]@streamline_data$euclidean_length))

# Per-point descriptors on bundle
b_pt <- add_shape_descriptors(b, descriptors = c("curvature", "torsion"))
expect_equal(length(b_pt@streamlines[[1L]]@point_data$curvature), sl1@n_points)

# ---- compute_hausdorff_distance: streamline x streamline --------------------

d_sl <- compute_hausdorff_distance(sl1, sl2)
expect_true(is.numeric(d_sl) && length(d_sl) == 1L && d_sl >= 0)

# y not a streamline when x is streamline -> error
expect_error(compute_hausdorff_distance(sl1, not_sl))
expect_error(compute_hausdorff_distance(sl1))

# ---- compute_hausdorff_distance: bundle x missing ---------------------------

d_b <- compute_hausdorff_distance(b)
expect_true(inherits(d_b, "dist"))
expect_equal(attr(d_b, "Size"), 2L)

# as.matrix gives 2x2
dm <- as.matrix(d_b)
expect_equal(dim(dm), c(2L, 2L))
expect_equal(dm[1L, 1L], 0)

# ---- compute_hausdorff_distance: bundle x streamline ------------------------

d_bsl <- compute_hausdorff_distance(b, sl1)
expect_equal(length(d_bsl), 2L)
expect_true(all(d_bsl >= 0))

# ---- compute_hausdorff_distance: bundle x bundle ----------------------------

b2 <- bundle(streamlines = list(sl2))
d_bb <- compute_hausdorff_distance(b, b2)
expect_true(inherits(d_bb, "dist"))
expect_equal(attr(d_bb, "Size"), 3L)

# ---- compute_hausdorff_distance: invalid y type ----------------------------

expect_error(compute_hausdorff_distance(b, not_sl))

# ---- compute_hausdorff_distance: catch-all (non-streamline/bundle x) -------

expect_error(compute_hausdorff_distance(42))
