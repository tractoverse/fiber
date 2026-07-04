# [`reparametrize()`](https://tractoverse.github.io/fiber/reference/reparametrize.md) method for `bundle` objects

Resamples every
[streamline](https://tractoverse.github.io/fiber/reference/streamline.md)
inside a
[bundle](https://tractoverse.github.io/fiber/reference/bundle.md) onto a
common uniform arc-length grid. See
[`reparametrize()`](https://tractoverse.github.io/fiber/reference/reparametrize.md)
for the full parameter documentation.

## Arguments

- x:

  A [bundle](https://tractoverse.github.io/fiber/reference/bundle.md)
  object.

- n_points:

  Number of equally-spaced arc-length points to use.

  - For a single
    [streamline](https://tractoverse.github.io/fiber/reference/streamline.md),
    defaults to `x@n_points`.

  - For a
    [bundle](https://tractoverse.github.io/fiber/reference/bundle.md),
    defaults to the rounded mean number of points across all
    streamlines.

  Pass `NULL` to use these defaults explicitly.

## Value

A [bundle](https://tractoverse.github.io/fiber/reference/bundle.md)
reparametrized onto the new grid. Every streamline in the returned
bundle has exactly `n_points` rows in `@points` (defaulting to the
rounded mean number of points across all streamlines when `n_points` is
`NULL`). `@streamline_data` and `@bundle_data` are preserved unchanged.

## See also

[`reparametrize()`](https://tractoverse.github.io/fiber/reference/reparametrize.md)

## Examples

``` r
sl1 <- streamline(points = cbind(X = runif(5), Y = runif(5), Z = runif(5)))
sl2 <- streamline(points = cbind(X = runif(10), Y = runif(10), Z = runif(10)))
b <- bundle(streamlines = list(sl1, sl2))
b_reparam <- reparametrize(b, n_points = 8)
b_reparam[[1]]@n_points  # 8
#> [1] 8
b_reparam[[2]]@n_points  # 8
#> [1] 8
```
