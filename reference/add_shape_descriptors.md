# Adds shape descriptors to a streamline or bundle

`add_shape_descriptors()` is an S7 generic that computes a number of
shape descriptors for each
[streamline](https://astamm.github.io/fiber/reference/streamline.md)
object and stores them in the `@streamline_data` or `@point_data` slots
as appropriate, with methods available for the following classes:

- [`fiber::bundle`](https://astamm.github.io/fiber/reference/add_shape_descriptors-fiber-bundle-method.md)

- [`fiber::streamline`](https://astamm.github.io/fiber/reference/add_shape_descriptors-fiber-streamline-method.md)

This function provides a convenient way to compute shape descriptors and
attach them to
[streamline](https://astamm.github.io/fiber/reference/streamline.md) or
[bundle](https://astamm.github.io/fiber/reference/bundle.md) objects.
See the documentation for each individual shape descriptor function
(e.g.
[`get_euclidean_length()`](https://astamm.github.io/fiber/reference/get_euclidean_length.md),
[`get_curvilinear_length()`](https://astamm.github.io/fiber/reference/get_curvilinear_length.md),
[`get_sinuosity()`](https://astamm.github.io/fiber/reference/get_sinuosity.md),
[`get_curvature()`](https://astamm.github.io/fiber/reference/get_curvature.md),
[`get_torsion()`](https://astamm.github.io/fiber/reference/get_torsion.md))
for more details on how each descriptor is computed.

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

  A [streamline](https://astamm.github.io/fiber/reference/streamline.md)
  or [bundle](https://astamm.github.io/fiber/reference/bundle.md)
  object.

- descriptors:

  A character vector of shape descriptors to add. Defaults to all
  available descriptors:
  `c("euclidean_length", "curvilinear_length", "sinuosity", "curvature", "torsion")`.

## Value

An object of the same class as `x` with the specified shape descriptors
added to the `@streamline_data` or `@point_data` slots of each
streamline.

## Examples

``` r
# add multiple shape descriptors to a single streamline
pts <- matrix(runif(30), ncol = 3)
colnames(pts) <- c("X", "Y", "Z")
sl <- streamline(points = pts)
sl <- add_shape_descriptors(
  sl,
  descriptors = c("euclidean_length", "curvilinear_length", "sinuosity")
)
# add multiple shape descriptors to a bundle
sl1 <- streamline(points = pts)
pts2 <- matrix(runif(60), ncol = 3)
colnames(pts2) <- c("X", "Y", "Z")
sl2 <- streamline(points = pts2)
b <- bundle(streamlines = list(sl1, sl2))
b <- add_shape_descriptors(
  b,
  descriptors = c("euclidean_length", "curvilinear_length", "sinuosity")
)
```
