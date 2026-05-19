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
    defaults to `nrow(x@points)`.

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
`NULL`).

## See also

[`reparametrize()`](https://tractoverse.github.io/fiber/reference/reparametrize.md)

## Examples

``` r
pts1 <- matrix(runif(30), ncol = 3)
colnames(pts1) <- c("X", "Y", "Z")
pts2 <- matrix(runif(60), ncol = 3)
colnames(pts2) <- c("X", "Y", "Z")
b <- bundle(streamlines = list(streamline(points = pts1),
                                streamline(points = pts2)))
b_reparam <- reparametrize(b, n_points = 15)
b_reparam[[1]]@n_points  # 15
#> [1] 15
b_reparam[[2]]@n_points  # 15
#> [1] 15
```
