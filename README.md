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

Expected Input
Input files should be detailed line listing Cerner microbiology reports exported as plain text (.txt).
