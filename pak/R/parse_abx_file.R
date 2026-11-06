#' @export

parse_abx_file <- function(file) {

  pages <- readLines(file)

  culture_blocks <- split_culture_reports(pages)

  abx_df <- purrr::map_dfr(
    culture_blocks,
    parse_abx_culture
  )

  abx_df
}
