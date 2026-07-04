# Coerce an object to a streamline

`as_streamline()` converts a supported object into a
[streamline](https://tractoverse.github.io/fiber/reference/streamline.md).

## Usage

``` r
as_streamline(x, ...)
```

## Arguments

- x:

  An object to coerce.

- ...:

  Additional arguments (currently unused).

## Value

A
[streamline](https://tractoverse.github.io/fiber/reference/streamline.md)
object.

## Details

Currently supported input classes:

- [streamline](https://tractoverse.github.io/fiber/reference/streamline.md):
  returned unchanged.

- `dwiFiber` (from dti): the object must contain **exactly one** fiber.
  For multi-fiber objects use
  [`as_bundle()`](https://tractoverse.github.io/fiber/reference/as_bundle.md)
  instead.

## See also

[`as_bundle()`](https://tractoverse.github.io/fiber/reference/as_bundle.md),
[`as_dwifiber()`](https://tractoverse.github.io/fiber/reference/as_dwifiber.md)

## Examples

``` r
sl <- streamline(points = cbind(X = runif(5), Y = runif(5), Z = runif(5)))
identical(as_streamline(sl), sl)  # TRUE — identity coercion
#> [1] TRUE
```
