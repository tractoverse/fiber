# Changelog

## fiber 0.1.0

### Breaking changes

- The package has been rebuilt from scratch around two
  [S7](https://rconsortium.github.io/S7/) classes: `streamline` and
  `bundle`. The previous tibble-based `streamline` and list-based
  `tract` are removed.

### New features

- `new_streamline()` / `new_bundle()` constructors for the S7 classes.
- [`bind_bundles()`](https://astamm.github.io/fiber/reference/bind_bundles.md)
  combines any mix of `streamline`s and `bundle`s into a single
  `bundle`.
- [`reparametrize()`](https://astamm.github.io/fiber/reference/reparametrize.md)
  resamples a `streamline` or every streamline in a `bundle` onto a
  uniform arc-length grid.
- [`get_euclidean_length()`](https://astamm.github.io/fiber/reference/get_euclidean_length.md),
  [`get_curvilinear_length()`](https://astamm.github.io/fiber/reference/get_curvilinear_length.md),
  [`get_sinuosity()`](https://astamm.github.io/fiber/reference/get_sinuosity.md)
  — geometric shape scalars.
- [`get_curvature()`](https://astamm.github.io/fiber/reference/get_curvature.md),
  [`get_torsion()`](https://astamm.github.io/fiber/reference/get_torsion.md)
  — full curvature/torsion profiles or summary scalars (`"mean"`,
  `"sd"`, `"max"`).
- `get_hausdorff_distance()` — symmetric Hausdorff distance between two
  `streamline`s.

### Dependencies

- Runtime dependencies reduced to **S7**, **rlang**, and **cli** only.
