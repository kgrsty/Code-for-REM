Clin Microbiology Parser
Tools for extracting structured microbiology, organism, and antibiotic susceptibility data from clinical microbiology reports.

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

Expected Input:
Input files should be detailed line listing clinical microbiology reports exported as plain text (.txt).

Main Functions:
parse_clin_microbiology(file): Returns a list of structured datasets extracted from a clinical microbiology report.
parse_clin_microbiology()
│
├── parse_organisms()
├── parse_abx()
└── parse_sleeve()

parse_organisms(file): Extracts organism-level findings.
readLines()
  ↓
split_culture_reports()
  ↓
get_culture_info()
  ↓
extract_organisms()
  ↓
Organism Data Frame

parse_abx(file): Extracts antimicrobial susceptibility testing results.
readLines()
  ↓
split_culture_reports()
  ↓
get_culture_info()
  ↓
get_org_blocks()
  ↓
parse_abx_block()
  ↓
Antibiotic Susceptibility Data Frame

parse_sleeve(file): Extracts procedure and date-related information from sleeve reports.






