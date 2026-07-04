# Adds shape descriptors to a streamline or bundle

`add_shape_descriptors()` is an S7 generic that computes a number of
shape descriptors for each
[streamline](https://tractoverse.github.io/fiber/reference/streamline.md)
object and stores them in the `@streamline_data` or `@point_data` slots
as appropriate, with methods available for the following classes:

- [`fiber::bundle`](https://tractoverse.github.io/fiber/reference/add_shape_descriptors-fiber-bundle-method.md)

- [`fiber::streamline`](https://tractoverse.github.io/fiber/reference/add_shape_descriptors-fiber-streamline-method.md)

This function provides a convenient way to compute shape descriptors and
attach them to
[streamline](https://tractoverse.github.io/fiber/reference/streamline.md)
or [bundle](https://tractoverse.github.io/fiber/reference/bundle.md)
objects. See the documentation for each individual shape descriptor
function (e.g.
[`get_euclidean_length()`](https://tractoverse.github.io/fiber/reference/get_euclidean_length.md),
[`get_curvilinear_length()`](https://tractoverse.github.io/fiber/reference/get_curvilinear_length.md),
[`get_sinuosity()`](https://tractoverse.github.io/fiber/reference/get_sinuosity.md),
[`get_curvature()`](https://tractoverse.github.io/fiber/reference/get_curvature.md),
[`get_torsion()`](https://tractoverse.github.io/fiber/reference/get_torsion.md))
for more details on how each descriptor is computed.

For [bundle](https://tractoverse.github.io/fiber/reference/bundle.md)
objects, scalar descriptors (`euclidean_length`, `curvilinear_length`,
`sinuosity`) are stored as length-S vectors in `bundle@streamline_data`.
Per-point descriptors (`curvature`, `torsion`) continue to be stored in
each individual streamline's `@point_data`. Both are accessible via
`bundle[[i]]@streamline_data` and `bundle[[i]]@point_data` respectively,
through the subsetting push-down mechanism.

## Usage

``` r
add_shape_descriptors(
  x,
  descriptors = c("euclidean_length", "curvilinear_length", "sinuosity", "curvature",
    "torsion")
)
```

## Arguments

- x:

  A
  [streamline](https://tractoverse.github.io/fiber/reference/streamline.md)
  or [bundle](https://tractoverse.github.io/fiber/reference/bundle.md)
  object.

- descriptors:

  A character vector of shape descriptors to add. Defaults to all
  available descriptors:
  `c("euclidean_length", "curvilinear_length", "sinuosity", "curvature", "torsion")`.

## Value

An object of the same class as `x` with the specified shape descriptors
added to the appropriate slots.

## Examples

``` r
# add multiple shape descriptors to a single streamline
sl <- streamline(points = cbind(X = runif(10), Y = runif(10), Z = runif(10)))
sl <- add_shape_descriptors(
  sl,
  descriptors = c("euclidean_length", "curvilinear_length", "sinuosity")
)
sl@streamline_data$euclidean_length
#> [1] 0.8047799

# add multiple shape descriptors to a bundle
sl2 <- streamline(points = cbind(X = runif(20), Y = runif(20), Z = runif(20)))
b <- bundle(streamlines = list(sl, sl2))
b <- add_shape_descriptors(
  b,
  descriptors = c("euclidean_length", "curvilinear_length", "sinuosity")
)
b@streamline_data$euclidean_length  # length-2 vector
#> [1] 0.8047799 0.5586424
```
