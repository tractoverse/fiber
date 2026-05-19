# [`add_shape_descriptors()`](https://astamm.github.io/fiber/reference/add_shape_descriptors.md) method for `streamline` objects

Adds multiple shape descriptors to a single
[streamline](https://astamm.github.io/fiber/reference/streamline.md)
object.

## Arguments

- x:

  A [streamline](https://astamm.github.io/fiber/reference/streamline.md)
  object.

- descriptors:

  A character vector of shape descriptors to add. Defaults to all
  available descriptors:
  `c("euclidean_length", "curvilinear_length", "sinuosity", "curvature", "torsion")`.

## Value

A [streamline](https://astamm.github.io/fiber/reference/streamline.md)
with the specified shape descriptors added to the `@streamline_data` or
`@point_data` slots as appropriate.

## See also

[`add_shape_descriptors()`](https://astamm.github.io/fiber/reference/add_shape_descriptors.md)
