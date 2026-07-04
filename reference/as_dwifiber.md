# Coerce a streamline or bundle to a `dwiFiber` object

`as_dwifiber()` converts a
[streamline](https://tractoverse.github.io/fiber/reference/streamline.md)
or [bundle](https://tractoverse.github.io/fiber/reference/bundle.md) to
the S4 class `dwiFiber` from the dti package.

## Usage

``` r
as_dwifiber(x, ...)
```

## Arguments

- x:

  A
  [streamline](https://tractoverse.github.io/fiber/reference/streamline.md)
  or [bundle](https://tractoverse.github.io/fiber/reference/bundle.md)
  object.

- ...:

  Additional arguments (currently unused).

## Value

An S4 object of class `dwiFiber` (from dti).

## Details

Per-point direction vectors are taken from `@point_data$direction_x`,
`@point_data$direction_y`, and `@point_data$direction_z` when present;
otherwise they are estimated via finite differences of the coordinates
(forward difference at the first point, backward difference at the last,
central differences in between), then unit-normalised.

Bundle-level metadata stored in `@bundle_data` under the keys `method`,
`minfa`, `maxangle`, `level`, and `source` are transferred to the
corresponding `dwiFiber` slots when present. Vector-valued fields such
as `ddim`, `ddim0`, `voxelext`, and `orientation` must be stored as
individual scalars (e.g. `ddim_1`, `ddim_2`, `ddim_3`) and are
reconstructed into vectors for the `dwiFiber` object.

## See also

[`as_streamline()`](https://tractoverse.github.io/fiber/reference/as_streamline.md),
[`as_bundle()`](https://tractoverse.github.io/fiber/reference/as_bundle.md)

## Examples

``` r
if (requireNamespace("dti", quietly = TRUE)) {
  sl <- streamline(points = cbind(X = runif(5), Y = runif(5), Z = runif(5)))
  b  <- bundle(streamlines = list(sl))
  dfi <- as_dwifiber(b)
  class(dfi)  # "dwiFiber"
}
#> Warning: RGL: unable to open X11 display
#> Warning: 'rgl.init' failed, will use the null device.
#> See '?rgl.useNULL' for ways to avoid this warning.
#> [1] "dwiFiber"
#> attr(,"package")
#> [1] "dti"
```
