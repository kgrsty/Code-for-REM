#' Extracts and returns the unique organism names from a culture report section by locating lines containing "Organism:", pulling the text between "Organism:" and "Panel:", trimming whitespace, and removing any missing or empty values.
#' @keywords internal
#' @param Detailed Listing DAT file

# Extract all organism names from a culture report
extract_organisms <- function(org_block) {

  org_lines <- grep("Organism:", org_block, value = TRUE)

  orgs <- stringr::str_trim(
    stringr::str_match(
      org_lines,
      "Organism:\\s*(.*?)\\s*Panel:"
    )[,2]
  )

  unique(
    orgs[!is.na(orgs) & orgs != ""]
  )
}





