# Coerce an object to a bundle_set

`as_bundle_set()` converts a supported object into a
[bundle_set](https://tractoverse.github.io/fiber/reference/bundle_set.md).

## Usage

``` r
as_bundle_set(x, ...)
```

## Arguments

- x:

  An object to coerce.

- ...:

  Additional arguments passed to methods (e.g. `name` for bundles).

## Value

A
[bundle_set](https://tractoverse.github.io/fiber/reference/bundle_set.md)
object.

## Details

Currently supported input classes:

- [bundle_set](https://tractoverse.github.io/fiber/reference/bundle_set.md):
  returned unchanged.

- [bundle](https://tractoverse.github.io/fiber/reference/bundle.md):
  wrapped in a single-element
  [bundle_set](https://tractoverse.github.io/fiber/reference/bundle_set.md).
  An optional `name` argument sets the element name (defaults to
  `"bundle_1"`).

## See also

[`bundle_set()`](https://tractoverse.github.io/fiber/reference/bundle_set.md),
[`bind_bundle_sets()`](https://tractoverse.github.io/fiber/reference/bind_bundle_sets.md)

## Examples

``` r
pts <- matrix(runif(15), ncol = 3, dimnames = list(NULL, c("X", "Y", "Z")))
b <- bundle(streamlines = list(streamline(points = pts)))
bs <- as_bundle_set(b, name = "sub-01")
bs@n_bundles  # 1
#> [1] 1
```
