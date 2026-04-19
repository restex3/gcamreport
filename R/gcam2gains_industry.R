#' Convert GCAM Industry Data to GAINS Format
#'
#' @param prj GCAM project object
#' @param scenario Scenario name
#' @param query_name Query name (default: "industry final energy by tech and fuel")
#' @return Data frame in GAINS format
#' @export
convert_industry_to_gains <- function(
    prj,
    scenario,
    query_name = "industry final energy by tech and fuel"
) {

  # Load mappings
  sector_mapping <- load_gcam2gains_mapping("industry_sectors")
  fuel_mapping <- load_gcam2gains_mapping("fuels")
  province_mapping <- load_gcam2gains_mapping("provinces")

  # Get GCAM data
  gcam_data <- rgcam::getQuery(prj, query_name, scenario)

  # Filter for Chinese provinces only
  provinces <- province_mapping$province_code
  gcam_data <- gcam_data %>%
    dplyr::filter(region %in% provinces)

  # Apply sector mapping
  gains_data <- gcam_data %>%
    dplyr::left_join(
      sector_mapping %>%
        dplyr::select(gcam_sector, gains_sector, gains_subsector, industry_type),
      by = c("sector" = "gcam_sector")
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
      industry_type,
      fuel = gains_fuel,
      fuel_category,
      technology,
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


#' Get Industry Primary Output (for validation)
#'
#' @param prj GCAM project object
#' @param scenario Scenario name
#' @return Data frame with industry primary output
#' @export
get_industry_output <- function(prj, scenario) {

  # Load mappings
  sector_mapping <- load_gcam2gains_mapping("industry_sectors")
  province_mapping <- load_gcam2gains_mapping("provinces")

  # Get GCAM data
  gcam_data <- rgcam::getQuery(prj, "industry primary output by sector", scenario)

  # Filter for Chinese provinces
  provinces <- province_mapping$province_code
  gcam_data <- gcam_data %>%
    dplyr::filter(region %in% provinces)

  # Apply sector mapping
  gains_data <- gcam_data %>%
    dplyr::left_join(
      sector_mapping %>%
        dplyr::select(gcam_sector, gains_sector, gains_subsector, industry_type),
      by = c("sector" = "gcam_sector")
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
      industry_type,
      year,
      value
    ) %>%
    dplyr::arrange(province_code, subsector, year)

  # Add metadata
  attr(gains_data, "units") <- "EJ"
  attr(gains_data, "source") <- "GCAM-China"
  attr(gains_data, "query") <- "industry primary output by sector"

  return(gains_data)
}


#' Get Iron and Steel Production by Technology
#'
#' @param prj GCAM project object
#' @param scenario Scenario name
#' @return Data frame with iron and steel production
#' @export
get_steel_production <- function(prj, scenario) {

  province_mapping <- load_gcam2gains_mapping("provinces")

  # Get GCAM data
  gcam_data <- rgcam::getQuery(prj, "iron and steel production by tech", scenario)

  # Filter for Chinese provinces
  provinces <- province_mapping$province_code
  gcam_data <- gcam_data %>%
    dplyr::filter(region %in% provinces)

  # Add province information
  gains_data <- gcam_data %>%
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
      sector,
      subsector,
      technology,
      year,
      value
    ) %>%
    dplyr::arrange(province_code, technology, year)

  # Add metadata
  attr(gains_data, "units") <- "Mt"
  attr(gains_data, "source") <- "GCAM-China"
  attr(gains_data, "query") <- "iron and steel production by tech"

  return(gains_data)
}
