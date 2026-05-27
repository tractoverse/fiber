library(fiber)

# ---- helpers -----------------------------------------------------------------

pts <- matrix(
  c(1, 2, 3, 4, 5, 6, 7, 8, 9),
  ncol = 3,
  dimnames = list(NULL, c("X", "Y", "Z"))
)
sl <- streamline(pts)
b1 <- bundle(list(sl), bundle_data = list(subject = "sub-01"))
b2 <- bundle(list(sl, sl), bundle_data = list(subject = "sub-02"))

# ---- bundle_set constructor -------------------------------------------------

bs <- bundle_set(bundles = list("sub-01" = b1, "sub-02" = b2))
expect_true(is_bundle_set(bs))
expect_equal(bs@n_bundles, 2L)
expect_equal(bs@bundle_names, c("sub-01", "sub-02"))

# empty bundle_set is allowed
bs0 <- bundle_set(bundles = list())
expect_true(is_bundle_set(bs0))
expect_equal(bs0@n_bundles, 0L)

# unnamed non-empty list -> error
expect_error(bundle_set(bundles = list(b1)))

# non-bundle element -> error
expect_error(bundle_set(bundles = list("x" = sl)))

# set_data is stored
bs_meta <- bundle_set(
  bundles = list("sub-01" = b1),
  set_data = list(study = "phantom")
)
expect_equal(bs_meta@set_data[["study"]], "phantom")
expect_equal(bs_meta@set_attributes, "study")

# ---- is_bundle_set -----------------------------------------------------------

expect_true(is_bundle_set(bs))
expect_false(is_bundle_set(b1))
expect_false(is_bundle_set(sl))

# ---- format.bundle_set -------------------------------------------------------

f0 <- format(bs0)
expect_true(grepl("0 bundles", f0))

f2 <- format(bs)
expect_true(grepl("2 bundles", f2))
expect_true(grepl("sub-01", f2))

# set_data keys appear in format
f_meta <- format(bs_meta)
expect_true(grepl("set: study", f_meta))

# ---- print.bundle_set --------------------------------------------------------

expect_stdout(print(bs), "bundles")

# ---- length / names ----------------------------------------------------------

expect_equal(length(bs), 2L)
expect_equal(names(bs), c("sub-01", "sub-02"))

# ---- indexing ----------------------------------------------------------------

# [[ by name
expect_true(is_bundle(bs[["sub-01"]]))

# [[ by position
expect_true(is_bundle(bs[[2L]]))

# [ returns a bundle_set preserving set_data
bs_sub <- bs_meta["sub-01"]
expect_true(is_bundle_set(bs_sub))
expect_equal(bs_sub@set_data[["study"]], "phantom")
expect_equal(bs_sub@n_bundles, 1L)

# ---- as_bundle_set -----------------------------------------------------------

# identity
expect_true(is_bundle_set(as_bundle_set(bs)))

# wrap a bundle
bs_from_b <- as_bundle_set(b1, name = "sub-01")
expect_true(is_bundle_set(bs_from_b))
expect_equal(bs_from_b@bundle_names, "sub-01")
expect_equal(bs_from_b@n_bundles, 1L)

# unknown class -> error
expect_error(as_bundle_set("not a bundle"))

# ---- bind_bundle_sets --------------------------------------------------------

bs1 <- bundle_set(list("sub-01" = b1))
bs2 <- bundle_set(list("sub-02" = b2))

# two bundle_sets
bs_all <- bind_bundle_sets(bs1, bs2)
expect_equal(bs_all@n_bundles, 2L)
expect_equal(sort(bs_all@bundle_names), c("sub-01", "sub-02"))

# named bare bundles
bs_named <- bind_bundle_sets("sub-01" = b1, "sub-02" = b2)
expect_equal(bs_named@n_bundles, 2L)

# mix of bundle_set and named bundle
bs_mix <- bind_bundle_sets(bs1, "sub-02" = b2)
expect_equal(bs_mix@n_bundles, 2L)

# set_data inherited from first bundle_set
bs1_meta <- bundle_set(list("sub-01" = b1), set_data = list(study = "test"))
bs_sd <- bind_bundle_sets(bs1_meta, bs2)
expect_equal(bs_sd@set_data[["study"]], "test")

# set_data override
bs_sd2 <- bind_bundle_sets(bs1_meta, bs2, set_data = list(study = "override"))
expect_equal(bs_sd2@set_data[["study"]], "override")

# unnamed bundle -> error
expect_error(bind_bundle_sets(b1))

# duplicate names -> error
expect_error(bind_bundle_sets(bs1, bs1))

# no args -> error
expect_error(bind_bundle_sets())

# wrong type -> error
expect_error(bind_bundle_sets("x" = "not_a_bundle"))
