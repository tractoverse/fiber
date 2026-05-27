

<!-- README.md is generated from README.qmd. Please edit that file -->

# fiber

<!-- badges: start -->

[![R-CMD-check](https://github.com/tractoverse/fiber/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/tractoverse/fiber/actions/workflows/R-CMD-check.yaml)
[![Codecov test
coverage](https://codecov.io/gh/tractoverse/fiber/graph/badge.svg)](https://app.codecov.io/gh/tractoverse/fiber)
[![pkgdown](https://github.com/tractoverse/fiber/actions/workflows/pkgdown.yaml/badge.svg)](https://github.com/tractoverse/fiber/actions/workflows/pkgdown.yaml)
[![CRAN
status](https://www.r-pkg.org/badges/version/fiber)](https://CRAN.R-project.org/package=fiber)
<!-- badges: end -->

## Overview

The [**fiber**](https://tractoverse.github.io/fiber/) package provides
three [S7](https://rconsortium.github.io/S7/) classes — `streamline`,
`bundle`, and `bundle_set` — for representing diffusion MRI tractography
data in R, together with a concise set of methods:

| Function | Description |
|----|----|
| `streamline()` | Construct a single streamline |
| `bundle()` | Construct a bundle of streamlines |
| `bundle_set()` | Construct a named set of bundles (multi-subject / multi-session) |
| `is_streamline()` | Test if an object is a `streamline` |
| `is_bundle()` | Test if an object is a `bundle` |
| `is_bundle_set()` | Test if an object is a `bundle_set` |
| `bind_bundles()` | Combine streamlines and/or bundles into a single bundle |
| `bind_bundle_sets()` | Combine named bundles and/or bundle sets into a single bundle set |
| `as_bundle_set()` | Coerce to `bundle_set` class |
| `reparametrize()` | Resample onto a uniform arc-length grid |
| `as_dwifiber()` | Coerce to `dwiFiber` class from [](https://cran.r-project.org/package=dti) |
| `as_streamline()` | Coerce to `streamline` class |
| `as_bundle()` | Coerce to `bundle` class |
| `get_euclidean_length()` | Straight-line distance between endpoints |
| `get_curvilinear_length()` | Total arc-length |
| `get_sinuosity()` | Curvilinear / Euclidean length ratio |
| `get_curvature()` | Curvature profile or summary scalar |
| `get_torsion()` | Torsion profile or summary scalar |
| `add_shape_descriptors()` | Add curvature, torsion, and/or sinuosity to `@point_data` and/or `@streamline_data` |
| `compute_hausdorff_distance()` | Symmetric Hausdorff distance |

### Classes

A `streamline` stores:

- `@points` — an $n \times 3$ numeric matrix with columns `"X"`, `"Y"`,
  `"Z"`.
- `@point_data` — a named list of per-point vectors of length $n$ (any
  type).
- `@streamline_data` — a named list of per-streamline scalars (any
  type).

A `bundle` stores:

- `@streamlines` — a list of `streamline` objects.
- `@bundle_data` — a named list of bundle-level metadata.

A `bundle_set` stores:

- `@bundles` — a *named* list of `bundle` objects (names typically
  encode subject or session IDs, e.g. `"sub-01"`).
- `@set_data` — a named list of set-level metadata.

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

# Multi-subject: collect bundles from two subjects into a bundle_set
b_sub01 <- bundle(
  streamlines = list(sl),
  bundle_data = list(subject = "sub-01")
)
b_sub02 <- bundle(
  streamlines = list(sl2),
  bundle_data = list(subject = "sub-02")
)
bs <- bind_bundle_sets("sub-01" = b_sub01, "sub-02" = b_sub02)
bs
#> <bundle_set [2 bundles | 1–1 streamlines/bundle]: sub-01, sub-02>
bs[["sub-01"]]
#> <bundle [1 streamlines | 50–50 pts/streamline] | bundle: subject>
```
