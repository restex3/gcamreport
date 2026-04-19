# Converting raw data into package data
library(usethis)
library(magrittr)

### paths
rawDataFolder <- here::here()


# nonCO2 emissions considered
nonco2_emissions_list_vGCAMChina7.1 <- c(
  "BC", "BC_AWB", "C2F6", "CF4", "CH4", "CH4_AGR", "CH4_AWB", "CO", "CO_AWB",
  "H2", "H2_AWB", "HFC125", "HFC134a", "HFC143a", "HFC152a", "HFC227ea", "HFC23", "HFC236fa",
  "HFC245fa", "HFC32", "HFC365mfc", "HFC43", "N2O", "N2O_AGR", "N2O_AWB", "NH3", "NH3_AGR",
  "NH3_AWB", "NMVOC", "NMVOC_AGR", "NMVOC_AWB", "NOx", "NOx_AGR", "NOx_AWB", "OC", "OC_AWB",
  "PM10", "PM2.5", "SF6", "SO2_1", "SO2_1_AWB", "SO2_2", "SO2_2_AWB", "SO2_3", "SO2_3_AWB",
  "SO2_4", "SO2_4_AWB"
)
use_data(nonco2_emissions_list_vGCAMChina7.1, overwrite = T)



# regions_continents_map
reg_cont_vGCAMChina7.1 <- readr::read_csv(
  file.path(rawDataFolder, "inst/extdata/mappings/GCAMChina7.1", "regions_continents_map.csv"),
  comment = "#"
)
use_data(reg_cont_vGCAMChina7.1, overwrite = T)


# emissions maps
co2_sector_map_vGCAMChina7.1 <- readr::read_csv(
  file.path(rawDataFolder, "inst/extdata/mappings/GCAMChina7.1", "CO2_sector_map.csv"),
  comment = "#", na = ""
) %>% gather_map()
use_data(co2_sector_map_vGCAMChina7.1, overwrite = T)

co2_ets_sector_map_vGCAMChina7.1 <- readr::read_csv(
  file.path(rawDataFolder, "inst/extdata/mappings/GCAMChina7.1", "CO2_ETS_sector_map.csv"),
  comment = "#", na = ""
) %>% gather_map()
use_data(co2_ets_sector_map_vGCAMChina7.1, overwrite = T)

co2_tech_map_vGCAMChina7.1 <- readr::read_csv(
  file.path(rawDataFolder, "inst/extdata/mappings/GCAMChina7.1", "CO2_tech_map.csv"),
  comment = "#", na = ""
) %>% gather_map()
use_data(co2_tech_map_vGCAMChina7.1, overwrite = T)

co2_resource_map_vGCAMChina7.1 <- readr::read_csv(
  file.path(rawDataFolder, "inst/extdata/mappings/GCAMChina7.1", "CO2_resource_map.csv"),
  comment = "#", na = ""
) %>% gather_map()
use_data(co2_resource_map_vGCAMChina7.1, overwrite = T)

kyoto_sector_map_vGCAMChina7.1 <- readr::read_csv(
  file.path(rawDataFolder, "inst/extdata/mappings/GCAMChina7.1", "kyotogas_sector.csv"),
  comment = "#", na = ""
) %>% gather_map()
use_data(kyoto_sector_map_vGCAMChina7.1, overwrite = T)

nonco2_emis_sector_map_vGCAMChina7.1 <- readr::read_csv(
  file.path(rawDataFolder, "inst/extdata/mappings/GCAMChina7.1", "nonCO2_emissions_sector_map.csv"),
  comment = "#", na = ""
) %>% gather_map()
use_data(nonco2_emis_sector_map_vGCAMChina7.1, overwrite = T)

nonco2_emis_resource_map_vGCAMChina7.1 <- readr::read_csv(
  file.path(rawDataFolder, "inst/extdata/mappings/GCAMChina7.1", "nonCO2_emissions_resource_map.csv"),
  comment = "#", na = ""
) %>% gather_map()
use_data(nonco2_emis_resource_map_vGCAMChina7.1, overwrite = T)

carbon_seq_tech_map_vGCAMChina7.1 <- readr::read_csv(
  file.path(rawDataFolder, "inst/extdata/mappings/GCAMChina7.1", "carbon_seq_tech_map.csv"),
  comment = "#", na = ""
) %>% gather_map()
use_data(carbon_seq_tech_map_vGCAMChina7.1, overwrite = T)


# ag maps
ag_demand_map_vGCAMChina7.1 <- readr::read_csv(
  file.path(rawDataFolder, "inst/extdata/mappings/GCAMChina7.1", "ag_demand_map.csv"),
  comment = "#"
) %>% gather_map()
use_data(ag_demand_map_vGCAMChina7.1, overwrite = T)

ag_price_map_vGCAMChina7.1 <- readr::read_csv(
  file.path(rawDataFolder, "inst/extdata/mappings/GCAMChina7.1", "ag_price_map.csv"),
  comment = "#"
) %>% gather_map()
use_data(ag_price_map_vGCAMChina7.1, overwrite = T)

ag_production_map_vGCAMChina7.1 <- readr::read_csv(
  file.path(rawDataFolder, "inst/extdata/mappings/GCAMChina7.1", "ag_production_map.csv"),
  comment = "#"
) %>% gather_map()
use_data(ag_production_map_vGCAMChina7.1, overwrite = T)

ag_demand_price_map_vGCAMChina7.1 <- readr::read_csv(
  file.path(rawDataFolder, "inst/extdata/mappings/GCAMChina7.1", "ag_demand_price_map.csv"),
  comment = "#"
)
use_data(ag_demand_price_map_vGCAMChina7.1, overwrite = T)

trade_ag_vGCAMChina7.1 <- readr::read_csv(
  file.path(rawDataFolder, "inst/extdata/mappings/GCAMChina7.1", "trade_ag.csv"), comment = "#"
) %>% gather_map()
use_data(trade_ag_vGCAMChina7.1, overwrite = T)

land_use_map_vGCAMChina7.1 <- readr::read_csv(
  file.path(rawDataFolder, "inst/extdata/mappings/GCAMChina7.1", "land_use_map.csv"),
  comment = "#"
) %>% gather_map()
use_data(land_use_map_vGCAMChina7.1, overwrite = T)

yield_map_vGCAMChina7.1 <- readr::read_csv(
  file.path(rawDataFolder, "inst/extdata/mappings/GCAMScenarioMIPCMIP7", "yield_map.csv"),
  comment = "#"
)
use_data(yield_map_vGCAMChina7.1, overwrite = T)

food_intake_map_vGCAMChina7.1 <- readr::read_csv(
  file.path(rawDataFolder, "inst/extdata/mappings/GCAMChina7.1", "food_intake_map.csv"),
  comment = "#"
) %>% gather_map()
use_data(food_intake_map_vGCAMChina7.1, overwrite = T)

food_items_map_vGCAMChina7.1 <- readr::read_csv(
  file.path(rawDataFolder, "inst/extdata/mappings/GCAMChina7.1", "food_items_map.csv"),
  comment = "#"
)
use_data(food_items_map_vGCAMChina7.1, overwrite = T)

# waste share (waste / supply), exogenously driven per SSP scenario.
L100.AgMIP_FoodWaste_Share_Pathway_SSP_vGCAMChina7.1 <- readr::read_csv(
  file.path(rawDataFolder, "inst/extdata/mappings/GCAMChina7.1", "L100.AgMIP_FoodWaste_Share_Pathway_SSP.csv"),
  comment = "#"
) %>%
  dplyr::rename(ssp = scenario) %>%
  dplyr::select(-GCAM_region_ID)
use_data(L100.AgMIP_FoodWaste_Share_Pathway_SSP_vGCAMChina7.1, overwrite = T)

# wood fuel - industrial roundwood
WoodFuel_IndRoundwood_ratio_vGCAMChina7.1 <- readr::read_csv(
  file.path(rawDataFolder, "inst/extdata/mappings/GCAMChina7.1", "FAO_GCAM_Ratio_WoodFuel_IndRoundwood_R_Yh.csv"),
  comment = "#"
)
use_data(WoodFuel_IndRoundwood_ratio_vGCAMChina7.1, overwrite = T)

# cereal yield and land scalar
cereal_scaler_vGCAMChina7.1 <- readr::read_csv(
  file.path(rawDataFolder, "inst/extdata/mappings/GCAMChina7.1", "GCAM_Yield_R_Cereals_Scaler_Y.csv"),
  comment = "#"
)
use_data(cereal_scaler_vGCAMChina7.1, overwrite = T)



# primary, secondary, final energy maps
primary_energy_map_vGCAMChina7.1 <- readr::read_csv(
  file.path(rawDataFolder, "inst/extdata/mappings/GCAMChina7.1", "primary_energy_map.csv"),
  comment = "#"
) %>% gather_map()
use_data(primary_energy_map_vGCAMChina7.1, overwrite = T)

production_map_vGCAMChina7.1 <- readr::read_csv(
  file.path(rawDataFolder, "inst/extdata/mappings/GCAMChina7.1", "production_map.csv"),
  comment = "#"
) %>% gather_map()
use_data(production_map_vGCAMChina7.1, overwrite = T)

iron_steel_prod_tech_map_vGCAMChina7.1 <- readr::read_csv(
  file.path(rawDataFolder, "inst/extdata/mappings/GCAMChina7.1", "iron_steel_prod_tech_map.csv"),
  comment = "#"
) %>% gather_map()
use_data(iron_steel_prod_tech_map_vGCAMChina7.1, overwrite = T)

secondary_energy_map_vGCAMChina7.1 <- readr::read_csv(
  file.path(rawDataFolder, "inst/extdata/mappings/GCAMChina7.1", "capacity_map.csv"),
  comment = "#"
) %>%
  dplyr::filter(!grepl("cogen", technology)) %>%
  gather_map()
use_data(secondary_energy_map_vGCAMChina7.1, overwrite = T)

capacity_map_vGCAMChina7.1 <- readr::read_csv(
  file.path(rawDataFolder, "inst/extdata/mappings/GCAMChina7.1", "capacity_map.csv"),
  comment = "#"
) %>%
  dplyr::filter(!grepl("cogen", technology)) %>%
  gather_map()
use_data(capacity_map_vGCAMChina7.1, overwrite = T)

cf_gcam_vGCAMChina7.1 <- readr::read_csv(
  file.path(rawDataFolder, "inst/extdata/mappings/GCAMChina7.1", "A23.globaltech_capacity_factor.csv"),
  comment = "#", na = ""
)
use_data(cf_gcam_vGCAMChina7.1, overwrite = T)

cf_rgn_base <- readr::read_csv(
  file.path(rawDataFolder, "inst/extdata/mappings/GCAMChina7.1", "L223.StubTechCapFactor_elec.csv"),
  comment = "#", na = ""
)
cf_rgn_china <- readr::read_csv(
  file.path(rawDataFolder, "inst/extdata/mappings/GCAMChina7.1", "L223.StubTechCapFactor_elec_CHINA.csv"),
  comment = "#", na = ""
)
china_provinces <- c("AH","BJ","CQ","FJ","GD","GS","GX","GZ","HA","HB","HE","HI","HK",
                     "HL","HN","JL","JS","JX","LN","MC","NM","NX","QH","SC","SD","SH",
                     "SN","SX","TJ","XJ","XZ","YN","ZJ")
cf_rgn_vGCAMChina7.1 <- cf_rgn_base %>%
  dplyr::filter(!region %in% china_provinces) %>%
  dplyr::bind_rows(cf_rgn_china) %>%
  dplyr::distinct()
use_data(cf_rgn_vGCAMChina7.1, overwrite = T)

final_energy_map_vGCAMChina7.1 <- readr::read_csv(
  file.path(rawDataFolder, "inst/extdata/mappings/GCAMChina7.1", "final_energy_map_gcamchina.csv"),
  comment = "#"
) %>% gather_map()
use_data(final_energy_map_vGCAMChina7.1, overwrite = T)

en_demand_price_map_vGCAMChina7.1 <- readr::read_csv(
  file.path(rawDataFolder, "inst/extdata/mappings/GCAMChina7.1", "en_demand_price_map.csv"),
  comment = "#"
)
use_data(en_demand_price_map_vGCAMChina7.1, overwrite = T)

transport_final_en_map_vGCAMChina7.1 <- readr::read_csv(
  file.path(rawDataFolder, "inst/extdata/mappings/GCAMChina7.1", "transport_final_en_map_gcamchina.csv"),
  comment = "#", na = ""
) %>% gather_map()
use_data(transport_final_en_map_vGCAMChina7.1, overwrite = T)

energy_price_map_vGCAMChina7.1 <- readr::read_csv(
  file.path(rawDataFolder, "inst/extdata/mappings/GCAMChina7.1", "en_price_map.csv"),
  comment = "#", na = ""
) %>% gather_map()
use_data(energy_price_map_vGCAMChina7.1, overwrite = T)

en_demand_price_map_vGCAMChina7.1 <- readr::read_csv(
  file.path(rawDataFolder, "inst/extdata/mappings/GCAMChina7.1", "en_demand_price_map.csv"),
  comment = "#", na = ""
)
use_data(en_demand_price_map_vGCAMChina7.1, overwrite = T)

res_extraction_map_vGCAMChina7.1 <- readr::read_csv(
  file.path(rawDataFolder, "inst/extdata/mappings/GCAMChina7.1", "res_extraction_map.csv"),
  comment = "#"
) %>% gather_map()
use_data(res_extraction_map_vGCAMChina7.1, overwrite = T)

# Energy Service maps
transport_en_service_vGCAMChina7.1 <- readr::read_csv(
  file.path(rawDataFolder, "inst/extdata/mappings/GCAMChina7.1", "transport_en_service.csv"),
  comment = "#"
) %>% gather_map()
use_data(transport_en_service_vGCAMChina7.1, overwrite = T)

buildings_en_service_vGCAMChina7.1 <- readr::read_csv(
  file.path(rawDataFolder, "inst/extdata/mappings/GCAMChina7.1", "buildings_en_service.csv"),
  comment = "#"
) %>% gather_map()
use_data(buildings_en_service_vGCAMChina7.1, overwrite = T)


# capital updates
capital_gcam_vGCAMChina7.1 <- readr::read_csv(
  file.path(rawDataFolder, "inst/extdata/mappings/GCAMChina7.1", "L2234.GlobalIntTechCapital_elecS_CHINA.csv"),
  comment = "#", na = ""
) %>%
  dplyr::rename(technology = intermittent.technology) %>%
  dplyr::bind_rows(readr::read_csv(
    file.path(rawDataFolder, "inst/extdata/mappings/GCAMChina7.1", "L2234.GlobalTechCapital_elecS_CHINA.csv"),
    comment = "#", na = ""
  )) %>%
  dplyr::select(sector = supplysector, subsector, technology, year, capital.overnight)
use_data(capital_gcam_vGCAMChina7.1, overwrite = T)

investment_vGCAMChina7.1 <- readr::read_csv(
  file.path(rawDataFolder, "inst/extdata/mappings/GCAMChina7.1", "investment.csv"),
  na = ""
) %>%
  tidyr::gather(year, value, `2015`:`2100`) %>%
  dplyr::mutate(year = as.integer(sub("X", "", year))) %>%
  dplyr::mutate(value = gsub("%", "", value)) %>%
  dplyr::mutate(value = as.numeric(value))
use_data(investment_vGCAMChina7.1, overwrite = T)


carbon_content_vGCAMChina7.1 <- readr::read_csv(
  file.path(rawDataFolder, "inst/extdata/mappings/GCAMChina7.1", "L202.CarbonCoef.csv"),
  comment = "#", na = ""
)
use_data(carbon_content_vGCAMChina7.1, overwrite = T)

nonco2_content_vGCAMChina7.1 <- readr::read_csv(
  file.path(rawDataFolder, "inst/extdata/mappings/GCAMChina7.1", "L201.ghg_res.csv"),
  comment = "#", na = ""
)
use_data(nonco2_content_vGCAMChina7.1, overwrite = T)

iea_capacity_vGCAMChina7.1 <- readr::read_csv(
  file.path(rawDataFolder, "inst/extdata/mappings/GCAMChina7.1", "IEAWEO2019_Capacity.csv")
)
use_data(iea_capacity_vGCAMChina7.1, overwrite = T)

co2_market_vGCAMChina7.1 <- readr::read_csv(
  file.path(rawDataFolder, "inst/extdata/mappings/GCAMChina7.1", "CO2market_new.csv"),
  comment = "#"
)
use_data(co2_market_vGCAMChina7.1, overwrite = T)

co2_market_frag_map_vGCAMChina7.1 <- readr::read_csv(
  file.path(rawDataFolder, "inst/extdata/mappings/GCAMChina7.1", "CO2market_frag_map.csv"),
  comment = "#"
)
use_data(co2_market_frag_map_vGCAMChina7.1, overwrite = T)

# iron and steel
iron_steel_trade_map_vGCAMChina7.1 <- readr::read_csv(
  file.path(rawDataFolder, "inst/extdata/mappings/GCAMChina7.1", "iron_steel_trade.csv"),
  comment = "#"
) %>% gather_map()
use_data(iron_steel_trade_map_vGCAMChina7.1, overwrite = T)

# water
water_map_vGCAMChina7.1 <- readr::read_csv(
  file.path(rawDataFolder, "inst/extdata/mappings/GCAMChina7.1", "water.csv"),
  comment = "#"
) %>% gather_map()
use_data(water_map_vGCAMChina7.1, overwrite = T)

conveyance.eff_vGCAMChina7.1 <- readr::read_csv(
  file.path(rawDataFolder, "inst/extdata/mappings/GCAMChina7.1", "conveyance.eff.csv"),
  comment = "#"
)
use_data(conveyance.eff_vGCAMChina7.1, overwrite = T)

# transport sales & stock
ucd_size_class_vGCAMChina7.1 <- readr::read_csv(
  file.path(rawDataFolder, "inst/extdata/mappings/GCAMChina7.1",
            "UCD_size_class_revisions.csv"), comment = "#"
)
use_data(ucd_size_class_vGCAMChina7.1, overwrite = T)

ucd_core_vGCAMChina7.1 <- readr::read_csv(
  file.path(rawDataFolder, "inst/extdata/mappings/GCAMChina7.1",
            "UCD_trn_data_CORE.csv"), comment = "#"
) %>%
  tidyr::gather(year, value, `2005`:`2100`) %>%
  dplyr::mutate(year = as.integer(sub("X", "", year)))
use_data(ucd_core_vGCAMChina7.1, overwrite = T)

region_mapping_ucd_vGCAMChina7.1 <- readr::read_csv(
  file.path(rawDataFolder, "inst/extdata/mappings/GCAMChina7.1",
            "region_mapping_ucd.csv"), comment = "#"
)
use_data(region_mapping_ucd_vGCAMChina7.1, overwrite = T)

transport_stock_map_vGCAMChina7.1 <- readr::read_csv(
  file.path(rawDataFolder, "inst/extdata/mappings/GCAMChina7.1",
            "trn_stock_map.csv"), comment = "#"
) %>% gather_map()
use_data(transport_stock_map_vGCAMChina7.1, overwrite = T)
transport_sales_map_vGCAMChina7.1 <- readr::read_csv(
  file.path(rawDataFolder, "inst/extdata/mappings/GCAMChina7.1",
            "trn_sales_map.csv"), comment = "#"
) %>% gather_map()
use_data(transport_sales_map_vGCAMChina7.1, overwrite = T)


# Reporting years
last_historical_year_vGCAMChina7.1 <- 2015
use_data(last_historical_year_vGCAMChina7.1, overwrite = T)




# CONSTANTS
# List of Constants
convert_vGCAMChina7.1 <- list(
  # Basic format conv_[from]_[to]
  conv_thousand_million = 1 / 1000,
  conv_million_billion = 1 / 1000,
  # NOTE: These values are only used for queries that don't have an associated mapping file
  # for queries such as primary_fuel_prices this conversion is specified in the mapping file
  # These values are taken from GDP inflator in the GCAM R package
  conv_05USD_10USD = 1.100372,
  conv_90USD_10USD = 1.511373,
  conv_75USD_10USD = 3.224173,
  conv_15USD_10USD = 0.91863,
  conv_19USD_75USD = 0.2672871,
  conv_10USD_20USD = 1.175896,
  conv_C_CO2 = 44 / 12,
  # Elec related conversions
  hr_per_yr = 8760,
  EJ_to_GWh = 277778,
  bcm_to_EJ = 0.03600,
  GJ_to_EJ = 1.0E9,
  # Energy content of biomass, GJ/ton
  aglu.BIO_ENERGY_CONTENT_GJT = 17.5,
  # 1Mt (million metric ton) = 1e6kg
  kg_to_Mt = 1e6,
  # land units
  km2_to_ha = 100,
  # ghg * CO2_equivalent gives CO2 units
  CO2_equivalent = 3.666667
)
use_data(convert_vGCAMChina7.1, overwrite = T)

# GHG emission conversion
F_GASES_vGCAMChina7.1 <- c(
  "C2F6", "CF4", "HFC125", "HFC134a", "HFC245fa", "SF6", "HFC143a",
  "HFC152a", "HFC227ea", "HFC23", "HFC236fa", "HFC32", "HFC365mfc",
  "HFC43", "HFC245fa", "HFC43-10"
)
use_data(F_GASES_vGCAMChina7.1, overwrite = T)

GHG_gases_vGCAMChina7.1 <- c("CH4", "N2O", F_GASES_vGCAMChina7.1, "CO2", "CO2LUC")
use_data(GHG_gases_vGCAMChina7.1, overwrite = T)



# QUERY files

# gcamreport queries complete
queryFile <- file.path(rawDataFolder, "inst/extdata/queries/GCAMChina7.1", "queries_gcamreport_general.xml")
queries_general_vGCAMChina7.1 <- rgcam::parse_batch_query(queryFile)
use_data(queries_general_vGCAMChina7.1, overwrite = T)

# gcamreport queries nonCO2
queryFile <- file.path(rawDataFolder, "inst/extdata/queries/GCAMChina7.1", "queries_gcamreport_nonCO2.xml")
queries_nonCO2_vGCAMChina7.1 <- rgcam::parse_batch_query(queryFile)
use_data(queries_nonCO2_vGCAMChina7.1, overwrite = T)



# TEMPLATE & VARIABLES

# Read in template
template_vGCAMChina7.1 <- read.csv2(
  file.path(rawDataFolder, "inst/extdata", "template/GCAM7.1/common-definitions-template.csv"),
  comment = "#", sep = ',', fileEncoding = "UTF-8"
) %>%
  dplyr::select(Variable = variable, Unit = unit, Tier = tier, Internal_variable) %>%
  dplyr::mutate(Model = "GCAM-China 7.1") %>%
  as.data.frame()
decode_html <- function(text) {
  xml2::xml_text(xml2::read_xml(paste0("<x>", text, "</x>")))
}
# Applying the function to decode HTML entities in col1
template_vGCAMChina7.1$Unit <- sapply(template_vGCAMChina7.1$Unit, decode_html)
iron_steel_prod_vars <- data.frame(
  Variable = c(
    "Production|Steel|Blast Furnace",
    "Production|Steel|EAF-scrap",
    "Production|Steel|Hydrogen-DRI",
    "Production|Steel|EAF-DRI",
    "Production|Steel|Blast Furnace|BLASTFUR",
    "Production|Steel|Blast Furnace|BLASTFUR CCS",
    "Production|Steel|Blast Furnace|BLASTFUR with hydrogen",
    "Production|Steel|Blast Furnace|Biomass-based",
    "Production|Steel|EAF-scrap|EAF with scrap",
    "Production|Steel|EAF-DRI|EAF with DRI",
    "Production|Steel|EAF-DRI|EAF with DRI CCS",
    "Production|Steel|Hydrogen-DRI|Hydrogen-based DRI"
  ),
  Unit = "Mt/yr",
  Tier = 3,
  Internal_variable = "iron_steel_prod_tech_clean",
  Model = "GCAM-China 7.1",
  stringsAsFactors = FALSE
)
template_vGCAMChina7.1 <- dplyr::bind_rows(template_vGCAMChina7.1, iron_steel_prod_vars)

primary_energy_elec_vars <- data.frame(
  Variable = c(
    "Primary Energy|Electricity|Oil|w/o CCS",
    "Primary Energy|Electricity|Gas|w/o CCS",
    "Primary Energy|Electricity|Coal|w/o CCS",
    "Primary Energy|Electricity|Biomass|w/o CCS",
    "Primary Energy|Electricity|Coal|w/ CCS",
    "Primary Energy|Electricity|Oil|w/ CCS",
    "Primary Energy|Electricity|Biomass|w/ CCS",
    "Primary Energy|Electricity|Gas|w/ CCS",
    "Primary Energy|Electricity|Nuclear",
    "Primary Energy|Electricity|Hydro",
    "Primary Energy|Electricity|Wind",
    "Primary Energy|Electricity|Geothermal",
    "Primary Energy|Electricity|Solar"
  ),
  Unit = "EJ/yr",
  Tier = 3,
  Internal_variable = "primary_energy_electricity_clean",
  Model = "GCAM-China 7.1",
  stringsAsFactors = FALSE
)
template_vGCAMChina7.1 <- dplyr::bind_rows(template_vGCAMChina7.1, primary_energy_elec_vars)

# Add GAINS-format livestock variables
gains_livestock_vars <- data.frame(
  Variable = c(
    "Agricultural Production|Non-Energy|Livestock",
    "Agricultural Production|Non-Energy|Livestock|Beef",
    "Agricultural Production|Non-Energy|Livestock|Dairy",
    "Agricultural Production|Non-Energy|Livestock|Pork",
    "Agricultural Production|Non-Energy|Livestock|Poultry",
    "Agricultural Production|Non-Energy|Livestock|SheepGoat"
  ),
  Unit = "million t DM/yr",
  Tier = 3,
  Internal_variable = "ag_production_clean",
  Model = "GCAM-China 7.1",
  stringsAsFactors = FALSE
)
template_vGCAMChina7.1 <- dplyr::bind_rows(template_vGCAMChina7.1, gains_livestock_vars)

use_data(template_vGCAMChina7.1, overwrite = T)


# variables_functions_mapping
var_fun_map_vGCAMChina7.1 <- read.csv(
  file.path(rawDataFolder, "inst/extdata", "mappings/GCAMChina7.1/variables_functions_mapping.csv"),
  sep = ";", header = T, na.strings = c("", "NA")
)

var_fun_map_vGCAMChina7.1$dependencies <- as.list(strsplit(var_fun_map_vGCAMChina7.1$dependencies, ","))
var_fun_map_vGCAMChina7.1$queries <- as.list(strsplit(var_fun_map_vGCAMChina7.1$queries, ","))
use_data(var_fun_map_vGCAMChina7.1, overwrite = T)
