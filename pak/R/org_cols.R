#' Defines the standard column structure used for organism-level output tables.
#' @keywords internal


org_cols <- function(file) {

  pages <- readLines(file)

  culture_blocks <- split_culture_reports(pages)

  orgs2 <- purrr::map_dfr(
    culture_blocks,
    function(block) {

      meta <- get_culture_info(block)

      orgs <- extract_organisms(block)

      out <- tibble::tibble(
        Accession = meta$Accession,
        Patient_name = meta$Patient_name
      )

      for (i in seq_along(orgs)) {
        out[[paste0("org", i)]] <- orgs[i]
      }

      out
    }
  )

  orgs2
}
