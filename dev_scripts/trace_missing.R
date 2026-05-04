library(gcamreport)

gains_orig <- read.csv('E:/GCAM/GCAM_tools/gcam2gains/GCAM_GAINS_SEC_ACT_MAP.csv', stringsAsFactors=FALSE)
gains_target <- sort(unique(gains_orig$SOURCE_VARIABLE))

template <- get('template_vGCAMChina8.0')
template_vars <- unique(template$Variable)

# Load the GCAMChina-specific final energy map
fe_map <- read.csv('inst/extdata/mappings/GCAMChina8.0/final_energy_map_gcamchina.csv',
                   stringsAsFactors=FALSE, comment.char='#', check.names=FALSE)

# Load primary energy map
pe_map <- get('primary_energy_map_vGCAMChina8.0')

# Load production map
prod_map <- get('production_map_vGCAMChina8.0')

# Iron and steel prod tech map
is_map <- get('iron_steel_prod_tech_map_vGCAMChina8.0')

# Transport final energy map
tr_map <- tryCatch(read.csv('inst/extdata/mappings/GCAMChina8.0/transport_final_en_map_gcamchina.csv',
                   stringsAsFactors=FALSE, comment.char='#', check.names=FALSE), error=function(e) NULL)

# buildings en service
be_map <- get('buildings_en_service_vGCAMChina8.0')

cat("=========================================================\n")
cat("  TRACING MISSING/ALIAS GAINS VARIABLES TO DATA SOURCES\n")
cat("=========================================================\n\n")

# Group analysis
groups <- list(
  "Non-Energy Use by fuel" = c(
    'Final Energy|Non-Energy Use|Biomass',
    'Final Energy|Non-Energy Use|Coal',
    'Final Energy|Non-Energy Use|Gas',
    'Final Energy|Non-Energy Use|Oil'
  ),
  "Off-road Construction" = c(
    'Final Energy|Industry|Off-road|Construction',
    'Final Energy|Industry|Off-road|Construction|Electricity',
    'Final Energy|Industry|Off-road|Construction|Gases',
    'Final Energy|Industry|Off-road|Construction|Hydrogen',
    'Final Energy|Industry|Off-road|Construction|Liquids'
  ),
  "Steel remaining" = c(
    'Final Energy|Industry|Steel|Electricity',
    'Final Energy|Industry|Steel|Solids|Coal',
    'Feedstock|Industry|Steel|Coke'
  ),
  "Other missing FE" = c(
    'Final Energy|Residential and Commercial|Other',
    'Final Energy|Industry|Other'
  ),
  "Primary Energy|Oil|Liquids" = 'Primary Energy|Oil|Liquids',
  "Primary Energy Convert" = c(
    'Primary Energy|Biomass|Convert',
    'Primary Energy|Coal|Convert',
    'Primary Energy|Gas|Convert',
    'Primary Energy|Oil|Convert'
  ),
  "Primary Energy|Electricity|*" = c(
    'Primary Energy|Electricity|Biomass|w/ CCS',
    'Primary Energy|Electricity|Biomass|w/o CCS',
    'Primary Energy|Electricity|Coal|w/ CCS',
    'Primary Energy|Electricity|Coal|w/o CCS',
    'Primary Energy|Electricity|Gas|w/ CCS',
    'Primary Energy|Electricity|Gas|w/o CCS',
    'Primary Energy|Electricity|Geothermal',
    'Primary Energy|Electricity|Hydro',
    'Primary Energy|Electricity|Nuclear',
    'Primary Energy|Electricity|Oil|w/ CCS',
    'Primary Energy|Electricity|Oil|w/o CCS',
    'Primary Energy|Electricity|Solar',
    'Primary Energy|Electricity|Wind'
  ),
  "GDP|MER" = 'GDP|MER',
  "Proxy-Livestock (Non-Energy naming)" = c(
    'Agricultural Production|Non-Energy|Livestock|Beef',
    'Agricultural Production|Non-Energy|Livestock|Dairy',
    'Agricultural Production|Non-Energy|Livestock|Pork',
    'Agricultural Production|Non-Energy|Livestock|Poultry',
    'Agricultural Production|Non-Energy|Livestock|SheepGoat'
  ),
  "Proxy-Land Cover" = c(
    'Land Cover|Cropland|Otherarable',
    'Land Cover|Cropland|Crops',
    'Land Cover|Forest|Managed',
    'Land Cover|Pasture|Grazed'
  ),
  "Proxy-Production" = c(
    'Production|Cement',
    'Production|Chemicals|Nitrogen Fertilizer',
    'Production|Chemicals|Fertilizer',
    'Production|Steel|Blast Furnace',
    'Production|Steel|EAF-scrap',
    'Production|Steel|EAF-DRI',
    'Production|Steel|Hydrogen-DRI'
  ),
  "Proxy-FE Steel rename" = c(
    'Final Energy|Industry|Steel|Gases',
    'Final Energy|Industry|Steel|Liquids'
  )
)

# ============================================================
# 1. NON-ENERGY USE
# ============================================================
cat("\n--- 1. NON-ENERGY USE by fuel ---\n")
cat("Query: 'final energy consumption by sector and fuel'\n")
# Check what final_energy_map_gcamchina produces for Non-Energy Use
fe_neu <- fe_map[grepl('Non-Energy', apply(fe_map, 1, paste, collapse='|')), ]
cat(sprintf("  V8 final_energy_map_gcamchina has %d rows with Non-Energy Use\n", nrow(fe_neu)))
if(nrow(fe_neu) > 0) {
  # Get unique var columns (var1 through varN)
  var_cols <- grep('^var[0-9]+$', names(fe_neu))
  for(i in 1:nrow(fe_neu)) {
    vars <- unlist(fe_neu[i, var_cols])
    vars <- vars[!is.na(vars) & vars != '']
    cat(sprintf("  sector=%s input=%s -> %s\n",
                fe_neu$sector[i], fe_neu$input[i],
                paste(vars, collapse='|')))
  }
}

# Check template for Non-Energy Use vars
neu_template <- grep('Non-Energy Use', template_vars, value=TRUE)
cat(sprintf("\n  Template Non-Energy Use vars (%d):\n", length(neu_template)))
for(v in sort(neu_template)) cat(sprintf("    %s\n", v))

# The GAINS target is: Final Energy|Non-Energy Use|Biomass/Coal/Gas/Oil
# But V8 produces: Final Energy|Non-Energy Use|Solids|Coal, etc.
# Compare:
gains_neu <- c('Final Energy|Non-Energy Use|Biomass','Final Energy|Non-Energy Use|Coal',
               'Final Energy|Non-Energy Use|Gas','Final Energy|Non-Energy Use|Oil')
cat("\n  GAINS targets vs V8 template:\n")
for(v in gains_neu) {
  in_t <- v %in% template_vars
  cat(sprintf("    %s -> template=%s\n", v, if(in_t) 'YES' else 'NO'))
}

# ============================================================
# 2. OFF-ROAD CONSTRUCTION
# ============================================================
cat("\n--- 2. OFF-ROAD CONSTRUCTION ---\n")
cat("Query: 'final energy consumption by sector and fuel'\n")
# Check construction in fe_map
cons_rows <- fe_map[grepl('construction', fe_map$sector, ignore.case=TRUE), ]
cat(sprintf("  V8 map has %d rows with 'construction' in sector\n", nrow(cons_rows)))
for(i in 1:min(nrow(cons_rows), 15)) {
  var_cols <- grep('^var[0-9]+$', names(cons_rows))
  vars <- unlist(cons_rows[i, var_cols])
  vars <- vars[!is.na(vars) & vars != '']
  cat(sprintf("  sector=%s input=%s -> %s\n",
              cons_rows$sector[i], cons_rows$input[i],
              paste(vars, collapse='|')))
}

# Check template for off-road/construction
off_template <- grep('off.road|Off-road|Offroad', template_vars, value=TRUE, ignore.case=TRUE)
cat(sprintf("\n  Template 'off-road' vars: %d\n", length(off_template)))
for(v in off_template) cat(sprintf("    %s\n", v))
cons_template <- grep('construction', template_vars, value=TRUE, ignore.case=TRUE)
cat(sprintf("\n  Template 'construction' vars: %d\n", length(cons_template)))
for(v in cons_template) cat(sprintf("    %s\n", v))

# ============================================================
# 3. PRIMARY ENERGY ELECTRICITY
# ============================================================
cat("\n--- 3. PRIMARY ENERGY|ELECTRICITY|* ---\n")
cat("Query: 'elec gen by gen tech (cogen only)' or 'elec gen by gen tech'\n")
# Check V8 secondary energy map
se_map <- get('secondary_energy_map_vGCAMChina8.0')
se_elec <- unique(as.character(se_map$var))
se_elec <- se_elec[grepl('Electricity|elec', se_elec, ignore.case=TRUE)]
cat(sprintf("  Secondary energy map elec vars (%d):\n", length(se_elec)))
for(v in sort(se_elec)) cat(sprintf("    %s\n", v))

# Check primary energy electricity vars in template
pe_elec_template <- grep('Primary Energy.*Electricity', template_vars, value=TRUE)
cat(sprintf("\n  Template Primary Energy|Electricity vars (%d):\n", length(pe_elec_template)))
for(v in sort(pe_elec_template)) cat(sprintf("    %s\n", v))

# Check how get_primary_energy_electricity works
cat("\n  Current primary_energy_electricity output vars:\n")
pe_map_vars <- unique(as.character(pe_map$var))
pe_elec_pe <- pe_map_vars[grepl('Electricity', pe_map_vars)]
for(v in sort(pe_elec_pe)) cat(sprintf("    %s\n", v))

# ============================================================
# 4. GDP|MER
# ============================================================
cat("\n--- 4. GDP|MER ---\n")
cat("Query: 'GDP MER by region'\n")
gdp_template <- grep('GDP.*MER', template_vars, value=TRUE)
cat(sprintf("  Template GDP|MER vars: %d\n", length(gdp_template)))
for(v in gdp_template) cat(sprintf("    %s\n", v))
gdp_all <- grep('^GDP', template_vars, value=TRUE)
cat(sprintf("\n  All GDP* vars: %d\n", length(gdp_all)))
for(v in head(gdp_all, 20)) cat(sprintf("    %s\n", v))

# ============================================================
# 5. IRON AND STEEL PRODUCTION BY TECH
# ============================================================
cat("\n--- 5. STEEL PRODUCTION BY TECH ---\n")
cat("Query: 'industry primary output by sector'\n")
is_vars <- unique(as.character(is_map$var))
is_vars <- is_vars[!is.na(is_vars) & is_vars != 'NoReported']
cat(sprintf("  Iron steel prod tech map vars (%d):\n", length(is_vars)))
for(v in sort(is_vars)) cat(sprintf("    %s\n", v))

# Check Production map for steel
prod_vars <- unique(as.character(prod_map$var))
prod_vars <- prod_vars[!is.na(prod_vars) & prod_vars != 'NoReported']
cat(sprintf("\n  Production map vars (%d):\n", length(prod_vars)))
for(v in sort(prod_vars)) cat(sprintf("    %s\n", v))

# Check template for steel production
steel_t <- grep('Production.*Steel', template_vars, value=TRUE)
cat(sprintf("\n  Template Production|Steel vars (%d):\n", length(steel_t)))
for(v in sort(steel_t)) cat(sprintf("    %s\n", v))

steel_is <- grep('Production.*Iron', template_vars, value=TRUE)
cat(sprintf("\n  Template Production|Iron and Steel vars (%d):\n", length(steel_is)))
for(v in sort(steel_is)) cat(sprintf("    %s\n", v))

# ============================================================
# 6. RESIDENTIAL AND COMMERCIAL|Other & Industry|Other
# ============================================================
cat("\n--- 6. 'Other' categories ---\n")
rc_other <- grep('Residential and Commercial.*Other', template_vars, value=TRUE)
cat(sprintf("  Template Residential and Commercial|Other (%d):\n", length(rc_other)))
for(v in rc_other) cat(sprintf("    %s\n", v))

ind_other <- grep('Final Energy\\|Industry\\|Other$', template_vars, value=TRUE)
cat(sprintf("\n  Template Final Energy|Industry|Other (%d):\n", length(ind_other)))
for(v in ind_other) cat(sprintf("    %s\n", v))

# Check if these exist from building services / industry maps
# For buildings: Residential and Commercial is an aggregation
# Check if Other category exists in buildings map
be_vars <- unique(as.character(be_map$var))
be_vars <- be_vars[!is.na(be_vars) & be_vars != 'NoReported']
be_other <- grep('Other', be_vars, value=TRUE, ignore.case=TRUE)
cat(sprintf("\n  Buildings map 'Other' vars:\n"))
for(v in be_other) cat(sprintf("    %s\n", v))

# ============================================================
# 7. FEEDSTOCK|Industry|Steel|Coke
# ============================================================
cat("\n--- 7. FEEDSTOCK|Industry|Steel|Coke ---\n")
cat("Possible query: 'inputs by tech' or 'inputs by sector'\n")
feed_template <- grep('Feedstock', template_vars, value=TRUE)
cat(sprintf("  Template Feedstock vars (%d):\n", length(feed_template)))
for(v in feed_template) cat(sprintf("    %s\n", v))

# Check if inputs maps have steel/coke
input_template <- grep('Inputs', template_vars, value=TRUE)
cat(sprintf("\n  Template Inputs vars (%d):\n", length(input_template)))
for(v in head(input_template, 30)) cat(sprintf("    %s\n", v))

# ============================================================
# 8. AG PRODUCTION NON-ENERGY NAMING
# ============================================================
cat("\n--- 8. AG PRODUCTION Non-Energy NAMING ---\n")
ag_map <- get('ag_production_map_vGCAMChina8.0')
ag_vars <- unique(as.character(ag_map$var))
ag_vars <- ag_vars[!is.na(ag_vars) & ag_vars != 'NoReported']
cat(sprintf("  Ag production map vars (%d - showing livestock only):\n", length(ag_vars)))
ag_live <- grep('Livestock', ag_vars, value=TRUE)
for(v in sort(ag_live)) cat(sprintf("    %s\n", v))

cat("\n  GAINS target: Agricultural Production|Non-Energy|Livestock|*\n")
cat("  V8 produces: Agricultural Production|Livestock|* (no 'Non-Energy')\n")
cat("  -> Naming mismatch! V8 doesn't have the 'Non-Energy' level.\n")
