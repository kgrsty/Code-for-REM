#' Reads a report file and returns all parsed antibiotic susceptibility results across all cultures.
#' @export

parse_abx <- function(file) {

  pages <- readLines(file)

  culture_blocks <- split_culture_reports(pages)

  abx_df <- purrr::map_dfr(
    culture_blocks,
    parse_abx_culture
  )

  abx_df
}
