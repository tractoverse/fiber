# Combine streamlines and/or bundles into a single bundle

Accepts any mix of
[streamline](https://astamm.github.io/fiber/reference/streamline.md) and
[bundle](https://astamm.github.io/fiber/reference/bundle.md) objects.
All streamlines are collected into a flat list and wrapped in a new
[bundle](https://astamm.github.io/fiber/reference/bundle.md).
`bundle_data` from the first
[bundle](https://astamm.github.io/fiber/reference/bundle.md) argument
(if any) is preserved; pass your own via the `bundle_data` argument to
override.

## Usage

``` r
bind_bundles(..., bundle_data = NULL)
```

## Arguments

- ...:

  One or more
  [streamline](https://astamm.github.io/fiber/reference/streamline.md)
  or [bundle](https://astamm.github.io/fiber/reference/bundle.md)
  objects.

- bundle_data:

  A named list of bundle-level metadata to attach to the resulting
  [bundle](https://astamm.github.io/fiber/reference/bundle.md). Defaults
  to an empty list (or the `bundle_data` of the first
  [bundle](https://astamm.github.io/fiber/reference/bundle.md) input if
  one is present and `bundle_data` is not supplied).

## Value

A [bundle](https://astamm.github.io/fiber/reference/bundle.md)
containing all input streamlines.
