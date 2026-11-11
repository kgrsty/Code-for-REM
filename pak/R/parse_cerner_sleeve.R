#' @export

parse_cerner_sleeve <- function(file) {

  pages <- readLines(file)

  culture_blocks <- split_culture_reports(pages)

    purrr::map_dfr(
    culture_blocks,
    parse_cerner_culture
  )
 
}
  
