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
    ~ parse_org_block(
        .x,
        Accession = meta$Accession,
        Patient_name = meta$Patient_name
      )
  )

}

clean_org_block <- function (org_block,
                            Accession,
                            Patient_name) 
{
    org_block[!grepl("^\\d{2}/\\d{2}/\\d{2}\\s+\\d{2}:\\d{2}", 
        trimws(org_block))]
}

parse_abx_row <- function(x){

# Convert escaped inequality signs into readable values
  x <- gsub("\\\\<", "<", x)
  x <- gsub("\\\\>", ">", x)

# Extract antibiotic name
  drug <- stringr::str_match(
    x,
    "^\\s*([A-Za-z0-9\\-/]+)"
  )[,2]

  if(grepl("%", x)) {

# Extract MIC value
  mic <- stringr::str_match(
      x,
      "%([^ ]+)"
    )[,2]

  } else {

    mic <- NA_character_

  }

#--------------------------------------------------
# Extract interpretation
#--------------------------------------------------
# S = Susceptible
# I = Intermediate
# R = Resistant
# S-DD = Susceptible Dose Dependent
  
  interp <- stringr::str_match(
    x,
    "(%?S-DD|%?S|%?I|%?R)\\s+Ver"
  )[,2]

  interp <- gsub("^%", "", interp)

# Return parsed antibiotic result
  tibble::tibble(
    antibiotic = drug,
    mic_value = mic,
    interpretation = interp
  
  )

abx_df <- purrr::map_dfr(
  culture_blocks,
  parse_abx_culture
)
} 