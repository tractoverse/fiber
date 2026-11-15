## Resubmission

This is a resubmission of v0.3.0. In response to the previous rejection, I have
fixed the following NOTE from `R CMD check` on
`r-devel-linux-x86_64-debian-gcc`:

* `Rd contents`: 14 method documentation pages documented `\arguments` without
  a corresponding `\usage`. The per-method `\arguments` documentation has been
  removed from these pages (full parameter documentation remains on each
  generic's own help page), so each page now contains only `\description`,
  `\value`, `\seealso`, and `\examples`. Affected topics:
  `add_shape_descriptors`, `as_bundle`, `as_dwifiber`, `as_streamline`,
  `compute_hausdorff_distance`, and `reparametrize` (all `*-method` pages).

## Test environments

**Local:**
* macOS, R 4.7.0
* macOS, R 4.6.0

**Continuous integration via GitHub Actions (`R-CMD-check.yaml`):**
* macOS latest, R release
* Windows latest, R release
* Ubuntu latest, R devel
* Ubuntu latest, R release
* Ubuntu latest, R oldrel-1

**Win-builder:**
* [win-builder](https://win-builder.r-project.org/) R release
* [win-builder](https://win-builder.r-project.org/) R-devel

**R-Hub**
* All 35 available platforms except *rchk* since there is no C/C++ code.

## R CMD check results

0 errors | 0 warnings | 0 note
