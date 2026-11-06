parse_sleeve_dates <- function(block) {

  idx <- grep(
    "\\d{2}/\\d{2}/\\d{2}\\s+\\d{2}:\\d{2}.*(Organism:|Panel:)",
    block
  )[1]

  if (is.na(idx)) {
    return(NA_character_)
  }

  stringr::str_extract(
    block[idx],
    "\\d{2}/\\d{2}/\\d{2}\\s+\\d{2}:\\d{2}"
  )
}

