#' Processes all organism sections within a culture report and combines susceptibility results into one dataframe.
#' @keywords internal

parse_abx_culture <- function(block){

# Extract accession and patient metadata
  meta <- get_culture_info(block)

# Split report into individual organism sections
  org_blocks <- get_org_blocks(block)

# Exit if no organism susceptibility data exists
  if(is.null(org_blocks)){
    return(NULL)
  }

# Parse susceptibility data for each organism
  purrr::map_dfr(
    org_blocks,
    ~ parse_abx_block(
        .x,
        Accession = meta$Accession,
        Patient_name = meta$Patient_name
      )
  )

}
