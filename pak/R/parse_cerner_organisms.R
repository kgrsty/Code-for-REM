#' @export
#' @param Detailed Listing DAT file

parse_cerner_organisms <- function(file) {

  pages <- readLines(file)

  class(pages)

  culture_blocks <- split_culture_reports(pages)

   cultures <- purrr::map_dfr(
  culture_blocks,
  get_culture_info
)

  organisms_df <- purrr::map_dfr(
    culture_blocks,
    parse_org
  ) 

return(organisms_df)
}
