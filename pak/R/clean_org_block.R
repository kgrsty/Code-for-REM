#' Removes report headers, page breaks, and other non-data lines from an organism section before parsing
#' @keywords internal


clean_org_block <- function(org_block) {

  org_block <- remove_page_breaks(org_block)

  org_block <- org_block[
    !grepl(
      "^\\d{2}/\\d{2}/\\d{2}\\s+\\d{2}:\\d{2}",
      trimws(org_block)
    )
  ]

  org_block
}
