#This code is for use with Cerner Detailed Listing to extract:
# Name, Accession, Procedure, Source, Collect_date, Organism results, antibiotic susceptibility testing results
#Strategy:split Cerner document into the following blocks:
# 1. culture
# 2. organism
# 3. antibiotics/susceptibility
# 4. results
# 5. sleeve date


#install packages
library(stringr) #manipulate text
library(dplyr) #filter, summarize and transform tables
library(purrr) #iteration (writing loops)
library(tidyr) #Reshape and tidy tables
library(writexl) #write excel sheet
library(lubridate) #date manipulation

#read in raw data
pages <- readLines("U:/Coding Stuff/REM/detailed_listing/preview_10_22_2026_14_28_25.tmp.DAT")

##################################extract culture info#################################
######################################################################################################
# Split microbiology text file into individual reports using patient header lines as report boundaries
######################################################################################################
# Find every line that begins with "Name:"
# Some reports may contain additional references to "Name",
# filter to identify true culture report starts
name_idx <- grep("^ Name:", pages)

# Identify the beginning of each culture report block
# A valid report header should have an MRN/Age/Sex line within the next few lines after the patient name
real_name_idx <- name_idx[
  sapply(name_idx, function(i){

    any(
      grepl(
        "MRN/Age/Sex:",
        pages[i:min(i + 5, length(pages))]
      )
    )

  })
]

# Determine where each culture report ends
# The end of one report is the line immediately before
# the start of the next record
name_end <- c(
  real_name_idx[-1] - 1,
  length(pages)  # last report extends to end of file
)

#create culture blocks
# Split the full text file into individual culture reports
# Each element of culture_blocks contains one complete report
culture_blocks <- Map(
  function(start, end){
    pages[start:end]
  },
  real_name_idx,
  name_end
)

#check number of patient records
length(culture_blocks)

# Display the patient name line from each report header
# Useful for verifying block boundaries
pages[real_name_idx]

#extract culture-level info
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
###############################################Extract Patient Information########################################
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

#create dataframe
cultures <- purrr::map_dfr(
  culture_blocks,
  get_culture_info
)

#sort by collect_date
cultures <- cultures[order(cultures$Collect_Date), increasing = TRUE]
cultures_df1 <- cultures[order(cultures$Patient_name), increasing = TRUE]

#add row id for easier markups during collection
cultures_df1 <- cbind(row_id = seq_len(nrow(cultures_df1)), cultures_df1)

write_xlsx(cultures, "U:/Coding Stuff/REM/detailed_listing/culture_block.xlsx")

###############################extract Organism info###############################################################
#organism blocks-create start and end
get_org_blocks <- function(culture_blocks){

# Find each line containing an organism header
# (typically "Organism:" followed by a susceptibility panel)
  starts <- grep(
    "Organism:|Panel:",
    culture_blocks
  )

# Return NULL if no organisms are present
  if(length(starts) == 0){
    return(NULL)
  }

# Define the end of each organism block
# Each block ends immediately before the next organism block
  ends <- c(
    starts[-1] - 1,
    length(culture_blocks)
  )

# Extract each organism section into a separate list element
  Map(
    function(s,e){
      culture_blocks[s:e]
    },
    starts,
    ends
  )
}

#test extraction on one culture report
org_block <- get_org_blocks(
 culture_blocks[[3]]
)


# Extract organism names from single block
get_org_name <- function(org_block) {
stringr::str_match(
org_block[1],
"Organism:\\s*(.*?)\\s*Panel:"
)[,2]
}

# Preview organism names found in test block
sapply(org_block, get_org_name)

# Extract all organism names from a culture report
extract_orgs <- function(org_block) {

# Keep only lines containing Organism:
  org_lines <- grep("Organism:", org_block, value = TRUE)

# Extract text between Organism: and Panel:
  orgs <- stringr::str_trim(
    stringr::str_match(
      org_lines,
      "Organism:\\s*(.*?)\\s*Panel:"
    )[,2]
  )

# Remove blanks and duplicates
  unique(orgs[!is.na(orgs) & orgs != ""])
}

# Test extraction
extract_orgs(org_block)

# Create one row per organism
organism_df <- purrr::map_dfr(culture_blocks, function(block) {

# Extract accession and patient metadata
  meta <- get_culture_info(block)

# Extract all organisms from the report
  orgs <- extract_orgs(block)

# Create one row for each organism
  tibble::tibble(
    Accession = meta$Accession,
    Patient_name = meta$Patient_name,
  Organism = orgs
  )
})

#grouping organisms by accession 
orgs <- split(organism_df$Organism, organism_df$Accession)
#removing duplicates within each accession
orgs <- lapply(orgs, unique)

# Create one row per accession with separate organism columns
organism_df1 <- purrr::map_dfr(culture_blocks, function(block) {

  meta <- get_culture_info(block)

  orgs <- extract_orgs(block)

# Start output table with accession metadata
  out <- tibble::tibble(
    Accession = meta$Accession,
    Patient_name = meta$Patient_name
  )

# Add organism columns dynamically: org1, org2, org3, etc.
  for(i in seq_along(orgs)) {
    out[[paste0("org", i)]] <- orgs[i]
  }

  out
})

#lookup table for organism abbreviations
org_pattern <- "PA|EC|Pamuc|Panmuc|CitFcomp|Klepne|Entclocomp|Kleoxy|MRSA|Citbra
|Citfar|Citgil|Citkos|Citmur|Citrod|Citsed|Citwer|Cityou|Kleoza|Citfre|Citama|Klegra|Klepneoza|Klepnepne
|Klepnerhi|Entclo|Entaer|Entaer1|Kleorn|Klerhi|Citfre2|Entaer2|Entclo1|Entclo2|Kleoza1|Kleoza2|Kleter|
Ec1|Ec2|Klepnepne1|Klepnepne2|Kleoxy2|Sa1|Entcloasb|Klepne1|Klepne2|Entcloasb1|Entcloasb2|Entclocomp1
|Entclocomp2|Klepnvar|Klevar|Sa2|Citfre1|Kleoxy1|Pa1|Pa2|Panmuc1|Panmuc2|Stemal|MSSA|Cronobspe|Sermar
|Raoul|Raouspe|Klerae|Mormor|Mormormor|Promir|PromirG|Provpn|Provul|Proret|Prospe|Prostu|SA|Bucc|Aschpe
|Entoclocom|AcibauC|MRSAscv|Pseory|Sermar,|BorNper|PseNA|Rahne"

# Combine organism columns into a single summary field
organism_df2 <- organism_df1 %>%
  rowwise() %>%
  mutate(
# Concatenate org1, org2, org3, etc.
# into a semicolon-separated organism list
    Organism = paste(
      na.omit(c_across(starts_with("org"))),
      collapse = "; "
    )
  ) %>%
  ungroup()

# Merge organism information with culture metadata
final <- full_join(cultures, organism_df2, by = "Accession" )

# Select final output columns
final <- final %>%
select (Accession, Patient_name.x, Procedure, Source, Collect_Date, Organism, org1, org2)

# Export final dataset
write_xlsx(final, "U:/Coding Stuff/REM/detailed_listing/organism_block.xlsx")

##################################################################################################################
################Antibiotic/Susceptiblity Testing Section##############################
#create abx/ast blocks using functions
#culture and org blocks need to be run first
# parsing structure
#1.culture
#2.  → all organisms
#3.      → all antibiotics
#4.          → all ast testing

#######################parse org block#################################
#load parse org block
parse_org_block <- function(org_block,
                            Accession,
                            Patient_name){

# Extract organism name from the Organism:/Panel: line
  organism <- get_org_name(org_block)

# Remove timestamp/result lines and keep only organism-specific susceptibility data
  rows <- clean_org_block(org_block)

# Keep only rows containing susceptibility results
# (% indicates MIC values; S/I/R/S-DD indicate interpretation)
  rows <- rows[
    grepl(
      "%|\\s(S|I|R|S-DD)\\s+Ver",
      rows
    )
  ]

# Parse each antibiotic row into a structured table
  abx_df <- purrr::map_dfr(
    rows,
    parse_abx_row
  )

# Add accession and patient identifiers
  abx_df %>%
    mutate(
      Accession = Accession,
      Patient_name = Patient_name,
      .before = 1
    )
}

#####################################################################################################

#################################Parse all organism susceptibility blocks within one culture report######################
parse_abx_culture <- function(block){

# Extract accession and patient metadata
  meta <- get_culture_info(block)

# Split report into individual organism sections
  org_blocks <- get_org_blocks(block)

# Exit if no organism susceptibility data exists
  if(is.null(org_blocks)){
    return(NULL)
  }

# Parse susceptibility data for each organism
  purrr::map_dfr(
    org_blocks,
    ~ parse_org_block(
        .x,
        Accession = meta$Accession,
        Patient_name = meta$Patient_name
      )
  )

}
#####################################################################################################

##########################clean org block##############################################################
# Remove report-level lines from organism block
clean_org_block <- function (org_block,
                            Accession,
                            Patient_name) 
{
    org_block[!grepl("^\\d{2}/\\d{2}/\\d{2}\\s+\\d{2}:\\d{2}", 
        trimws(org_block))]
}
########################################################################################################

###################################parse abx rows########################################################
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
###########################################################################################################

#run abx parser across all cultures (make sure functions are loaded!!)
abx_df <- purrr::map_dfr(
  culture_blocks,
  parse_abx_culture
)

#merge organism and susceptibility results
abxorg_df <- organism_df %>%
  left_join(
    abx_df,
    by = c("Accession", "Patient_name"),
    relationship = "many-to-many"
  )

# Export results
write_xlsx(abx_df, "U:/Coding Stuff/REM/detailed_listing/abx_block.xlsx")
write_xlsx(abxorg_df, "U:/Coding Stuff/REM/detailed_listing/abxorg_block.xlsx")

##############################################################################################################
###################################Results Block#####################################################

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

#test extraction on a single culture report
cat(get_results_block(culture_blocks[[6]]), sep = "\n")

# Extract results section from every culture report
results_blocks <- lapply(
  culture_blocks,
  get_results_block
)

# Create one row per accession containing raw results
parse_results <- function(block) {

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

# Create dataframe containing raw result text
results_df <- purrr::map_dfr(
  culture_blocks,
  parse_results
)

# Common phrases that are not organism results and should be removed before parsing
remove_phrases <- c(
  "Normal oral flora",
  "Additional mixed flora",
  "No Further Identification",
  "Rare Yeast",
  "Moderate Yeast",
  "Few Yeast",
  "Many Yeast",
# Susceptibility comments
  "Susceptibility\\s* results for this isolate are generally available within 24 hours.",
  "Susceptibility results\\s* for this isolate are generally available within 24 hours.",
  "Susceptibility results for\\s* this isolate are generally available within 24 hours.",
  "Susceptibility results for this\\s* isolate are generally available within 24 hours.",
  "Susceptibility results for this isolate are\\s* generally available within 24 hours.",
  "Susceptibility results for this isolate are generally\\s* available within 24 hours.",
  "Susceptibility results for this isolate are generally available\\s* within 24 hours.",
  "Susceptibility results for this isolate are generally available within\\s* 24 hours.",
  "Susceptibilities Are Not Performed",
  "Susceptibilities\\s* Are Not Performed",
  "Susceptibilities Are\\s* Not Performed",
  "Susceptibilities Are Not\\s* Performed",
  "Susceptibilities Are Not Performed\\s*",
  "Additional Susceptibilities Are Not\\s*",
   "Infectious\\s*Diseases consultation is recommended.",
  "Infectious Diseases\\s*consultation is recommended.",
  "Infectious Diseases consultation\\s* is recommended.",
  "Infectious Diseases consultation is\\s* recommended.",
  "Infectious Diseases consultation is recommended\\s*.",
# Remove date/time/tech header lines
  "^\\s*\\d{2}/\\d{2}/\\d{2}\\s+\\d{2}:\\d{2}\\s+\\S+\\s+"
)

#extract results removing above phrases
clean_results <- stringr::str_remove_all(
results_df$results_raw,
paste(remove_phrases, collapse = "|")
)

#test cleaning on a test record
cat(clean_results[3])

# Extract quantified organism results
# Assumes organism descriptions begin with
# Many, Moderate, Few, or Rare
orgs <- stringr::str_extract_all(
  clean_results,
  "(Many|Moderate|Few|Rare)\\s+[^\\n]+"
)

# Test extraction
orgs[[3]]
orgs[[10]]

# Expand list-column so each organism result becomes its own row
results1_df <- results_df %>%
  mutate(orgs = orgs) %>%
  tidyr::unnest_longer(orgs) %>%
  rename(Results = orgs)

# Remove original raw results column
# Keep one organism result per row
results_final = results1_df %>%
  select(-1)

#Export Results
write_xlsx(results_final, "U:/Coding Stuff/REM/detailed_listing/results_block.xlsx")

##########################Sleeve date (susceptibility testing result date)##################################
#Use modified results section code to pull out antibiotic susceptibility testing result date 
#sleeve date is the date present on sleeve of blood plates containing IDed organisms in Micro minus one day
#create results blocks
get_results_block <- function(block) {

# Find the Organism/Panel section that contains the sleeve collection date information
  start <- grep("\\d{2}/\\d{2}/\\d{2}\\s+\\d{2}:\\d{2}\\s+\\S+\\s+Organism:|Panel:"
    ,
    block
  )[1]

# Return empty vector if no matching section is found
  if (is.na(start)) {
    return(character())
  }

# Find the next Organism/Panel marker which indicates the start of the next organism section
  mic_idx <- grep(
    "Organism:|Panel:",
    block
  )

# Use the first marker occurring after the current section
  end <- mic_idx[mic_idx > start][1]

# If no additional marker exists, use the remainder of the report
  if (is.na(end)) {
    end <- length(block)
  } else {
    end <- end - 1
  }

# Return the sleeve date section
  block[start:end]
}

#test extraction on a single report
cat(get_results_block(culture_blocks[[1]]), sep = "\n")

#Extract sleeve date sections from all reports
sleeve_blocks <- lapply(
  culture_blocks,
  get_results_block
)

# Parse sleeve date information from one report
parse_results <- function(block) {

# Extract sleeve date block
  results <- get_results_block(block)

# Extract culture metadata
  meta <- get_culture_info(block)

  tibble::tibble(
    Sleeve_date = paste(results, collapse = " "),
    Accession = meta$Accession
  )
}

# Create dataframe containing sleeve date text
sleeve_df <- purrr::map_dfr(
  culture_blocks,
  parse_results
)

sleeve_df1 <- sleeve_df %>%
  mutate(
    Sleeve_date = stringr::str_extract(
      Sleeve_date,
      "\\d{2}/\\d{2}/\\d{2}\\s+\\d{2}:\\d{2}"
    ))


# Extract sleeve collection date/time and convert to sleeve date
# Reports contain collection date/time.
# Sleeve placement date is defined as one day prior to extracted date
sleeve_df1 <- sleeve_df1 %>%
  mutate(
    Sleeve_date = as_date(mdy_hm(Sleeve_date)) - days(1),
    Sleeve_date = format(Sleeve_date, "%m/%d/%Y"))
 
#sort sleeve date oldest to newest
sleeve_df1 <- sleeve_df1[order(sleeve_df1$Sleeve_date), increasing = TRUE]

#add row id for easier markups during collection
sleeve_df1 <- cbind(row_id = seq_len(nrow(sleeve_df1)), sleeve_df1)

# Export final sleeve date dataset
write_xlsx(sleeve_df1, "U:/Coding Stuff/REM/detailed_listing/Sleeve_Date.xlsx")
