# Coerce an object to a bundle

`as_bundle()` converts a supported object into a
[bundle](https://tractoverse.github.io/fiber/reference/bundle.md).

## Usage

``` r
as_bundle(x, ...)
```

## Arguments

- x:

  An object to coerce.

- ...:

  Additional arguments (currently unused).

## Value

A [bundle](https://tractoverse.github.io/fiber/reference/bundle.md)
object.

## Details

Currently supported input classes:

- [streamline](https://tractoverse.github.io/fiber/reference/streamline.md):
  wrapped in a single-element
  [bundle](https://tractoverse.github.io/fiber/reference/bundle.md)
  (lossless).

- [bundle](https://tractoverse.github.io/fiber/reference/bundle.md):
  returned unchanged.

- `dwiFiber` (from dti): each fiber becomes a
  [streamline](https://tractoverse.github.io/fiber/reference/streamline.md).
  The per-point direction vectors (columns 4–6 of `@fibers`) are stored
  as `@point_data$direction_x`, `@point_data$direction_y`, and
  `@point_data$direction_z`. Tracking metadata (`method`, `minfa`,
  `maxangle`) are stored as scalars in `@bundle_data`. Vector metadata
  (`ddim`, `ddim0`, `voxelext`, `orientation`) are stored as individual
  scalar entries (e.g. `voxelext_1`, `voxelext_2`, `voxelext_3`).

## See also

[`as_streamline()`](https://tractoverse.github.io/fiber/reference/as_streamline.md),
[`as_dwifiber()`](https://tractoverse.github.io/fiber/reference/as_dwifiber.md)

## Examples

``` r
sl <- streamline(points = cbind(X = runif(5), Y = runif(5), Z = runif(5)))
b  <- as_bundle(sl)
b@n_streamlines  # 1
#> [1] 1
```
