get_org_blocks <- function(block){

# Find each line containing an organism header
# (typically "Organism:" followed by a susceptibility panel)
  starts <- grep(
    "Organism:|Panel:",
    block
  )

# Return NULL if no organisms are present
  if(length(starts) == 0){
    return(NULL)
  }

# Define the end of each organism block
# Each block ends immediately before the next organism block
  ends <- c(
    starts[-1] - 1,
    length(block)
  )

# Extract each organism section into a separate list element
  Map(
    function(s,e){
      block[s:e]
    },
    starts,
    ends
  )

}

