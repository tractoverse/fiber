

<!-- README.md is generated from README.qmd. Please edit that file -->

# fiber

<!-- badges: start -->

[![R-CMD-check](https://github.com/astamm/fiber/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/astamm/fiber/actions/workflows/R-CMD-check.yaml)
[![Codecov test
coverage](https://codecov.io/gh/astamm/fiber/graph/badge.svg)](https://app.codecov.io/gh/astamm/fiber)
[![pkgdown](https://github.com/astamm/fiber/actions/workflows/pkgdown.yaml/badge.svg)](https://github.com/astamm/fiber/actions/workflows/pkgdown.yaml)
[![CRAN
status](https://www.r-pkg.org/badges/version/fiber)](https://CRAN.R-project.org/package=fiber)
<!-- badges: end -->

## Overview

The [**fiber**](https://astamm.github.io/fiber/) package provides two
[S7](https://rconsortium.github.io/S7/) classes — `streamline` and
`bundle` — for representing diffusion MRI tractography data in R,
together with a concise set of methods:

| Function                   | Description                              |
|----------------------------|------------------------------------------|
| `new_streamline()`         | Construct a single streamline            |
| `new_bundle()`             | Construct a bundle of streamlines        |
| `bind_bundles()`           | Combine streamlines and/or bundles       |
| `reparametrize()`          | Resample onto a uniform arc-length grid  |
| `get_euclidean_length()`   | Straight-line distance between endpoints |
| `get_curvilinear_length()` | Total arc-length                         |
| `get_sinuosity()`          | Curvilinear / Euclidean length ratio     |
| `get_curvature()`          | Curvature profile or summary scalar      |
| `get_torsion()`            | Torsion profile or summary scalar        |
| `get_hausdorff_distance()` | Symmetric Hausdorff distance             |

### Classes

A `streamline` stores:

- `@points` — an $n \times 3$ numeric matrix with columns `"X"`, `"Y"`,
  `"Z"`.
- `@point_data` — a named list of per-point numeric vectors (length
  $n$).
- `@streamline_data` — a named list of per-streamline numeric scalars.

A `bundle` stores:

- `@streamlines` — a list of `streamline` objects.
- `@bundle_data` — a named list of bundle-level metadata.

## Installation

You can install the development version of **fiber** from
[GitHub](https://github.com/astamm/fiber) with:

``` r
# install.packages("pak")
pak::pak("astamm/fiber")
```

## Quick start

``` r
library(fiber)

# Build a helix streamline (50 points)
t <- seq(0, 2 * pi, length.out = 50)
sl <- new_streamline(
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
#>           s    curvature
#> 1 0.0000000 1.537338e-05
#> 2 0.1297554 1.625127e-02
#> 3 0.2595108 4.592627e-02
#> 4 0.3892662 8.636675e-02
#> 5 0.5190216 1.352354e-01
#> 6 0.6487770 1.906608e-01

# Bundle two streamlines
sl2 <- new_streamline(
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
get_hausdorff_distance(sl, sl2)
#> [1] 0.1
```
