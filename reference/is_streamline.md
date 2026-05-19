# Test whether an object is a streamline

Test whether an object is a streamline

## Usage

``` r
is_streamline(x)
```

## Arguments

- x:

  An object.

## Value

`TRUE` if `x` is of class
[streamline](https://astamm.github.io/fiber/reference/streamline.md),
otherwise `FALSE`.

## Examples

``` r
pts <- matrix(runif(15), ncol = 3, dimnames = list(NULL, c("X", "Y", "Z")))
sl <- streamline(points = pts)
is_streamline(sl)     # TRUE
#> [1] TRUE
is_streamline(42)     # FALSE
#> [1] FALSE
```
