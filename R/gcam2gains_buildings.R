#' Load GCAM2GAINS Mapping Files
#'
#' @param mapping_name Name of the mapping file (without .csv extension)
#' @return Data frame with mapping information
#' @export
load_gcam2gains_mapping <- function(mapping_name) {
  mapping_file <- system.file(
    "extdata", "mappings", "GCAM2GAINS",
    paste0(mapping_name, ".csv"),
    package = "gcamreport"
  )

  if (!file.exists(mapping_file)) {
    stop("Mapping file not found: ", mapping_name)
  }

  readr::read_csv(mapping_file, show_col_types = FALSE)
}


#' Convert GCAM Buildings Data to GAINS Format
#'
#' @param prj GCAM project object
#' @param scenario Scenario name
#' @param query_name Query name (default: "building total final energy by service")
#' @return Data frame in GAINS format
#' @export
convert_buildings_to_gains <- function(
    prj,
    scenario,
    query_name = "building total final energy by service"
) {

  # Load mapping
  service_mapping <- load_gcam2gains_mapping("buildings_services")
  province_mapping <- load_gcam2gains_mapping("provinces")

  # Get GCAM data
  gcam_data <- rgcam::getQuery(prj, query_name, scenario)

  # Filter for Chinese provinces only
  provinces <- province_mapping$province_code
  gcam_data <- gcam_data %>%
    dplyr::filter(region %in% provinces)

  # Extract service type from sector
  # sector format: "comm cooling", "resid heating modern_d1", etc.
  gcam_data <- gcam_data %>%
    dplyr::mutate(
      building_type = dplyr::case_when(
        grepl("^comm", sector) ~ "commercial",
        grepl("^resid", sector) ~ "residential",
        TRUE ~ NA_character_
      ),
      service_type = dplyr::case_when(
        grepl("cooling", sector) ~ "cooling",
        grepl("heating", sector) ~ "heating",
        grepl("others", sector) ~ "others",
        TRUE ~ NA_character_
      ),
      gcam_service = paste(building_type, service_type)
    )

  # Aggregate income groups for residential
  # Sum all d1-d10 groups into single residential category
  gcam_data_agg <- gcam_data %>%
    dplyr::group_by(scenario, region, building_type, service_type, gcam_service, year) %>%
    dplyr::summarise(
      value = sum(value, na.rm = TRUE),
      .groups = "drop"
    )

  # Apply mapping
  gains_data <- gcam_data_agg %>%
    dplyr::left_join(
      service_mapping %>%
        dplyr::select(gcam_service, gains_sector, gains_subsector),
      by = "gcam_service"
    ) %>%
    dplyr::left_join(
      province_mapping %>%
        dplyr::select(province_code, province_name_en, province_name_zh),
      by = c("region" = "province_code")
    )

  # Format for GAINS
  gains_data <- gains_data %>%
    dplyr::select(
      scenario,
      province_code = region,
      province_name = province_name_en,
      province_name_zh,
      sector = gains_sector,
      subsector = gains_subsector,
      year,
      value
    ) %>%
    dplyr::arrange(province_code, subsector, year)

  # Add metadata
  attr(gains_data, "units") <- "EJ"
  attr(gains_data, "source") <- "GCAM-China"
  attr(gains_data, "query") <- query_name
  attr(gains_data, "conversion_date") <- Sys.Date()

  return(gains_data)
}


#' Validate GCAM2GAINS Conversion
#'
#' @param gains_data Converted GAINS data
#' @param gcam_data Original GCAM data
#' @return List with validation results
#' @export
validate_gains_conversion <- function(gains_data, gcam_data) {

  results <- list()

  # Check for missing provinces
  expected_provinces <- c("AH","BJ","CQ","FJ","GD","GS","GX","GZ","HA","HB","HE","HI","HL",
                         "HN","JL","JS","JX","LN","NM","NX","QH","SC","SD","SH","SN","SX","TJ",
                         "XJ","XZ","YN","ZJ")

  actual_provinces <- unique(gains_data$province_code)
  missing_provinces <- setdiff(expected_provinces, actual_provinces)

  results$missing_provinces <- missing_provinces
  results$n_provinces <- length(actual_provinces)

  # Check for NA values
  results$na_count <- sum(is.na(gains_data$value))
  results$na_sectors <- gains_data %>%
    dplyr::filter(is.na(value)) %>%
    dplyr::distinct(subsector) %>%
    dplyr::pull(subsector)

  # Check total values match (if applicable)
  if (!missing(gcam_data)) {
    gcam_total <- sum(gcam_data$value, na.rm = TRUE)
    gains_total <- sum(gains_data$value, na.rm = TRUE)
    results$total_difference <- gains_total - gcam_total
    results$relative_difference <- (gains_total - gcam_total) / gcam_total
  }

  # Summary
  results$is_valid <- length(missing_provinces) == 0 && results$na_count == 0

  return(results)
}
