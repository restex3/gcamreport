# GCAM-China Support in `gcamreport`

This document summarizes the dedicated `GCAM-China` support that has been added
to `gcamreport`, how to use it, how it compares to the official
`GCAM-China-reporting` workflow, and what still remains as maintenance work.

For an index-style manual optimized for coding agents and quick technical
lookup, see:

- `docs/gcam-china/GCAM-China_AGENT_MANUAL.md`

## Scope

This support targets:

- GCAM version: `vGCAMChina7.1`
- Reference database used for validation:
  `E:/GCAM/GCAM-China_v7.1/output/China60Ref`
- Official comparison workflow:
  `E:/GCAM/GCAM_tools/GCAM-China-reporting`

The validation focus is the national `China` IAMC export.

## Current Status

For the national `China` output from `China60Ref`, `gcamreport` is now aligned
with the official workflow for the core GCAM-China reporting chains:

- `Emissions|CO2*`
- `Secondary Energy|Electricity*`
- `Capacity|Electricity*`
- `Capacity Additions|Electricity*`

The latest full comparison summary is in:

- `E:/GCAM/GCAM_tools/tmp_china60ref_compare/fullcheck_summary.txt`

At the time this README was written, the full national comparison status was:

- Official China variables: `118`
- `gcamreport` China variables: `1908`
- Official variables covered by `gcamreport`: `118 / 118`
- Exact-equal overlap variables: `113`
- Remaining non-equal overlap variables: `5`

Those remaining `5` differences are only floating-point scale noise in
`Final Energy` variables, with maximum absolute difference:

- `8.54e-05 EJ/yr`

In practice, the national `China` export can now be treated as numerically
equivalent to the official workflow for the validated variable set.

## Key Improvements

### 1. Runtime GCAM-China support

`vGCAMChina7.1` now uses GCAM-China-specific runtime files instead of relying
only on baked package data:

- runtime variable-function mapping
- runtime query XML loading
- runtime conversion fallback fixes

This allows GCAM-China query and mapping updates to take effect without forcing
an immediate package data rebuild.

### 2. Official CO2 sector route

The CO2 chain was moved to the official GCAM-China route:

- official `CO2 emissions by sector` query integrated
- official `CO2_sector_map.csv` packaged and used
- China-specific sector normalization corrected
- national `China` CO2 rows injected directly from `co2_emissions_clean`

This fixed:

- `Emissions|CO2`
- `Emissions|CO2|Energy and Industrial Processes`
- `Emissions|CO2|Industrial Processes`
- `Emissions|CO2|AFOLU`

### 3. Capacity factor and capacity chain alignment

The electricity capacity chain was reworked to follow the official GCAM-China
logic:

- official `incl cogen` power queries integrated
- official WEO capacity mapping used
- official province-specific renewable CF correction integrated
- official `hydro` and `rooftop_pv` pseudo-vintaging integrated
- capacity conversion bug fixed (`EJ_to_GWh`)
- duplicate/fallback mapping issues in solar and capacity joins fixed

This brought:

- `Secondary Energy|Electricity*`
- `Capacity|Electricity*`
- `Capacity Additions|Electricity*`

into national alignment with the official workflow.

### 4. Final Energy and Capital Cost alignment

The full national comparison later showed remaining differences in:

- `Final Energy*`
- `Capital Cost|Electricity*`

These were reduced by:

- switching `Final Energy` to the official GCAM-China mapping
- switching transport final energy to the official GCAM-China mapping
- preventing GCAM-China residential sectors from being incorrectly treated as
  deciles
- switching electricity capital cost to official GCAM-China `L2234.*_CHINA.csv`
  files
- aligning conversion constants with the official GCAM-China values

### 5. Maintenance and robustness improvements

Additional engineering work included:

- `approx_fun()` single-point fallback to avoid interpolation spam
- tolerant handling of missing production price queries such as
  `aluminum prices`
- zero-valued official placeholders added where needed, such as geothermal
  capacity variables
- CO2 resource production parent variables explicitly added where official
  output expects them
- reusable full validation scripts added

## Validation Scripts

Two scripts were added to make the official comparison reproducible.

### Full `gcamreport` run

File:

- `dev_scripts/GCAM-China_fullcheck.R`

Purpose:

- loads the saved GCAM-China project
- runs a national `China` full export with `desired_variables = "All"`
- saves the result to:
  `E:/GCAM/GCAM_tools/tmp_china60ref_compare/gcamreport_fullcheck.csv`
- saves `vetting_summary` to:
  `E:/GCAM/GCAM_tools/tmp_china60ref_compare/fullcheck_vetting_summary.rds`

### Official comparison

File:

- `dev_scripts/GCAM-China_compare_official.R`

Purpose:

- compares `gcamreport_fullcheck.csv` to the official
  `official_GCAM_China_China60ref.csv`
- writes:
  - `fullcheck_summary.txt`
  - `fullcheck_compare_overlap.csv`
  - `fullcheck_official_only.csv`
  - `fullcheck_gcamreport_only.csv`

## Main Files Added or Changed

Core logic:

- `E:/GCAM/GCAM_tools/gcamreport/R/functions.R`
- `E:/GCAM/GCAM_tools/gcamreport/R/main.R`

GCAM-China mappings:

- `E:/GCAM/GCAM_tools/gcamreport/inst/extdata/mappings/GCAMChina7.1/CO2_sector_map.csv`
- `E:/GCAM/GCAM_tools/gcamreport/inst/extdata/mappings/GCAMChina7.1/CO2_resource_map.csv`
- `E:/GCAM/GCAM_tools/gcamreport/inst/extdata/mappings/GCAMChina7.1/elec_gen_map_gcamchina.csv`
- `E:/GCAM/GCAM_tools/gcamreport/inst/extdata/mappings/GCAMChina7.1/gcam_weo_mapping.csv`
- `E:/GCAM/GCAM_tools/gcamreport/inst/extdata/mappings/GCAMChina7.1/IEAWEO2023_Capacity.csv`
- `E:/GCAM/GCAM_tools/gcamreport/inst/extdata/mappings/GCAMChina7.1/CF_tech_mapping.csv`
- `E:/GCAM/GCAM_tools/gcamreport/inst/extdata/mappings/GCAMChina7.1/df_CF_China_province_8_12.csv`
- `E:/GCAM/GCAM_tools/gcamreport/inst/extdata/mappings/GCAMChina7.1/final_energy_map_gcamchina.csv`
- `E:/GCAM/GCAM_tools/gcamreport/inst/extdata/mappings/GCAMChina7.1/transport_final_en_map_gcamchina.csv`
- `E:/GCAM/GCAM_tools/gcamreport/inst/extdata/mappings/GCAMChina7.1/L2234.GlobalIntTechCapital_elecS_CHINA.csv`
- `E:/GCAM/GCAM_tools/gcamreport/inst/extdata/mappings/GCAMChina7.1/L2234.GlobalTechCapital_elecS_CHINA.csv`

Query and dependency metadata:

- `E:/GCAM/GCAM_tools/gcamreport/inst/extdata/queries/GCAMChina7.1/queries_gcamreport_general.xml`
- `E:/GCAM/GCAM_tools/gcamreport/inst/extdata/mappings/GCAMChina7.1/variables_functions_mapping.csv`
- `E:/GCAM/GCAM_tools/gcamreport/inst/extdata/saveDataFiles_GCAMChina7.1.R`

Utilities:

- `dev_scripts/GCAM-China_fullcheck.R`
- `dev_scripts/GCAM-China_compare_official.R`
- `docs/gcam-china/GCAM_CHINA_WORK_PLAN.md`

## Remaining Maintenance Items

The result-level work is largely complete, but a few maintenance issues remain:

- Some non-critical project-loading warnings are still emitted for queries that
  only exist for `China` or only for a subset of provinces.
- `Vetting variables: ERROR` still appears in full runs.
  This is tied to historical vetting on `World`-level aggregates and does not
  indicate mismatch versus the official national `China` CSV.
- `gcamreport` still exports many more detailed variables than the official
  workflow. This is expected, but if a strict official-template-only mode is
  desired, it could be added later.

## Recommended Workflow

For ongoing maintenance of GCAM-China support:

1. Run `GCAM-China_fullcheck.R`
2. Run `GCAM-China_compare_official.R`
3. Check `fullcheck_summary.txt`
4. If needed, inspect:
   - `fullcheck_compare_overlap.csv`
   - `fullcheck_official_only.csv`
   - `fullcheck_gcamreport_only.csv`
   - `fullcheck_vetting_summary.rds`

Both scripts are stored under `dev_scripts/`.

## Summary

`gcamreport` now has a dedicated GCAM-China implementation that reproduces the
official national `China` IAMC export to numerical equivalence for the
validated overlap set, while also exposing a broader internal variable space
useful for further development and analysis.
