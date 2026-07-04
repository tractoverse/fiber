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
sl <- streamline(points = cbind(X = runif(10), Y = runif(10), Z = runif(10)))
get_torsion(sl)
#>  [1]  1.826578e+02  1.380349e+00  2.709291e+00  2.849553e+00 -4.872782e+00
#>  [6] -3.844751e+00  2.215573e+00  5.292907e+00 -2.781532e-03 -5.689486e+02
```
