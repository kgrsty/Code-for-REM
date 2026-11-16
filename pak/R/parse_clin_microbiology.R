#' Parse Clinical report Detailed Listing
#'
#' Reads a Clinical report Detailed Listing
#'  extracts and exports culture info (specimen list) and sleeve date (isolate list).
#'
#' @param file Path to DAT file.
#'
#' @return culture-level info
#'
#' @export

parse_clin_microbiology <- function(file){

  pages <- readLines(file)

  class(pages)

  culture_blocks <- split_culture_reports(pages)

  cultures_df <- purrr::map_dfr(
  culture_blocks,
  get_culture_info
)
  sleeve_df <- purrr::map_dfr(
    culture_blocks,
    parse_culture
  )

  organisms_df <- purrr::map_dfr(
    culture_blocks,
    parse_org
  )


  list(
    cultures = cultures_df,
    sleeves = sleeve_df,
    organisms = organisms_df
  )
}




