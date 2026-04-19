# GCAM-China Agriculture Allocation - Final Assessment

**Date**: 2026-04-19
**Status**: Critical Issue Identified

---

## Data Availability Assessment

### What We Found

After thorough investigation, GCAM-China provincial data is **extremely limited** for agriculture:

| Data Type | Query | Provincial Data | National Data |
|-----------|-------|----------------|---------------|
| Crop Production | `ag production by crop type` | ❌ NO | ✅ YES (20 crops) |
| Crop Demand | `demand balances by crop commodity` | ⚠️ Very Limited | ✅ YES |
| Land Allocation | `land allocation by crop and water source` | ❌ NO | ✅ YES |
| Livestock Production | `meat and dairy production by type` | ❌ NO | ✅ YES (5 products) |
| Livestock Demand | `demand balances by meat and dairy commodity` | ❌ NO | ✅ YES |

**Provincial crop demand** only includes:
- regional biomassOil (soybean for biodiesel)
- regional corn for ethanol
- regional sugar for ethanol
- **Total: 1,661 rows** (vs 1,024 rows for national comprehensive demand)

**Conclusion**: The original allocation strategy based on provincial demand is **NOT feasible** because the required provincial data does not exist in GCAM-China.

---

## Root Cause

GCAM-China models China as:
1. **National level** for production (agriculture, livestock)
2. **Provincial level** for energy consumption (buildings, transport, industry)
3. **Very limited provincial data** for agriculture (only biofuel-related)

This is a **fundamental limitation** of the GCAM-China model structure, not a data extraction issue.

---

## Revised Solutions

### Solution 1: Use External Statistical Data (Recommended)

**Approach**: Use China Statistical Yearbook provincial production data to calculate allocation coefficients

**Steps**:
1. Obtain provincial crop/livestock production data from National Bureau of Statistics
2. Calculate provincial shares for a base year (e.g., 2020)
3. Apply these shares to GCAM national production for all years
4. Assume shares remain constant over time

**Pros**:
- Most accurate for current/near-term years
- Based on real data
- Simple to implement

**Cons**:
- Requires external data source
- Assumes constant provincial shares over time
- May not reflect future changes in agricultural patterns

**Implementation**:
```r
# Load statistical yearbook data
statistical_shares <- read.csv("provincial_ag_shares_2020.csv")

# Apply to GCAM national production
provincial_production <- national_production %>%
  left_join(statistical_shares, by = "crop") %>%
  mutate(provincial_value = national_value * provincial_share)
```

---

### Solution 2: Uniform Distribution (Simplest)

**Approach**: Distribute national production equally across 31 provinces

**Steps**:
```r
provincial_share = 1 / 31
provincial_production = national_production / 31
```

**Pros**:
- Extremely simple
- No external data needed
- Transparent

**Cons**:
- Completely inaccurate
- Ignores all regional differences
- Not recommended for serious analysis

---

### Solution 3: Use GCAM-China Source Code/Input Files

**Approach**: Extract provincial agricultural parameters from GCAM-China XML input files

**Steps**:
1. Locate GCAM-China input XML files
2. Extract provincial agricultural technology parameters
3. Use these to infer production allocation

**Pros**:
- Uses GCAM's own assumptions
- Internally consistent

**Cons**:
- Requires access to GCAM-China source files
- Complex to extract and process
- May not be readily available

---

### Solution 4: Provide National-Level Data Only

**Approach**: Accept the limitation and provide only national-level agricultural data to GAINS

**Steps**:
1. Extract national crop and livestock production
2. Map to GAINS format
3. Document that provincial disaggregation is not available

**Pros**:
- Accurate for national totals
- No assumptions needed
- Transparent about limitations

**Cons**:
- GAINS may require provincial data
- Loses spatial resolution
- May not meet project requirements

---

## Recommendation

**Primary Recommendation**: **Solution 1** (External Statistical Data)

**Rationale**:
1. Most accurate approach given GCAM-China limitations
2. Widely accepted method in integrated assessment modeling
3. Data is publicly available from National Bureau of Statistics
4. Can be validated and documented

**Implementation Priority**:
1. Obtain 2020 provincial agricultural production data from statistical yearbook
2. Calculate provincial shares by crop and livestock type
3. Create allocation coefficient file
4. Apply to GCAM national production
5. Document assumptions and limitations
6. Validate against known patterns (e.g., rice in south, wheat in north)

**Alternative**: If GAINS can accept national-level data, use **Solution 4**

---

## Impact on Project Timeline

**Original Estimate**: 7-8 weeks for agriculture sector

**Revised Estimate**:
- With external data (Solution 1): **2-3 weeks**
  - 1 week: Obtain and process statistical data
  - 1 week: Implement allocation and conversion
  - 0.5-1 week: Validation and testing

- Without external data (Solution 4): **1 week**
  - National-level conversion only
  - No allocation needed

**Total Project Timeline Update**:
- Buildings: ✅ Complete
- Transport: ✅ Complete
- Industry: ✅ Complete
- Agriculture: 2-3 weeks (with external data) or 1 week (national only)

**New Total**: 2-3 weeks remaining (vs original 7-8 weeks)

---

## Next Steps

### Immediate Actions

1. **Consult with GAINS team**
   - Can GAINS accept national-level agricultural data?
   - Or is provincial disaggregation required?

2. **If provincial data required**:
   - Obtain China Statistical Yearbook data
   - Process and create allocation coefficients
   - Implement Solution 1

3. **If national data acceptable**:
   - Implement Solution 4
   - Complete project quickly

### Documentation

- Update all reports with this finding
- Document the limitation clearly
- Explain allocation methodology chosen
- Provide uncertainty estimates

---

## Key Takeaway

**The original allocation strategy based on GCAM provincial demand data is not feasible because that data does not exist in GCAM-China.**

**We must use external statistical data or provide national-level data only.**

---

**Assessment Date**: 2026-04-19
**Assessed By**: Claude
**Status**: Awaiting decision on approach
