
#' @export


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
} 
