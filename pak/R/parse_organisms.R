#' Reads a microbiology report file, splits it into individual culture reports, extracts all organisms and their associated accession/patient metadata from each culture, and returns a single combined dataframe with one row per organism.
#' @keywords internal
#' @param Detailed Listing DAT file

parse_organisms <- function(file) {

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
