#' Convert GCAM Transport Data to GAINS Format
#'
#' @param prj GCAM project object
#' @param scenario Scenario name
#' @param query_name Query name (default: "transport final energy by mode and fuel")
#' @return Data frame in GAINS format
#' @export
convert_transport_to_gains <- function(
    prj,
    scenario,
    query_name = "transport final energy by mode and fuel"
) {

  # Load mappings
  mode_mapping <- load_gcam2gains_mapping("transport_modes")
  fuel_mapping <- load_gcam2gains_mapping("fuels")
  province_mapping <- load_gcam2gains_mapping("provinces")

  # Get GCAM data
  gcam_data <- rgcam::getQuery(prj, query_name, scenario)

  # Filter for Chinese provinces only
  provinces <- province_mapping$province_code
  gcam_data <- gcam_data %>%
    dplyr::filter(region %in% provinces)

  # Apply mode mapping
  gains_data <- gcam_data %>%
    dplyr::left_join(
      mode_mapping %>%
        dplyr::select(gcam_mode, gains_sector, gains_subsector, mode_type),
      by = c("mode" = "gcam_mode")
    )

  # Apply fuel mapping
  gains_data <- gains_data %>%
    dplyr::left_join(
      fuel_mapping %>%
        dplyr::select(gcam_fuel, gains_fuel, fuel_category),
      by = c("input" = "gcam_fuel")
    )

  # Add province information
  gains_data <- gains_data %>%
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
      mode_type,
      fuel = gains_fuel,
      fuel_category,
      year,
      value
    ) %>%
    dplyr::arrange(province_code, subsector, fuel, year)

  # Add metadata
  attr(gains_data, "units") <- "EJ"
  attr(gains_data, "source") <- "GCAM-China"
  attr(gains_data, "query") <- query_name
  attr(gains_data, "conversion_date") <- Sys.Date()

  return(gains_data)
}


#' Get Transport Service Output (for validation)
#'
#' @param prj GCAM project object
#' @param scenario Scenario name
#' @return Data frame with transport service output
#' @export
get_transport_service_output <- function(prj, scenario) {

  # Load mappings
  mode_mapping <- load_gcam2gains_mapping("transport_modes")
  province_mapping <- load_gcam2gains_mapping("provinces")

  # Get GCAM data
  gcam_data <- rgcam::getQuery(prj, "transport service output by mode", scenario)

  # Filter for Chinese provinces
  provinces <- province_mapping$province_code
  gcam_data <- gcam_data %>%
    dplyr::filter(region %in% provinces)

  # Apply mode mapping
  gains_data <- gcam_data %>%
    dplyr::left_join(
      mode_mapping %>%
        dplyr::select(gcam_mode, gains_sector, gains_subsector, mode_type),
      by = c("mode" = "gcam_mode")
    ) %>%
    dplyr::left_join(
      province_mapping %>%
        dplyr::select(province_code, province_name_en, province_name_zh),
      by = c("region" = "province_code")
    )

  # Format output
  gains_data <- gains_data %>%
    dplyr::select(
      scenario,
      province_code = region,
      province_name = province_name_en,
      province_name_zh,
      sector = gains_sector,
      subsector = gains_subsector,
      mode_type,
      year,
      value
    ) %>%
    dplyr::arrange(province_code, subsector, year)

  # Add metadata
  attr(gains_data, "units") <- "million pass-km or million ton-km"
  attr(gains_data, "source") <- "GCAM-China"
  attr(gains_data, "query") <- "transport service output by mode"

  return(gains_data)
}
