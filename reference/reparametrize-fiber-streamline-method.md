# [`reparametrize()`](https://astamm.github.io/fiber/reference/reparametrize.md) method for `streamline` objects

Resamples a single
[streamline](https://astamm.github.io/fiber/reference/streamline.md)
onto a uniform arc-length grid. See
[`reparametrize()`](https://astamm.github.io/fiber/reference/reparametrize.md)
for the full parameter documentation.

## Arguments

- x:

  A [streamline](https://astamm.github.io/fiber/reference/streamline.md)
  object.

- n_points:

  Number of equally-spaced arc-length points to use.

  - For a single
    [streamline](https://astamm.github.io/fiber/reference/streamline.md),
    defaults to `nrow(x@points)`.

  - For a [bundle](https://astamm.github.io/fiber/reference/bundle.md),
    defaults to the rounded mean number of points across all
    streamlines.

  Pass `NULL` to use these defaults explicitly.

## Value

A [streamline](https://astamm.github.io/fiber/reference/streamline.md)
reparametrized onto the new grid. The returned object has the same class
as the input but with `@points` resampled to exactly `n_points` rows and
all `@point_data` vectors resampled correspondingly via linear
interpolation.

## See also

[`reparametrize()`](https://astamm.github.io/fiber/reference/reparametrize.md)

## Examples

``` r
pts <- matrix(runif(30), ncol = 3)
colnames(pts) <- c("X", "Y", "Z")
sl <- streamline(points = pts, point_data = list(FA = runif(10)))
sl_reparam <- reparametrize(sl, n_points = 20)
sl_reparam@n_points  # 20
#> [1] 20
```
