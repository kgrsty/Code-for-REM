#' Extracts all susceptibility results for one organism and returns them in a tidy format.
#' @keywords internal


parse_abx_block <- function(org_block,
                            Accession,
                            Patient_name) {

  organism <- get_org_name(org_block)

  rows <- clean_org_block(org_block)

  rows <- rows[
    grepl(
      "%|\\s(S|I|R|S-DD)\\s+Ver",
      rows
    )
  ]

  abx_df <- purrr::map_dfr(
    rows,
    parse_abx_row
  )

  abx_df %>%
    dplyr::mutate(
      Accession = Accession,
      Patient_name = Patient_name,
      Organism = organism,
      .before = 1
    )
}





