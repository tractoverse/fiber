library(fiber)

# ---- helpers ----------------------------------------------------------------

make_sl <- function(n = 5L) {
  pts <- as.numeric(seq_len(n))
  streamline(points = cbind(X = pts, Y = pts, Z = pts))
}

# ---- as_streamline ----------------------------------------------------------

sl <- make_sl()

# identity: as_streamline(streamline) returns the same object
expect_identical(as_streamline(sl), sl)

# as_streamline applied to a single-streamline bundle
b1 <- bundle(streamlines = list(sl))
result_sl <- as_streamline(b1)
expect_true(is_streamline(result_sl))
expect_identical(result_sl@points[, "X"], sl@points[, "X"])
expect_identical(result_sl@points[, "Y"], sl@points[, "Y"])
expect_identical(result_sl@points[, "Z"], sl@points[, "Z"])

# as_streamline on a multi-streamline bundle should error
b2 <- bundle(streamlines = list(sl, make_sl(4L)))
expect_error(as_streamline(b2))

# as_streamline on an unknown class should error
expect_error(as_streamline(42L))
expect_error(as_streamline("hello"))

# ---- as_bundle --------------------------------------------------------------

# wrapping: as_bundle(streamline) gives a 1-streamline bundle
b_from_sl <- as_bundle(sl)
expect_true(is_bundle(b_from_sl))
expect_equal(b_from_sl@n_streamlines, 1L)
expect_identical(b_from_sl[[1L]]@points[, "X"], sl@points[, "X"])

# identity: as_bundle(bundle) returns the same object
b_orig <- bundle(streamlines = list(sl))
expect_identical(as_bundle(b_orig), b_orig)

# as_bundle on an unknown class should error
expect_error(as_bundle(TRUE))

# ---- as_dwifiber (only when dti is available) -------------------------------

if (requireNamespace("dti", quietly = TRUE)) {
  rgl_use_null <- Sys.getenv("RGL_USE_NULL", unset = NA)
  Sys.setenv(RGL_USE_NULL = "true") # avoid rgl warnings

  # bundle -> dwiFiber and back
  sl1 <- make_sl(6L)
  sl2 <- make_sl(4L)
  b <- bundle(
    streamlines = list(sl1, sl2),
    bundle_data = list(
      method = "LINEPROP",
      minfa = 0.3,
      maxangle = 30,
      # voxelext stored as individual scalars under the new API
      voxelext_1 = 2,
      voxelext_2 = 2,
      voxelext_3 = 2
    )
  )

  dfi <- as_dwifiber(b)
  expect_true(is(dfi, "dwiFiber"))
  expect_equal(length(dfi@startind), 2L)
  expect_equal(dfi@method, "LINEPROP")
  expect_equal(dfi@minfa, 0.3)
  expect_equal(dfi@maxangle, 30)
  expect_equal(dfi@voxelext, c(2, 2, 2))

  # Round-trip: dwiFiber -> bundle -> dwiFiber
  b_rt <- as_bundle(dfi)
  expect_true(is_bundle(b_rt))
  expect_equal(b_rt@n_streamlines, 2L)

  # Coordinates are recovered correctly via @points
  expect_identical(b_rt[[1L]]@points[, "X"], sl1@points[, "X"])
  expect_identical(b_rt[[1L]]@points[, "Y"], sl1@points[, "Y"])
  expect_identical(b_rt[[1L]]@points[, "Z"], sl1@points[, "Z"])

  # as_dwifiber(streamline) same as wrapping in a bundle first
  dfi_sl <- as_dwifiber(sl1)
  expect_true(is(dfi_sl, "dwiFiber"))
  expect_equal(length(dfi_sl@startind), 1L)

  Sys.setenv(RGL_USE_NULL = rgl_use_null) # restore previous state
}
