# GCAM-China Work Plan

## Goal

Make `gcamreport` `vGCAMChina7.1` a practical replacement for the official
`GCAM-China-reporting` workflow for **China national IAMC export**.

Primary reference database for validation:

- `E:\GCAM\GCAM-China_v7.1\output\China60Ref`

Primary external reference workflow:

- `E:\GCAM\GCAM_tools\GCAM-China-reporting`

Temporary comparison artifacts:

- `E:\GCAM\GCAM_tools\tmp_china60ref_compare`

## Current Status

### What is already working

- The official workflow can be run against `China60Ref` and produces a national
  CSV output after minor runtime patching for this database/query set.
- `gcamreport` can create projects from `China60Ref`, run full reporting, and
  produce national CSV outputs for `vGCAMChina7.1`.
- The following GCAM-China specific fixes are already in place:
  - runtime query loading for `vGCAMChina7.1`
  - runtime `variables_functions_mapping.csv` loading
  - official `CO2 emissions by sector` query added to runtime XML
  - official `CO2_sector_map.csv` copied into `inst/extdata/mappings/GCAMChina7.1`
  - `co2_sector_map_vGCAMChina7.1` package data generation entry added
  - CO2 price fragmented join made tolerant to missing sector shares
  - path handling for project creation fixed
  - `Capacity Additions` filtering bug fixed so the variable is no longer
    dropped before renaming
  - interpolation guard added for missing interpolation endpoints

### What is in good shape

- CO2 is much closer to the official workflow than at the start.
- Current probes show `Emissions|CO2` and
  `Emissions|CO2|Energy and Industrial Processes` are in the right order of
  magnitude and close enough to continue refining instead of redesigning.

### What is not finished

- CO2 is **not fully closed** yet. Remaining differences are mainly in the
  detailed `E&I` chain and some China-specific sector normalization.
- Capacity and Capacity Additions are **not yet trustworthy**.
- Capacity totals and additions are still systematically too large relative to
  the official workflow.
- The capacity chain is now partially repaired structurally, but the numeric
  calibration is still wrong.

## Files That Matter Most

- `E:\GCAM\GCAM_tools\gcamreport\R\functions.R`
- `E:\GCAM\GCAM_tools\gcamreport\R\main.R`
- `E:\GCAM\GCAM_tools\gcamreport\inst\extdata\queries\GCAMChina7.1\queries_gcamreport_general.xml`
- `E:\GCAM\GCAM_tools\gcamreport\inst\extdata\mappings\GCAMChina7.1\variables_functions_mapping.csv`
- `E:\GCAM\GCAM_tools\gcamreport\inst\extdata\mappings\GCAMChina7.1\CO2_sector_map.csv`
- `E:\GCAM\GCAM_tools\gcamreport\inst\extdata\mappings\GCAMChina7.1\elec_gen_map_gcamchina.csv`
- `E:\GCAM\GCAM_tools\gcamreport\inst\extdata\saveDataFiles_GCAMChina7.1.R`

## Work Order

### Phase 1. Finish CO2 completely

#### Objective

Make national `CO2` outputs match the official workflow closely enough that the
CO2 chain can be considered complete.

#### Tasks

1. Keep `vGCAMChina7.1` on the official `CO2 emissions by sector` route.
2. Keep official `CO2_sector_map.csv` as the primary mapping source.
3. Continue expanding China-specific sector normalization until unmapped
   high-value sectors are exhausted.
4. Verify that `Emissions|CO2` is always rebuilt from:
   - `Emissions|CO2|Energy and Industrial Processes`
   - `Emissions|CO2|AFOLU`
5. Remove any remaining accidental double counting of total CO2.
6. Validate the following variables against the official national export:
   - `Emissions|CO2`
   - `Emissions|CO2|Energy and Industrial Processes`
   - `Emissions|CO2|Energy`
   - `Emissions|CO2|Energy|Supply`
   - `Emissions|CO2|Energy|Demand`
   - `Emissions|CO2|AFOLU`

#### Acceptance target

- National yearly values are close to official output across 2005-2060.
- No obvious order-of-magnitude mismatch remains.
- CO2 probe output is stable from a clean rebuild, not only from cached
  projects.

### Phase 2. Fix `cf_iea` for GCAM-China

#### Objective

Make the capacity-factor chain follow the official GCAM-China logic rather than
 the generic GCAM path.

#### Tasks

1. Compare the current `get_cf_iea_tmp()` logic line-by-line with the official
   CF calculation in `GCAM-China-reporting/Reporting.R`.
2. Use the official electricity generation mapping as the source of truth for
   the IEA capacity comparison.
3. Make sure segment technologies like:
   - `coal_base_conv pul`
   - `coal_int_conv pul`
   - `gas_base_CC`
   - `hydro_base`
   - `wind_base`
   are assigned capacity factors in the same way as the official workflow.
4. Confirm whether official logic uses:
   - segment-specific CFs directly
   - collapsed technology names
   - China-only province-level CF tables
5. Reproduce official hydro and solar/wind CF behavior before touching totals.

#### Acceptance target

- `elec_cf` contains valid CF entries for all major China electricity
  technologies used by the capacity chain.
- No major technology family falls through to implicit zero capacity.

### Phase 3. Fix total electricity capacity

#### Objective

Make `Capacity|Electricity*` align with official national values.

#### Tasks

1. Trace the chain for `vGCAMChina7.1`:
   - raw vintage generation query
   - technology normalization
   - CF join
   - EJ to GW conversion
   - electricity generation map join
   - final aggregation to China
2. Confirm whether the official workflow uses:
   - provincial sum for China
   - direct China query rows
   - both, with overrides
3. Reproduce official treatment of:
   - hydro
   - wind
   - solar PV
   - rooftop PV
   - storage
   - nuclear
   - coal and gas segment technologies
4. Verify if `China` capacity should always be reconstructed from provinces for
   GCAM-China.

#### Acceptance target

- National `Capacity|Electricity` and major subcategories are close to the
  official output over 2020-2060.

### Phase 4. Fix capacity additions

#### Objective

Make `Capacity Additions|Electricity*` align with official national values.

#### Tasks

1. Keep the existing fix that prevents `Capacity Additions` from being dropped
   before variable renaming.
2. Reproduce the official pseudo-vintaging logic for:
   - hydro
   - rooftop PV
3. Confirm whether official additions are:
   - direct vintage-year generation changes
   - five-year average additions
   - province-summed China totals
4. Check whether storage and hydro are being over-counted due to query shape.

#### Acceptance target

- `Capacity Additions|Electricity` and its major subcategories match the
  official directionally and are not off by order-of-magnitude multiples.

### Phase 5. Recheck capital cost and investment

#### Objective

After capacity totals and additions are fixed, re-evaluate:

- `Capital Cost|Electricity*`
- `Investment|Energy Supply|Electricity*`

These should not be tuned before the capacity chain is stable.

## Validation Procedure

### Fast probes

Use narrow probes first:

- CO2 probe
- capacity probe
- capacity additions probe

Only after probe-level agreement is reached, run the full national export.

### Comparison outputs

Keep using:

- `comparison_summary.txt`
- `comparison_diff.csv`
- `official_only_variables.csv`
- `gcamreport_only_variables.csv`

under:

- `E:\GCAM\GCAM_tools\tmp_china60ref_compare`

### Required comparison baseline

Always compare against:

- `official_GCAM_China_China60ref.csv`

not against older `gcamreport` outputs.

## Rules for Subsequent Work

1. Do not touch the generic GCAM versions unless a change is clearly isolated
   to `vGCAMChina7.1`.
2. Prefer a China-specific branch in logic over breaking other model versions.
3. For capacity logic, prefer reproducing the official workflow over preserving
   generic abstractions.
4. Validate each major fix with a small probe before a full rerun.
5. If a runtime-only fix proves correct, package it afterward by updating
   `saveDataFiles_GCAMChina7.1.R` and associated data files.

## Immediate Next Actions

1. Finish CO2 residual alignment by sector.
2. Rework `cf_iea` for `vGCAMChina7.1` to follow the official GCAM-China
   workflow exactly.
3. Rebuild `Capacity|Electricity*`.
4. Rebuild `Capacity Additions|Electricity*`.
5. Re-run the full national comparison after those two chains stabilize.

