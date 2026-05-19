# Sinuosity of a streamline

`get_sinuosity()` is a function that computes the ratio of curvilinear
length to Euclidean length for a
[streamline](https://astamm.github.io/fiber/reference/streamline.md)
object, with a value of 1 indicating a perfectly straight streamline and
larger values indicating greater curviness.

## Usage

``` r
get_sinuosity(x)
```

## Arguments

- x:

  A [streamline](https://astamm.github.io/fiber/reference/streamline.md)
  object.

## Value

A numeric scalar \\\ge 1\\.

## Examples

``` r
pts <- matrix(runif(30), ncol = 3)
colnames(pts) <- c("X", "Y", "Z")
sl <- streamline(points = pts)
get_sinuosity(sl)
#> [1] 10.17893
```
