Cerner Microbiology Parser
Tools for extracting structured microbiology, organism, and antibiotic susceptibility data from Cerner text reports.

Overview
The Cerner_micro package parses raw Cerner microbiology reports and converts them into analysis-ready data frames. The package is designed to process microbiology detailed line listings exported from Cerner and extract:

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
Input files should be detailed line listing Cerner microbiology reports exported as plain text (.txt).

Main Functions:
-Parse Cerner Microbiology
parse_cerner_microbiology(file): Returns a list of structured datasets extracted from a Cerner report.

-Parse Organisms
parse_cerner_organisms(file): Extracts organism-level findings.
org_df <- parse_cerner_organisms(file)

-Parse Antibiotics
parse_cerner_abx(file): Extracts antimicrobial susceptibility testing results.
abx_df <- parse_cerner_abx(file)

-Parse Sleeve Data
parse_cerner_sleeve(file): Extracts procedure and date-related information from sleeve reports.
sleeve_df <- parse_cerner_sleeve(file)

Example Workflow:
-install packages
-parse_cerner_microbiology -> results (list of dataframes)
-cultures_df <- results$cultures
-organisms_df <- results$organisms
-sleeve_df <- results$sleeves

Known Limitations:
-Formatting may differ across Cerner versions.
-Rare organisms with unusual naming conventions may require additional parsing rules.
-Some multi-page susceptibility panels may contain repeated header information that must be filtered during parsing.
-Reports with substantial customization may require local modifications.

Future Development:
Planned Enhancements:
-Automated quality checks
-Support for Beaker report layouts

Author:
Kimberly Grasty, MS, MPH
Research Specialist
University of Pennsylvania / Penn Medicine
