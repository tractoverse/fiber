# Test whether an object is a bundle_set

Test whether an object is a bundle_set

## Usage

``` r
is_bundle_set(x)
```

## Arguments

- x:

  An object.

## Value

`TRUE` if `x` is of class
[bundle_set](https://tractoverse.github.io/fiber/reference/bundle_set.md),
otherwise `FALSE`.

## Examples

``` r
pts <- matrix(runif(15), ncol = 3, dimnames = list(NULL, c("X", "Y", "Z")))
b <- bundle(streamlines = list(streamline(points = pts)))
bs <- bundle_set(bundles = list("sub-01" = b))
is_bundle_set(bs)  # TRUE
#> [1] TRUE
is_bundle_set(b)   # FALSE
#> [1] FALSE
```
