ClinMicro provides tools for parsing clinical microbiology reports- converting culture results, organism identification, and antimicrobial susceptibility testing into tidy data frames for downstream analysis.

Overview
The ClinMicro package parses raw clinical microbiology reports and converts them into analysis-ready data frames. The package is designed to process microbiology detailed line listings and extract:

Culture-level metadata:
-Organisms identified in each culture
-Antibiotic susceptibility results
-Procedure dates and report dates
-Patient and accession information

Features:
-Parses multi-page microbiology reports
-Handles multiple cultures within a single report
-Extracts organism-level results
-Extracts antibiotic susceptibility (MIC/SIR) data
-Preserves accession and patient identifiers
-Returns tidy data frames suitable for downstream analysis

Installation:
remotes::install_github(
  "kgrsty/Code-for-REM",
  subdir = "pak"
)

Expected Input:
Input files should be detailed line listing clinical microbiology reports exported as plain text (.txt).


Main Functions:
Function	Description:
  parse_culture()	Extract culture-level metadata for each culture report.
  parse_organisms()	Extract organisms identified within each culture.
  parse_abx()	Extract antimicrobial susceptibility testing results.
  parse_sleeve()	Parse sleeve culture reports and associated dates.

Example: Organisms
R
orgs <- parse_organisms(
"Microbiology_Detailed_Line_Listing.txt"
)
head(orgs)

Expected output:
Accession	Patient_name	Organism
26-289-08389	Smith, John	Staphylococcus aureus
26-289-08389	Smith, John	Candida albicans

Example: Antibiotic Susceptibilities
R
abx <- parse_abx(
"Microbiology_Detailed_Line_Listing.txt"
)
head(abx)
 
Expected output:
Accession	Organism	Antibiotic	MIC	Interpretation
26-289-08389	Staphylococcus aureus	Oxacillin	≤0.25	S
26-289-08389	Staphylococcus aureus	Vancomycin	1	  S

Status:
Current version: 0.0.0.9000
Under active development. Function names and outputs may change as additional microbiology report formats are supported.


