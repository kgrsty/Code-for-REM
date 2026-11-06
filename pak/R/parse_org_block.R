parse_org_block <- function(org_block,
                            Accession,
                            Patient_name){

# Extract organism name from the Organism:/Panel: line
  organism <- get_org_name(org_block)

# Remove timestamp/result lines and keep only organism-specific susceptibility data
  rows <- clean_org_block(org_block)

# Keep only rows containing susceptibility results
# (% indicates MIC values; S/I/R/S-DD indicate interpretation)
  rows <- rows[
    grepl(
      "%|\\s(S|I|R|S-DD)\\s+Ver",
      rows
    )
  ]

# Parse each antibiotic row into a structured table
  abx_df <- purrr::map_dfr(
    rows,
    parse_abx_row
  )

# Add accession and patient identifiers
  abx_df %>%
    mutate(
      Accession = Accession,
      Patient_name = Patient_name,
      .before = 1
    )
}







