library(tinytest)
library(fiber)

# ---- helpers -----------------------------------------------------------------

sl <- streamline(points = cbind(X = 1:3, Y = 1:3, Z = 1:3))
b1 <- bundle(
  streamlines = list(sl),
  bundle_data = list(subject = "sub-01")
)
b1_unnamed <- bundle(streamlines = list(sl))
b2 <- bundle(
  streamlines = list(sl, sl),
  bundle_data = list(subject = "sub-02")
)
b2_unnamed <- bundle(streamlines = list(sl, sl))

# ---- bundle_set constructor -------------------------------------------------

# Named bundles
bs <- bundle_set(bundles = list("sub-01" = b1, "sub-02" = b2))
expect_true(is_bundle_set(bs))
expect_equal(bs@n_bundles, 2L)
expect_equal(bs@bundle_attributes, c("subject", "id_from_input_names"))
expect_equal(bs@bundle_data$subject, c("sub-01", "sub-02"))

# Unnamed bundles
bs_unnamed <- bundle_set(bundles = list(b1_unnamed, b2_unnamed))
expect_true(is_bundle_set(bs_unnamed))
expect_equal(bs_unnamed@n_bundles, 2L)

# Empty bundle_set is allowed
bs0 <- bundle_set(bundles = list())
expect_true(is_bundle_set(bs0))
expect_equal(bs0@n_bundles, 0L)

# Non-bundle element -> error
expect_error(bundle_set(bundles = list("x" = sl)))

# set_data must be scalars
expect_error(
  bundle_set(
    bundles = list(b1),
    set_data = list(study = c("a", "b"))
  )
)

# set_data is stored
bs_meta <- bundle_set(
  bundles = list("sub-01" = b1),
  set_data = list(study = "phantom")
)
expect_equal(bs_meta@set_data[["study"]], "phantom")
expect_equal(bs_meta@set_attributes, "study")

# ---- automatic lifting of bundle_data ---------------------------------------

# Both bundles have 'subject' in their @bundle_data -> lifted to @bundle_data
expect_equal(bs@bundle_attributes, c("subject", "id_from_input_names"))
expect_equal(bs@bundle_data[["subject"]], c("sub-01", "sub-02"))

# Explicit bundle_data overrides automatic lifting
bs_explicit <- bundle_set(
  bundles = list("sub-01" = b1, "sub-02" = b2),
  bundle_data = list(subject = c("A", "B"))
)
expect_equal(bs_explicit@bundle_data[["subject"]], c("A", "B"))

# bundle_data wrong length -> error
expect_error(
  bundle_set(
    bundles = list(b1, b2),
    bundle_data = list(x = c(1)) # length 1 but 2 bundles
  )
)

# ---- is_bundle_set -----------------------------------------------------------

expect_true(is_bundle_set(bs))
expect_false(is_bundle_set(b1))
expect_false(is_bundle_set(sl))

# ---- format.bundle_set -------------------------------------------------------

f0 <- format(bs0)
expect_true(grepl("no bundle", f0))

f2 <- format(bs)
expect_true(grepl("subject", f2))

f_un <- format(bs_unnamed)
expect_false(grepl("subject", f_un))

# set_data keys appear in format
f_meta <- format(bs_meta)
expect_true(grepl("study", f_meta))

# ---- print.bundle_set --------------------------------------------------------

expect_stdout(print(bs), "Object of class")

# ---- length ------------------------------------------------------------------

expect_equal(length(bs), 2L)

# ---- indexing ----------------------------------------------------------------

# [[ by name
expect_true(is_bundle(bs[["sub-01"]]))

# [[ by position
expect_true(is_bundle(bs[[2L]]))

# [[ pushes @bundle_data back into the extracted bundle
expect_equal(bs[["sub-01"]]@bundle_data[["subject"]], "sub-01")
expect_equal(bs[[2L]]@bundle_data[["subject"]], "sub-02")

# [ returns a bundle_set with subset of @bundle_data
bs_sub <- bs["sub-01"]
expect_true(is_bundle_set(bs_sub))
expect_equal(bs_sub@n_bundles, 1L)
expect_equal(bs_sub@bundle_data[["subject"]], c("sub-01"))

# [ preserves @set_data
bs_sub_meta <- bs_meta["sub-01"]
expect_equal(bs_sub_meta@set_data[["study"]], "phantom")

# ---- as_bundle_set -----------------------------------------------------------

# identity
expect_true(is_bundle_set(as_bundle_set(bs)))

# wrap a bundle with a name
bs_from_b <- as_bundle_set(b1, name = "sub-01")
expect_true(is_bundle_set(bs_from_b))
expect_equal(bs_from_b@bundle_data$subject, "sub-01")
expect_equal(bs_from_b@n_bundles, 1L)

# unknown class -> error
expect_error(as_bundle_set("not a bundle"))

# ---- bind_bundle_sets --------------------------------------------------------

bs1 <- bundle_set(list(b1), bundle_data = list(subject = "sub-01"))
bs2 <- bundle_set(list(b2), bundle_data = list(subject = "sub-02"))

# two bundle_sets
bs_all <- bind_bundle_sets(bs1, bs2)
expect_equal(bs_all@n_bundles, 2L)
expect_equal(sort(bs_all@bundle_data$subject), c("sub-01", "sub-02"))

# named bare bundles
bs_named <- bind_bundle_sets("sub-01" = b1, "sub-02" = b2)
expect_equal(bs_named@n_bundles, 2L)

# unnamed bare bundles are now allowed
bs_anon2 <- bind_bundle_sets(b1, b2)
expect_equal(bs_anon2@n_bundles, 2L)

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

# no args -> error
expect_error(bind_bundle_sets())

# wrong type -> error
expect_error(bind_bundle_sets("x" = "not_a_bundle"))
