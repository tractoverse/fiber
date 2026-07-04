# [`add_shape_descriptors()`](https://tractoverse.github.io/fiber/reference/add_shape_descriptors.md) method for `bundle` objects

Adds shape descriptors to a
[bundle](https://tractoverse.github.io/fiber/reference/bundle.md).
Scalar descriptors (`euclidean_length`, `curvilinear_length`,
`sinuosity`) are stored as length-S vectors in `bundle@streamline_data`.
Per-point descriptors (`curvature`, `torsion`) are stored in each
individual streamline's `@point_data`. Both are accessible via the
subsetting push-down (`bundle[[i]]`).

## Arguments

- x:

  A [bundle](https://tractoverse.github.io/fiber/reference/bundle.md)
  object.

- descriptors:

  A character vector of shape descriptors to add. Defaults to all
  available descriptors:
  `c("euclidean_length", "curvilinear_length", "sinuosity", "curvature", "torsion")`.

## Value

A [bundle](https://tractoverse.github.io/fiber/reference/bundle.md) with
the specified shape descriptors added.

## See also

[`add_shape_descriptors()`](https://tractoverse.github.io/fiber/reference/add_shape_descriptors.md)
