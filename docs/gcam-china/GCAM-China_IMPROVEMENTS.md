# GCAM-China Improvements Log

This file records the main improvements made to support `vGCAMChina7.1` in
`gcamreport`.

## Baseline Goal

Target:

- Make `gcamreport` a practical replacement for the official
  `GCAM-China-reporting` workflow for national `China` IAMC export.

Reference database:

- `E:/GCAM/GCAM-China_v7.1/output/China60Ref`

Official comparison output:

- `E:/GCAM/GCAM_tools/tmp_china60ref_compare/official_GCAM_China_China60ref.csv`

## Phase 1. Runtime GCAM-China support

Implemented:

- runtime loading of `variables_functions_mapping.csv` for `vGCAMChina7.1`
- runtime loading of GCAM-China query XML
- runtime conversion fallback helper
- runtime mapping access helpers for GCAM-China specific files

Purpose:

- ensure local GCAM-China query and mapping edits are actually used by the
  reporting workflow

## Phase 2. Official CO2 integration

Implemented:

- official `CO2 emissions by sector` query integrated into GCAM-China query XML
- official `CO2_sector_map.csv` packaged and used
- official `CO2_resource_map.csv` path exposed in runtime helper
- corrected China-specific CO2 sector normalization
- direct injection of finalized `China` CO2 rows into the final report
- explicit support for:
  - `Emissions|CO2`
  - `Emissions|CO2|Energy and Industrial Processes`
  - `Emissions|CO2|Industrial Processes`
  - `Emissions|CO2|AFOLU`
  - `Emissions|CO2|Energy|Supply|Gases`
  - `Emissions|CO2|Energy|Supply|Liquids`
  - `Emissions|CO2|Energy|Supply|Solids`

Critical bug fixed:

- removing ` feedstocks` from normalized sector names caused industrial process
  emissions to be undercounted

Result:

- official national CO2 chain aligned

## Phase 3. Electricity generation and capacity chain

Implemented:

- official `elec gen by gen tech (incl cogen)` query
- official `elec gen by gen tech and vintage (incl cogen)` query
- official WEO mapping and capacity file
- official province-specific renewable capacity factor adjustment
- official hydro and rooftop PV pseudo-vintaging
- corrected `EJ_to_GWh` conversion at runtime
- removed problematic capacity fallback duplication for GCAM-China branch

Result:

- national `Secondary Energy|Electricity*`
- national `Capacity|Electricity*`
- national `Capacity Additions|Electricity*`

all aligned with official output

## Phase 4. Final Energy and Capital Cost alignment

Implemented:

- switched GCAM-China final energy mapping to official
  `final_energy_map_detailedIndustry-ylv2-v7.csv`
- switched GCAM-China transport final energy mapping to official
  `transport_final_en_map.csv`
- disabled accidental decile splitting for GCAM-China residential sectors
- switched electricity capital cost to official China-specific
  `L2234.*_CHINA.csv` files
- aligned GCAM-China conversion constants with the official workflow

Result:

- full national comparison narrowed from major differences to only floating
  point noise for a few `Final Energy` variables

## Phase 5. Maintenance and engineering improvements

Implemented:

- `approx_fun()` now falls back cleanly for zero-point and one-point cases
- `production_price_clean` tolerates missing optional production price queries
- selected official zero-valued placeholders are injected when absent
- official comparison scripts added:
  - `GCAM-China_fullcheck.R`
  - `GCAM-China_compare_official.R`
- comparison artifacts standardized under:
  `E:/GCAM/GCAM_tools/tmp_china60ref_compare`

Result:

- full validation runs are reproducible
- warning volume is reduced
- GCAM-China support is easier to maintain

## Current Validation Snapshot

Latest national fullcheck summary:

- official China variables: `118`
- `gcamreport` China variables: `1908`
- overlap variables: `118`
- exact-equal overlap variables: `113`
- remaining non-equal overlap variables: `5`

Remaining differences are only floating-point scale noise in `Final Energy`
variables, with maximum absolute difference:

- `8.54e-05 EJ/yr`

There are no remaining official-only national `China` variables.

## Important Files

Logic:

- `E:/GCAM/GCAM_tools/gcamreport/R/functions.R`
- `E:/GCAM/GCAM_tools/gcamreport/R/main.R`

Metadata and mappings:

- `E:/GCAM/GCAM_tools/gcamreport/inst/extdata/queries/GCAMChina7.1/queries_gcamreport_general.xml`
- `E:/GCAM/GCAM_tools/gcamreport/inst/extdata/mappings/GCAMChina7.1/variables_functions_mapping.csv`
- `E:/GCAM/GCAM_tools/gcamreport/inst/extdata/saveDataFiles_GCAMChina7.1.R`

Validation:

- `E:/GCAM/GCAM_tools/gcamreport/GCAM-China_fullcheck.R`
- `E:/GCAM/GCAM_tools/gcamreport/GCAM-China_compare_official.R`
- `E:/GCAM/GCAM_tools/tmp_china60ref_compare/fullcheck_summary.txt`

## Remaining Non-Blocking Issues

- Full-run `Vetting variables: ERROR` persists for `World`-level historical
  vetting and should be treated separately from official national comparison.
- Some query availability warnings remain for genuinely partial province
  coverage in the project.
- `gcamreport` still exposes many more variables than the official workflow;
  this is useful, but not the same thing as official-template parity.
