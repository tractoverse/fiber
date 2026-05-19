library(fiber)

# ---- bundle constructor -----------------------------------------------------

# valid matrix
pts <- matrix(
  c(1, 2, 3, 4, 5, 6, 7, 8, 9),
  ncol = 3,
  dimnames = list(NULL, c("X", "Y", "Z"))
)
sl <- streamline(pts)
sl_pd <- streamline(pts, point_data = list(FA = c(0.1, 0.2, 0.3)))
sl_all <- streamline(
  pts,
  point_data = list(FA = c(0.1, 0.2, 0.3)),
  streamline_data = list(weight = 0.5)
)

b <- bundle(list(sl, sl_pd))
expect_true(is_bundle(b))

# non-list -> error
expect_error(bundle(sl))

# list with non-streamline element -> error
expect_error(bundle(list(sl, "not a streamline")))

# empty list is allowed (zero-streamline bundle)
b0 <- bundle(list())
expect_true(is_bundle(b0))

# bundle_data is stored
b_meta <- bundle(list(sl), bundle_data = list(origin = "phantom"))
expect_equal(b_meta@bundle_data[["origin"]], "phantom")

# ---- is_bundle --------------------------------------------------------------

expect_true(is_bundle(b))
expect_false(is_bundle(sl))
expect_false(is_bundle(list(sl)))

# ---- format.bundle ----------------------------------------------------------

f0 <- format(b0)
expect_true(grepl("0 streamlines", f0))

b_plain <- bundle(list(sl, sl))
fp <- format(b_plain)
expect_true(grepl("streamlines", fp))

b_pd <- bundle(list(sl_pd, sl_pd))
fp_pd <- format(b_pd)
expect_true(grepl("point: FA", fp_pd))

b_all <- bundle(list(sl_all, sl_all))
fp_all <- format(b_all)
expect_true(grepl("point: FA", fp_all))
expect_true(grepl("streamline: weight", fp_all))

# ---- print.bundle -----------------------------------------------------------

expect_stdout(print(b_plain), "streamlines")

# ---- length.bundle ----------------------------------------------------------

expect_equal(length(b), 2L)
expect_equal(length(b0), 0L)

# ---- indexing ---------------------------------------------------------------

expect_true(is_streamline(b@streamlines[[1L]]))

# [[ extracts a streamline via S7 method
expect_true(is_streamline(b[[1L]]))

# [ returns a bundle (subset) preserving bundle_data
b_sub <- b_meta[1L]
expect_true(is_bundle(b_sub))
expect_equal(b_sub@bundle_data[["origin"]], "phantom")
expect_equal(b_sub@n_streamlines, 1L)

# ---- bundle_attributes getter -----------------------------------------------

expect_null(b@bundle_attributes)
b_attr <- bundle(list(sl), bundle_data = list(a = 1, b = 2))
expect_equal(b_attr@bundle_attributes, c("a", "b"))

# ---- format with bundle_data ------------------------------------------------

b_bd <- bundle(list(sl), bundle_data = list(origin = "test"))
fb_bd <- format(b_bd)
expect_true(grepl("bundle: origin", fb_bd))
