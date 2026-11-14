# [`reparametrize()`](https://tractoverse.github.io/fiber/reference/reparametrize.md) method for `bundle_set` objects

Resamples every
[bundle](https://tractoverse.github.io/fiber/reference/bundle.md) inside
a
[bundle_set](https://tractoverse.github.io/fiber/reference/bundle_set.md)
onto a uniform arc-length grid. Each bundle is reparametrized
independently. See
[`reparametrize()`](https://tractoverse.github.io/fiber/reference/reparametrize.md)
for the full parameter documentation.

## Arguments

- x:

  A
  [bundle_set](https://tractoverse.github.io/fiber/reference/bundle_set.md)
  object.

- n_points:

  Number of equally-spaced arc-length points to use.

  - For a single
    [streamline](https://tractoverse.github.io/fiber/reference/streamline.md),
    defaults to `x@n_points`.

  - For a
    [bundle](https://tractoverse.github.io/fiber/reference/bundle.md),
    defaults to the rounded mean number of points across all
    streamlines.

  Pass `NULL` to use these defaults explicitly.

## Value

A
[bundle_set](https://tractoverse.github.io/fiber/reference/bundle_set.md)
where every streamline in every bundle has exactly `n_points` rows in
`@points`. When `n_points` is `NULL`, each bundle falls back to the
rounded mean number of points across its own streamlines. `@bundle_data`
and `@bundle_set_data` are preserved unchanged.

## See also

[`reparametrize()`](https://tractoverse.github.io/fiber/reference/reparametrize.md)
