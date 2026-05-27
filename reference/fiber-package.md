# fiber: S7 Data Structures for Diffusion MRI Tractography

Provides three S7 classes — streamline, bundle, and bundle_set — for
representing diffusion MRI tractography data in R, together with a
concise set of methods for computing shape descriptors (arc-length,
curvature, torsion, sinuosity), the Hausdorff distance between
streamlines, arc-length reparametrization of streamlines and bundles
onto uniform grids, combination of streamlines or bundles into a single
bundle, combination of bundles from multiple subjects or sessions into a
bundle_set, and coercion to and from the dwiFiber S4 class of the 'dti'
package. See Dell'Acqua, F., Descoteaux, M. and Leemans, A. (2024)
"Handbook of Diffusion MR Tractography"
[doi:10.1016/C2018-0-02520-7](https://doi.org/10.1016/C2018-0-02520-7)
for more about the mathematical and computational underpinnings of
diffusion MRI tractography.

## See also

Useful links:

- <https://github.com/tractoverse/fiber>

- <https://tractoverse.github.io/fiber/>

- Report bugs at <https://github.com/tractoverse/fiber/issues>

## Author

**Maintainer**: Aymeric Stamm <aymeric.stamm@cnrs.fr>
([ORCID](https://orcid.org/0000-0002-8725-3654))

Authors:

- Aymeric Stamm <aymeric.stamm@cnrs.fr>
  ([ORCID](https://orcid.org/0000-0002-8725-3654))
