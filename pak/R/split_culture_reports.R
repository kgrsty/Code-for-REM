#parser for culture metadata
#' @param Detailed Listing DAT file
#' @export
#' @return split patient blocks

split_culture_reports <- function(pages){

name_idx <- grep("^ Name:", pages)
  
real_name_idx <- name_idx[
  sapply(name_idx, function(i){

    any(
      grepl(
        "MRN/Age/Sex:",
        pages[i:min(i + 5, length(pages))]
      )
    )

  })
]
  name_end <- c(
  real_name_idx[-1] - 1,
  length(pages)
  )
  
  
culture_blocks <- Map(
  function(start, end){
    pages[start:end]
  },
  real_name_idx,
  name_end
)
  return(culture_blocks)
}  

