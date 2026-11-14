# The fiber API

This vignette is the reference for **fiber**’s programming interface. It
describes every class, slot, read-only property, generic, and method,
together with the subsetting (“push-down”) semantics and the coercion
rules between fiber classes and the `dwiFiber` S4 class of the
[dti](https://cran.r-project.org/package=dti) package. For a gentler
introduction, see the [getting
started](https://tractoverse.github.io/fiber/articles/fiber.qmd)
vignette.

The package defines three [S7](https://rconsortium.github.io/S7/)
classes:

- [streamline](#class-streamline)
- [bundle](#class-bundle)
- [bundle_set](#class-bundle_set)

and a set of generics and functions:

- Constructors & predicates:
  [`streamline()`](https://tractoverse.github.io/fiber/reference/streamline.md),
  [`bundle()`](https://tractoverse.github.io/fiber/reference/bundle.md),
  [`bundle_set()`](https://tractoverse.github.io/fiber/reference/bundle_set.md),
  [`is_streamline()`](https://tractoverse.github.io/fiber/reference/is_streamline.md),
  [`is_bundle()`](https://tractoverse.github.io/fiber/reference/is_bundle.md),
  [`is_bundle_set()`](https://tractoverse.github.io/fiber/reference/is_bundle_set.md)
- Combination:
  [`bind_bundles()`](https://tractoverse.github.io/fiber/reference/bind_bundles.md),
  [`bind_bundle_sets()`](https://tractoverse.github.io/fiber/reference/bind_bundle_sets.md)
- Reparametrisation:
  [`reparametrize()`](https://tractoverse.github.io/fiber/reference/reparametrize.md)
- Shape descriptors:
  [`get_euclidean_length()`](https://tractoverse.github.io/fiber/reference/get_euclidean_length.md),
  [`get_curvilinear_length()`](https://tractoverse.github.io/fiber/reference/get_curvilinear_length.md),
  [`get_sinuosity()`](https://tractoverse.github.io/fiber/reference/get_sinuosity.md),
  [`get_curvature()`](https://tractoverse.github.io/fiber/reference/get_curvature.md),
  [`get_torsion()`](https://tractoverse.github.io/fiber/reference/get_torsion.md),
  [`add_shape_descriptors()`](https://tractoverse.github.io/fiber/reference/add_shape_descriptors.md)
- Distances:
  [`compute_hausdorff_distance()`](https://tractoverse.github.io/fiber/reference/compute_hausdorff_distance.md)
- Coercion:
  [`as_streamline()`](https://tractoverse.github.io/fiber/reference/as_streamline.md),
  [`as_bundle()`](https://tractoverse.github.io/fiber/reference/as_bundle.md),
  [`as_bundle_set()`](https://tractoverse.github.io/fiber/reference/as_bundle_set.md),
  [`as_dwifiber()`](https://tractoverse.github.io/fiber/reference/as_dwifiber.md)

## Class: streamline

A `streamline` represents a single fibre tract as a polyline of 3-D
points. It stores three compartments:

### Slots

| Slot | Type / shape | Contents |
|----|----|----|
| `@points` | `P x 3` numeric matrix, columns `"X"`, `"Y"`, `"Z"` | The 3-D coordinates of the `P` points along the tract. |
| `@point_data` | named list of numeric vectors, each of length `P` | Per-point scalar attributes (e.g. fractional anisotropy). `"X"` / `"Y"` / `"Z"` are **not** allowed here. |
| `@streamline_data` | named list of scalars (length 1, any type) | Per-streamline attributes (e.g. mean FA or a character label). |

### Read-only properties

| Property | Type | Meaning |
|----|----|----|
| `@n_points` | integer | Number of points (`nrow(@points)`). |
| `@point_attributes` | character | Names of the entries in `@point_data`. |
| `@streamline_attributes` | character | Names of the entries in `@streamline_data`. |

### Construction

``` r

sl <- streamline(
  points = cbind(X = 0:4, Y = 0:4, Z = 0:4),
  point_data = list(FA = runif(5)),
  streamline_data = list(label = "CST")
)
sl
#> 
#> ── Object of class `fiber::streamline()` with 5 points. ──
#> 
#> • Point attributes: "FA"
#> • Streamline attributes: "label"
#> 
sl@n_points
#> [1] 5
sl@point_attributes
#> [1] "FA"
```

The validator insists that `@points` is a numeric `P x 3` matrix with
column names exactly `c("X", "Y", "Z")`, that every `@point_data` entry
is a numeric vector of length `P`, and that every `@streamline_data`
entry has length 1.

### Method surface

[`format()`](https://rdrr.io/r/base/format.html) returns a cli-formatted
string; [`print()`](https://rdrr.io/r/base/print.html) prints it and
returns the object invisibly.

## Class: bundle

A `bundle` is an ordered collection of `streamline` objects, e.g. a
tractogram.

### Slots

| Slot | Type / shape | Contents |
|----|----|----|
| `@streamlines` | list of `streamline` objects | The individual tracts. |
| `@streamline_data` | named list of vectors, each of length `S` | Per-streamline attributes aggregated at the bundle level. Common keys may be lifted here automatically at construction. |
| `@bundle_data` | named list of scalars (length 1, any type) | Bundle-level metadata. |

### Read-only properties

| Property | Type | Meaning |
|----|----|----|
| `@n_streamlines` | integer | Number of streamlines. |
| `@streamline_attributes` | character | Names of the entries in `@streamline_data`. |
| `@bundle_attributes` | character | Names of the entries in `@bundle_data`. |

### Automatic lifting

At construction, any `@streamline_data` key present in **all** supplied
streamlines is copied into `bundle@streamline_data` as a length-`S`
vector, and the key is then not stored redundantly in each streamline.
Values supplied explicitly via the `streamline_data` argument take
precedence.

``` r

sl1 <- streamline(
  points = cbind(X = 0:4, Y = 0:4, Z = 0:4),
  streamline_data = list(mean_FA = 0.6, label = "A")
)
sl2 <- streamline(
  points = cbind(X = 1:3, Y = 1:3, Z = 1:3),
  streamline_data = list(mean_FA = 0.7, label = "A")
)
b <- bundle(streamlines = list(sl1, sl2))
b@streamline_data$mean_FA # c(0.6, 0.7) — lifted automatically
#> [1] 0.6 0.7
b@streamline_attributes # c("mean_FA", "label")
#> [1] "mean_FA" "label"
```

The bundle validator requires every element of `@streamlines` to be a
`streamline` (with no duplicate names), every `@streamline_data` entry
to have length `S`, and every `@bundle_data` entry to have length 1.

### Subsetting and push-down

`bundle[[i]]` extracts the `i`-th streamline and **pushes back** the
corresponding `bundle@streamline_data` values into the streamline’s
`@streamline_data`:

``` r

b[[1]]@streamline_data$mean_FA # 0.6
#> [1] 0.6
```

`bundle[i]` returns a new `bundle` with only the selected streamlines,
preserving `@bundle_data` and the subset of `@streamline_data`:

``` r

b[1]@streamline_data$mean_FA # c(0.6)
#> [1] 0.6
b[1]@streamline_data$label # "A"
#> [1] "A"
```

## Class: bundle_set

A `bundle_set` is a collection of `bundle` objects. It is designed for
two closely related use cases: grouping the multiple white-matter
bundles of a single subject, or grouping bundles across subjects /
sessions in a multi-subject / multi-session study.

### Slots

| Slot | Type / shape | Contents |
|----|----|----|
| `@bundles` | list of `bundle` objects (names optional) | One element per bundle (e.g. per white-matter bundle of a subject, or per subject / session). |
| `@bundle_data` | named list of vectors, each of length `B` | Per-bundle attributes aggregated at the set level. |
| `@bundle_set_data` | named list of scalars (length 1, any type) | Set-level metadata. |

### Read-only properties

| Property | Type | Meaning |
|----|----|----|
| `@n_bundles` | integer | Number of bundles. |
| `@bundle_attributes` | character | Names of the entries in `@bundle_data`. |
| `@bundle_set_attributes` | character | Names of the entries in `@bundle_set_data`. |

### Names become `id_from_input_names`

If the input `bundles` list is named
(e.g. `list("sub-01" = b1, "sub-02" = b2)`), the names are transferred
into `bundle_set@bundle_data` under the key `id_from_input_names` and
the names are then dropped from `@bundles`.

``` r

b_sub01 <- bundle(
  streamlines = list(sl1),
  bundle_data = list(subject = "sub-01")
)
b_sub02 <- bundle(
  streamlines = list(sl2),
  bundle_data = list(subject = "sub-02")
)
bs <- bundle_set(list("sub-01" = b_sub01, "sub-02" = b_sub02))
bs@bundle_data$id_from_input_names # c("sub-01", "sub-02")
#> [1] "sub-01" "sub-02"
```

As with bundles, common `@bundle_data` keys are lifted automatically at
construction, and the explicit `bundle_data` argument takes precedence.

### Subsetting and push-down

`bundle_set[[i]]` extracts the `i`-th bundle and pushes the matching
`bundle_set@bundle_data` values into the bundle’s `@bundle_data`.
`bundle_set[i]` returns a new `bundle_set` with `@bundle_set_data` and
the subset of `@bundle_data` preserved.

``` r

bs[["sub-01"]]@bundle_data$subject # "sub-01" (pushed down)
#> [1] "sub-01"
bs[1]@bundle_data$subject # "sub-01"
#> [1] "sub-01"
```

## Predicates

| Function           | Returns `TRUE` when `x` is … |
|--------------------|------------------------------|
| `is_streamline(x)` | a `streamline`               |
| `is_bundle(x)`     | a `bundle`                   |
| `is_bundle_set(x)` | a `bundle_set`               |

``` r

is_streamline(sl) # TRUE
#> [1] TRUE
is_bundle(sl) # FALSE
#> [1] FALSE
is_bundle_set(bs) # TRUE
#> [1] TRUE
```

## Combination

### bind_bundles()

`bind_bundles(...)` combines any mix of `streamline` and `bundle`
objects into a single flat `bundle`. `bundle_data` and `streamline_data`
from the first `bundle` argument are preserved by default; pass your own
via the `streamline_data` and `bundle_data` arguments to override. Keys
present in only some inputs are NA-padded for the others.

``` r

b_all <- bind_bundles(sl1, b)
b_all@n_streamlines # 3
#> [1] 3
```

### bind_bundle_sets()

`bind_bundle_sets(...)` combines any mix of `bundle` and `bundle_set`
objects into a single flat `bundle_set`. Bare `bundle` arguments may be
named to carry their name into the resulting set (with
`id_from_input_names` populated accordingly), or left unnamed.
`bundle_data` from the first `bundle_set` argument is preserved by
default; pass your own via `bundle_data` or `bundle_set_data`.

``` r

bs_merged <- bind_bundle_sets("sub-A" = b_sub01, bs)
bs_merged@n_bundles # 3
#> [1] 3
```

## Reparametrisation

`reparametrize(x, n_points = NULL)` resamples coordinates (and any
numeric `@point_data` entries) onto a uniform arc-length grid by linear
interpolation.

- For a `streamline`, `n_points` defaults to `x@n_points`.
- For a `bundle`, it defaults to the rounded mean number of points
  across its streamlines, and every streamline is resampled to the same
  grid size.
- For a `bundle_set`, each bundle is reparametrized independently
  (defaulting, per bundle, to the rounded mean across that bundle’s
  streamlines).

Non-numeric `@point_data` entries are dropped with a warning (they have
no natural arc-length interpolant). `@streamline_data`, `@bundle_data`,
and `@bundle_set_data` are preserved unchanged.

``` r

sl_20 <- reparametrize(sl1, n_points = 20L)
sl_20@n_points # 20
#> [1] 20
b_20 <- reparametrize(b, n_points = 20L)
b_20[[1]]@n_points # 20
#> [1] 20
```

`n_points` must be at least 2.

## Shape descriptors

| Function | Returns |
|----|----|
| `get_euclidean_length(x)` | Straight-line distance between the endpoints (resolution-`P` independent). |
| `get_curvilinear_length(x)` | Total arc-length (sum of Euclidean segment lengths). |
| `get_sinuosity(x)` | Curvilinear / Euclidean ratio (1 = straight; larger = curvier). |
| `get_curvature(x)` | Per-point curvature profile (length `P`), via cubic smoothing splines. |
| `get_torsion(x)` | Per-point torsion profile (length `P`), via cubic smoothing splines. |

[`get_curvature()`](https://tractoverse.github.io/fiber/reference/get_curvature.md)
and
[`get_torsion()`](https://tractoverse.github.io/fiber/reference/get_torsion.md)
are per-point profile descriptors: they fit smoothing splines to each
coordinate along the arc-length abscissa, so they need at least four
distinct points and are well defined only where the tract is actually
curved. On a perfectly straight segment, curvature is identically zero
and torsion (which measures out-of-plane twisting) is undefined (`NaN`).
The helix below is a good curve to illustrate both, because it is
genuinely curved in every direction:

``` r

sl_curve <- streamline(
  points = cbind(
    X = cos(seq(0, 2 * pi, length.out = 21)),
    Y = sin(seq(0, 2 * pi, length.out = 21)),
    Z = seq(0, 2 * pi, length.out = 21)
  )
)
# Scalar descriptors are fine on any streamline
get_euclidean_length(sl1)
#> [1] 6.928203
get_curvilinear_length(sl1)
#> [1] 6.928203
get_sinuosity(sl1)
#> [1] 1

# Per-point profiles are meaningful on a truly curved tract
head(get_curvature(sl_curve))
#> [1] 2.547019e-05 2.553796e-02 6.620551e-02 1.142371e-01 1.646170e-01
#> [6] 2.142204e-01
head(get_torsion(sl_curve))
#> [1] -115.1033091    0.5632915    0.4238968    0.4045585    0.4208142
#> [6]    0.4554351
```

### add_shape_descriptors()

`add_shape_descriptors(x, descriptors = ...)` is an S7 generic with
methods for `streamline`, `bundle`, and `bundle_set`. The default
`descriptors` is
`c("euclidean_length", "curvilinear_length", "sinuosity", "curvature", "torsion")`.

- For a `streamline`, scalar descriptors land in `@streamline_data` and
  per-point ones in `@point_data`.
- For a `bundle`, scalar descriptors are stored as length-`S` vectors in
  `bundle@streamline_data`; per-point ones (`curvature`, `torsion`) are
  stored in each individual streamline’s `@point_data`. Both are
  accessible via the subsetting push-down.
- For a `bundle_set`, the operation is applied per bundle, preserving
  `@bundle_data` and `@bundle_set_data`.

Unknown descriptor names trigger a structured
[`cli::cli_warn()`](https://cli.r-lib.org/reference/cli_abort.html)
message.

Note that
[`get_curvature()`](https://tractoverse.github.io/fiber/reference/get_curvature.md)
and
[`get_torsion()`](https://tractoverse.github.io/fiber/reference/get_torsion.md)
fit cubic smoothing splines and therefore need a streamline with at
least four distinct points (the examples below use 10-point
streamlines).

``` r

b_long <- bundle(
  streamlines = list(
    streamline(points = cbind(X = 0:9, Y = 0:9, Z = 0:9)),
    streamline(points = cbind(X = 1:10, Y = 1:10, Z = 1:10))
  )
)
b_desc <- add_shape_descriptors(b_long)
names(b_desc@streamline_data)
#> [1] "euclidean_length"   "curvilinear_length" "sinuosity"
names(b_desc[[1]]@point_data)
#> [1] "curvature" "torsion"
```

## Hausdorff distance

`compute_hausdorff_distance(x, y = NULL)` computes the symmetric
Hausdorff distance. It dispatches on four cases:

| `x` | `y` | Returns |
|----|----|----|
| `streamline` | `streamline` | Scalar: `max(d_H(x→y), d_H(y→x))`. |
| `bundle` | `NULL` | `dist` object (size `n`) of all pairwise distances within `x`. |
| `bundle` | `streamline` | Numeric vector (length `n`): distance from `y` to each streamline in `x`. |
| `bundle` | `bundle` | `dist` object over the concatenation of all streamlines of `x` and `y`. |

``` r

sb <- streamline(points = cbind(X = 0:4, Y = 0:4, Z = 0:4))
sc <- streamline(points = cbind(X = 1:5, Y = 1:5, Z = 1:5))

# streamline x streamline -> scalar
compute_hausdorff_distance(sb, sc)
#> [1] 1.732051

# bundle x missing -> dist object
bd <- bundle(streamlines = list(sb, sc))
as.matrix(compute_hausdorff_distance(bd))
#>          1        2
#> 1 0.000000 1.732051
#> 2 1.732051 0.000000

# bundle x streamline -> vector
compute_hausdorff_distance(bd, sb)
#> [1] 0.000000 1.732051

# bundle x bundle -> combined dist object
bd2 <- bundle(streamlines = list(sc))
as.matrix(compute_hausdorff_distance(bd, bd2))
#>          1        2        3
#> 1 0.000000 1.732051 1.732051
#> 2 1.732051 0.000000 0.000000
#> 3 1.732051 0.000000 0.000000
```

The core pairwise computation is implemented in C++ (via cpp11).
Coordinates are coerced to double precision before being passed to the
compiled code, so integer-stored `@points` matrices (e.g. built from
`X = 1:5`) are handled correctly. Unsupported `x` types (and invalid
`y`) produce a clear error via the catch-all method.

## Coercion

### as_streamline()

`as_streamline(x)` returns a `streamline`:

- `streamline` → returned unchanged (identity).
- `bundle` → the sole streamline (errors if the bundle has ≠ 1
  streamlines).
- `dwiFiber` (from dti) → the single fiber as a `streamline` (errors if
  multi-fiber; use
  [`as_bundle()`](https://tractoverse.github.io/fiber/reference/as_bundle.md)
  instead).

### as_bundle()

`as_bundle(x)` returns a `bundle`:

- `streamline` → a single-element `bundle` (lossless).
- `bundle` → returned unchanged (identity).
- `dwiFiber` → each fiber becomes a `streamline`. Per-point direction
  vectors (columns 4–6 of `@fibers`) are stored as
  `@point_data$direction_x/y/z`. Tracking metadata (`method`, `minfa`,
  `maxangle`) become scalars in `@bundle_data`; vector metadata (`ddim`,
  `ddim0`, `voxelext`, `orientation`) are expanded into individual
  scalar entries (e.g. `voxelext_1`, `voxelext_2`, `voxelext_3`).

### as_bundle_set()

`as_bundle_set(x)` returns a `bundle_set`:

- `bundle_set` → returned unchanged (identity).
- `bundle` → a single-element `bundle_set`; the optional `name` argument
  sets the element name.

### as_dwifiber()

`as_dwifiber(x)` converts a `streamline` or `bundle` to the `dwiFiber`
S4 class from dti. It requires the `dti` package to be installed.
Per-point directions are taken from `@point_data$direction_x/y/z` when
present, otherwise estimated from the coordinates via finite differences
(forward / backward at the ends, central elsewhere), then
unit-normalised. Bundled metadata under `method`, `minfa`, `maxangle`,
`level`, and `source` are transferred to the corresponding `dwiFiber`
slots when present.

> **Note**
>
> Because dti loads the `rgl` package on startup, calling the coercion
> functions in an environment without a graphics display can print an
> rgl warning (e.g. `'rgl.init' failed` or `X11 error`). That warning
> comes from rgl, not from fiber, and does not affect the conversion.

``` r

if (requireNamespace("dti", quietly = TRUE)) {
  dfi <- as_dwifiber(bd)
  class(dfi)
  # round-trip
  as_bundle(dfi)@n_streamlines
}
#> [1] 2
```

## Console output

All three classes provide
[`format()`](https://rdrr.io/r/base/format.html) and
[`print()`](https://rdrr.io/r/base/print.html) methods that render
cli-styled, ANSI-aware summaries (object class, point/bundle counts, and
the per-point, per-streamline, per-bundle, and set-level attribute
names). [`print()`](https://rdrr.io/r/base/print.html) also returns the
object invisibly, and [`length()`](https://rdrr.io/r/base/length.html),
`[[`, and `[` follow the semantics described above.

## The complete function list

For the canonical documentation of every generic, method, argument, and
return value, see the package reference at
<https://tractoverse.github.io/fiber/reference/>.
