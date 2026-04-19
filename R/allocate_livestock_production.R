#' Allocate National Livestock Production to Provinces
#'
#' Allocates national-level livestock production to provinces based on provincial
#' feed crop demand as a proxy.
#'
#' @param prj GCAM project object
#' @param scenario Scenario name
#' @return Data frame with provincial livestock production
#' @export
allocate_livestock_production <- function(prj, scenario) {

  # Load mappings
  livestock_mapping <- load_gcam2gains_mapping("livestock")
  province_mapping <- load_gcam2gains_mapping("provinces")

  # Get national livestock production (China only)
  cat("Loading national livestock production...\n")
  national_prod <- rgcam::getQuery(prj, "meat and dairy production by type", scenario)
  national_prod <- national_prod %>%
    dplyr::filter(region == "China")

  # Get provincial feed crop demand
  cat("Loading provincial feed crop demand...\n")
  provincial_demand <- rgcam::getQuery(prj, "demand balances by crop commodity", scenario)

  # Filter for Chinese provinces and FeedCrops only
  provinces <- province_mapping$province_code
  feed_demand <- provincial_demand %>%
    dplyr::filter(
      region %in% provinces,
      sector == "FeedCrops"
    )

  # Parse livestock-feed relationships from mapping
  # primary_feed format: "FodderGrass;FodderHerb;Corn"
  livestock_feed_weights <- livestock_mapping %>%
    dplyr::mutate(
      feed_list = strsplit(primary_feed, ";")
    ) %>%
    tidyr::unnest(feed_list) %>%
    dplyr::select(
      livestock = gcam_livestock,
      livestock_category,
      feed_crop = feed_list
    )

  # For simplicity, use total feed demand as proxy for all livestock
  # More sophisticated approach would weight by specific feed types
  cat("Calculating provincial feed demand shares...\n")
  feed_shares <- feed_demand %>%
    dplyr::group_by(year) %>%
    dplyr::mutate(
      national_feed_demand = sum(value, na.rm = TRUE),
      provincial_share = ifelse(national_feed_demand > 0, value / national_feed_demand, 0)
    ) %>%
    dplyr::ungroup() %>%
    dplyr::select(region, year, provincial_share, national_feed_demand)

  # Allocate livestock production to provinces
  cat("Allocating livestock production to provinces...\n")
  provincial_prod <- national_prod %>%
    # Cross join with all provinces and years (to get all combinations)
    dplyr::left_join(
      feed_shares,
      by = "year"
    ) %>%
    # Calculate provincial production
    dplyr::mutate(
      provincial_value = value * provincial_share
    ) %>%
    # Select and rename columns
    dplyr::select(
      scenario,
      region,
      livestock = sector,
      year,
      national_production = value,
      provincial_share,
      provincial_production = provincial_value
    )

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
  attr(provincial_prod, "allocation_method") <- "feed-demand-based"
  attr(provincial_prod, "allocation_date") <- Sys.Date()
  attr(provincial_prod, "note") <- "Allocated based on provincial feed crop demand as proxy"

  return(provincial_prod)
}


#' Validate Livestock Production Allocation
#'
#' Validates that provincial totals sum to national totals
#'
#' @param provincial_prod Provincial production data from allocate_livestock_production()
#' @return List with validation results
#' @export
validate_livestock_allocation <- function(provincial_prod) {

  results <- list()

  # Check that provincial totals match national totals
  validation <- provincial_prod %>%
    dplyr::group_by(livestock, year) %>%
    dplyr::summarise(
      national_total = dplyr::first(national_production),
      provincial_sum = sum(provincial_production, na.rm = TRUE),
      difference = provincial_sum - national_total,
      relative_error = abs(difference) / national_total,
      .groups = "drop"
    )

  results$validation_table <- validation

  # Summary statistics
  results$max_relative_error <- max(validation$relative_error, na.rm = TRUE)
  results$mean_relative_error <- mean(validation$relative_error, na.rm = TRUE)
  results$n_livestock <- length(unique(provincial_prod$livestock))
  results$n_provinces <- length(unique(provincial_prod$region))
  results$n_years <- length(unique(provincial_prod$year))

  # Check for missing allocations
  missing_allocations <- provincial_prod %>%
    dplyr::filter(is.na(provincial_production) | provincial_share == 0)

  results$n_missing <- nrow(missing_allocations)
  results$missing_livestock <- unique(missing_allocations$livestock)

  # Overall validation
  results$is_valid <- results$max_relative_error < 0.01 && results$n_missing == 0

  return(results)
}


#' Get Livestock Production Summary by Province
#'
#' @param provincial_prod Provincial production data
#' @param year_filter Optional year to filter (default: 2020)
#' @return Summary table
#' @export
summarize_livestock_production <- function(provincial_prod, year_filter = 2020) {

  summary <- provincial_prod %>%
    dplyr::filter(year == year_filter) %>%
    dplyr::group_by(region, province_name_en, livestock_category) %>%
    dplyr::summarise(
      total_production = sum(provincial_production, na.rm = TRUE),
      n_products = dplyr::n(),
      .groups = "drop"
    ) %>%
    dplyr::arrange(dplyr::desc(total_production))

  return(summary)
}


#' Compare Livestock Allocation with Statistical Data
#'
#' Compares allocated livestock production with external statistical data
#' for validation purposes.
#'
#' @param provincial_prod Provincial production data
#' @param statistical_data External statistical data (optional)
#' @param year_filter Year to compare (default: 2020)
#' @return Comparison results
#' @export
compare_with_statistics <- function(provincial_prod, statistical_data = NULL, year_filter = 2020) {

  if (is.null(statistical_data)) {
    message("No statistical data provided. Returning provincial production only.")
    return(provincial_prod %>% dplyr::filter(year == year_filter))
  }

  # Join with statistical data
  comparison <- provincial_prod %>%
    dplyr::filter(year == year_filter) %>%
    dplyr::left_join(
      statistical_data,
      by = c("region", "livestock"),
      suffix = c("_gcam", "_stat")
    ) %>%
    dplyr::mutate(
      difference = provincial_production - statistical_production,
      relative_error = abs(difference) / statistical_production
    )

  return(comparison)
}
