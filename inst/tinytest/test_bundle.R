library(fiber)

# ---- helpers ----------------------------------------------------------------

sl <- streamline(points = cbind(X = 1:3, Y = 1:3, Z = 1:3))
sl_pd <- streamline(
  points = cbind(X = 1:3, Y = 1:3, Z = 1:3),
  point_data = list(FA = c(0.1, 0.2, 0.3))
)
sl_sld <- streamline(
  points = cbind(X = 1:3, Y = 1:3, Z = 1:3),
  streamline_data = list(weight = 0.5, label = "CST")
)
sl_sld2 <- streamline(
  points = cbind(X = 4:6, Y = 4:6, Z = 4:6),
  streamline_data = list(weight = 0.8, label = "CST")
)

# ---- bundle constructor -----------------------------------------------------

b <- bundle(streamlines = list(sl, sl_pd))
expect_true(is_bundle(b))

# non-list -> error
expect_error(bundle(streamlines = sl))

# list with non-streamline element -> error
expect_error(bundle(streamlines = list(sl, "not a streamline")))

# empty list is allowed (zero-streamline bundle)
b0 <- bundle(streamlines = list())
expect_true(is_bundle(b0))

# bundle_data must be scalars
expect_error(
  bundle(
    streamlines = list(sl),
    bundle_data = list(origin = c("a", "b"))
  )
)

# bundle_data scalar is stored
b_meta <- bundle(streamlines = list(sl), bundle_data = list(origin = "phantom"))
expect_equal(b_meta@bundle_data[["origin"]], "phantom")

# ---- automatic lifting of streamline_data -----------------------------------

# Both streamlines share 'weight' and 'label' -> lifted to bundle@streamline_data
b_lift <- bundle(streamlines = list(sl_sld, sl_sld2))
expect_equal(b_lift@streamline_attributes, c("weight", "label"))
expect_equal(b_lift@streamline_data[["weight"]], c(0.5, 0.8))
expect_equal(b_lift@streamline_data[["label"]], c("CST", "CST"))

# Non-overlapping keys: no lifting, but bundle must still be valid (#bug)
sl_sld_a <- streamline(
  points = cbind(X = 1:3, Y = 1:3, Z = 1:3),
  streamline_data = list(fa = 0.6)
)
sl_sld_b <- streamline(
  points = cbind(X = 4:6, Y = 4:6, Z = 4:6),
  streamline_data = list(md = 0.9)
)
b_nooverlap <- bundle(streamlines = list(sl_sld_a, sl_sld_b))
expect_true(is_bundle(b_nooverlap))
expect_equal(b_nooverlap@n_streamlines, 2L)
expect_equal(b_nooverlap@streamline_attributes, character(0L))
expect_equal(b_nooverlap@streamlines[[1L]]@streamline_data[["fa"]], 0.6)
expect_equal(b_nooverlap@streamlines[[2L]]@streamline_data[["md"]], 0.9)

# Explicit streamline_data overrides automatic lifting
b_explicit <- bundle(
  streamlines = list(sl_sld, sl_sld2),
  streamline_data = list(weight = c(1.0, 2.0))
)
expect_equal(b_explicit@streamline_data[["weight"]], c(1.0, 2.0))

# streamline_data entry wrong length -> error
expect_error(
  bundle(
    streamlines = list(sl, sl_pd),
    streamline_data = list(fa = c(0.1)) # length 1, but 2 streamlines
  )
)

# ---- is_bundle --------------------------------------------------------------

expect_true(is_bundle(b))
expect_false(is_bundle(sl))
expect_false(is_bundle(list(sl)))

# ---- format.bundle ----------------------------------------------------------

f0 <- format(b0)
expect_true(grepl("no streamline", f0))

b_plain <- bundle(streamlines = list(sl, sl))
fp <- format(b_plain)
expect_true(grepl("streamline", fp))

b_pd_bundle <- bundle(streamlines = list(sl_pd, sl_pd))
fp_pd <- format(b_pd_bundle)
expect_true(grepl("FA", fp_pd))

b_all <- bundle(streamlines = list(sl_sld, sl_sld))
fp_all <- format(b_all)
expect_true(grepl("weight", fp_all))
expect_true(grepl("label", fp_all))

# ---- print.bundle -----------------------------------------------------------

expect_stdout(print(b_plain), "streamline")

# ---- length.bundle ----------------------------------------------------------

expect_equal(length(b), 2L)
expect_equal(length(b0), 0L)

# ---- indexing ---------------------------------------------------------------

expect_true(is_streamline(b@streamlines[[1L]]))

# [[ pushes bundle@streamline_data back into the returned streamline
expect_true(is_streamline(b_lift[[1L]]))
expect_equal(b_lift[[1L]]@streamline_data[["weight"]], 0.5)
expect_equal(b_lift[[2L]]@streamline_data[["weight"]], 0.8)

# [ returns a bundle with subset of @streamline_data
b_sub <- b_lift[1L]
expect_true(is_bundle(b_sub))
expect_equal(b_sub@n_streamlines, 1L)
expect_equal(b_sub@streamline_data[["weight"]], c(0.5))
# Pushed back into the extracted streamline
expect_equal(b_sub[[1L]]@streamline_data[["weight"]], 0.5)

# [ preserves @bundle_data
b_sub_meta <- b_meta[1L]
expect_equal(b_sub_meta@bundle_data[["origin"]], "phantom")

# ---- bundle_attributes getter -----------------------------------------------

expect_equal(b@bundle_attributes, character(0L))
b_attr <- bundle(streamlines = list(sl), bundle_data = list(a = 1, b = 2))
expect_equal(b_attr@bundle_attributes, c("a", "b"))

# ---- format with bundle_data ------------------------------------------------

b_bd <- bundle(streamlines = list(sl), bundle_data = list(origin = "test"))
f_bd <- format(b_bd)
expect_true(grepl("origin", f_bd))
