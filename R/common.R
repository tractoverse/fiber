#' @importFrom rlang :=
#' @export
rlang::`:=`

#' @importFrom rlang .data
#' @export
rlang::.data

get_hausdorff_distance_impl <- function(point, streamline) {
  streamline %>%
    dplyr::mutate(
      distance = purrr::pmap(list(x, y, z), c) %>%
        purrr::map_dbl(~ sqrt(sum((. - point)^2)))
    ) %>%
    dplyr::summarise(dist = min(dist)) %>%
    dplyr::pull(distance)
}
