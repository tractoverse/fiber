# Combine bundles and/or bundle_sets into a single bundle_set

Accepts any mix of named
[bundle](https://tractoverse.github.io/fiber/reference/bundle.md)
objects (passed as `name = bundle`) or
[bundle_set](https://tractoverse.github.io/fiber/reference/bundle_set.md)
objects. All bundles are collected into a flat named list and wrapped in
a new
[bundle_set](https://tractoverse.github.io/fiber/reference/bundle_set.md).

## Usage

``` r
bind_bundle_sets(..., set_data = NULL)
```

## Arguments

- ...:

  Named
  [bundle](https://tractoverse.github.io/fiber/reference/bundle.md)
  objects or
  [bundle_set](https://tractoverse.github.io/fiber/reference/bundle_set.md)
  objects to combine. Each bare
  [bundle](https://tractoverse.github.io/fiber/reference/bundle.md)
  argument must be **named** so that its label in the resulting set is
  unambiguous.

- set_data:

  A named list of set-level metadata to attach to the resulting
  [bundle_set](https://tractoverse.github.io/fiber/reference/bundle_set.md).
  Defaults to the `set_data` of the first
  [bundle_set](https://tractoverse.github.io/fiber/reference/bundle_set.md)
  input (if present) or an empty list.

## Value

A
[bundle_set](https://tractoverse.github.io/fiber/reference/bundle_set.md)
containing all input bundles.

## Examples

``` r
pts <- matrix(runif(15), ncol = 3, dimnames = list(NULL, c("X", "Y", "Z")))
b1 <- bundle(streamlines = list(streamline(points = pts)))
b2 <- bundle(streamlines = list(streamline(points = pts)))

# two named bare bundles
bs <- bind_bundle_sets("sub-01" = b1, "sub-02" = b2)
bs@n_bundles   # 2
#> [1] 2
bs@bundle_names  # c("sub-01", "sub-02")
#> [1] "sub-01" "sub-02"

# combine two bundle_sets
bs1 <- bundle_set(list("sub-01" = b1))
bs2 <- bundle_set(list("sub-02" = b2))
bs_all <- bind_bundle_sets(bs1, bs2)
bs_all@n_bundles  # 2
#> [1] 2
```
