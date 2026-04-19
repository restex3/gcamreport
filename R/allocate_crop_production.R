#' Allocate National Crop Production to Provinces
#'
#' Allocates national-level crop production to provinces based on provincial
#' crop demand as a proxy.
#'
#' @param prj GCAM project object
#' @param scenario Scenario name
#' @return Data frame with provincial crop production
#' @export
allocate_crop_production <- function(prj, scenario) {

  # Load mappings
  crop_mapping <- load_gcam2gains_mapping("crops")
  province_mapping <- load_gcam2gains_mapping("provinces")

  # Get national crop production (China only)
  cat("Loading national crop production...\n")
  national_prod <- rgcam::getQuery(prj, "ag production by crop type", scenario)
  national_prod <- national_prod %>%
    dplyr::filter(region == "China")

  # Get provincial crop demand
  cat("Loading provincial crop demand...\n")
  provincial_demand <- rgcam::getQuery(prj, "demand balances by crop commodity", scenario)

  # Filter for Chinese provinces
  provinces <- province_mapping$province_code
  provincial_demand <- provincial_demand %>%
    dplyr::filter(region %in% provinces)

  # Map crop production sectors to demand sectors
  # This mapping connects production crops to their demand categories
  crop_to_demand_mapping <- data.frame(
    production_sector = c("Corn", "Rice", "Wheat", "OtherGrain",
                         "Soybean", "OilCrop", "OilPalm",
                         "SugarCrop", "RootTuber",
                         "Vegetables", "Fruits", "Legumes", "NutsSeeds", "MiscCrop",
                         "FiberCrop",
                         "FodderGrass", "FodderHerb", "Pasture",
                         "biomass", "Forest"),
    demand_sector = c("FoodDemand_Staples", "FoodDemand_Staples", "FoodDemand_Staples", "FoodDemand_Staples",
                     "FoodDemand_NonStaples", "FoodDemand_NonStaples", "FoodDemand_NonStaples",
                     "FoodDemand_NonStaples", "FoodDemand_NonStaples",
                     "FoodDemand_NonStaples", "FoodDemand_NonStaples", "FoodDemand_NonStaples",
                     "FoodDemand_NonStaples", "FoodDemand_NonStaples",
                     "NonFoodDemand_Crops",
                     "FeedCrops", "FeedCrops", "FeedCrops",
                     "regional biomass", "NonFoodDemand_Crops"),
    stringsAsFactors = FALSE
  )

  # Calculate provincial demand shares for each demand category
  cat("Calculating provincial demand shares...\n")
  demand_shares <- provincial_demand %>%
    dplyr::group_by(sector, year) %>%
    dplyr::mutate(
      national_demand = sum(value, na.rm = TRUE),
      provincial_share = ifelse(national_demand > 0, value / national_demand, 0)
    ) %>%
    dplyr::ungroup() %>%
    dplyr::select(region, sector, year, provincial_share, national_demand)

  # Allocate production to provinces
  cat("Allocating production to provinces...\n")
  provincial_prod <- national_prod %>%
    # Add demand sector mapping
    dplyr::left_join(
      crop_to_demand_mapping,
      by = c("sector" = "production_sector")
    ) %>%
    # Join with demand shares
    dplyr::left_join(
      demand_shares,
      by = c("demand_sector" = "sector", "year" = "year")
    ) %>%
    # Calculate provincial production
    dplyr::mutate(
      provincial_value = value * provincial_share
    ) %>%
    # Select and rename columns
    dplyr::select(
      scenario,
      region,
      crop = sector,
      demand_sector,
      year,
      national_production = value,
      provincial_share,
      provincial_production = provincial_value
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
  attr(provincial_prod, "allocation_method") <- "demand-based"
  attr(provincial_prod, "allocation_date") <- Sys.Date()

  return(provincial_prod)
}


#' Validate Crop Production Allocation
#'
#' Validates that provincial totals sum to national totals
#'
#' @param provincial_prod Provincial production data from allocate_crop_production()
#' @return List with validation results
#' @export
validate_crop_allocation <- function(provincial_prod) {

  results <- list()

  # Check that provincial totals match national totals
  validation <- provincial_prod %>%
    dplyr::group_by(crop, year) %>%
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
  results$n_crops <- length(unique(provincial_prod$crop))
  results$n_provinces <- length(unique(provincial_prod$region))
  results$n_years <- length(unique(provincial_prod$year))

  # Check for missing allocations
  missing_allocations <- provincial_prod %>%
    dplyr::filter(is.na(provincial_production) | provincial_share == 0)

  results$n_missing <- nrow(missing_allocations)
  results$missing_crops <- unique(missing_allocations$crop)

  # Overall validation
  results$is_valid <- results$max_relative_error < 0.01 && results$n_missing == 0

  return(results)
}


#' Get Crop Production Summary by Province
#'
#' @param provincial_prod Provincial production data
#' @param year_filter Optional year to filter (default: 2020)
#' @return Summary table
#' @export
summarize_crop_production <- function(provincial_prod, year_filter = 2020) {

  summary <- provincial_prod %>%
    dplyr::filter(year == year_filter) %>%
    dplyr::group_by(region, province_name_en) %>%
    dplyr::summarise(
      total_production = sum(provincial_production, na.rm = TRUE),
      n_crops = dplyr::n(),
      .groups = "drop"
    ) %>%
    dplyr::arrange(dplyr::desc(total_production))

  return(summary)
}
