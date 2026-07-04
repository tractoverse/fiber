# Combine bundles and/or bundle_sets into a single bundle_set

Accepts any mix of
[bundle](https://tractoverse.github.io/fiber/reference/bundle.md)
objects or
[bundle_set](https://tractoverse.github.io/fiber/reference/bundle_set.md)
objects. All bundles are collected into a flat list and wrapped in a new
[bundle_set](https://tractoverse.github.io/fiber/reference/bundle_set.md).
Bare [bundle](https://tractoverse.github.io/fiber/reference/bundle.md)
arguments may optionally be named; unnamed bundles are included without
a name label.

## Usage

``` r
bind_bundle_sets(..., bundle_data = NULL, set_data = NULL)
```

## Arguments

- ...:

  [bundle](https://tractoverse.github.io/fiber/reference/bundle.md)
  objects or
  [bundle_set](https://tractoverse.github.io/fiber/reference/bundle_set.md)
  objects to combine. Named bare
  [bundle](https://tractoverse.github.io/fiber/reference/bundle.md)
  arguments will carry their name into the resulting set.

- bundle_data:

  A named list of per-bundle vectors to attach to the resulting
  [bundle_set](https://tractoverse.github.io/fiber/reference/bundle_set.md).
  Defaults to the `@bundle_data` of the first
  [bundle_set](https://tractoverse.github.io/fiber/reference/bundle_set.md)
  input if present.

- set_data:

  A named list of set-level scalar metadata to attach to the resulting
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
sl <- streamline(points = cbind(X = runif(5), Y = runif(5), Z = runif(5)))
b1 <- bundle(streamlines = list(sl))
b2 <- bundle(streamlines = list(sl))

# two named bare bundles
bs <- bind_bundle_sets("sub-01" = b1, "sub-02" = b2)
bs@n_bundles   # 2
#> [1] 2
bs@bundle_data$if_from_input_list  # c("sub-01", "sub-02")
#> NULL

# combine two bundle_sets
bs1 <- bundle_set(list("sub-01" = b1))
bs2 <- bundle_set(list("sub-02" = b2))
bs_all <- bind_bundle_sets(bs1, bs2)
bs_all@n_bundles  # 2
#> [1] 2
```
