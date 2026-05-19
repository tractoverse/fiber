## Resubmission

In this release v0.1.1, we:

* Improved documentation of S7 classes, generics and methods following the release of roxygen2 8.0.0.
* Removed redundant `new_streamline()` and `new_bundle()` constructors.
* Added coercers from and to the `dwiFiber` S4 class of the [dti](https://cran.r-project.org/package=dti) package.
* Refactored shape descriptors API.
* Rewrote pairwise Hausdorff distance matrix using C++ via the [cpp11](https://cran.r-project.org/package=cpp11) package.
* Created the tractoverse GitHub organization and transferred fiber repository to it.

Part of these improvements are meant to address issues raised by the CRAN maintainers.

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
* All 34 available platforms except *rchk* since there is no C/C++ code.

## R CMD check results

0 errors | 0 warnings | 1 note

* This is a new release.

## Submission notes

This is a major refactoring of the package prior to its first CRAN submission.
The package now provides two S7 classes (`streamline` and `bundle`) with a
minimal set of methods for tractography data analysis. Runtime dependencies
have been reduced to S7, rlang, and cli.
