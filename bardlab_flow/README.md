# bardlab.flow

Helper functions for flow cytometry data analysis in the Bard Lab.

This package provides functions for:
- Converting flowSet objects to tibbles (`extract_fcs_exprs`)
- Checking if points fall within polygons with transformation support (`check_points_within_polygon`)
- Inverse hyperbolic sine transformation for ggplot2 scales (`asinh_trans`)

## Installation

To install directly from R, use the `install_github` function from `devtools`:

```R
devtools::install_github("jbardlab/bardlab_rcode", subdir = "bardlab_flow")
```
