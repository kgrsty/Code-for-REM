#This code is used to extract the information below from a Cerner Condensed line listing
#Extract Fields-Name, MRN, Accession, Source, Procedure, Receive Date and Final Isolate
#organism_list look up table to find applicable organisms
#specimens with multiple organisms are split into separate columns


#load packages
library(stringr) #manipulate text
library(dplyr) #filter, summarize and transform tables
library(writexl) #write excel sheet
library(purrr)

#read in pdata
lines <- readLines("U:/Coding Stuff/REM/condensed_listing/preview_10_12_2026_17_10_48_0.tmp.DAT")

#remove header
lines <- lines[
  !grepl(
    "Date:|Microbiology Detailed Line Listing Report|Id:|Sequence:|Page:",
    lines
  )
]

#remove header
lines <- lines[
  !grepl(
    "Date/Time - Procedure Started -",
    lines
  )
]

#test record start pattern grep
grep("\\d{2}/\\d{2}/\\d{2}\\s+\\d{2}:\\d{2}", lines, value = TRUE)

#============================================================================++++++++++
#Extract Fields-Name, MRN, Accession, Source, Procedure, Receive Date and Final Isolate
#structure of pdf looks like this:
  #Line 1: Name + MRN + Receive Date + Procedure
  #Line 2: Accession + Source + First part of Final Isolate
  #Line 3: blank
  #Line 4+: Continuation of Final Isolate

#############################find start of record###############################################################
start_idx <- grep(
  "\\d{2}/\\d{2}/\\d{2}\\s+\\d{2}:\\d{2}",
  lines)

#check length (should be 19)
length(start_idx)

#Check number of positions
start_idx

#examine lines 1 to 5
lines[start_idx[1:5]]

##############################create empty dataframe to populate###########################################
##############do loops to find the start and end of each record to make record blocks############
# Create empty list to store one parsed record per patient block
out <- list()
# Loop through each patient record
for(i in seq_along(start_idx)) {
# Starting line for this record
  start <- start_idx[i]
# Ending line is either the line before the next record
# or the end of the file for the last record
  end <- if(i < length(start_idx))
    start_idx[i + 1] - 1
  else
    length(lines)

#create patient record blocks
  block <- lines[start:end]
#First line contains patient demographics and accession info
  line1 <- block[1]
#Second line often contains continuation of isolate text
  line2 <- block[2]

# Extract Name
  name <- trimws(substr(line1, 1, 25))

# Extract MRN. Location is also in this field, split into MRN and Location
 mrn_full <- str_extract(
  line1,
  "\\d+\\s+(HUP|PMC)"
)
 mrn <- str_extract(mrn_full, "\\d+")
  
#Extract Location
 location <- str_extract(mrn_full, "HUP|PMC")

#Extract Receive date
  receive_date <- str_extract(
    line1,
    "\\d{2}/\\d{2}/\\d{2}\\s+\\d{2}:\\d{2}"
  )

 #--------------------------------------------------
  # Remove everything up through receive date
  # Remaining text should contain:
  # Procedure Accession Source Isolate
  #--------------------------------------------------
after_date <- trimws(
  sub(
    paste0(".*", receive_date),
    "",
    line1
  )
)
  
  #--------------------------------------------------
  # Extract Procedure, Accession, Source,
  # and beginning of Final Isolate
  #
  # Example:
  # C RESP 26-282-10219 BAL GNR,GPR,Gpc
  #--------------------------------------------------

parsed <- stringr::str_match(
  after_date,
  "^(.*?)\\s+(\\d{2}-\\d{3}-\\d{5})\\s+(\\S+)\\s*(.*)$"
)

procedure <- parsed[,2]
accession <- parsed[,3]
source <- parsed[,4]
first_isolate <- parsed[,5]

#--------------------------------------------------
# Grab all remaining non-empty lines
#--------------------------------------------------
  
#footer- dashes,total accession selected, end of report
  extras <- block[
    seq_along(block) > 1 &
      nchar(trimws(block)) > 0
  ]

#remove footers
extras <- extras[
  !grepl("^=+", extras) &
  !grepl("Total accession selected", extras) &
  !grepl("END OF REPORT", extras)
]

# combine isolate text lines for Final Isolate
final_isolate <- stringr::str_squish(
  paste(
    na.omit(c(first_isolate, trimws(extras))),
    collapse = " "
  )
)
# Convert blank strings to NA
if (!nzchar(final_isolate)) {
  final_isolate <- NA_character_
}

#create dataframe using created empty frame
  out[[i]] <- data.frame(
    Name = name,
    MRN = mrn,
    Location = location,
    Receive_Date = receive_date,
    Procedure = procedure,
    Accession = accession,
    Source = source,
    Final_Isolate = final_isolate,
    Organism = "NA"
  )
}

#Combine all records into one dataframe
condense <- bind_rows(out)


#Cerner organism abbreviation lookup pattern
org_pattern <- "PA|EC|Pamuc|Panmuc|CitFcomp|Klepne|Entclocomp|Kleoxy|MRSA|Citbra
|Citfar|Citgil|Citkos|Citmur|Citrod|Citsed|Citwer|Cityou|Kleoza|Citfre|Citama|Klegra|Klepneoza|Klepnepne
|Klepnerhi|Entclo|Entaer|Entaer1|Kleorn|Klerhi|Citfre2|Entaer2|Entclo1|Entclo2|Kleoza1|Kleoza2|Kleter|
Ec1|Ec2|Klepnepne1|Klepnepne2|Kleoxy2|Sa1|Entcloasb|Klepne1|Klepne2|Entcloasb1|Entcloasb2|Entclocomp1
|Entclocomp2|Klepnvar|Klevar|Sa2|Citfre1|Kleoxy1|Pa1|Pa2|Panmuc1|Panmuc2|Stemal|MSSA|Cronobspe|Sermar
|Raoul|Raouspe|Klerae|Mormor|Mormormor|Promir|PromirG|Provpn|Provul|Proret|Prospe|Prostu|SA|Bucc|Aschpe
|Entoclocom|AcibauC|MRSAscv|Pseory|Sermar,"

#remove anything with "SA" in Final_Isolate (false-positive SA matches)
condense1 <- condense %>%
mutate(
Final_Isolate = str_remove(Final_Isolate, "NOT No SA"),
Final_Isolate = str_remove(Final_Isolate, "BCSA1")
)

#populate Organism column from lookup pattern
condense2 <- condense1 %>%
mutate(
#Remove duplicates and combine organisms
Organism = str_extract_all(Final_Isolate, org_pattern),
Organism = sapply(Organism, function(x) paste(unique(x), collapse = "; ")))

# Convert Organism strings back to lists
orgs <- strsplit(condense2$Organism, ";\\s*")
  
################################### # Create separate organism columns #####################################
#extract organisms names from text (final isolate column and org_pattern lookup table)

#remove blanks and duplicates
orgs <- lapply(orgs, function(x) {
  x <- x[!is.na(x)]
  x <- x[x != ""]
  unique(x)
})

#check the max the number of orgs in any record
max_orgs <- max(lengths(orgs))

 
#Pad each record with NA values, so all rows become equal length, then stack into a table
org_cols <- do.call(
  rbind,
  lapply(orgs, function(x) {
    c(x, rep(NA, max_orgs - length(x)))
  })
)

#create column names
colnames(org_cols) <- paste0("Organism_", seq_len(max_orgs))

#bind organism columns to dataset
condense3 <- cbind(condense2, org_cols)
################################################################################################

#Export file
write_xlsx(condense3, "U:/Coding Stuff/REM/condensed_listing/condensed.xlsx")




