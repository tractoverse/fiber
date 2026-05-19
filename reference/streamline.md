# Streamline S7 class

A `streamline` represents a single fibre tract. It stores three data
compartments that mirror the conceptual levels found in tractography
file formats:

- `@points` — an \\n \times 3\\ numeric matrix whose columns are named
  `"X"`, `"Y"`, and `"Z"`, holding the ordered 3-D coordinates of the
  \\n\\ points along the tract.

- `@point_data` — a named list of numeric vectors, each of length \\n\\,
  holding per-point scalar attributes (e.g. fractional anisotropy
  sampled at every point).

- `@streamline_data` — a named list of numeric scalars (length-1
  vectors) holding per-streamline attributes (e.g. a tract-level weight
  or mean FA).

## Usage

``` r
streamline(points = NULL, point_data = list(), streamline_data = list())
```

## Arguments

- points:

  A numeric matrix with columns `"X"`, `"Y"`, and `"Z"`.

- point_data:

  A named list of per-point numeric vectors.

- streamline_data:

  A named list of per-streamline numeric scalars.

## Value

A `streamline` S7 object.

## Methods for standard generics

The following methods are defined for `streamline` objects:

- `format(x, ...)`: Returns a compact character string such as
  `<streamline [10 pts] | point: FA>`.

- `print(x, ...)`: Prints the formatted string to the console and
  invisibly returns `x`.

## Additional properties

- `@n_points`:

  An integer scalar giving the number of points in the streamline
  (read-only).

- `@point_attributes`:

  A character vector of the names of the per-point attributes
  (read-only).

- `@streamline_attributes`:

  A character vector of the names of the per-streamline attributes
  (read-only).

## Examples

``` r
# Create a streamline with 5 points and some attributes
sl <- streamline(
  points = matrix(
    c(0, 0, 0,
      1, 0, 0,
      1, 1, 0,
      1, 1, 1,
      0, 1, 1),
    ncol = 3,
    byrow = TRUE,
    dimnames = list(NULL, c("X", "Y", "Z"))
  ),
  point_data = list(FA = c(0.5, 0.6, 0.7, 0.8, 0.9)),
  streamline_data = list(mean_FA = 0.7)
)
sl@n_points  # 5
#> [1] 5
sl@point_attributes  # "FA"
#> [1] "FA"
sl@streamline_attributes  # "mean_FA"
#> [1] "mean_FA"

# format() and print() methods
format(sl)  # "<streamline [5 pts] | point: FA | streamline: mean_FA>"
#> [1] "<streamline [5 pts] | point: FA | streamline: mean_FA>"
print(sl)
#> <streamline [5 pts] | point: FA | streamline: mean_FA> 
```
