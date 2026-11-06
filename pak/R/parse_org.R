#' @param Detailed Listing DAT file
#' @export
#' @return organism by name and accession
library (tibble)

parse_org <- function(block) {


# Extract all organisms from the report
  orgs <- extract_organisms(block)

# Create one row for each organism
  tibble::tibble(
  Organism = orgs
  )
}

orgs_df <- parse_org( "U:/Coding Stuff/REM/detailed_listing/preview_10_15_2026_15_25_26.tmp.DAT")
