#' @export

parse_sleeve_dates <- function(block) {

  line <- grep(
    "\\d{2}/\\d{2}/\\d{2}\\s+\\d{2}:\\d{2}.*?(Organism:|Panel:)",
    block,
    value = TRUE
  )[1]

  if (is.na(line)) {
    return(NA_character_)
  }

  stringr::str_extract(
    line,
    "\\d{2}/\\d{2}/\\d{2}\\s+\\d{2}:\\d{2}"
  )
}
