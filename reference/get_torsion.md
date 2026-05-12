# Torsion of a streamline

Computes the torsion \\\tau(s)\\ at each point along the arc-length
abscissa using cubic smoothing splines (4 degrees of freedom per
component).

## Usage

``` r
get_torsion(x, scalar = NULL)
```

## Arguments

- x:

  A [streamline](https://astamm.github.io/fiber/reference/streamline.md)
  object.

- scalar:

  One of `"mean"`, `"sd"`, `"max"`, or `NULL` (default). When `NULL` the
  full profile is returned as a data frame with columns `s` and
  `torsion`.

## Value

Either a `data.frame` (when `scalar = NULL`) or a single numeric value.
