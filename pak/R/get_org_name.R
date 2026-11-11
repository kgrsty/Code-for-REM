#' @export


get_org_name <- function(org_block) {
stringr::str_match(
org_block[1],
"Organism:\\s*(.*?)\\s*Panel:"
)[,2]
}
