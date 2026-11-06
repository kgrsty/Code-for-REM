parse_results <- function(block) {

  header <- get_results_header(block)

  meta <- get_culture_info(block)

  tibble::tibble(
    Sleeve_date = stringr::str_extract(
      header,
      "\\d{2}/\\d{2}/\\d{2}\\s+\\d{2}:\\d{2}"
    ),
    Accession = meta$Accession
  )
}