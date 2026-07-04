library(fiber)

make_sl <- function(n = 3L) {
  streamline(
    points = cbind(
      X = as.numeric(seq_len(n)),
      Y = as.numeric(seq_len(n)),
      Z = as.numeric(seq_len(n))
    )
  )
}

sl <- make_sl(3L)

# ---- reparametrize: streamline ----------------------------------------------

# default n_points (same as input)
sl_r <- reparametrize(sl)
expect_true(is_streamline(sl_r))
expect_equal(sl_r@n_points, sl@n_points)

# explicit n_points
sl_r10 <- reparametrize(sl, n_points = 10L)
expect_equal(sl_r10@n_points, 10L)
# @points has 10 rows and 3 columns
expect_equal(nrow(sl_r10@points), 10L)
expect_equal(ncol(sl_r10@points), 3L)

# n_points < 2 -> error
expect_error(reparametrize(sl, n_points = 1L))

# preserves numeric point_data via interpolation
sl_pd <- streamline(
  points = cbind(X = 1:3, Y = 1:3, Z = 1:3),
  point_data = list(FA = c(0.1, 0.2, 0.3))
)
sl_pd_r <- reparametrize(sl_pd, n_points = 5L)
expect_equal(length(sl_pd_r@point_data$FA), 5L)

# numeric extra point_data entries are interpolated
sl_extra <- streamline(
  points = cbind(X = 1:3, Y = 1:3, Z = 1:3),
  point_data = list(W = c(1.0, 2.0, 3.0))
)
sl_extra_r <- reparametrize(sl_extra, n_points = 5L)
expect_equal(length(sl_extra_r@point_data$W), 5L)

# streamline_data is preserved
sl_sld <- streamline(
  points = cbind(X = 1:3, Y = 1:3, Z = 1:3),
  streamline_data = list(weight = 0.5)
)
sl_sld_r <- reparametrize(sl_sld, n_points = 5L)
expect_equal(sl_sld_r@streamline_data[["weight"]], 0.5)

# ---- reparametrize: bundle --------------------------------------------------

sl2 <- make_sl(10L)
b <- bundle(streamlines = list(sl, sl2))

# default n_points (rounded mean)
b_r <- reparametrize(b)
expect_true(is_bundle(b_r))
expect_equal(length(b_r@streamlines), 2L)

# explicit n_points
b_r5 <- reparametrize(b, n_points = 5L)
expect_equal(b_r5[[1L]]@n_points, 5L)
expect_equal(b_r5[[2L]]@n_points, 5L)

# empty bundle returns unchanged
b0 <- bundle(streamlines = list())
b0_r <- reparametrize(b0)
expect_equal(b0_r@n_streamlines, 0L)

# bundle@streamline_data is preserved through reparametrization
sl_a <- streamline(
  points = cbind(X = 1:3, Y = 1:3, Z = 1:3),
  streamline_data = list(weight = 0.5)
)
sl_b <- streamline(
  points = cbind(X = 4:8, Y = 4:8, Z = 4:8),
  streamline_data = list(weight = 0.7)
)
b_sld <- bundle(streamlines = list(sl_a, sl_b))
b_sld_r <- reparametrize(b_sld, n_points = 4L)
expect_equal(b_sld_r@streamline_data[["weight"]], c(0.5, 0.7))

# ---- bind_bundles ------------------------------------------------------------

sl1 <- make_sl(3L)
sl3 <- make_sl(5L)
b1 <- bundle(streamlines = list(sl1), bundle_data = list(origin = "A"))
b2 <- bundle(streamlines = list(sl3))

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

# explicit streamline_data is passed through
b_sld_bind <- bind_bundles(b1, b2, streamline_data = list(fa = c(0.5, 0.6)))
expect_equal(b_sld_bind@streamline_data[["fa"]], c(0.5, 0.6))

# no arguments -> error
expect_error(bind_bundles())

# invalid argument -> error
expect_error(bind_bundles(b1, "not_valid"))
