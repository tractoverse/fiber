# Bundle set S7 class

A `bundle_set` is a **named collection of
[bundle](https://tractoverse.github.io/fiber/reference/bundle.md)
objects**, designed for multi-subject or multi-session studies where
each element represents one subject's (or session's) tractogram. It
stores two compartments:

- `@bundles` — a *named* list of
  [bundle](https://tractoverse.github.io/fiber/reference/bundle.md)
  objects. Names typically encode subject or session identifiers (e.g.
  `"sub-01"`, `"sub-02"`).

- `@set_data` — a named list of set-level metadata (arbitrary R objects,
  e.g. study name, atlas used, acquisition protocol).

## Usage

``` r
bundle_set(bundles = list(), set_data = list())
```

## Arguments

- bundles:

  A named list of
  [bundle](https://tractoverse.github.io/fiber/reference/bundle.md)
  objects.

- set_data:

  A named list of set-level metadata.

## Value

A `bundle_set` S7 object.

## Methods for standard generics

The following methods are defined for `bundle_set` objects:

- `format(x, ...)`: Returns a compact character string.

- `print(x, ...)`: Prints the formatted string to the console and
  invisibly returns `x`.

- `length(x)`: Returns the number of bundles.

- `x[[i]]`: Extracts the `i`-th (or named)
  [bundle](https://tractoverse.github.io/fiber/reference/bundle.md) from
  the set.

- `x[i]`: Returns a new bundle_set containing only the selected bundles,
  preserving `@set_data`.

- `names(x)`: Returns the names of the bundles.

## Additional properties

- `@n_bundles`:

  An integer scalar giving the number of bundles in the set (read-only).

- `@bundle_names`:

  A character vector of the names of the bundles (read-only).

- `@set_attributes`:

  A character vector of the names of the set-level attributes
  (read-only).

## Examples

``` r
pts <- matrix(runif(15), ncol = 3, dimnames = list(NULL, c("X", "Y", "Z")))
b1 <- bundle(streamlines = list(streamline(points = pts)),
             bundle_data = list(subject = "sub-01"))
b2 <- bundle(streamlines = list(streamline(points = pts)),
             bundle_data = list(subject = "sub-02"))
bs <- bundle_set(bundles = list("sub-01" = b1, "sub-02" = b2))
bs@n_bundles      # 2
#> [1] 2
bs@bundle_names   # c("sub-01", "sub-02")
#> [1] "sub-01" "sub-02"
bs[["sub-01"]]    # first bundle
#> <bundle [1 streamlines | 5–5 pts/streamline] | bundle: subject> 
```
