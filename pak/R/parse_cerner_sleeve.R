parse_cerner_sleeve <- function(block) {

  tibble::tibble(
    Sleeve_date = parse_sleeve_dates(block)
  )

}