#parser for culture metadata
#' @param Detailed Listing DAT file
#' @export
#' @return dataframe with name, accession, procedure, source, collect_date

get_culture_info <- function(block){

# Helper function:
# Finds the first line matching a pattern and returns it.
# Returns NA if the pattern is not found.
  get_line <- function(pattern){

    x <- grep(
      pattern,
      block,
      value = TRUE
    )

    if(length(x) == 0) return(NA_character_)

    x[1]

  }

#Extract Patient Name
Name <- stringr::str_match(
  get_line("^ Name:"),
  "Name:\\s*(.*?)\\s*Provider:"
)[,2]

#Extract Accession number
  Accession <- stringr::str_extract(
    get_line("Accession:"),
    "[0-9]{2}-[0-9]{3}-[0-9]{5}"
  )

# Procedure, Source, and Collect Date all occur
# on the same report line
#Helper function (line)

line <- get_line("Procedure")
  
#Exract Procedure Name
Procedure <- stringr::str_match(
  line,
  "Procedure:\\s*(.*?)\\s*Source:"
)[,2]
  
#Extract Specimen Source
Source <- stringr::str_match(
  line,
  "Source:\\s*(.*?)\\s*Collect Date"
)[,2]
  
#Extract Collection Date
 Collect_Date <- stringr::str_match(
line,
"Collect Date:\\s*(\\d{2}/\\d{2}/\\d{2}\\s+\\d{2}:\\d{2})"
)[,2]


#return parsed metadata
  tibble::tibble(
    Accession = Accession,
    Patient_name = Name,
    Procedure = Procedure,
    Source = Source,
    Collect_Date = Collect_Date
  )

}