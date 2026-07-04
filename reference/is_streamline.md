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
[streamline](https://tractoverse.github.io/fiber/reference/streamline.md),
otherwise `FALSE`.

## Examples

``` r
sl <- streamline(points = cbind(X = 1:5, Y = 1:5, Z = 1:5))
is_streamline(sl) # TRUE
#> [1] TRUE
is_streamline(42) # FALSE
#> [1] FALSE
```
