## Resubmission

In this release v0.1.2, we address issues raised by the CRAN maintainers:

* Added missing `\value` tag to `compute_hausdorff_distance-any-method.Rd`,
  documenting that the catch-all method always throws an error for unsupported
  input types.
* Replaced `\dontrun{}` with `if (requireNamespace("dti", quietly = TRUE)) {}`
  in the `as_dwifiber()` example, since `dti` is a suggested package.

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
