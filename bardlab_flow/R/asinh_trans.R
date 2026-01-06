#' Inverse Hyperbolic Sine Transformation for ggplot2
#'
#' Creates a transformation object for use with ggplot2 scales that applies
#' inverse hyperbolic sine (asinh) transformation, commonly used for flow cytometry data.
#'
#' @return A transformation object for use with ggplot2 scale functions
#' @export
#'
#' @importFrom scales trans_new label_scientific
#'
#' @examples
#' \dontrun{
#' library(ggplot2)
#' ggplot(data, aes(x = FSC, y = SSC)) +
#'   geom_point() +
#'   scale_x_continuous(trans = asinh_trans()) +
#'   scale_y_continuous(trans = asinh_trans())
#' }
asinh_trans <- function() {
  scales::trans_new(
    name = "asinh",
    transform = base::asinh,
    inverse = base::sinh,
    breaks = function(x) {
      breaks <- c(1e1, 1e2, 1e3, 1e4, 1e5, 5e5, 1e6, 5e6, 1e7, 1e8)
      breaks[breaks >= min(x) & breaks <= max(x)]
    },
    format = scales::label_scientific()
  )
}
