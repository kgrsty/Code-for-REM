#' @export
#' @param Detailed Listing DAT file

parse_cerner_organisms <- function(file) {

  pages <- readLines(file)

  culture_blocks <- split_culture_reports(pages)

  organisms_df <- purrr::map_dfr(
    culture_blocks,
    parse_org
  ) 

  organisms_df
}