# Bundle S7 class

A `bundle` is an ordered collection of
[streamline](https://tractoverse.github.io/fiber/reference/streamline.md)
objects representing a tractogram or white-matter bundle. It stores
three compartments:

- `@streamlines` — a list of
  [streamline](https://tractoverse.github.io/fiber/reference/streamline.md)
  objects.

- `@streamline_data` — a named list of per-streamline vectors (any
  type), each of length \\S\\ (the number of streamlines). Values common
  to all streamlines may be lifted here automatically from the
  individual streamlines' `@streamline_data` slots at construction time.

- `@bundle_data` — a named list of scalars (length-1 values, any type)
  holding bundle-level metadata.

## Usage

``` r
bundle(streamlines = list(), streamline_data = list(), bundle_data = list())
```

## Arguments

- streamlines:

  A list of
  [streamline](https://tractoverse.github.io/fiber/reference/streamline.md)
  objects.

- streamline_data:

  A named list of per-streamline vectors of length S. If not supplied,
  any `@streamline_data` keys common to **all** streamlines are lifted
  automatically.

- bundle_data:

  A named list of bundle-level scalar metadata.

## Value

A `bundle` S7 object.

## Methods for standard generics

The following methods are defined for `bundle` objects:

- `format(x, ...)`: Returns a cli-formatted string describing the bundle
  object.

- `print(x, ...)`: Prints the formatted string to the console and
  invisibly returns `x`.

- `length(x)`: Returns the number of streamlines (equivalent to
  `x@n_streamlines`).

- `x[[i]]`: Extracts the `i`-th
  [streamline](https://tractoverse.github.io/fiber/reference/streamline.md)
  from the bundle, with bundle-level `@streamline_data` pushed back into
  the streamline.

- `x[i]`: Returns a new bundle containing only the selected streamlines,
  with `@bundle_data` and the subset of `@streamline_data` preserved.

## Additional properties

- `@n_streamlines`:

  An integer scalar giving the number of streamlines in the bundle
  (read-only).

- `@streamline_attributes`:

  A character vector of the names of the per-streamline attributes
  stored at the bundle level (read-only).

- `@bundle_attributes`:

  A character vector of the names of the bundle-level attributes
  (read-only).

## Examples

``` r
sl1 <- streamline(
  points = cbind(X = 0:4, Y = 0:4, Z = 0:4),
  streamline_data = list(mean_FA = 0.6, label = "CST")
)
sl2 <- streamline(
  points = cbind(X = 1:3, Y = 1:3, Z = 1:3),
  streamline_data = list(mean_FA = 0.7, label = "CST")
)
# mean_FA and label are common to both streamlines and are lifted
b <- bundle(streamlines = list(sl1, sl2))
b@n_streamlines  # 2
#> [1] 2
b@streamline_attributes  # c("mean_FA", "label")
#> [1] "mean_FA" "label"  
b@streamline_data$mean_FA  # c(0.6, 0.7)
#> [1] 0.6 0.7

# Subsetting pushes streamline_data back down
b[[1]]@streamline_data$mean_FA  # 0.6
#> [1] 0.6
b[1]@streamline_data$mean_FA    # c(0.6)
#> [1] 0.6
```
