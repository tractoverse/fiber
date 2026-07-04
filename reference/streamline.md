# Streamline S7 class

A `streamline` represents a single fibre tract. It stores three data
compartments:

- `@points` — a \\P \times 3\\ numeric matrix with column names `"X"`,
  `"Y"`, and `"Z"` holding the 3-D coordinates of the \\P\\ points along
  the tract.

- `@point_data` — a named list of numeric vectors, each of length \\P\\,
  holding additional per-point scalar attributes (e.g. fractional
  anisotropy). Coordinates are **not** stored here.

- `@streamline_data` — a named list of scalars (length-1 values of any
  type) holding per-streamline attributes (e.g. a tract-level weight or
  mean FA, or a character label).

## Usage

``` r
streamline(points = NULL, point_data = list(), streamline_data = list())
```

## Arguments

- points:

  A \\P \times 3\\ numeric matrix with column names `"X"`, `"Y"`, and
  `"Z"` giving the 3-D coordinates of the streamline points.

- point_data:

  A named list of numeric vectors, each of length \\P\\, holding
  additional per-point attributes. Must **not** include `"X"`, `"Y"`, or
  `"Z"` (those live in `@points`).

- streamline_data:

  A named list of per-streamline scalars (length-1, any type).

## Value

A `streamline` S7 object.

## Methods for standard generics

The following methods are defined for `streamline` objects:

- `format(x, ...)`: Returns a cli-formatted string describing the
  streamline object.

- `print(x, ...)`: Prints the formatted string to the console and
  invisibly returns `x`.

## Additional properties

- `@n_points`:

  An integer scalar giving the number of points in the streamline
  (read-only).

- `@point_attributes`:

  A character vector of the names of the per-point attributes stored in
  `@point_data` (read-only).

- `@streamline_attributes`:

  A character vector of the names of the per-streamline attributes
  (read-only).

## Examples

``` r
# Create a streamline with 5 points and some attributes
sl <- streamline(
  points = cbind(
    X = c(0, 1, 1, 1, 0),
    Y = c(0, 0, 1, 1, 1),
    Z = c(0, 0, 0, 1, 1)
  ),
  point_data = list(FA = c(0.5, 0.6, 0.7, 0.8, 0.9)),
  streamline_data = list(mean_FA = 0.7, label = "CST")
)
sl@n_points         # 5
#> [1] 5
sl@point_attributes # "FA"
#> [1] "FA"
sl@streamline_attributes # c("mean_FA", "label")
#> [1] "mean_FA" "label"  

# format() and print() methods
format(sl)
#> [1] "\n── \033[1m\033[1mObject of class \033[1m`fiber::streamline()`\033[1m with \033[1m5\033[1m points.\033[1m\033[22m ──\n\n\033[36m•\033[39m Point attributes: \033[34m\"FA\"\033[39m\n\033[36m•\033[39m Streamline attributes: \033[34m\"mean_FA\"\033[39m and \033[34m\"label\"\033[39m\n"
print(sl)
#> 
#> ── Object of class `fiber::streamline()` with 5 points. ──
#> 
#> • Point attributes: "FA"
#> • Streamline attributes: "mean_FA" and "label"
#>  
```
