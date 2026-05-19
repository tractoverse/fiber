# Combine streamlines and/or bundles into a single bundle

Accepts any mix of
[streamline](https://tractoverse.github.io/fiber/reference/streamline.md)
and [bundle](https://tractoverse.github.io/fiber/reference/bundle.md)
objects. All streamlines are collected into a flat list and wrapped in a
new [bundle](https://tractoverse.github.io/fiber/reference/bundle.md).
`bundle_data` from the first
[bundle](https://tractoverse.github.io/fiber/reference/bundle.md)
argument (if any) is preserved; pass your own via the `bundle_data`
argument to override.

## Usage

``` r
bind_bundles(..., bundle_data = NULL)
```

## Arguments

- ...:

  One or more
  [streamline](https://tractoverse.github.io/fiber/reference/streamline.md)
  or [bundle](https://tractoverse.github.io/fiber/reference/bundle.md)
  objects.

- bundle_data:

  A named list of bundle-level metadata to attach to the resulting
  [bundle](https://tractoverse.github.io/fiber/reference/bundle.md).
  Defaults to an empty list (or the `bundle_data` of the first
  [bundle](https://tractoverse.github.io/fiber/reference/bundle.md)
  input if one is present and `bundle_data` is not supplied).

## Value

A [bundle](https://tractoverse.github.io/fiber/reference/bundle.md)
containing all input streamlines.

## Examples

``` r
pts <- matrix(runif(15), ncol = 3, dimnames = list(NULL, c("X", "Y", "Z")))
sl1 <- streamline(points = pts)
sl2 <- streamline(points = pts)
b1 <- bundle(streamlines = list(sl1))
b2 <- bundle(streamlines = list(sl2))

# combine two bundles
b_all <- bind_bundles(b1, b2)
b_all@n_streamlines  # 2
#> [1] 2

# mix a bundle and a loose streamline
b_mixed <- bind_bundles(b1, sl2)
b_mixed@n_streamlines  # 2
#> [1] 2
```
