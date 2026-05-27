# Curvature of a streamline

`get_curvature()` is function that computes the curvature of a
[streamline](https://tractoverse.github.io/fiber/reference/streamline.md)
object. The curvature \\\kappa(s)\\ at each point along the arc-length
abscissa is computed using cubic smoothing splines (3 degrees of freedom
per component).

## Usage

``` r
get_curvature(x)
```

## Arguments

- x:

  A
  [streamline](https://tractoverse.github.io/fiber/reference/streamline.md)
  object.

## Value

A non-negative numeric vector of length `x@n_points` giving the
curvature \\\kappa(s)\\ at each sampled point along the streamline.
Higher values indicate sharper bending at that location.

## Examples

``` r
pts <- matrix(runif(30), ncol = 3)
colnames(pts) <- c("X", "Y", "Z")
sl <- streamline(points = pts)
get_curvature(sl)
#>  [1]  0.002945844  2.508761028  4.095939414 17.631667662  9.692609338
#>  [6]  3.356014601  2.422609079  4.964980139  4.268878589  0.004732570
```
