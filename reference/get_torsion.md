# Torsion of a streamline

`get_torsion()` is function that computes the torsion of a
[streamline](https://astamm.github.io/fiber/reference/streamline.md)
object. The torsion \\\tau(s)\\ at each point along the arc-length
abscissa is computed using cubic smoothing splines (4 degrees of freedom
per component).

## Usage

``` r
get_torsion(x)
```

## Arguments

- x:

  A [streamline](https://astamm.github.io/fiber/reference/streamline.md)
  object.

## Value

A numeric vector of length `x@n_points` giving the torsion \\\tau(s)\\
at each sampled point along the streamline. Positive values indicate
right-handed twisting; negative values indicate left-handed twisting;
zero indicates a planar curve at that location.

## Examples

``` r
pts <- matrix(runif(30), ncol = 3)
colnames(pts) <- c("X", "Y", "Z")
sl <- streamline(points = pts)
get_torsion(sl)
#>  [1]  3.611232e+02 -5.092617e+00 -7.061474e+00 -8.313501e-01  8.988472e-01
#>  [6] -1.113674e+00 -7.678624e+00 -6.685776e-01  8.650203e-04  1.253739e+02
```
