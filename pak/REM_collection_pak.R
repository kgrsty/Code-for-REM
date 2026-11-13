#R package to generate specimen and isolate lists for REM project using Cerner detailed line listing

#load package and libs
install.packages("CernerMicro")
library(CernerMicro)
pak::pak("kgrsty/Code-for-REM/pak")
library(pak)
library(tidyverse)
library(writexl)

#load documentation, load functions
devtools::document()
devtools::load_all()

#generate results dataframe containing list of 3 dataframes- cultures (specimen collection), sleeve dates (isolate collection) and organisms
results<- parse_cerner_microbiology( "U:/Coding Stuff/REM/detailed_listing/preview_10_13_2026_15_58_00.tmp.DAT")

#Specimen Collection List
#accession, name, source, procdure, collect_date
cultures_df <- results$cultures

#arrange collect_date from earliest to latest
#add row ID for easier markups during collection
cultures_final <- cultures_df %>%
  arrange(Collect_Date) %>%
  mutate(row_id = row_number(), .before = 1)

#write excel file to collection list folder
write_xlsx(cultures_final, "U:/Coding Stuff/REM/detailed_listing/Collection_Lists/Specimen_List.xlsx")

#Sleeve Date
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
 mutate(row_id = row_number(), .before = 1) %>%
  select(-Patient_name)

#write excel file to collection list folder
write_xlsx(sleeve_final, "U:/Coding Stuff/REM/detailed_listing/Collection_Lists/Isolate_List.xlsx")


#Extras
#returns accession, name, organism(s)
organisms_df <- results$organisms
#write excel file to collection list folder
write_xlsx(organisms_df, "U:/Coding Stuff/REM/detailed_listing/Collection_Lists/Org_List.xlsx")


#patients with multiple organisms spread across columns
org_columns <- org_cols("U:/Coding Stuff/REM/detailed_listing/preview_10_13_2026_15_58_00.tmp.DAT")
#write excel file to collection list folder
write_xlsx(org_columns, "U:/Coding Stuff/REM/detailed_listing/Collection_Lists/OrgCols_List.xlsx")


#returns accession, name, organism, antibiotic, MIC value and interpretation
#if abx block contains a page break, subsequent organisms convert to NAs
abx_df <- parse_cerner_abx("U:/Coding Stuff/REM/detailed_listing/preview_10_13_2026_15_58_00.tmp.DAT")
#write excel file to collection list folder
write_xlsx(abx_df, "U:/Coding Stuff/REM/detailed_listing/Collection_Lists/AbxOrgs_List.xlsx")

