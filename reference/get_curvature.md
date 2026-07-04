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
sl <- streamline(points = cbind(X = runif(10), Y = runif(10), Z = runif(10)))
get_curvature(sl)
#>  [1] 2.224264e-03 2.902512e+00 5.463207e+00 4.946100e+00 2.085087e+01
#>  [6] 5.724639e+00 1.397124e+00 7.540224e-01 1.602833e-01 4.313347e-04
```
