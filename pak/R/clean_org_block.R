#' Removes report headers, page breaks, and other non-data lines from an organism section before parsing
#' @keywords internal


clean_org_block <- function (org_block,
                            Accession,
                            Patient_name) 
{
    org_block[!grepl("^\\d{2}/\\d{2}/\\d{2}\\s+\\d{2}:\\d{2}", 
        trimws(org_block))]
}
