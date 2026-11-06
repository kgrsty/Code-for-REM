#' @export
#' @param Detailed Listing DAT file
#' @return dataframe with raw results section, name. and accession

get_results_block <- function(block) {

# Locate the first Final, Amend, or Preliminary result line
  start <- grep(
    "\\b(Final|Amend|Preliminary)\\b",
    block
  )[1]

# Return empty character vector if no results section exists
  if (is.na(start)) {
    return(character())
  }

# Identify markers that indicate the start of
# susceptibility testing or the next report section
  end_markers <- grep(
    "Organism:|Panel:|Date:|Ertapenem|Pip-tazo|Ceftazidime|Cefepime|Aztreonam|Meropenem",
    block
  )

# Find the first marker occurring after the result section
  end <- end_markers[end_markers > start][1]

# If no end marker exists, use end of report
  if (is.na(end)) {
    end <- length(block)
  } else {
    end <- end - 1
  }

# Return result lines only
  block[start:end]
}


parse_results_all <- function(block) {

# Extract Final culture result section
  results <- get_results_block(block)

# Extract culture metadata
  meta <- get_culture_info(block)

# Return parsed results section
  tibble::tibble(
    results_raw = paste(get_results_block(block), collapse = "\n"),
    Accession = meta$Accession,
    Patient_name = meta$Patient_name
  )

}

