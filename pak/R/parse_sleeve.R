
#' Reads a sleeve report file and returns a combined dataframe of parsed sleeve culture results.
#' @export

parse_sleeve <- function(file) {

  pages <- readLines(file)

  culture_blocks <- split_culture_reports(pages)

    purrr::map_dfr(
    culture_blocks,
    parse_culture
  )
 
}
  
