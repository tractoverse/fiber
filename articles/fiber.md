# Getting started with fiber

The **fiber** package provides three
[S7](https://rconsortium.github.io/S7/) classes for representing
diffusion MRI tractography data in R:

| Class | Represents |
|----|----|
| `streamline` | A single fibre tract (a polyline of 3-D points). |
| `bundle` | A collection of streamlines (a tractogram / bundle). |
| `bundle_set` | A collection of bundles (white-matter bundles of a subject, or across subjects / sessions). |

Together they let you store geometry, per-point and per-streamline
attributes (e.g. fractional anisotropy), and per-bundle or per-set
metadata, and they come with a concise set of tools for computing shape
descriptors, resampling onto uniform grids, computing the Hausdorff
distance, and coercing to and from the `dwiFiber` S4 class of the
[dti](https://cran.r-project.org/package=dti) package.

This vignette walks through the core workflow. A companion, technical
[vignette](https://tractoverse.github.io/fiber/articles/fiber-api.qmd)
(`fiber-api`) describes the complete API in detail.

## Building a streamline

A `streamline` stores a `$P \times 3$` matrix of coordinates. The
columns must be named `"X"`, `"Y"`, and `"Z"`.

``` r

# A helix in 3-D, sampled at 50 points
t <- seq(0, 2 * pi, length.out = 50)
sl <- streamline(
  points = cbind(X = cos(t), Y = sin(t), Z = t / (2 * pi))
)
sl
#> 
#> ── Object of class `fiber::streamline()` with 50 points. ──
#> 
#> • Point attributes: none
#> • Streamline attributes: none
#> 
```

You can attach per-point attributes (e.g. fractional anisotropy) via
`point_data` and per-streamline scalars (e.g. a mean FA or a label) via
`streamline_data`:

``` r

sl <- streamline(
  points = cbind(X = cos(t), Y = sin(t), Z = t / (2 * pi)),
  point_data = list(FA = runif(50)),
  streamline_data = list(mean_FA = mean(runif(50)), label = "helix")
)
sl@n_points # 50
#> [1] 50
sl@point_attributes # "FA"
#> [1] "FA"
sl@streamline_attributes # c("mean_FA", "label")
#> [1] "mean_FA" "label"
```

## Shape descriptors

Functions like
[`get_curvilinear_length()`](https://tractoverse.github.io/fiber/reference/get_curvilinear_length.md),
[`get_sinuosity()`](https://tractoverse.github.io/fiber/reference/get_sinuosity.md),
and
[`get_euclidean_length()`](https://tractoverse.github.io/fiber/reference/get_euclidean_length.md)
compute scalar shape descriptors from the geometry:

``` r

get_curvilinear_length(sl)
#> [1] 6.358015
get_sinuosity(sl)
#> [1] 6.358015
```

[`get_curvature()`](https://tractoverse.github.io/fiber/reference/get_curvature.md)
and
[`get_torsion()`](https://tractoverse.github.io/fiber/reference/get_torsion.md)
return a per-point profile along the arc-length abscissa:

``` r

head(get_curvature(sl))
#> [1] 1.537338e-05 1.625127e-02 4.592627e-02 8.636675e-02 1.352354e-01
#> [6] 1.906608e-01
```

[`add_shape_descriptors()`](https://tractoverse.github.io/fiber/reference/add_shape_descriptors.md)
attaches several descriptors to an object at once. Scalar descriptors
land in `@streamline_data`; per-point ones (`curvature`, `torsion`) land
in `@point_data`:

``` r

sl2 <- add_shape_descriptors(sl)
sl2@streamline_data$euclidean_length
#> [1] 1
head(sl2@point_data$curvature)
#> [1] 1.537338e-05 1.625127e-02 4.592627e-02 8.636675e-02 1.352354e-01
#> [6] 1.906608e-01
```

## Bundling streamlines

Wrap a list of `streamline`s in a `bundle`. Any `@streamline_data` keys
common to **all** streamlines are lifted automatically into
`bundle@streamline_data` as length-`S` vectors:

``` r

sl_a <- streamline(points = cbind(X = cos(t), Y = sin(t), Z = t / (2 * pi)))
sl_b <- streamline(
  points = cbind(X = 1.1 * cos(t), Y = 1.1 * sin(t), Z = t / (2 * pi))
)
b <- bundle(streamlines = list(sl_a, sl_b))
b
#> 
#> ── Object of class `fiber::bundle()` with 2 streamliness and [50–50] points per streamline. ──
#> 
#> • Point attributes: none
#> • Streamline attributes: none
#> • Bundle attributes: none
#> 
b@n_streamlines # 2
#> [1] 2
b@streamline_data$mean_FA # lifted automatically, if present
#> NULL
```

You can mix streamlines and bundles with
[`bind_bundles()`](https://tractoverse.github.io/fiber/reference/bind_bundles.md):

``` r

b2 <- bind_bundles(sl_a, b)
b2@n_streamlines # 3
#> [1] 3
```

## Reparametrisation

[`reparametrize()`](https://tractoverse.github.io/fiber/reference/reparametrize.md)
resamples streamlines onto a uniform arc-length grid using linear
interpolation. A single streamline can be resampled to any number of
points; by default a `bundle` is resampled to the rounded mean number of
points across its streamlines:

``` r

sl_20 <- reparametrize(sl_a, n_points = 20L)
sl_20@n_points # 20
#> [1] 20

b_20 <- reparametrize(b, n_points = 20L)
b_20[[1]]@n_points # 20
#> [1] 20
b_20[[2]]@n_points # 20
#> [1] 20
```

## Hausdorff distance

[`compute_hausdorff_distance()`](https://tractoverse.github.io/fiber/reference/compute_hausdorff_distance.md)
computes the symmetric Hausdorff distance between streamlines. Depending
on the inputs, it returns a scalar, a vector, or a `dist` object:

``` r

# streamlines -> scalar
compute_hausdorff_distance(sl_a, sl_b)
#> [1] 0.1

# bundle (with no second argument) -> pairwise dist object
d <- compute_hausdorff_distance(b)
as.matrix(d)
#>     1   2
#> 1 0.0 0.1
#> 2 0.1 0.0

# bundle vs streamline -> vector
compute_hausdorff_distance(b, sl_a)
#> [1] 0.0 0.1
```

The core pairwise computation runs in C++ (via cpp11) for speed.

## Bundle sets

A `bundle_set` collects `bundle` objects. Two use cases are equally well
supported: grouping the multiple white-matter bundles of a single
subject, or grouping bundles across subjects / sessions. Names of the
input list (like `"callosum"` or `"sub-01"`) are transferred into
`bundle_set@bundle_data` as the `id_from_input_names` attribute:

``` r

# Single subject: several white-matter bundles of one subject
bs_single <- bundle_set(list(
  callosum = bundle(list(sl_a)),
  arcuate = bundle(list(sl_b))
))
bs_single
#> 
#> ── Object of class `fiber::bundle_set()` with 2 bundles and [1–1] streamlines per bundle. ──
#> 
#> • Point attributes: none
#> • Streamline attributes: none
#> • Bundle attributes: "id_from_input_names"
#> • Set attributes: none
#> 
bs_single@n_bundles # 2
#> [1] 2
bs_single[["callosum"]] # extract one bundle (push-down)
#> 
#> ── Object of class `fiber::bundle()` with 1 streamlines and [50–50] points per streamline. ──
#> 
#> • Point attributes: none
#> • Streamline attributes: none
#> • Bundle attributes: "id_from_input_names"
#> 

# Multi-subject: the same bundle across two subjects / sessions
b_sub01 <- bundle(
  streamlines = list(sl_a),
  bundle_data = list(subject = "sub-01")
)
b_sub02 <- bundle(
  streamlines = list(sl_b),
  bundle_data = list(subject = "sub-02")
)

bs <- bundle_set(list("sub-01" = b_sub01, "sub-02" = b_sub02))
bs
#> 
#> ── Object of class `fiber::bundle_set()` with 2 bundles and [1–1] streamlines per bundle. ──
#> 
#> • Point attributes: none
#> • Streamline attributes: none
#> • Bundle attributes: "subject" and "id_from_input_names"
#> • Set attributes: none
#> 
bs@bundle_data$subject # c("sub-01", "sub-02")
#> [1] "sub-01" "sub-02"
bs[["sub-01"]] # extract one subject (push-down)
#> 
#> ── Object of class `fiber::bundle()` with 1 streamlines and [50–50] points per streamline. ──
#> 
#> • Point attributes: none
#> • Streamline attributes: none
#> • Bundle attributes: "subject" and "id_from_input_names"
#> 
```

`bundle_set` objects also support
[`reparametrize()`](https://tractoverse.github.io/fiber/reference/reparametrize.md)
and
[`add_shape_descriptors()`](https://tractoverse.github.io/fiber/reference/add_shape_descriptors.md),
which operate per bundle and preserve `@bundle_data` /
`@bundle_set_data`.

## A real corpus callosum tractogram

The package ships a real tractogram from the corpus callosum
(`inst/extdata/CC_SingleTensor.csv`): 100 streamlines, each a sequence
of 3-D points with a per-point fractional anisotropy (`FA`) value. The
file reads straight into a `bundle`, grouping points by `StreamlineId`
and keeping `FA` as a per-point attribute:

``` r

cc <- read.csv(
  system.file("extdata", "CC_SingleTensor.csv", package = "fiber"),
  header = TRUE
)

make_streamline <- function(d) {
  d <- d[order(d$PointId), ]
  streamline(
    points = as.matrix(d[c("X", "Y", "Z")]),
    point_data = list(FA = d$FA)
  )
}
cc_bundle <- bundle(
  streamlines = lapply(split(cc, cc$StreamlineId), make_streamline)
)

cc_bundle@n_streamlines # 100
#> [1] 100
cc_bundle[[1]]@n_points # 150
#> [1] 150
cc_bundle[[1]]@point_attributes # "FA"
#> [1] "FA"
range(cc_bundle[[1]]@point_data$FA) # per-point FA on the first stream
#> [1] 0.1284090 0.9019012
```

The `FA` per-point attribute is present on every streamline, so `FA` is
a shared point attribute across the whole tractogram:
`cc_bundle[[1]]@point_attributes` returns `"FA"` for each of the 100
streamlines. To summarise anisotropy per streamline, lift a scalar
(e.g. per-streamline mean `FA`) into `@streamline_data`; the constructor
then carries it automatically:

``` r

cc_bundle2 <- bundle(
  streamlines = lapply(
    split(cc, cc$StreamlineId),
    function(d) {
      d <- d[order(d$PointId), ]
      streamline(
        points = as.matrix(d[c("X", "Y", "Z")]),
        point_data = list(FA = d$FA),
        streamline_data = list(mean_FA = mean(d$FA))
      )
    }
  )
)
cc_bundle2@streamline_data$mean_FA
#>   [1] 0.5795448 0.5845522 0.5952879 0.5946678 0.5892372 0.5769750 0.5765600
#>   [8] 0.5754540 0.5867316 0.5914767 0.5528441 0.5635257 0.5591195 0.5995738
#>  [15] 0.6122286 0.6092749 0.5864019 0.5680139 0.5614040 0.5859508 0.5926974
#>  [22] 0.5859467 0.6018204 0.6175521 0.6333238 0.6412199 0.6390573 0.6170749
#>  [29] 0.5898951 0.5745954 0.5674078 0.5720140 0.5863193 0.5993463 0.5945758
#>  [36] 0.5873722 0.5704101 0.5940291 0.6021282 0.6058955 0.6183781 0.6173499
#>  [43] 0.6073979 0.5886485 0.5873168 0.5755910 0.6447720 0.6571459 0.6438632
#>  [50] 0.6567112 0.6604739 0.6523562 0.6442567 0.6524128 0.6537668 0.6484673
#>  [57] 0.6408378 0.6184391 0.5746873 0.5702121 0.6325441 0.6638909 0.6736785
#>  [64] 0.6715991 0.6649784 0.6660586 0.6615916 0.6666470 0.6515800 0.6453447
#>  [71] 0.6349435 0.6328630 0.6655557 0.6633166 0.6620502 0.6631885 0.6670419
#>  [78] 0.6653470 0.6709908 0.6656554 0.6469573 0.6090103 0.6253341 0.6093987
#>  [85] 0.6171695 0.6218980 0.6223410 0.5870607 0.5367839 0.5781535 0.6197044
#>  [92] 0.6372225 0.6384414 0.6404254 0.6102462 0.5553582 0.5742839 0.6118168
#>  [99] 0.6562072 0.6626442
mean(cc_bundle2@streamline_data$mean_FA) # mean across the 100 streamlines
#> [1] 0.6158391
```

## Interoperability with the dti package

If the [dti](https://cran.r-project.org/package=dti) package is
installed, you can coerce fiber objects to and from its `dwiFiber` S4
class:

``` r

if (requireNamespace("dti", quietly = TRUE)) {
  dfi <- as_dwifiber(b)
  class(dfi) # "dwiFiber"
  b_back <- as_bundle(dfi)
  b_back@n_streamlines
}
#> [1] 2
```

[`as_dwifiber()`](https://tractoverse.github.io/fiber/reference/as_dwifiber.md)
uses per-point directions stored in `@point_data` (`direction_x`,
`direction_y`, `direction_z`) when present, otherwise it estimates them
from the coordinates via finite differences.

If dti emits an rgl warning (`'rgl.init' failed`, `X11 error`, …) when
you run the coercion above, that comes from dti loading the `rgl`
package and failing to open a graphics display in your environment. It
is unrelated to the fiber package — the conversion itself is unaffected.

## Further reading

- The [fiber API
  reference](https://tractoverse.github.io/fiber/articles/fiber-api.qmd)
  vignette documents every function and class in detail.
- Browse the online reference at
  <https://tractoverse.github.io/fiber/reference/>.
