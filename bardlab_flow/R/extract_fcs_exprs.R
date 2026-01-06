#' Extract Expression Data from flowSet
#'
#' Converts a flowSet object to a tibble containing expression data with sample names and cell IDs.
#'
#' @param flowset A flowSet object containing flow cytometry data
#'
#' @return A tibble containing expression data from all samples with fileName and cell_ID columns
#' @export
#'
#' @importFrom dplyr mutate bind_rows
#' @importFrom tibble as_tibble
#' @importFrom flowCore exprs sampleNames
#'
#' @examples
#' \dontrun{
#' # Assuming you have a flowSet object called fs
#' expr_data <- extract_fcs_exprs(fs)
#' }
extract_fcs_exprs <- function(flowset) {
  # function to convert flowSet to tibble
  sample_names <- sampleNames(flowset)
  tibble_list <- list()
  for (i in seq_along(flowset)) {
    flow_frame <- flowset[[i]]
    sample_name <- sample_names[i]
    expression_matrix <- exprs(flow_frame)
    tibble_list[[i]] <- as_tibble(expression_matrix) %>%
      mutate(fileName = sample_name) %>%
      mutate(cell_ID = row_number()) # add a unique cell_ID for every particle
  }
  return(bind_rows(tibble_list))
}
