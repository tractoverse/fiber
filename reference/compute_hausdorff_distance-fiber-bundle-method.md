# [`compute_hausdorff_distance()`](https://tractoverse.github.io/fiber/reference/compute_hausdorff_distance.md) method for `bundle` objects

Dispatches to one of three behaviours depending on `y`:

## Arguments

- x:

  A [bundle](https://tractoverse.github.io/fiber/reference/bundle.md)
  object.

- y:

  `NULL`, a
  [streamline](https://tractoverse.github.io/fiber/reference/streamline.md),
  or a
  [bundle](https://tractoverse.github.io/fiber/reference/bundle.md).

## Value

- A [`dist`](https://rdrr.io/r/stats/dist.html) object of size
  `x@n_streamlines` when `y` is `NULL` or a
  [bundle](https://tractoverse.github.io/fiber/reference/bundle.md). The
  lower triangle stores all pairwise symmetric Hausdorff distances
  (computed in C++). Use
  [`as.matrix()`](https://rdrr.io/r/base/matrix.html) to obtain the full
  \\n \times n\\ matrix.

- A numeric vector of length `x@n_streamlines` when `y` is a
  [streamline](https://tractoverse.github.io/fiber/reference/streamline.md).

## Details

- `y = NULL`: pairwise distances within `x` as a
  [`dist`](https://rdrr.io/r/stats/dist.html) object of size \\n\\,
  computed in C++ via a single linear loop.

- `y` is a
  [streamline](https://tractoverse.github.io/fiber/reference/streamline.md):
  numeric vector of distances from `y` to each streamline in `x`.

- `y` is a
  [bundle](https://tractoverse.github.io/fiber/reference/bundle.md):
  [`dist`](https://rdrr.io/r/stats/dist.html) object for the
  concatenation of all streamlines from `x` and `y`.

## See also

[`compute_hausdorff_distance()`](https://tractoverse.github.io/fiber/reference/compute_hausdorff_distance.md)

## Examples

``` r
pts1 <- matrix(runif(30), ncol = 3)
colnames(pts1) <- c("X", "Y", "Z")
pts2 <- matrix(runif(30), ncol = 3)
colnames(pts2) <- c("X", "Y", "Z")
sl1 <- streamline(points = pts1)
sl2 <- streamline(points = pts2)
b <- bundle(streamlines = list(sl1, sl2))

# pairwise dist object (size 2)
compute_hausdorff_distance(b)
#>           1
#> 2 0.4346477
as.matrix(compute_hausdorff_distance(b))
#>           1         2
#> 1 0.0000000 0.4346477
#> 2 0.4346477 0.0000000

# distances from sl1 to each streamline in b
compute_hausdorff_distance(b, sl1)
#> [1] 0.0000000 0.4346477
```
