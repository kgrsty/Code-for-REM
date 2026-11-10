#' @export
#' @param Detailed Listing DAT file



# Extract all organism names from a culture report
extract_organisms <- function(org_block) {

# Keep only lines containing Organism:
  org_lines <- grep("Organism:", org_block, value = TRUE)

# Extract text between Organism: and Panel:
  orgs <- stringr::str_trim(
    stringr::str_match(
      org_lines,
      "Organism:\\s*(.*?)\\s*Panel:"
    )[,2]
  )

# Remove blanks and duplicates
orgs <- unique(
  orgs[!is.na(orgs) & orgs != ""]
)

}



