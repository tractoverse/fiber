# Test whether an object is a bundle

Test whether an object is a bundle

## Usage

``` r
is_bundle(x)
```

## Arguments

- x:

  An object.

## Value

`TRUE` if `x` is of class
[bundle](https://tractoverse.github.io/fiber/reference/bundle.md),
otherwise `FALSE`.

## Examples

``` r
sl <- streamline(points = cbind(X = 1:5, Y = 1:5, Z = 1:5))
b <- bundle(streamlines = list(sl))
is_bundle(b)   # TRUE
#> [1] TRUE
is_bundle(sl)  # FALSE
#> [1] FALSE
```
