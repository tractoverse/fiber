# Curvature of a streamline

Computes the curvature \\\kappa(s)\\ at each point along the arc-length
abscissa using cubic smoothing splines (3 degrees of freedom per
component).

## Usage

``` r
get_curvature(x, scalar = NULL)
```

## Arguments

- x:

  A [streamline](https://astamm.github.io/fiber/reference/streamline.md)
  object.

- scalar:

  One of `"mean"`, `"sd"`, `"max"`, or `NULL` (default). When `NULL` the
  full profile is returned as a data frame with columns `s` and
  `curvature`.

## Value

Either a `data.frame` (when `scalar = NULL`) or a single numeric value.
