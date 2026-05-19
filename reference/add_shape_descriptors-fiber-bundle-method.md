# [`add_shape_descriptors()`](https://tractoverse.github.io/fiber/reference/add_shape_descriptors.md) method for `bundle` objects

Adds multiple shape descriptors to every
[streamline](https://tractoverse.github.io/fiber/reference/streamline.md)
inside a
[bundle](https://tractoverse.github.io/fiber/reference/bundle.md).

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
the specified shape descriptors added to the `@streamline_data` or
`@point_data` slots of each streamline as appropriate.

## See also

[`add_shape_descriptors()`](https://tractoverse.github.io/fiber/reference/add_shape_descriptors.md)
