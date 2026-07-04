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
sl <- streamline(points = cbind(X = runif(10), Y = runif(10), Z = runif(10)))
get_curvilinear_length(sl)
#> [1] 5.805339
```
