library(fiber)

# ---- new_streamline ---------------------------------------------------------

# valid matrix
pts <- matrix(
  c(1, 2, 3, 4, 5, 6, 7, 8, 9),
  ncol = 3,
  dimnames = list(NULL, c("X", "Y", "Z"))
)
sl <- new_streamline(pts)
expect_true(is_streamline(sl))
expect_true(is.matrix(sl@points))

# not a matrix -> error
expect_error(new_streamline("not a matrix"))

# no colnames -> error
expect_error(new_streamline(matrix(1:9, ncol = 3)))

# missing required column names -> error
bad <- matrix(1:9, ncol = 3, dimnames = list(NULL, c("A", "B", "C")))
expect_error(new_streamline(bad))

# point_data length mismatch -> error
expect_error(new_streamline(pts, point_data = list(FA = c(0.1, 0.2))))

# streamline_data non-scalar -> error
expect_error(new_streamline(pts, streamline_data = list(weight = c(1, 2))))

# ---- with point_data and streamline_data ------------------------------------

sl_pd <- new_streamline(pts, point_data = list(FA = c(0.1, 0.2, 0.3)))
sl_sld <- new_streamline(pts, streamline_data = list(weight = 0.5))
sl_all <- new_streamline(
  pts,
  point_data = list(FA = c(0.1, 0.2, 0.3)),
  streamline_data = list(weight = 0.5)
)

expect_true(is_streamline(sl_pd))
expect_equal(sl_pd@point_data[["FA"]], c(0.1, 0.2, 0.3))
expect_equal(sl_sld@streamline_data[["weight"]], 0.5)
expect_equal(names(sl_all@point_data), "FA")
expect_equal(names(sl_all@streamline_data), "weight")

# ---- is_streamline ----------------------------------------------------------

expect_true(is_streamline(sl))
expect_false(is_streamline(pts))
expect_false(is_streamline(list()))

# ---- format.streamline ------------------------------------------------------

f <- format(sl)
expect_true(grepl("streamline", f))
expect_true(grepl("3 pts", f))

f_pd <- format(sl_pd)
expect_true(grepl("point: FA", f_pd))

f_all <- format(sl_all)
expect_true(grepl("point: FA", f_all))
expect_true(grepl("streamline: weight", f_all))

# ---- print.streamline -------------------------------------------------------

expect_stdout(print(sl), "streamline")
