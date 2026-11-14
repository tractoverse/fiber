# Changelog

## fiber 0.3.0

### Breaking changes

- `bundle_set`: renamed the set-level scalar metadata slot `@set_data`
  to `@bundle_set_data` (and `@set_attributes` to
  `@bundle_set_attributes`) so it follows the `<class>_data` /
  `<class>_attributes` naming pattern of the other classes. Existing
  code accessing `x@set_data` / `x@set_attributes` must be updated.

### Bug fixes

- [`bind_bundles()`](https://tractoverse.github.io/fiber/reference/bind_bundles.md)
  no longer silently drops `@streamline_data` / `@bundle_data` keys that
  are missing from some inputs. Keys absent from a given input are now
  NA-padded (previously the padding branch was dead code and such inputs
  errored instead).
- Auto-lifting of mixed-type common keys (`bundle(streamlines=...)` when
  different streamlines store the same `@point_data` /
  `@streamline_data` key with different types) no longer crashes with an
  opaque `vapply` type error. Values are now coalesced to a common type.
- [`compute_hausdorff_distance()`](https://tractoverse.github.io/fiber/reference/compute_hausdorff_distance.md)
  and the shape descriptors no longer crash (segfault at the C++
  boundary) when `@points` is stored as an integer matrix
  (e.g. constructed from integer vectors like `X = 1:5`). Coordinates
  are now coerced to double precision before being passed to the
  compiled code.

### New features

- `bundle_set` now supports
  [`reparametrize()`](https://tractoverse.github.io/fiber/reference/reparametrize.md)
  and
  [`add_shape_descriptors()`](https://tractoverse.github.io/fiber/reference/add_shape_descriptors.md);
  both operate per bundle and preserve `@bundle_data` /
  `@bundle_set_data`.

### Documentation

- `binding` example and `id_from_input_names` references in `NEWS` /
  `README` now match the actual function name.
- Added the first two vignettes:
  [`vignette("fiber")`](https://tractoverse.github.io/fiber/articles/fiber.md)
  (a practical getting started guide) and
  [`vignette("fiber-api")`](https://tractoverse.github.io/fiber/articles/fiber-api.md)
  (a technical reference for the classes, methods, and coercion rules).
- `bundle_set` documentation (class roxygen, README, and vignettes) now
  presents both motivating use cases: grouping the multiple white-matter
  bundles of a single subject, and grouping bundles across subjects /
  sessions.

### Tests

- Expanded the tinytest suite (~240 tests), raising source coverage from
  about 91% to just under 99%. New tests cover previously-uncovered
  validators (non-streamline/non-bundle elements),
  [`bind_bundles()`](https://tractoverse.github.io/fiber/reference/bind_bundles.md)
  /
  [`bind_bundle_sets()`](https://tractoverse.github.io/fiber/reference/bind_bundle_sets.md)
  append and NA-padding branches,
  [`format()`](https://rdrr.io/r/base/format.html) attribute display,
  and the
  [`as_dwifiber()`](https://tractoverse.github.io/fiber/reference/as_dwifiber.md)
  error path when `dti` is unavailable.

## fiber 0.2.0

CRAN release: 2026-07-04

### Breaking changes

- `streamline`: `@point_data` holds **numeric-only** attributes
  (e.g. fractional anisotropy).

- `bundle`: `@bundle_data` is now restricted to named lists of
  **scalars** (length-1 values, any type). Previously arbitrary R
  objects were accepted. Non-scalar values (e.g. affine matrices stored
  as a single `@bundle_data` entry) must be split into individual scalar
  entries or moved elsewhere.

- `bundle_set`: `@bundle_set_data` is now restricted to named lists of
  **scalars** (length-1 values, any type), consistent with
  `@bundle_data` at the bundle level.

### Improvements

- [`format()`](https://rdrr.io/r/base/format.html) and
  [`print()`](https://rdrr.io/r/base/print.html) methods for
  `streamline`, `bundle`, and `bundle_set` now use {cli} for styled,
  ANSI-aware console output. Unknown shape descriptors passed to
  [`add_shape_descriptors()`](https://tractoverse.github.io/fiber/reference/add_shape_descriptors.md)
  now emit structured
  [`cli::cli_warn()`](https://cli.r-lib.org/reference/cli_abort.html)
  messages instead of base-R warnings.

### New features

- `bundle` gains a `@streamline_data` slot — a named list of vectors of
  length $`S`$ (one entry per streamline) — for per-streamline
  attributes aggregated at the bundle level.
  [`add_shape_descriptors()`](https://tractoverse.github.io/fiber/reference/add_shape_descriptors.md)
  now stores scalar descriptors (`euclidean_length`,
  `curvilinear_length`, `sinuosity`) directly in
  `bundle@streamline_data` rather than in each individual streamline.

- `bundle_set` gains a `@bundle_data` slot — a named list of vectors of
  length $`B`$ (one entry per bundle) — for per-bundle attributes
  aggregated at the set level.

- **Automatic attribute lifting**: when constructing a `bundle`, any
  `@streamline_data` key present in *all* supplied streamlines is
  automatically copied into `bundle@streamline_data` as a length-$`S`$
  vector. The same happens one level up: common `@bundle_data` keys are
  lifted into `bundle_set@bundle_data` when constructing a `bundle_set`.
  Individual child slots are dropped; parent-level values take
  precedence on conflict.

- **Subsetting push-down**: `bundle[[i]]` now pushes the corresponding
  `bundle@streamline_data` values back into the extracted streamlines’
  `@streamline_data`. Likewise `bundle_set[[i]]` and pushes
  `bundle_set@bundle_data` values into the extracted bundles’
  `@bundle_data`.

- `bundle_set`: `@bundles` no longer needs to be a named list. Names are
  used to populate a bundle attribute vector called
  `id_from_input_names` and names are then dropped from the input list.

- [`bundle()`](https://tractoverse.github.io/fiber/reference/bundle.md)
  constructor gains a `streamline_data` argument for supplying
  per-streamline data explicitly (overrides automatic lifting).

- [`bind_bundles()`](https://tractoverse.github.io/fiber/reference/bind_bundles.md)
  gains a `streamline_data` argument.

- [`bind_bundle_sets()`](https://tractoverse.github.io/fiber/reference/bind_bundle_sets.md)
  gains a `bundle_data` argument. Bare `bundle` arguments no longer need
  to be named.

- [`as_bundle_set()`](https://tractoverse.github.io/fiber/reference/as_bundle_set.md)
  method for `bundle`: the `name` argument is now optional (default
  `NULL`); omitting it creates an unnamed single-element `bundle_set`.

## fiber 0.1.2

CRAN release: 2026-05-30

- Added `bundle_set` S7 class — a named collection of `bundle` objects
  for multi-subject or multi-session studies.
- Added
  [`is_bundle_set()`](https://tractoverse.github.io/fiber/reference/is_bundle_set.md)
  predicate,
  [`format()`](https://rdrr.io/r/base/format.html)/[`print()`](https://rdrr.io/r/base/print.html)/[`length()`](https://rdrr.io/r/base/length.html)/[`names()`](https://rdrr.io/r/base/names.html)/`[[`/`[`
  methods for `bundle_set`.
- Added
  [`as_bundle_set()`](https://tractoverse.github.io/fiber/reference/as_bundle_set.md)
  generic with methods for `bundle_set` (identity) and `bundle` (wrap).
- Added
  [`bind_bundle_sets()`](https://tractoverse.github.io/fiber/reference/bind_bundle_sets.md)
  to combine named `bundle` objects and/or `bundle_set` objects into a
  single `bundle_set`.
- Relaxed the `streamline` validator: `@point_data` entries no longer
  need to be numeric (any vector of the correct length is accepted);
  `@streamline_data` entries no longer need to be numeric either (any
  scalar is accepted). Non-numeric `@point_data` entries are dropped
  with a warning when
  [`reparametrize()`](https://tractoverse.github.io/fiber/reference/reparametrize.md)
  is called, since they have no natural arc-length interpolant.
- Added missing `\value` documentation to the
  [`compute_hausdorff_distance()`](https://tractoverse.github.io/fiber/reference/compute_hausdorff_distance.md)
  catch-all method (#CRAN).
- Replaced `\dontrun{}` with
  `if (requireNamespace("dti", quietly = TRUE)) {}` in the
  [`as_dwifiber()`](https://tractoverse.github.io/fiber/reference/as_dwifiber.md)
  example (#CRAN).

## fiber 0.1.1

- Improved documentation of S7 classes, generics and methods following
  the release of roxygen2 8.0.0.
- Removed redundant `new_streamline()` and `new_bundle()` constructors.
- Added coercers from and to the `dwiFiber` S4 class of the
  [dti](https://cran.r-project.org/package=dti) package.
- Refactored shape descriptors API.
- Rewrote pairwise Hausdorff distance matrix using C++ via the
  [cpp11](https://cran.r-project.org/package=cpp11) package.
- Created the tractoverse GitHub organization and transferred fiber
  repository to it.

## fiber 0.1.0

### Breaking changes

- The package has been rebuilt from scratch around two
  [S7](https://rconsortium.github.io/S7/) classes: `streamline` and
  `bundle`. The previous tibble-based `streamline` and list-based
  `tract` are removed.

### New features

- `new_streamline()` / `new_bundle()` constructors for the S7 classes.
- [`bind_bundles()`](https://tractoverse.github.io/fiber/reference/bind_bundles.md)
  combines any mix of `streamline`s and `bundle`s into a single
  `bundle`.
- [`reparametrize()`](https://tractoverse.github.io/fiber/reference/reparametrize.md)
  resamples a `streamline` or every streamline in a `bundle` onto a
  uniform arc-length grid.
- [`get_euclidean_length()`](https://tractoverse.github.io/fiber/reference/get_euclidean_length.md),
  [`get_curvilinear_length()`](https://tractoverse.github.io/fiber/reference/get_curvilinear_length.md),
  [`get_sinuosity()`](https://tractoverse.github.io/fiber/reference/get_sinuosity.md)
  — geometric shape scalars.
- [`get_curvature()`](https://tractoverse.github.io/fiber/reference/get_curvature.md),
  [`get_torsion()`](https://tractoverse.github.io/fiber/reference/get_torsion.md)
  — full curvature/torsion profiles or summary scalars (`"mean"`,
  `"sd"`, `"max"`).
- `get_hausdorff_distance()` — symmetric Hausdorff distance between two
  `streamline`s.

### Dependencies

- Runtime dependencies reduced to **S7**, **rlang**, and **cli** only.
