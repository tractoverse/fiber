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
#>  [1]  0.003051135  2.678905266  6.658138276 35.784987815 24.723066652
#>  [6] 27.966689070 46.045715652  2.812822424  1.842706014  0.002333150
```
