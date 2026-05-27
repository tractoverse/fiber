# Torsion of a streamline

`get_torsion()` is function that computes the torsion of a
[streamline](https://tractoverse.github.io/fiber/reference/streamline.md)
object. The torsion \\\tau(s)\\ at each point along the arc-length
abscissa is computed using cubic smoothing splines (4 degrees of freedom
per component).

## Usage

``` r
get_torsion(x)
```

## Arguments

- x:

  A
  [streamline](https://tractoverse.github.io/fiber/reference/streamline.md)
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
#>  [1] -4.773398e+01  1.162808e+00  2.996264e+00  8.199129e+00  5.831254e+00
#>  [6]  2.130476e-01  7.561493e+00  1.269322e+00 -3.229987e-04 -4.676693e+01
```
