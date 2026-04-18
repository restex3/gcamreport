# GCAM-China v7.1 Support - Change Summary

This summary consolidates all changes made to enable GCAM‑China v7.1 processing in `gcamreport`, including the recent additions for iron/steel by technology and primary energy electricity variables.

## Overview
- Added GCAM‑China v7.1 mappings, queries, and fallback logic to handle provincial structure and missing keys.
- Added iron & steel production by technology outputs, with new query, map, and template variables.
- Added primary energy electricity variables derived from `elec gen by gen tech (cogen only)`.
- Updated query sets, RDA data, and templates to ensure reporting works end‑to‑end.

## Queries (XML)
- `inst/extdata/queries/GCAMChina7.1/queries_gcamreport_general.xml`
  - Added/updated queries used by GCAM‑China v7.1.
  - Added `elec gen by gen tech (cogen only)` to support Primary Energy|Electricity variables.
  - Added `iron and steel production by tech`.

## New/Updated Mappings
- `inst/extdata/mappings/GCAMChina7.1/iron_steel_prod_tech_map.csv`
  - New map for iron/steel production by technology.
  - Includes `var1/var2/var3` structure and `NoReported` rows for province‑aggregate subsectors.
- `inst/extdata/mappings/GCAMChina7.1/variables_functions_mapping.csv`
  - Added `iron_steel_prod_tech_clean`.
  - Added `primary_energy_electricity_clean`.
- Primary energy map updated previously to include GCAM‑China fuels (regional biomass, wholesale gas, etc.).

## Templates (Variables)
- `inst/extdata/saveDataFiles_GCAMChina7.1.R`
  - Added template variables for:
    - `Production|Steel|Blast Furnace`
    - `Production|Steel|EAF-scrap`
    - `Production|Steel|Hydrogen-DRI`
    - `Production|Steel|EAF-DRI`
  - Added var3‑level steel tech variables:
    - `Production|Steel|Blast Furnace|BLASTFUR`
    - `Production|Steel|Blast Furnace|BLASTFUR CCS`
    - `Production|Steel|Blast Furnace|BLASTFUR with hydrogen`
    - `Production|Steel|Blast Furnace|Biomass-based`
    - `Production|Steel|EAF-scrap|EAF with scrap`
    - `Production|Steel|EAF-DRI|EAF with DRI`
    - `Production|Steel|EAF-DRI|EAF with DRI CCS`
    - `Production|Steel|Hydrogen-DRI|Hydrogen-based DRI`
  - Added Primary Energy|Electricity variables:
    - `Primary Energy|Electricity|Oil|w/o CCS`
    - `Primary Energy|Electricity|Gas|w/o CCS`
    - `Primary Energy|Electricity|Coal|w/o CCS`
    - `Primary Energy|Electricity|Biomass|w/o CCS`
    - `Primary Energy|Electricity|Coal|w/ CCS`
    - `Primary Energy|Electricity|Oil|w/ CCS`
    - `Primary Energy|Electricity|Biomass|w/ CCS`
    - `Primary Energy|Electricity|Gas|w/ CCS`
    - `Primary Energy|Electricity|Nuclear`
    - `Primary Energy|Electricity|Hydro`
    - `Primary Energy|Electricity|Wind`
    - `Primary Energy|Electricity|Geothermal`
    - `Primary Energy|Electricity|Solar`

## New/Updated R Functions
- `R/functions.R`
  - Added `get_iron_steel_prod_tech()` to read the new query and map to variables.
  - Added `get_primary_energy_electricity()` to compute Primary Energy|Electricity variables from `elec gen by gen tech (cogen only)`.
  - GCAM‑China specific fallback logic for several joins (previous work).
  - Primary energy logic uses CCS query when available; falls back to non‑CCS if missing.
  - Province handling: uses China values when province data are missing (where applicable).

## Mapping Fallbacks
- `inst/extdata/mappings/GCAMChina7.1/mapping_fallbacks.csv`
  - Snapshot of missing or fallback mapping keys (for review and refinement).

## Generated Data (RDA)
The following RDA files were regenerated as part of mapping/query updates:
- `data/queries_general_vGCAMChina7.1.rda`
- `data/template_vGCAMChina7.1.rda`
- `data/var_fun_map_vGCAMChina7.1.rda`
- `data/iron_steel_prod_tech_map_vGCAMChina7.1.rda`
- Other vGCAMChina7.1 mapping RDA files as applicable

## How to Rebuild Package Data After Mapping Changes
Run these commands after any mapping/query updates:
```
source("inst/extdata/saveDataFiles_GCAMChina7.1.R")
devtools::load_all(".")
```

## Notes
- `Main_queries.xml` is **not** modified by `gcamreport`. GCAM project queries are controlled by the GCAM output `Main_queries.xml`.
- Primary Energy|Electricity variables come strictly from `elec gen by gen tech (cogen only)` and do **not** alter `primary_energy_clean`.
