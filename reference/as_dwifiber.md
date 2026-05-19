# Coerce a streamline or bundle to a `dwiFiber` object

`as_dwifiber()` converts a
[streamline](https://astamm.github.io/fiber/reference/streamline.md) or
[bundle](https://astamm.github.io/fiber/reference/bundle.md) to the S4
class `dwiFiber` from the dti package.

## Usage

``` r
as_dwifiber(x, ...)
```

## Arguments

- x:

  A [streamline](https://astamm.github.io/fiber/reference/streamline.md)
  or [bundle](https://astamm.github.io/fiber/reference/bundle.md)
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
`minfa`, `maxangle`, `ddim`, `ddim0`, `voxelext`, `orientation`,
`rotation`, `level`, and `source` are transferred to the corresponding
`dwiFiber` / `dwi` slots when present. MRI-acquisition metadata that
cannot be recovered from a `fiber` object (gradient directions,
b-values, etc.) are filled with neutral placeholders.

## See also

[`as_streamline()`](https://astamm.github.io/fiber/reference/as_streamline.md),
[`as_bundle()`](https://astamm.github.io/fiber/reference/as_bundle.md)

## Examples

``` r
if (FALSE) { # \dontrun{
# requires the dti package
pts <- matrix(runif(15), ncol = 3, dimnames = list(NULL, c("X", "Y", "Z")))
sl  <- streamline(points = pts)
b   <- bundle(streamlines = list(sl))
dfi <- as_dwifiber(b)
class(dfi)  # "dwiFiber"
} # }
```
