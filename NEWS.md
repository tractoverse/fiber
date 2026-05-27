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
