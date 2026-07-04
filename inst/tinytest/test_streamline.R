library(fiber)

# ---- streamline constructor -------------------------------------------------

# Minimal valid streamline: Px3 numeric matrix with colnames X, Y, Z
sl <- streamline(points = cbind(X = 1:3, Y = 4:6, Z = 7:9))
expect_true(is_streamline(sl))
expect_equal(sl@n_points, 3L)

# Missing @points -> error
expect_error(streamline(points = cbind(X = 1:3, Y = 4:6)))
expect_error(streamline(points = matrix(numeric(0), ncol = 2)))

# Non-numeric matrix -> error
expect_error(
  streamline(
    points = matrix(
      c("a", "b", "c", "d", "e", "f", "g", "h", "i"),
      ncol = 3,
      dimnames = list(NULL, c("X", "Y", "Z"))
    )
  )
)

# Wrong column names -> error
expect_error(
  streamline(points = cbind(A = 1:3, B = 1:3, C = 1:3))
)

# point_data entry of wrong length -> error
expect_error(
  streamline(
    points = cbind(X = 1:3, Y = 1:3, Z = 1:3),
    point_data = list(FA = c(0.1, 0.2))
  )
)

# Non-numeric point_data -> error
expect_error(
  streamline(
    points = cbind(X = 1:3, Y = 1:3, Z = 1:3),
    point_data = list(label = c("a", "b", "c"))
  )
)

# streamline_data non-scalar -> error
expect_error(
  streamline(
    points = cbind(X = 1:3, Y = 1:3, Z = 1:3),
    streamline_data = list(weight = c(1, 2))
  )
)

# Non-numeric streamline_data scalar is valid
sl_chr <- streamline(
  points = cbind(X = 1:3, Y = 1:3, Z = 1:3),
  streamline_data = list(label = "CST")
)
expect_true(is_streamline(sl_chr))
expect_equal(sl_chr@streamline_data[["label"]], "CST")

# ---- with point_data and streamline_data ------------------------------------

sl_pd <- streamline(
  points = cbind(X = 1:3, Y = 1:3, Z = 1:3),
  point_data = list(FA = c(0.1, 0.2, 0.3))
)
sl_sld <- streamline(
  points = cbind(X = 1:3, Y = 1:3, Z = 1:3),
  streamline_data = list(weight = 0.5)
)
sl_all <- streamline(
  points = cbind(X = 1:3, Y = 1:3, Z = 1:3),
  point_data = list(FA = c(0.1, 0.2, 0.3)),
  streamline_data = list(weight = 0.5)
)

expect_true(is_streamline(sl_pd))
expect_equal(sl_pd@point_data[["FA"]], c(0.1, 0.2, 0.3))
expect_equal(sl_sld@streamline_data[["weight"]], 0.5)
# point_attributes lists @point_data keys (no coordinates there)
expect_equal(sl_all@point_attributes, "FA")
expect_equal(sl_all@streamline_attributes, "weight")

# @points stores coordinates as a Px3 matrix
expect_equal(sl@points[, "X"], as.numeric(1:3))
expect_equal(sl@points[, "Y"], as.numeric(4:6))
expect_equal(sl@points[, "Z"], as.numeric(7:9))
expect_equal(ncol(sl@points), 3L)
expect_equal(colnames(sl@points), c("X", "Y", "Z"))

# ---- is_streamline ----------------------------------------------------------

expect_true(is_streamline(sl))
expect_false(is_streamline(list(X = 1:3)))
expect_false(is_streamline(42))

# ---- format.streamline ------------------------------------------------------

expect_true(grepl("none", format(sl)))
expect_true(grepl("FA", format(sl_pd)))
expect_true(grepl("weight", format(sl_sld)))
expect_true(grepl("FA", format(sl_all)))
expect_true(grepl("weight", format(sl_all)))

# ---- print.streamline -------------------------------------------------------

expect_stdout(print(sl), "streamline")
