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

# ---- add_shape_descriptors: bundle_set --------------------------------------

bs_desc <- add_shape_descriptors(
  bundle_set(bundles = list(b, b)),
  descriptors = c("euclidean_length", "sinuosity", "curvature")
)
expect_true(inherits(bs_desc, "fiber::bundle_set"))
# Scalar descriptors land in each bundle's @streamline_data (length-S vectors)
expect_equal(length(bs_desc@bundles[[1L]]@streamline_data$euclidean_length), 2L)
# Per-point descriptors land in each streamline's @point_data
expect_equal(
  length(bs_desc@bundles[[1L]]@streamlines[[1L]]@point_data$curvature),
  sl1@n_points
)
# bundle_data / bundle_set_data preserved
bs_orig <- bundle_set(
  bundles = list(b, b),
  bundle_data = list(subject = c("a", "b"))
)
bs_desc2 <- add_shape_descriptors(bs_orig, descriptors = "euclidean_length")
expect_equal(bs_desc2@bundle_data, list(subject = c("a", "b")))

# unknown descriptor on a bundle emits a warning
expect_warning(add_shape_descriptors(b, descriptors = "unknown_desc"))

# empty bundle_set returns unchanged
bs_empty <- bundle_set(bundles = list())
expect_identical(add_shape_descriptors(bs_empty), bs_empty)

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

# ---- integer-coordinate streamlines ---------------------------------------

# @points may be stored as an integer matrix when constructed from integer
# vectors (e.g. X = 1:4). This used to crash hausdorff_distance_cpp() because
# cpp11's doubles_matrix<> requires double (REALSXP) input; .get_coords() now
# coerces to double, so integer-coordinate streamlines work everywhere.
sl_int <- streamline(points = cbind(X = 1:5, Y = 1:5, Z = 1:5))
expect_true(is.numeric(get_euclidean_length(sl_int)))
expect_true(is.numeric(get_curvilinear_length(sl_int)))
d_int <- compute_hausdorff_distance(sl_int, sl_int)
expect_true(is.numeric(d_int) && length(d_int) == 1L && d_int == 0)
b_int <- bundle(streamlines = list(sl_int, sl_int))
d_bint <- compute_hausdorff_distance(b_int)
expect_equal(attr(d_bint, "Size"), 2L)
