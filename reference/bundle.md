# Bundle S7 class

A `bundle` is an ordered collection of
[streamline](https://astamm.github.io/fiber/reference/streamline.md)
objects representing a tractogram or white-matter bundle. It stores two
compartments:

- `@streamlines` — a list of
  [streamline](https://astamm.github.io/fiber/reference/streamline.md)
  objects.

- `@bundle_data` — a named list of bundle-level metadata (arbitrary R
  objects, e.g. the affine transform used during tracking).

## Usage

``` r
bundle(streamlines = list(), bundle_data = list())
```

## Arguments

- streamlines:

  A list of
  [streamline](https://astamm.github.io/fiber/reference/streamline.md)
  objects.

- bundle_data:

  A named list of bundle-level metadata.

## Value

A `bundle` S7 object.

## Methods for standard generics

The following methods are defined for `bundle` objects:

- `format(x, ...)`: Returns a compact character string such as
  `<bundle [2 streamlines | 10–20 pts/streamline]>`.

- `print(x, ...)`: Prints the formatted string to the console and
  invisibly returns `x`.

- `length(x)`: Returns the number of streamlines (equivalent to
  `x@n_streamlines`).

- `x[[i]]`: Extracts the `i`-th
  [streamline](https://astamm.github.io/fiber/reference/streamline.md)
  from the bundle.

- `x[i]`: Returns a new bundle containing only the selected streamlines,
  preserving `@bundle_data`.

## Additional properties

- `@n_streamlines`:

  An integer scalar giving the number of streamlines in the bundle
  (read-only).

- `@bundle_attributes`:

  A character vector of the names of the bundle-level attributes
  (read-only).

## Examples

``` r
pts <- matrix(runif(15), ncol = 3, dimnames = list(NULL, c("X", "Y", "Z")))
sl <- streamline(points = pts)
b <- bundle(streamlines = list(sl))
b@n_streamlines  # 1
#> [1] 1
b@bundle_attributes  # NULL (no bundle-level attributes)
#> NULL

# bundle_data is stored
b2 <- bundle(
  streamlines = list(sl),
  bundle_data = list(subject = "sub-01")
)
b2@bundle_data$subject  # "sub-01"
#> [1] "sub-01"

# format(), print(), length() and indexing methods
format(b2)
#> [1] "<bundle [1 streamlines | 5–5 pts/streamline] | bundle: subject>"
print(b2)
#> <bundle [1 streamlines | 5–5 pts/streamline] | bundle: subject> 
length(b2)   # 1
#> [1] 1
b2[[1]]      # first streamline
#> <streamline [5 pts]> 

# subsetting preserves bundle_data
pts2 <- matrix(runif(15), ncol = 3, dimnames = list(NULL, c("X", "Y", "Z")))
sl2 <- streamline(points = pts2)
b3 <- bundle(streamlines = list(sl, sl2), bundle_data = list(subject = "sub-01"))
b3[1]@n_streamlines  # 1, bundle_data preserved
#> [1] 1
```
