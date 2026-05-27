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
pts <- matrix(runif(30), ncol = 3)
colnames(pts) <- c("X", "Y", "Z")
sl <- streamline(points = pts)
get_euclidean_length(sl)
#> [1] 0.4319309
```
