#' Convert GCAM Agriculture Data to GAINS Format
#'
#' Converts GCAM crop and livestock production data to GAINS format.
#' Includes allocation of national-level data to provinces.
#'
#' @param prj GCAM project object
#' @param scenario Scenario name
#' @param allocation_method Allocation method: "uniform" (default) or "statistical"
#' @param crop_shares Optional data frame with crop allocation shares
#' @param livestock_shares Optional data frame with livestock allocation shares
#' @return List with crop and livestock data in GAINS format
#' @export
convert_agriculture_to_gains <- function(
    prj,
    scenario,
    allocation_method = "uniform",
    crop_shares = NULL,
    livestock_shares = NULL
) {

  cat("\n=== Converting Agriculture Data to GAINS Format ===\n\n")

  # Load mappings
  crop_mapping <- load_gcam2gains_mapping("crops")
  livestock_mapping <- load_gcam2gains_mapping("livestock")

  # 1. Allocate crop production to provinces
  cat("Step 1: Allocating crop production...\n")
  crop_provincial <- allocate_crop_production_simple(
    prj, scenario,
    allocation_method = allocation_method,
    statistical_shares = crop_shares
  )

  # 2. Allocate livestock production to provinces
  cat("\nStep 2: Allocating livestock production...\n")
  livestock_provincial <- allocate_livestock_production_simple(
    prj, scenario,
    allocation_method = allocation_method,
    statistical_shares = livestock_shares
  )

  # 3. Format crop data for GAINS
  cat("\nStep 3: Formatting crop data for GAINS...\n")
  crop_gains <- crop_provincial %>%
    dplyr::left_join(
      crop_mapping %>%
        dplyr::select(gcam_crop, crop_category, gains_sector, gains_subsector),
      by = c("crop" = "gcam_crop")
    ) %>%
    dplyr::select(
      scenario,
      province_code = region,
      province_name = province_name_en,
      province_name_zh,
      sector = gains_sector,
      subsector = gains_subsector,
      crop,
      crop_category,
      year,
      production = provincial_production,
      allocation_share = provincial_share
    ) %>%
    dplyr::arrange(province_code, crop, year)

  # 4. Format livestock data for GAINS
  cat("Step 4: Formatting livestock data for GAINS...\n")
  livestock_gains <- livestock_provincial %>%
    dplyr::left_join(
      livestock_mapping %>%
        dplyr::select(gcam_livestock, livestock_category, gains_sector, gains_subsector),
      by = c("livestock" = "gcam_livestock")
    ) %>%
    dplyr::select(
      scenario,
      province_code = region,
      province_name = province_name_en,
      province_name_zh,
      sector = gains_sector,
      subsector = gains_subsector,
      livestock,
      livestock_category,
      year,
      production = provincial_production,
      allocation_share = provincial_share
    ) %>%
    dplyr::arrange(province_code, livestock, year)

  # Add metadata
  attr(crop_gains, "units") <- "Mt"
  attr(crop_gains, "source") <- "GCAM-China"
  attr(crop_gains, "allocation_method") <- allocation_method
  attr(crop_gains, "conversion_date") <- Sys.Date()

  attr(livestock_gains, "units") <- "Mt"
  attr(livestock_gains, "source") <- "GCAM-China"
  attr(livestock_gains, "allocation_method") <- allocation_method
  attr(livestock_gains, "conversion_date") <- Sys.Date()

  cat("\n=== Conversion Complete ===\n")
  if (allocation_method == "uniform") {
    cat("\nWARNING: Using uniform allocation (placeholder).\n")
    cat("For accurate results, use statistical yearbook data.\n")
    cat("See: create_statistical_shares_template() and create_livestock_shares_template()\n")
  }

  # Return results
  results <- list(
    crops = crop_gains,
    livestock = livestock_gains,
    allocation_method = allocation_method
  )

  return(results)
}


#' Export Agriculture GAINS Data to CSV
#'
#' @param agriculture_data Output from convert_agriculture_to_gains()
#' @param output_dir Output directory path
#' @param prefix File name prefix (default: "gains")
#' @export
export_agriculture_gains <- function(agriculture_data, output_dir, prefix = "gains") {

  # Create output directory if it doesn't exist
  if (!dir.exists(output_dir)) {
    dir.create(output_dir, recursive = TRUE)
  }

  # Export crop data
  crop_file <- file.path(output_dir, paste0(prefix, "_crops.csv"))
  readr::write_csv(agriculture_data$crops, crop_file)
  cat("Crop data exported to:", crop_file, "\n")

  # Export livestock data
  livestock_file <- file.path(output_dir, paste0(prefix, "_livestock.csv"))
  readr::write_csv(agriculture_data$livestock, livestock_file)
  cat("Livestock data exported to:", livestock_file, "\n")

  # Export validation results
  validation_file <- file.path(output_dir, paste0(prefix, "_validation.txt"))
  sink(validation_file)
  cat("=== Crop Allocation Validation ===\n")
  print(agriculture_data$crop_validation)
  cat("\n=== Livestock Allocation Validation ===\n")
  print(agriculture_data$livestock_validation)
  sink()
  cat("Validation results exported to:", validation_file, "\n")

  invisible(list(
    crop_file = crop_file,
    livestock_file = livestock_file,
    validation_file = validation_file
  ))
}


#' Get Agriculture Production Summary
#'
#' @param agriculture_data Output from convert_agriculture_to_gains()
#' @param year_filter Year to summarize (default: 2020)
#' @return List with crop and livestock summaries
#' @export
summarize_agriculture_gains <- function(agriculture_data, year_filter = 2020) {

  # Crop summary by province
  crop_summary <- agriculture_data$crops %>%
    dplyr::filter(year == year_filter) %>%
    dplyr::group_by(province_code, province_name, crop_category) %>%
    dplyr::summarise(
      total_production = sum(production, na.rm = TRUE),
      n_crops = dplyr::n(),
      .groups = "drop"
    ) %>%
    dplyr::arrange(dplyr::desc(total_production))

  # Livestock summary by province
  livestock_summary <- agriculture_data$livestock %>%
    dplyr::filter(year == year_filter) %>%
    dplyr::group_by(province_code, province_name, livestock_category) %>%
    dplyr::summarise(
      total_production = sum(production, na.rm = TRUE),
      n_products = dplyr::n(),
      .groups = "drop"
    ) %>%
    dplyr::arrange(dplyr::desc(total_production))

  # National totals
  crop_national <- agriculture_data$crops %>%
    dplyr::filter(year == year_filter) %>%
    dplyr::group_by(crop_category) %>%
    dplyr::summarise(
      total_production = sum(production, na.rm = TRUE),
      .groups = "drop"
    )

  livestock_national <- agriculture_data$livestock %>%
    dplyr::filter(year == year_filter) %>%
    dplyr::group_by(livestock_category) %>%
    dplyr::summarise(
      total_production = sum(production, na.rm = TRUE),
      .groups = "drop"
    )

  return(list(
    crop_by_province = crop_summary,
    livestock_by_province = livestock_summary,
    crop_national = crop_national,
    livestock_national = livestock_national
  ))
}
