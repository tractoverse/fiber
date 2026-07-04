# Euclidean length of a streamline

`get_euclidean_length()` is a function that computes the Euclidean
(straight-line) distance of a
[streamline](https://tractoverse.github.io/fiber/reference/streamline.md)
object.

## Usage

``` r
get_euclidean_length(x)
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
get_euclidean_length(sl)
#> [1] 0.5324479
```
