# Sinuosity of a streamline

`get_sinuosity()` is a function that computes the ratio of curvilinear
length to Euclidean length for a
[streamline](https://tractoverse.github.io/fiber/reference/streamline.md)
object, with a value of 1 indicating a perfectly straight streamline and
larger values indicating greater curviness.

## Usage

``` r
get_sinuosity(x)
```

## Arguments

- x:

  A
  [streamline](https://tractoverse.github.io/fiber/reference/streamline.md)
  object.

## Value

A numeric scalar \\\ge 1\\.

## Examples

``` r
sl <- streamline(points = cbind(X = runif(10), Y = runif(10), Z = runif(10)))
get_sinuosity(sl)
#> [1] 8.138817
```
