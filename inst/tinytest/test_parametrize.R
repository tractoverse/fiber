library(fiber)

pts <- matrix(
  c(1, 2, 3, 4, 5, 6, 7, 8, 9),
  ncol = 3,
  dimnames = list(NULL, c("X", "Y", "Z"))
)
sl <- streamline(pts)

# ---- reparametrize: streamline ----------------------------------------------

# default n_points (same as input)
sl_r <- reparametrize(sl)
expect_true(is_streamline(sl_r))
expect_equal(sl_r@n_points, sl@n_points)

# explicit n_points
sl_r10 <- reparametrize(sl, n_points = 10L)
expect_equal(sl_r10@n_points, 10L)

# n_points < 2 -> error
expect_error(reparametrize(sl, n_points = 1L))

# preserves point_data via interpolation
sl_pd <- streamline(pts, point_data = list(FA = c(0.1, 0.2, 0.3)))
sl_pd_r <- reparametrize(sl_pd, n_points = 5L)
expect_equal(length(sl_pd_r@point_data$FA), 5L)

# extra columns in points matrix are preserved
pts_extra <- cbind(pts, W = c(1.0, 2.0, 3.0))
colnames(pts_extra) <- c("X", "Y", "Z", "W")
sl_extra <- streamline(pts_extra)
sl_extra_r <- reparametrize(sl_extra, n_points = 5L)
expect_true("W" %in% colnames(sl_extra_r@points))

# ---- reparametrize: bundle --------------------------------------------------

pts2 <- matrix(runif(30), ncol = 3, dimnames = list(NULL, c("X", "Y", "Z")))
sl2 <- streamline(pts2)
b <- bundle(list(sl, sl2))

# default n_points (rounded mean)
b_r <- reparametrize(b)
expect_true(is_bundle(b_r))
expect_equal(length(b_r@streamlines), 2L)

# explicit n_points
b_r5 <- reparametrize(b, n_points = 5L)
expect_equal(b_r5[[1L]]@n_points, 5L)
expect_equal(b_r5[[2L]]@n_points, 5L)

# empty bundle returns unchanged
b0 <- bundle(list())
b0_r <- reparametrize(b0)
expect_equal(b0_r@n_streamlines, 0L)

# ---- bind_bundles ------------------------------------------------------------

sl1 <- streamline(pts)
sl3 <- streamline(pts2)
b1 <- bundle(list(sl1), bundle_data = list(origin = "A"))
b2 <- bundle(list(sl3))

# two bundles: preserves first bundle's bundle_data
b_all <- bind_bundles(b1, b2)
expect_true(is_bundle(b_all))
expect_equal(b_all@n_streamlines, 2L)
expect_equal(b_all@bundle_data[["origin"]], "A")

# mix bundle and streamline
b_mixed <- bind_bundles(b1, sl3)
expect_equal(b_mixed@n_streamlines, 2L)

# explicit bundle_data overrides
b_override <- bind_bundles(b1, b2, bundle_data = list(origin = "override"))
expect_equal(b_override@bundle_data[["origin"]], "override")

# no arguments -> error
expect_error(bind_bundles())

# invalid argument -> error
expect_error(bind_bundles(b1, "not_valid"))
