#install packages
install.packages(c("devtools", "usethis", "roxygen2", "writexl", "tidyverse"))

#load packages- may not need this
library(tidyverse)
library(writexl)


#create package skeleton 
usethis::create_package("U:/Coding Stuff/Cerner/pak")

#load all functions
devtools::load_all("U:/Coding Stuff/Cerner/pak/R")
devtools::document("U:/Coding Stuff/Cerner/pak")

#list functions
list.files("R")

#generate dataframes

#contains all dataframes
results<- parse_cerner_microbiology( "U:/Coding Stuff/REM/detailed_listing/preview_10_22_2026_14_28_25.tmp.DAT")

#accession, name, source, procdure, collect_date
cultures_df <- results$cultures
#arrange collect_date from earliest to latest
#remove Sleeve_date column
#add row ID for easier markups during collection
cultures_final <- cultures_df %>%
  arrange(Collect_Date) %>%
  mutate(row_id = row_number(), .before = 1)

#write excel file to collection list folder
write_xlsx(cultures_final, "U:/Coding Stuff/REM/detailed_listing/Collection_Lists/Specimen_List.xlsx")


#returns accession, name, date of isolate sleeve 
sleeve_df <- results$sleeves
# Extract sleeve collection date/time and convert to sleeve date
# Reports contain collection date/time.
# Sleeve placement date is defined as one day prior to extracted date
sleeve_df <- sleeve_df %>%
  mutate(Sleeve_date = as_date(mdy_hm(Sleeve_date)) - days(1),
    Sleeve_date = format(Sleeve_date, "%m/%d/%Y")) 
#add row ID for easier markups during collection
sleeve_final <- sleeve_df %>%
arrange(Sleeve_date) %>%
 mutate(row_id = row_number(), .before = 1)

#write excel file to collection list folder
write_xlsx(sleeve_final, "U:/Coding Stuff/REM/detailed_listing/Collection_Lists/Isolate_List.xlsx")

#returns accession, name, organism(s)
organisms_df <- results$organisms

#patients with multiple organisms spread across columns
org_columns <- org_cols("U:/Coding Stuff/REM/detailed_listing/preview_10_22_2026_14_28_25.tmp.DAT
