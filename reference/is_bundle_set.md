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
sl <- streamline(points = cbind(X = 1:5, Y = 1:5, Z = 1:5))
b <- bundle(streamlines = list(sl))
bs <- bundle_set(bundles = list(b))
is_bundle_set(bs)  # TRUE
#> [1] TRUE
is_bundle_set(b)   # FALSE
#> [1] FALSE
```
