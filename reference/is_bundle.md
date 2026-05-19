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
[bundle](https://astamm.github.io/fiber/reference/bundle.md), otherwise
`FALSE`.

## Examples

``` r
pts <- matrix(runif(15), ncol = 3, dimnames = list(NULL, c("X", "Y", "Z")))
sl <- streamline(points = pts)
b <- bundle(streamlines = list(sl))
is_bundle(b)   # TRUE
#> [1] TRUE
is_bundle(sl)  # FALSE
#> [1] FALSE
```
