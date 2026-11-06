#install packages
install.packages(c("devtools", "usethis", "roxygen2"))

#create package skeleton
usethis::create_package("U:/Coding Stuff/Cerner/pak")

#load all functions
devtools::load_all("U:/Coding Stuff/Cerner/pak/R")
devtools::document("U:/Coding Stuff/Cerner/pak")

#list functions
list.files("R")

#generate Specimen and Isolate collection list
#contains all fields (Name, Accession, Procedure, Source, Collect_date, Sleeve_date)
cultures_df <- parse_cerner_microbiology( "U:/Coding Stuff/REM/detailed_listing/preview_10_15_2026_15_25_26.tmp.DAT")

#arrange collect_date from earliest to latest
#remove Sleeve_date column
#add row ID for easier markups during collection
cultures_final <- cultures_df %>%
  arrange(Collect_Date) %>%
  select(-Sleeve_date) %>%
  mutate(row_id = row_number(), .before = 1)

#generate Isolate Colllection List with just accession and sleeve_date
Sleeve_df <- cultures_df %>%
select(Accession, Sleeve_date)

# Extract sleeve collection date/time and convert to sleeve date
# Reports contain collection date/time.
# Sleeve placement date is defined as one day prior to extracted date
Sleeve_df <- Sleeve_df %>%
  mutate(Sleeve_date = as_date(mdy_hm(Sleeve_date)) - days(1),
    Sleeve_date = format(Sleeve_date, "%m/%d/%Y")) 

Sleeve_final <- Sleeve_df %>%
arrange(Sleeve_date) %>%
 mutate(row_id = row_number(), .before = 1)


#write excel file to collection list folder
write_xlsx(cultures_final, "U:/Coding Stuff/REM/detailed_listing/Collection_Lists/Specimen_List.xlsx")

# Export final sleeve date dataset
write_xlsx(Sleeve_final, "U:/Coding Stuff/REM/detailed_listing/Collection_Lists/Isolate_List.xlsx")

#Organisms dataframe (one org per row)
organisms_df <- parse_cerner_organisms("U:/Coding Stuff/REM/detailed_listing/preview_10_15_2026_15_25_26.tmp.DAT")

#multiple orgs spread across columns
org_columns <- org_cols("U:/Coding Stuff/REM/detailed_listing/preview_10_15_2026_15_25_26.tmp.DAT")

#Antibiotics, MIC_value, interpretation, Patient_name, Accession
abx_df <- parse_abx_file("U:/Coding Stuff/REM/detailed_listing/preview_10_15_2026_15_25_26.tmp.DAT")