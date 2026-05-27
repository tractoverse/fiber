# Curvilinear length of a streamline

`get_curvilinear_length()` is a function that computes the total
arc-length of a
[streamline](https://tractoverse.github.io/fiber/reference/streamline.md)
object as the sum of Euclidean segment lengths between consecutive
points.

## Usage

``` r
get_curvilinear_length(x)
```

## Arguments

- x:

  A
  [streamline](https://tractoverse.github.io/fiber/reference/streamline.md)
  object.

## Value

A non-negative numeric scalar.

## Examples

``` r
pts <- matrix(runif(30), ncol = 3)
colnames(pts) <- c("X", "Y", "Z")
sl <- streamline(points = pts)
get_curvilinear_length(sl)
#> [1] 5.41975
```
