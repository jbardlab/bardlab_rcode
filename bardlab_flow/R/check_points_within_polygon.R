#' Check if Points are Within a Polygon
#'
#' Determines which points in a dataset fall within a specified polygon, with support for
#' coordinate transformation (linear, log, or asinh).
#'
#' @param data A data frame containing the points to check
#' @param polygon A data frame defining the polygon vertices with columns matching xcol and ycol
#' @param xcol Character string specifying the column name for x coordinates
#' @param ycol Character string specifying the column name for y coordinates
#' @param transform Character string specifying the transformation to apply: "linear", "log", or "asinh"
#'
#' @return A logical vector indicating whether each point is within the polygon (NA for invalid points)
#' @export
#'
#' @importFrom dplyr mutate filter across all_of
#' @importFrom rlang .data
#'
#' @examples
#' \dontrun{
#' # Create sample data
#' data <- data.frame(x = c(1, 5, 10), y = c(1, 5, 10))
#' polygon <- data.frame(x = c(0, 10, 10, 0, 0), y = c(0, 0, 10, 10, 0))
#'
#' # Check which points are in polygon
#' result <- check_points_within_polygon(data, polygon, "x", "y", transform = "linear")
#' }
check_points_within_polygon <- function(data, polygon, xcol, ycol, transform = "linear") {
  # Apply transformation based on transform parameter
  transform_func <- switch(transform,
    "linear" = function(x) x,
    "log" = function(x) log10(x),
    "asinh" = function(x) asinh(x),
    stop("Transform must be 'linear', 'log', or 'asinh'")
  )

  # Identify valid rows (for log transform, exclude zeros and negatives)
  if (transform == "log") {
    valid_rows <- data[[xcol]] > 0 & data[[ycol]] > 0
    polygon <- polygon %>%
      filter(.data[[xcol]] > 0 & .data[[ycol]] > 0)
  } else {
    valid_rows <- rep(TRUE, nrow(data))
  }

  # Initialize result vector with NAs
  result <- rep(NA, nrow(data))

  # Only process valid rows
  if (sum(valid_rows) > 0) {
    # Transform polygon coordinates
    polygon_transformed <- polygon %>%
      mutate(across(c(all_of(xcol), all_of(ycol)), transform_func))

    # Transform data coordinates (only valid rows)
    data_transformed <- data[valid_rows, ] %>%
      mutate(across(c(all_of(xcol), all_of(ycol)), transform_func))

    # Convert the transformed polygon to an sf object
    polygon_sf <- sf::st_sfc(sf::st_polygon(list(as.matrix(polygon_transformed))), crs = 3857)

    # Convert the transformed data to an sf object
    data_sf <- sf::st_as_sf(data_transformed, coords = c(xcol, ycol), crs = 3857)

    # Check if each point is within the polygon
    within_polygon <- sf::st_within(data_sf, polygon_sf, sparse = FALSE)

    # Fill in results for valid rows
    result[valid_rows] <- within_polygon[, 1]
  }

  return(result)
}
