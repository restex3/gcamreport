#' Allocate National Livestock Production to Provinces (Simplified Version)
#'
#' This version uses uniform distribution as a placeholder.
#' Replace with actual statistical data when available.
#'
#' @param prj GCAM project object
#' @param scenario Scenario name
#' @param allocation_method Method: "uniform" (default) or "statistical"
#' @param statistical_shares Optional data frame with provincial shares from statistical yearbook
#' @return Data frame with provincial livestock production
#' @export
allocate_livestock_production_simple <- function(
    prj,
    scenario,
    allocation_method = "uniform",
    statistical_shares = NULL
) {

  # Load mappings
  livestock_mapping <- load_gcam2gains_mapping("livestock")
  province_mapping <- load_gcam2gains_mapping("provinces")

  # Get national livestock production (China only)
  cat("Loading national livestock production...\n")
  national_prod <- rgcam::getQuery(prj, "meat and dairy production by type", scenario)
  national_prod <- national_prod %>%
    dplyr::filter(region == "China")

  provinces <- province_mapping$province_code
  n_provinces <- length(provinces)

  if (allocation_method == "uniform") {
    # Method 1: Uniform distribution (placeholder)
    cat("Using uniform distribution (1/31 for each province)...\n")
    cat("WARNING: This is a placeholder. Replace with statistical data for accuracy.\n")

    provincial_prod <- national_prod %>%
      tidyr::crossing(province_code = provinces) %>%
      dplyr::mutate(
        provincial_share = 1 / n_provinces,
        provincial_production = value * provincial_share
      ) %>%
      dplyr::select(
        scenario,
        region = province_code,
        livestock = sector,
        year,
        national_production = value,
        provincial_share,
        provincial_production
      )

  } else if (allocation_method == "statistical" && !is.null(statistical_shares)) {
    # Method 2: Use statistical yearbook data
    cat("Using statistical yearbook allocation shares...\n")

    # statistical_shares should have columns: livestock, province_code, share
    provincial_prod <- national_prod %>%
      dplyr::left_join(
        statistical_shares,
        by = c("sector" = "livestock")
      ) %>%
      dplyr::mutate(
        provincial_production = value * share
      ) %>%
      dplyr::select(
        scenario,
        region = province_code,
        livestock = sector,
        year,
        national_production = value,
        provincial_share = share,
        provincial_production
      )

  } else {
    stop("Invalid allocation method or missing statistical_shares data")
  }

  # Add livestock category information
  provincial_prod <- provincial_prod %>%
    dplyr::left_join(
      livestock_mapping %>%
        dplyr::select(gcam_livestock, livestock_category),
      by = c("livestock" = "gcam_livestock")
    )

  # Add province information
  provincial_prod <- provincial_prod %>%
    dplyr::left_join(
      province_mapping %>%
        dplyr::select(province_code, province_name_en, province_name_zh),
      by = c("region" = "province_code")
    )

  # Add metadata
  attr(provincial_prod, "units") <- "Mt"
  attr(provincial_prod, "source") <- "GCAM-China"
  attr(provincial_prod, "allocation_method") <- allocation_method
  attr(provincial_prod, "allocation_date") <- Sys.Date()

  return(provincial_prod)
}


#' Create Template for Livestock Statistical Allocation Shares
#'
#' Creates a template CSV file for entering provincial livestock allocation shares
#' from statistical yearbook data.
#'
#' @param output_file Path to output CSV file
#' @export
create_livestock_shares_template <- function(output_file = "provincial_livestock_shares_template.csv") {

  province_mapping <- load_gcam2gains_mapping("provinces")
  livestock_mapping <- load_gcam2gains_mapping("livestock")

  # Create template with all livestock-province combinations
  template <- tidyr::crossing(
    livestock = livestock_mapping$gcam_livestock,
    province_code = province_mapping$province_code
  ) %>%
    dplyr::left_join(
      province_mapping %>% dplyr::select(province_code, province_name_en),
      by = "province_code"
    ) %>%
    dplyr::mutate(
      share = NA_real_,
      notes = "Enter provincial share (0-1). Shares for each livestock should sum to 1.0"
    ) %>%
    dplyr::select(livestock, province_code, province_name_en, share, notes)

  readr::write_csv(template, output_file)
  cat("Template created:", output_file, "\n")
  cat("Fill in the 'share' column with data from statistical yearbook.\n")
  cat("For each livestock product, provincial shares should sum to 1.0\n")

  invisible(template)
}
