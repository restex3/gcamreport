# GCAM-China Agent Manual

This manual is optimized for fast lookup by coding agents and maintainers.

Use it as the canonical entry point for:

- what `vGCAMChina7.1` support currently does
- where each reporting chain is implemented
- which files are the source of truth
- how to rerun validation
- what kinds of issues are still considered maintenance-only

## 1. Goal

Primary goal:

- make `gcamreport` a practical replacement for the official
  `GCAM-China-reporting` workflow for national `China` IAMC export

Reference database:

- `E:/GCAM/GCAM-China_v7.1/output/China60Ref`

Official comparison file:

- `E:/GCAM/GCAM_tools/tmp_china60ref_compare/official_GCAM_China_China60ref.csv`

Latest `gcamreport` fullcheck file:

- `E:/GCAM/GCAM_tools/tmp_china60ref_compare/gcamreport_fullcheck.csv`

## 2. Current Validation State

Validated target:

- `Scenario = China60ref`
- `Region = China`
- `GCAM_version = vGCAMChina7.1`

Latest fullcheck summary:

- official China vars: `118`
- gcamreport China vars: `1908`
- overlap vars: `118`
- exact-equal overlap vars: `113`
- remaining non-equal overlap vars: `5`

Interpretation:

- all official national `China` variables are now covered
- remaining non-equal overlap vars are only floating-point noise in
  `Final Energy`
- result-level status is effectively equivalent to the official workflow

Summary file:

- `E:/GCAM/GCAM_tools/tmp_china60ref_compare/fullcheck_summary.txt`

Detailed overlap comparison:

- `E:/GCAM/GCAM_tools/tmp_china60ref_compare/fullcheck_compare_overlap.csv`

## 3. Canonical Files

### Core logic

- `R/functions.R`
- `R/main.R`

### GCAM-China query metadata

- `inst/extdata/queries/GCAMChina7.1/queries_gcamreport_general.xml`
- `inst/extdata/mappings/GCAMChina7.1/variables_functions_mapping.csv`

### GCAM-China mappings used at runtime

- `inst/extdata/mappings/GCAMChina7.1/CO2_sector_map.csv`
- `inst/extdata/mappings/GCAMChina7.1/CO2_resource_map.csv`
- `inst/extdata/mappings/GCAMChina7.1/elec_gen_map_gcamchina.csv`
- `inst/extdata/mappings/GCAMChina7.1/gcam_weo_mapping.csv`
- `inst/extdata/mappings/GCAMChina7.1/IEAWEO2023_Capacity.csv`
- `inst/extdata/mappings/GCAMChina7.1/CF_tech_mapping.csv`
- `inst/extdata/mappings/GCAMChina7.1/df_CF_China_province_8_12.csv`
- `inst/extdata/mappings/GCAMChina7.1/final_energy_map_gcamchina.csv`
- `inst/extdata/mappings/GCAMChina7.1/transport_final_en_map_gcamchina.csv`
- `inst/extdata/mappings/GCAMChina7.1/L2234.GlobalIntTechCapital_elecS_CHINA.csv`
- `inst/extdata/mappings/GCAMChina7.1/L2234.GlobalTechCapital_elecS_CHINA.csv`

### Package-data rebuild script

- `inst/extdata/saveDataFiles_GCAMChina7.1.R`

### Validation scripts

- `GCAM-China_fullcheck.R`
- `GCAM-China_compare_official.R`

### Human-readable documentation

- `README_GCAM-China.md`
- `GCAM-China_IMPROVEMENTS.md`
- `GCAM_CHINA_WORK_PLAN.md`

## 4. End-to-End Reporting Flow

Entry function:

- `generate_report()` in `R/main.R`

Project loading/creation:

- `load_project()` in `R/main.R`
- `create_project()` in `R/main.R`

Runtime configuration:

- `get_runtime_var_fun_map()` in `R/functions.R`
- `get_runtime_convert()` in `R/functions.R`

Result assembly:

- `do_bind_results()` in `R/functions.R`

GCAM-China specific report post-processing:

- `add_gcam_china_co2_report()`
- `add_gcam_china_zero_report_vars()`
- `add_china_from_provinces_report()`

## 5. Reporting Chains and Where to Edit Them

### CO2 chain

Key functions:

- `normalize_gcam_china_co2_sector()`
- `get_gcam_china_co2_sector_map()`
- `get_gcam_china_co2_resource_map()`
- `get_co2_emiss()`
- `get_co2_emissions()`

Primary source of truth:

- `CO2 emissions by sector`
- `inst/extdata/mappings/GCAMChina7.1/CO2_sector_map.csv`

### Electricity generation / capacity chain

Key functions:

- `get_gcam_china_elec_query_name()`
- `get_gcam_china_elec_gen_map()`
- `get_gcam_china_weo_mapping()`
- `get_gcam_china_iea_capacity_2023()`
- `get_gcam_china_cf_tech_mapping()`
- `get_gcam_china_cf_province()`
- `get_cf_iea_tmp()`
- `get_elec_cf_tmp()`
- `get_elec_capacity_tot()`
- `get_elec_capacity_add_tmp()`
- `get_elec_capacity_add()`

Primary source of truth:

- official `incl cogen` power queries
- official WEO mapping
- official province wind/renewable CF correction
- official hydro / rooftop PV pseudo-vintage logic

### Final Energy chain

Key functions:

- `get_gcam_china_final_energy_map()`
- `get_gcam_china_transport_final_en_map()`
- `get_fe_sector_tmp()`
- `get_fe_transportation_tmp()`
- `get_fe_sector()`

Primary source of truth:

- official `final_energy_map_detailedIndustry-ylv2-v7.csv`
- official `transport_final_en_map.csv`

Important pitfall:

- do not treat GCAM-China residential `modern_d1` ... `modern_d10` sectors as
  deciles in `get_fe_sector_tmp()`

### Capital Cost chain

Key functions:

- `get_gcam_china_capital_gcam()`
- `get_elec_capital()`

Primary source of truth:

- `L2234.GlobalIntTechCapital_elecS_CHINA.csv`
- `L2234.GlobalTechCapital_elecS_CHINA.csv`

## 6. Runtime Notes vs Errors

For `vGCAMChina7.1`, non-blocking situations are intentionally summarized at the
end of the run under:

- `GCAM-China run notes`

Examples:

- missing CCS primary energy query fallback
- missing optional production price queries
- missing water queries
- duplicate row aggregation before pivoting

These are not treated as result-breaking failures.

## 7. World Vetting Policy

For `vGCAMChina7.1`, `World` historical vetting is skipped.

Reason:

- this mode uses `China + provinces`, not the standard GCAM world-region set
- `World` historical checks are not meaningful for this reporting scope

Expected console message:

- `Historical World vetting is skipped for vGCAMChina7.1 ...`

## 8. Rebuild and Validation Workflow

### Full national validation

Run:

```r
source("GCAM-China_fullcheck.R")
```

Outputs:

- `tmp_china60ref_compare/gcamreport_fullcheck.csv`
- `tmp_china60ref_compare/fullcheck_vetting_summary.rds`

### Official comparison

Run:

```r
source("GCAM-China_compare_official.R")
```

Outputs:

- `tmp_china60ref_compare/fullcheck_summary.txt`
- `tmp_china60ref_compare/fullcheck_compare_overlap.csv`
- `tmp_china60ref_compare/fullcheck_official_only.csv`
- `tmp_china60ref_compare/fullcheck_gcamreport_only.csv`

### Rebuild package data after mapping changes

Run:

```r
source("inst/extdata/saveDataFiles_GCAMChina7.1.R")
devtools::load_all(".", reset = TRUE)
```

Note:

- GCAM-China runtime logic already prefers several `inst/extdata` files
- rebuilding package data is still recommended for long-term consistency

## 9. Known Maintenance-Only Issues

These do not currently block correct national `China` output:

- local R package version messages from `devtools::load_all()`
- some partial query availability notes in niche chains
- broader variable coverage in `gcamreport` than in the official workflow

## 10. Practical Guidance for Future Agents

If the user asks whether GCAM-China support is “done”, use this rule:

- for national `China` IAMC export from `China60Ref`, answer yes
- for broader package-wide polishing, answer “results are done; maintenance work
  can still continue”

If a future change breaks alignment, debug in this order:

1. `CO2` sector normalization and mapping
2. `incl cogen` power query routing
3. renewable CF correction and pseudo-vintage logic
4. final energy map and transport map
5. China-specific capital cost files
6. final report post-processing in `do_bind_results()`

## 11. Files Not Intended as Canonical User Workflow

These exist mainly as local helpers / investigation artifacts and should not be
treated as the primary user workflow:

- `GCAM-China_test.r`
- `GCAM-China_mapping_fallbacks.R`
- `rebuild_mappings.R`

They may still be useful during debugging.
