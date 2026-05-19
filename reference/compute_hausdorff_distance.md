# Computes the Hausdorff distance between streamlines

`compute_hausdorff_distance()` is an S7 generic that computes the
symmetric Hausdorff distance between
[streamline](https://tractoverse.github.io/fiber/reference/streamline.md)
objects based on their 3-D coordinate matrices, with methods available
for the following classes:

- `ANY`

- [`fiber::bundle`](https://tractoverse.github.io/fiber/reference/compute_hausdorff_distance-fiber-bundle-method.md)

- [`fiber::streamline`](https://tractoverse.github.io/fiber/reference/compute_hausdorff_distance-fiber-streamline-method.md)

The four dispatch cases are:

- **`streamline` + `streamline`**: returns a single numeric scalar — the
  symmetric Hausdorff distance between the two streamlines.

- **`bundle` + missing**: returns a symmetric numeric distance matrix of
  dimension \\n \times n\\, where \\n\\ is the number of streamlines in
  the bundle, giving all pairwise Hausdorff distances.

- **`bundle` + `streamline`**: returns a numeric vector of length \\n\\
  giving the Hausdorff distance from `y` to each streamline in `x`.

- **`bundle` + `bundle`**: returns a symmetric numeric distance matrix
  of dimension \\(n_x + n_y) \times (n_x + n_y)\\, treating the
  concatenation of all streamlines from `x` and `y` as one collection.

## Usage

``` r
compute_hausdorff_distance(x, y = NULL)
```

## Arguments

- x:

  A
  [streamline](https://tractoverse.github.io/fiber/reference/streamline.md)
  or [bundle](https://tractoverse.github.io/fiber/reference/bundle.md)
  object.

- y:

  A
  [streamline](https://tractoverse.github.io/fiber/reference/streamline.md)
  or [bundle](https://tractoverse.github.io/fiber/reference/bundle.md)
  object, or `NULL` (default). When `NULL` and `x` is a
  [bundle](https://tractoverse.github.io/fiber/reference/bundle.md), the
  pairwise distance matrix within `x` is returned.

## Value

- A non-negative numeric scalar when both `x` and `y` are
  [streamline](https://tractoverse.github.io/fiber/reference/streamline.md)s.

- A [`dist`](https://rdrr.io/r/stats/dist.html) object of size \\n\\
  when `x` is a
  [bundle](https://tractoverse.github.io/fiber/reference/bundle.md) and
  `y` is `NULL` or a
  [bundle](https://tractoverse.github.io/fiber/reference/bundle.md) (use
  [`as.matrix()`](https://rdrr.io/r/base/matrix.html) to expand to a
  full \\n \times n\\ matrix).

- A numeric vector of length \\n\\ when `x` is a
  [bundle](https://tractoverse.github.io/fiber/reference/bundle.md) and
  `y` is a
  [streamline](https://tractoverse.github.io/fiber/reference/streamline.md).

## Examples

``` r
pts1 <- matrix(runif(30), ncol = 3)
colnames(pts1) <- c("X", "Y", "Z")
sl1 <- streamline(points = pts1)
pts2 <- matrix(runif(30), ncol = 3)
colnames(pts2) <- c("X", "Y", "Z")
sl2 <- streamline(points = pts2)

# streamline x streamline -> scalar
compute_hausdorff_distance(sl1, sl2)
#> [1] 0.402474

# bundle x missing -> pairwise dist object
b <- bundle(streamlines = list(sl1, sl2))
compute_hausdorff_distance(b)
#>          1
#> 2 0.402474
as.matrix(compute_hausdorff_distance(b))
#>          1        2
#> 1 0.000000 0.402474
#> 2 0.402474 0.000000

# bundle x streamline -> vector
compute_hausdorff_distance(b, sl1)
#> [1] 0.000000 0.402474

# bundle x bundle -> combined pairwise matrix
b2 <- bundle(streamlines = list(sl2))
compute_hausdorff_distance(b, b2)
#>          1        2
#> 2 0.402474         
#> 3 0.402474 0.000000
```
