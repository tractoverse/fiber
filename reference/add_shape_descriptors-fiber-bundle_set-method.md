# [`add_shape_descriptors()`](https://tractoverse.github.io/fiber/reference/add_shape_descriptors.md) method for `bundle_set` objects

Adds shape descriptors to every
[bundle](https://tractoverse.github.io/fiber/reference/bundle.md) inside
a
[bundle_set](https://tractoverse.github.io/fiber/reference/bundle_set.md).
Scalar descriptors (`euclidean_length`, `curvilinear_length`,
`sinuosity`) are stored as length-S vectors in each bundle's
`@streamline_data`. Per-point descriptors (`curvature`, `torsion`) are
stored in each individual streamline's `@point_data`. Both are
accessible via the subsetting push-down (`bundle_set[[i]][[j]]`).
`@bundle_data` and `@bundle_set_data` are preserved unchanged.

## Arguments

- x:

  A
  [bundle_set](https://tractoverse.github.io/fiber/reference/bundle_set.md)
  object.

- descriptors:

  A character vector of shape descriptors to add. Defaults to all
  available descriptors:
  `c("euclidean_length", "curvilinear_length", "sinuosity", "curvature", "torsion")`.

## Value

A
[bundle_set](https://tractoverse.github.io/fiber/reference/bundle_set.md)
with the specified shape descriptors added.

## See also

[`add_shape_descriptors()`](https://tractoverse.github.io/fiber/reference/add_shape_descriptors.md)
