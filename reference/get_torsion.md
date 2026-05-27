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
#>  [1] 182.125814278  -0.720751004   0.748241771  -6.313966113  -1.778271931
#>  [6]  17.788142783 -10.570667727  -5.258582913   0.001705469 431.936686365
```
