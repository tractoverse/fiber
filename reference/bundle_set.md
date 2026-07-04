# Bundle set S7 class

A `bundle_set` is a collection of
[bundle](https://tractoverse.github.io/fiber/reference/bundle.md)
objects, designed for multi-subject or multi-session studies where each
element represents one subject's (or session's) tractogram. It stores
three compartments:

- `@bundles` — a list of
  [bundle](https://tractoverse.github.io/fiber/reference/bundle.md)
  objects (names are optional).

- `@bundle_data` — a named list of per-bundle vectors (any type), each
  of length \\B\\ (the number of bundles). Values common to all bundles
  may be lifted here automatically from the individual bundles'
  `@bundle_data` slots at construction time.

- `@set_data` — a named list of scalars (length-1 values, any type)
  holding set-level metadata.

## Usage

``` r
bundle_set(bundles = list(), bundle_data = list(), set_data = list())
```

## Arguments

- bundles:

  A list of
  [bundle](https://tractoverse.github.io/fiber/reference/bundle.md)
  objects (may be named or unnamed).

- bundle_data:

  A named list of per-bundle vectors of length B. If not supplied, any
  `@bundle_data` keys common to **all** bundles are lifted
  automatically.

- set_data:

  A named list of set-level scalar metadata.

## Value

A `bundle_set` S7 object.

## Methods for standard generics

The following methods are defined for `bundle_set` objects:

- `format(x, ...)`: Returns a styled character string.

- `print(x, ...)`: Prints the formatted string to the console and
  invisibly returns `x`.

- `length(x)`: Returns the number of bundles.

- `x[[i]]`: Extracts the `i`-th (or named)
  [bundle](https://tractoverse.github.io/fiber/reference/bundle.md) from
  the set, with set-level `@bundle_data` pushed back into the bundle.

- `x[i]`: Returns a new bundle_set containing only the selected bundles,
  with `@set_data` and the subset of `@bundle_data` preserved.

## Additional properties

- `@n_bundles`:

  An integer scalar giving the number of bundles in the set (read-only).

- `@bundle_attributes`:

  A character vector of the names of the per-bundle attributes stored at
  the set level (read-only).

- `@set_attributes`:

  A character vector of the names of the set-level attributes
  (read-only).

## Examples

``` r
sl <- streamline(points = cbind(X = 1:5, Y = 1:5, Z = 1:5))
b1 <- bundle(
  streamlines = list(sl),
  bundle_data = list(subject = "sub-01")
)
b2 <- bundle(
  streamlines = list(sl),
  bundle_data = list(subject = "sub-02")
)
# subject is common across bundles and lifted to bundle_set@bundle_data
bs <- bundle_set(bundles = list("sub-01" = b1, "sub-02" = b2))
bs@n_bundles          # 2
#> [1] 2
bs@bundle_attributes  # "subject"
#> [1] "subject"             "id_from_input_names"
bs@bundle_data$subject  # c("sub-01", "sub-02")
#> [1] "sub-01" "sub-02"
```
