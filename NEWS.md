# fiber (development version)

# fiber 0.2.0

## Breaking changes

* `streamline`: `@point_data` holds **numeric-only** attributes
  (e.g. fractional anisotropy).

* `bundle`: `@bundle_data` is now restricted to named lists of **scalars**
  (length-1 values, any type). Previously arbitrary R objects were accepted.
  Non-scalar values (e.g. affine matrices stored as a single `@bundle_data`
  entry) must be split into individual scalar entries or moved elsewhere.

* `bundle_set`: `@set_data` is now restricted to named lists of **scalars**
  (length-1 values, any type), consistent with `@bundle_data` at the bundle
  level.

## Improvements

* `format()` and `print()` methods for `streamline`, `bundle`, and
  `bundle_set` now use {cli} for styled, ANSI-aware console output. Unknown
  shape descriptors passed to `add_shape_descriptors()` now emit structured
  `cli::cli_warn()` messages instead of base-R warnings.

## New features

* `bundle` gains a `@streamline_data` slot — a named list of vectors of length
  $S$ (one entry per streamline) — for per-streamline attributes aggregated at
  the bundle level. `add_shape_descriptors()` now stores scalar descriptors
  (`euclidean_length`, `curvilinear_length`, `sinuosity`) directly in
  `bundle@streamline_data` rather than in each individual streamline.

* `bundle_set` gains a `@bundle_data` slot — a named list of vectors of length
  $B$ (one entry per bundle) — for per-bundle attributes aggregated at the
  set level.

* **Automatic attribute lifting**: when constructing a `bundle`, any
  `@streamline_data` key present in *all* supplied streamlines is
  automatically copied into `bundle@streamline_data` as a length-$S$ vector.
  The same happens one level up: common `@bundle_data` keys are lifted into
  `bundle_set@bundle_data` when constructing a `bundle_set`. Individual child
  slots are dropped; parent-level values take precedence on conflict.

* **Subsetting push-down**: `bundle[[i]]` now pushes the corresponding
  `bundle@streamline_data` values back into the extracted streamlines'
  `@streamline_data`. Likewise `bundle_set[[i]]` and pushes
  `bundle_set@bundle_data` values into the extracted bundles' `@bundle_data`.

* `bundle_set`: `@bundles` no longer needs to be a named list. Names are used
  to populate a bundle attribute vector called `id_from_input_list` and names
  are then dropped from the input list.

* `bundle()` constructor gains a `streamline_data` argument for supplying
  per-streamline data explicitly (overrides automatic lifting).

* `bind_bundles()` gains a `streamline_data` argument.

* `bind_bundle_sets()` gains a `bundle_data` argument. Bare `bundle` arguments
  no longer need to be named.

* `as_bundle_set()` method for `bundle`: the `name` argument is now optional
  (default `NULL`); omitting it creates an unnamed single-element `bundle_set`.

# fiber 0.1.2

* Added `bundle_set` S7 class — a named collection of `bundle` objects for multi-subject or multi-session studies.
* Added `is_bundle_set()` predicate, `format()`/`print()`/`length()`/`names()`/`[[`/`[` methods for `bundle_set`.
* Added `as_bundle_set()` generic with methods for `bundle_set` (identity) and `bundle` (wrap).
* Added `bind_bundle_sets()` to combine named `bundle` objects and/or `bundle_set` objects into a single `bundle_set`.
* Relaxed the `streamline` validator: `@point_data` entries no longer need to be numeric (any vector of the correct length is accepted); `@streamline_data` entries no longer need to be numeric either (any scalar is accepted). Non-numeric `@point_data` entries are dropped with a warning when `reparametrize()` is called, since they have no natural arc-length interpolant.
* Added missing `\value` documentation to the `compute_hausdorff_distance()` catch-all method (#CRAN).
* Replaced `\dontrun{}` with `if (requireNamespace("dti", quietly = TRUE)) {}` in the `as_dwifiber()` example (#CRAN).

# fiber 0.1.1

* Improved documentation of S7 classes, generics and methods following the release of roxygen2 8.0.0.
* Removed redundant `new_streamline()` and `new_bundle()` constructors.
* Added coercers from and to the `dwiFiber` S4 class of the [dti](https://cran.r-project.org/package=dti) package.
* Refactored shape descriptors API.
* Rewrote pairwise Hausdorff distance matrix using C++ via the [cpp11](https://cran.r-project.org/package=cpp11) package.
* Created the tractoverse GitHub organization and transferred fiber repository to it.

# fiber 0.1.0

## Breaking changes

* The package has been rebuilt from scratch around two [S7](https://rconsortium.github.io/S7/) classes: `streamline` and `bundle`. The previous tibble-based `streamline` and list-based `tract` are removed.

## New features

* `new_streamline()` / `new_bundle()` constructors for the S7 classes.
* `bind_bundles()` combines any mix of `streamline`s and `bundle`s into a single `bundle`.
* `reparametrize()` resamples a `streamline` or every streamline in a `bundle` onto a uniform arc-length grid.
* `get_euclidean_length()`, `get_curvilinear_length()`, `get_sinuosity()` — geometric shape scalars.
* `get_curvature()`, `get_torsion()` — full curvature/torsion profiles or summary scalars (`"mean"`, `"sd"`, `"max"`).
* `get_hausdorff_distance()` — symmetric Hausdorff distance between two `streamline`s.

## Dependencies

* Runtime dependencies reduced to **S7**, **rlang**, and **cli** only.
