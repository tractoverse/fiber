# fiber

## Overview

The [**fiber**](https://tractoverse.github.io/fiber/) package provides
two [S7](https://rconsortium.github.io/S7/) classes — `streamline` and
`bundle` — for representing diffusion MRI tractography data in R,
together with a concise set of methods:

| Function | Description |
|----|----|
| [`streamline()`](https://tractoverse.github.io/fiber/reference/streamline.md) | Construct a single streamline |
| [`bundle()`](https://tractoverse.github.io/fiber/reference/bundle.md) | Construct a bundle of streamlines |
| [`is_streamline()`](https://tractoverse.github.io/fiber/reference/is_streamline.md) | Test if an object is a `streamline` |
| [`is_bundle()`](https://tractoverse.github.io/fiber/reference/is_bundle.md) | Test if an object is a `bundle` |
| [`bind_bundles()`](https://tractoverse.github.io/fiber/reference/bind_bundles.md) | Combine streamlines and/or bundles |
| [`reparametrize()`](https://tractoverse.github.io/fiber/reference/reparametrize.md) | Resample onto a uniform arc-length grid |
| [`as_dwifiber()`](https://tractoverse.github.io/fiber/reference/as_dwifiber.md) | Coerce to `dwiFiber` class from [](https://cran.r-project.org/package=dti) |
| [`as_streamline()`](https://tractoverse.github.io/fiber/reference/as_streamline.md) | Coerce to `streamline` class |
| [`as_bundle()`](https://tractoverse.github.io/fiber/reference/as_bundle.md) | Coerce to `bundle` class |
| [`get_euclidean_length()`](https://tractoverse.github.io/fiber/reference/get_euclidean_length.md) | Straight-line distance between endpoints |
| [`get_curvilinear_length()`](https://tractoverse.github.io/fiber/reference/get_curvilinear_length.md) | Total arc-length |
| [`get_sinuosity()`](https://tractoverse.github.io/fiber/reference/get_sinuosity.md) | Curvilinear / Euclidean length ratio |
| [`get_curvature()`](https://tractoverse.github.io/fiber/reference/get_curvature.md) | Curvature profile or summary scalar |
| [`get_torsion()`](https://tractoverse.github.io/fiber/reference/get_torsion.md) | Torsion profile or summary scalar |
| [`add_shape_descriptors()`](https://tractoverse.github.io/fiber/reference/add_shape_descriptors.md) | Add curvature, torsion, and/or sinuosity to `@point_data` and/or `@streamline_data` |
| [`compute_hausdorff_distance()`](https://tractoverse.github.io/fiber/reference/compute_hausdorff_distance.md) | Symmetric Hausdorff distance |

### Classes

A `streamline` stores:

- `@points` — an $`n \times 3`$ numeric matrix with columns `"X"`,
  `"Y"`, `"Z"`.
- `@point_data` — a named list of per-point numeric vectors (length
  $`n`$).
- `@streamline_data` — a named list of per-streamline numeric scalars.

A `bundle` stores:

- `@streamlines` — a list of `streamline` objects.
- `@bundle_data` — a named list of bundle-level metadata.

## Installation

You can install the development version of **fiber** from
[GitHub](https://github.com/tractoverse/fiber) with:

``` r

# install.packages("pak")
pak::pak("tractoverse/fiber")
```

## Quick start

``` r

library(fiber)

# Build a helix streamline (50 points)
t <- seq(0, 2 * pi, length.out = 50)
sl <- streamline(
  points = cbind(X = cos(t), Y = sin(t), Z = t / (2 * pi))
)
sl
#> <streamline [50 pts]>

# Shape descriptors
get_curvilinear_length(sl)
#> [1] 6.358015
get_sinuosity(sl)
#> [1] 6.358015
head(get_curvature(sl))
#> [1] 1.537338e-05 1.625127e-02 4.592627e-02 8.636675e-02 1.352354e-01
#> [6] 1.906608e-01

# Bundle two streamlines
sl2 <- streamline(
  points = cbind(X = cos(t) * 1.1, Y = sin(t) * 1.1, Z = t / (2 * pi))
)
b <- bind_bundles(sl, sl2)
b
#> <bundle [2 streamlines | 50–50 pts/streamline]>

# Reparametrize to 20 points each
b20 <- reparametrize(b, n_points = 20L)
b20
#> <bundle [2 streamlines | 20–20 pts/streamline]>

# Hausdorff distance
compute_hausdorff_distance(sl, sl2)
#> [1] 0.1
```
