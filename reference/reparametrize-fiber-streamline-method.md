# [`reparametrize()`](https://tractoverse.github.io/fiber/reference/reparametrize.md) method for `streamline` objects

Resamples a single
[streamline](https://tractoverse.github.io/fiber/reference/streamline.md)
onto a uniform arc-length grid. See
[`reparametrize()`](https://tractoverse.github.io/fiber/reference/reparametrize.md)
for the full parameter documentation.

## Arguments

- x:

  A
  [streamline](https://tractoverse.github.io/fiber/reference/streamline.md)
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

A
[streamline](https://tractoverse.github.io/fiber/reference/streamline.md)
reparametrized onto the new grid. The returned object has `@points`
resampled to exactly `n_points` rows via linear interpolation, and any
numeric `@point_data` entries likewise resampled. Non-numeric
`@point_data` entries are dropped with a warning. `@streamline_data` is
preserved unchanged.

## See also

[`reparametrize()`](https://tractoverse.github.io/fiber/reference/reparametrize.md)

## Examples

``` r
sl <- streamline(
  points = cbind(X = runif(10), Y = runif(10), Z = runif(10)),
  point_data = list(FA = runif(10))
)
sl_reparam <- reparametrize(sl, n_points = 20)
sl_reparam@n_points  # 20
#> [1] 20
```
