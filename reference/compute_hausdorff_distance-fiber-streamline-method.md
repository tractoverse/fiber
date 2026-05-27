# [`compute_hausdorff_distance()`](https://tractoverse.github.io/fiber/reference/compute_hausdorff_distance.md) method for two `streamline` objects

[`compute_hausdorff_distance()`](https://tractoverse.github.io/fiber/reference/compute_hausdorff_distance.md)
method for two `streamline` objects

## Arguments

- x:

  A
  [streamline](https://tractoverse.github.io/fiber/reference/streamline.md)
  object.

- y:

  A
  [streamline](https://tractoverse.github.io/fiber/reference/streamline.md)
  object.

## Value

A non-negative numeric scalar equal to \\\max(d_H(x \to y),\\ d_H(y \to
x))\\, where \\d_H(A \to B) = \max\_{a \in A} \min\_{b \in B} \\a -
b\\\_2\\ is the directed Hausdorff distance. The core computation is
performed in C++ via `hausdorff_distance_cpp()`.

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
compute_hausdorff_distance(sl1, sl2)
#> [1] 0.402474
```
