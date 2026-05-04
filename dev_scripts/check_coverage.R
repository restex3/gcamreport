# GAINS Coverage Check for vGCAMChina8.0
library(gcamreport)

gains_orig <- read.csv('E:/GCAM/GCAM_tools/gcam2gains/GCAM_GAINS_SEC_ACT_MAP.csv', stringsAsFactors=FALSE)
gains_target <- sort(unique(gains_orig$SOURCE_VARIABLE))

template <- get('template_vGCAMChina8.0')
template_vars <- unique(template$Variable)

# Collect ALL leaf vars from ALL maps
map_names <- c(
  'ag_production_map', 'ag_demand_map', 'land_use_map', 'production_map',
  'final_energy_map', 'primary_energy_map', 'res_extraction_map',
  'co2_sector_map', 'co2_resource_map', 'nonco2_emis_sector_map',
  'nonco2_emis_resource_map', 'kyoto_sector_map', 'carbon_seq_tech_map',
  'co2_tech_map', 'iron_steel_prod_tech_map',
  'transport_final_en_map', 'buildings_en_service', 'transport_en_service',
  'capacity_map', 'secondary_energy_map', 'water_map',
  'ag_demand_price_map', 'ag_price_map', 'en_demand_price_map',
  'energy_price_map', 'food_intake_map', 'food_items_map',
  'transport_sales_map', 'transport_stock_map', 'yield_map',
  'co2_ets_sector_map', 'co2_market_frag_map', 'conveyance.eff',
  'investment', 'iron_steel_trade_map', 'trade_ag', 'co2_market',
  'capital_gcam', 'carbon_content', 'cereal_scaler',
  'cf_gcam', 'cf_rgn', 'convert', 'iea_capacity',
  'region_mapping_ucd', 'ucd_core', 'ucd_size_class'
)

all_map_leaves <- character(0)
for(mn in map_names) {
  full_name <- paste0(mn, '_vGCAMChina8.0')
  obj <- try(get(full_name), silent=TRUE)
  if(!inherits(obj, 'try-error') && 'var' %in% names(obj)) {
    all_map_leaves <- c(all_map_leaves, unique(as.character(obj$var)))
  }
}
all_map_leaves <- unique(all_map_leaves[!is.na(all_map_leaves)])
all_map_leaves <- all_map_leaves[all_map_leaves != 'NoReported']

# Alias mapping from main.R
alias_map <- list(
  'Agricultural Production|Livestock|Ruminant|Meat' = c(
    'Agricultural Production|Non-Energy|Livestock|Beef',
    'Agricultural Production|Non-Energy|Livestock|SheepGoat'
  ),
  'Agricultural Production|Livestock|Ruminant|Dairy' = 'Agricultural Production|Non-Energy|Livestock|Dairy',
  'Agricultural Production|Livestock|Non-Ruminant|Meat|Pig' = 'Agricultural Production|Non-Energy|Livestock|Pork',
  'Agricultural Production|Livestock|Non-Ruminant|Meat|Poultry' = 'Agricultural Production|Non-Energy|Livestock|Poultry',
  'Land Cover|Cropland' = c('Land Cover|Cropland|Otherarable', 'Land Cover|Cropland|Crops'),
  'Land Cover|Forest' = 'Land Cover|Forest|Managed',
  'Land Cover|Pasture' = 'Land Cover|Pasture|Grazed',
  'Production|Non-Metallic Minerals|Cement' = 'Production|Cement',
  'Production|Chemicals|Ammonia' = c('Production|Chemicals|Nitrogen Fertilizer', 'Production|Chemicals|Fertilizer'),
  'Production|Iron and Steel|Steel' = c(
    'Production|Steel|Blast Furnace',
    'Production|Steel|EAF-scrap',
    'Production|Steel|EAF-DRI',
    'Production|Steel|Hydrogen-DRI'
  ),
  'Final Energy|Industry|Iron and Steel|Gases' = 'Final Energy|Industry|Steel|Gases',
  'Final Energy|Industry|Iron and Steel|Liquids' = 'Final Energy|Industry|Steel|Liquids'
)

get_source <- function(target) {
  for(src in names(alias_map)) {
    if(target %in% alias_map[[src]]) return(src)
  }
  return(NA)
}

check_data_status <- function(var, template_vars, map_leaves) {
  if(var %in% map_leaves) return('MAP_LEAF')
  if(!var %in% template_vars) return('NOT_IN_TEMPLATE')
  pattern <- paste0('^', gsub('\\|', '\\\\|', var), '\\|')
  children <- grep(pattern, template_vars, value=TRUE)
  if(length(children) > 0) {
    leaf_children <- children[children %in% map_leaves]
    if(length(leaf_children) > 0) return('ANCESTOR_HAS_DATA')
    return('ANCESTOR_MAY_HAVE_DATA')
  }
  return('TEMPLATE_ONLY_NO_DATA')
}

cat('===================================================\n')
cat('  GAINS COVERAGE FOR vGCAMChina8.0\n')
cat('===================================================\n\n')

cat(sprintf('Total GAINS targets: %d\n', length(gains_target)))
cat(sprintf('Total map leaf vars: %d\n', length(all_map_leaves)))
cat(sprintf('Total template vars: %d\n\n', length(template_vars)))

# Classify each GAINS target
real_independent <- c()
real_dup <- c()
proxy <- c()
missing <- c()

for(v in gains_target) {
  status <- check_data_status(v, template_vars, all_map_leaves)
  is_alias <- v %in% unlist(alias_map)

  if(is_alias && status %in% c('MAP_LEAF', 'ANCESTOR_HAS_DATA', 'ANCESTOR_MAY_HAVE_DATA')) {
    real_dup <- c(real_dup, v)
  } else if(is_alias && status %in% c('TEMPLATE_ONLY_NO_DATA', 'NOT_IN_TEMPLATE')) {
    proxy <- c(proxy, v)
  } else if(!is_alias && status %in% c('MAP_LEAF', 'ANCESTOR_HAS_DATA', 'ANCESTOR_MAY_HAVE_DATA')) {
    real_independent <- c(real_independent, v)
  } else if(!is_alias && status %in% c('TEMPLATE_ONLY_NO_DATA', 'NOT_IN_TEMPLATE')) {
    missing <- c(missing, v)
  }
}

cat(sprintf('REAL independent (from query data): %2d (%.1f%%)\n', length(real_independent), 100*length(real_independent)/81))
cat(sprintf('REAL but alias duplicates it:      %2d (%.1f%%)\n', length(real_dup), 100*length(real_dup)/81))
cat(sprintf('PROXY (only alias, fake data):     %2d (%.1f%%)\n', length(proxy), 100*length(proxy)/81))
cat(sprintf('MISSING (no data at all):         %2d (%.1f%%)\n', length(missing), 100*length(missing)/81))

cat(sprintf('\nREAL subtotal:                     %2d (%.1f%%)\n',
            length(real_independent)+length(real_dup),
            100*(length(real_independent)+length(real_dup))/81))

if(length(proxy) > 0) {
  cat('\n--- PROXY (NO real data, only alias backfill) ---\n')
  for(v in sort(proxy)) {
    src <- get_source(v)
    cat(sprintf('  %-55s <- %s\n', v, src))
  }
}

if(length(missing) > 0) {
  cat('\n--- TRULY MISSING ---\n')
  for(v in sort(missing)) cat(sprintf('  %s\n', v))
}

if(length(real_dup) > 0) {
  cat('\n--- REAL data exists, but alias creates redundant copy ---\n')
  for(v in sort(real_dup)) {
    src <- get_source(v)
    cat(sprintf('  %-55s <- %s (alias is redundant)\n', v, src))
  }
}

# Detailed breakdown of proxy types
if(length(proxy) > 0) {
  cat('\n=== PROXY DETAIL: What the alias does ===\n')
  for(v in sort(proxy)) {
    src <- get_source(v)
    src_status <- check_data_status(src, template_vars, all_map_leaves)
    cat(sprintf('\n  Target: %s\n  Aliased from: %s (status: %s)\n', v, src, src_status))
    if(grepl('Ruminant|Meat', src) && grepl('SheepGoat', v)) {
      cat('  PROBLEM: Ruminant|Meat = Beef+SheepGoat, but SheepGoat gets the SAME total value\n')
    }
    if(grepl('Cropland$', src) && grepl('Crops|Otherarable', v)) {
      cat('  PROBLEM: Cropland = Crops+Otherarable, but each gets the SAME total value\n')
    }
    if(grepl('Iron and Steel\\|Steel$', src) && grepl('Blast|EAF|Hydrogen', v)) {
      cat('  PROBLEM: Total steel = sum of all techs, but each tech gets the SAME total value\n')
    }
    if(grepl('Ammonia$', src) && (grepl('Fertilizer', v) || grepl('Nitrogen', v))) {
      cat('  PROBLEM: Chemicals|Ammonia total = sum of N Fertilizer + Fertilizer, but each gets SAME total\n')
    }
  }
}
