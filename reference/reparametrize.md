# Reparametrize a streamline or bundle onto a uniform arc-length grid

`reparametrize()` is an S7 generic that resamples the 3-D coordinates
(and any `@point_data` attributes) of a tractography object onto a
uniform arc-length grid using linear interpolation, with methods
available for the following classes:

- [`fiber::bundle`](https://tractoverse.github.io/fiber/reference/reparametrize-fiber-bundle-method.md)

- [`fiber::streamline`](https://tractoverse.github.io/fiber/reference/reparametrize-fiber-streamline-method.md)

## Usage

``` r
reparametrize(x, n_points = NULL)
```

## Arguments

- x:

  A
  [streamline](https://tractoverse.github.io/fiber/reference/streamline.md)
  or [bundle](https://tractoverse.github.io/fiber/reference/bundle.md)
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

An object of the same class as `x` reparametrized onto the new grid.

## Examples

``` r
# reparametrize a single streamline to 10 points
pts <- matrix(runif(30), ncol = 3)
colnames(pts) <- c("X", "Y", "Z")
sl <- streamline(points = pts)
sl_reparam <- reparametrize(sl, n_points = 10)
# reparametrize a bundle to the mean number of points across its streamlines
sl1 <- streamline(points = pts)
pts2 <- matrix(runif(60), ncol = 3)
colnames(pts2) <- c("X", "Y", "Z")
sl2 <- streamline(points = pts2)
b <- bundle(streamlines = list(sl1, sl2))
bundle_reparam <- reparametrize(b)
```
