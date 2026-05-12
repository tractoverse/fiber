# Reparametrize a streamline or bundle onto a uniform arc-length grid

Resamples the 3-D coordinates (and any `@point_data` attributes) of a
[streamline](https://astamm.github.io/fiber/reference/streamline.md) or
every
[streamline](https://astamm.github.io/fiber/reference/streamline.md)
inside a [bundle](https://astamm.github.io/fiber/reference/bundle.md)
onto a uniform arc-length grid using linear interpolation.

## Usage

``` r
reparametrize(x, n_points = NULL)
```

## Arguments

- x:

  A [streamline](https://astamm.github.io/fiber/reference/streamline.md)
  or [bundle](https://astamm.github.io/fiber/reference/bundle.md)
  object.

- n_points:

  Number of equally-spaced arc-length points to use.

  - For a single
    [streamline](https://astamm.github.io/fiber/reference/streamline.md),
    defaults to `nrow(x@points)`.

  - For a [bundle](https://astamm.github.io/fiber/reference/bundle.md),
    defaults to the rounded mean number of points across all
    streamlines. Pass `NULL` to use these defaults explicitly.

## Value

An object of the same class as `x` reparametrized onto the new grid.
