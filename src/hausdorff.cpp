#include <cpp11.hpp>
#include <cmath>

// ---- internal: directed Hausdorff ------------------------------------------
//
// max_{a in A} min_{b in B} ||a - b||_2
// Both mat_a and mat_b are (n x 3) column-major R matrices.

static double directed_hausdorff_impl(
  cpp11::doubles_matrix<> mat_a,
  cpp11::doubles_matrix<> mat_b
) {
  int na = mat_a.nrow();
  int nb = mat_b.nrow();
  double result = 0.0;
  for (int i = 0; i < na; ++i) {
    double min_d = R_PosInf;
    for (int j = 0; j < nb; ++j) {
      double dx = mat_a(i, 0) - mat_b(j, 0);
      double dy = mat_a(i, 1) - mat_b(j, 1);
      double dz = mat_a(i, 2) - mat_b(j, 2);
      double d = std::sqrt(dx * dx + dy * dy + dz * dz);
      if (d < min_d) min_d = d;
    }
    if (min_d > result) result = min_d;
  }
  return result;
}

// ---- exported: symmetric Hausdorff distance --------------------------------
//
// max(d_H(A -> B), d_H(B -> A))

[[cpp11::register]]
double hausdorff_distance_cpp(cpp11::doubles_matrix<> mat_a, cpp11::doubles_matrix<> mat_b) { return std::max(directed_hausdorff_impl(mat_a, mat_b), directed_hausdorff_impl(mat_b, mat_a)); }

// ---- exported: pairwise Hausdorff for a list of point-cloud matrices -------
//
// Returns the lower-triangle vector in R's dist(n) storage order (1-indexed k,
// column-major). For each 1-based index kR in [1, n*(n-1)/2], the 0-based
// row and column indices (i < j) are recovered analytically via:
//
//   k = kR - 1
//   i = n - 2 - floor(sqrt(-8*k + 4*n*(n-1) - 7) / 2 - 0.5)
//   j = k + i + 1 - n*(n-1)/2 + (n-i)*((n-i)-1)/2

[[cpp11::register]]
cpp11::doubles pairwise_hausdorff_cpp(cpp11::list mats) {
  int n = mats.size();
  int m = n * (n - 1) / 2;
  cpp11::writable::doubles result(m);

  for (int kR = 1; kR <= m; ++kR) {
    int k = kR - 1;
    int i = n - 2 - (int)std::floor(std::sqrt(-8.0 * k + 4.0 * n * (n - 1) - 7) / 2.0 - 0.5);
    int j = k + i + 1 - n * (n - 1) / 2 + (n - i) * ((n - i) - 1) / 2;
    cpp11::doubles_matrix<> mat_i(mats[i]);
    cpp11::doubles_matrix<> mat_j(mats[j]);
    result[k] = hausdorff_distance_cpp(mat_i, mat_j);
  }
  return result;
}
