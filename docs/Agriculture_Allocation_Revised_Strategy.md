# GCAM-China Agriculture Allocation - Revised Strategy

**Date**: 2026-04-19
**Issue**: Provincial crop demand data is very limited

---

## Problem Identified

The query "demand balances by crop commodity" does NOT provide comprehensive provincial crop demand data.

**Provincial data available**:
- Only 3 sectors: regional biomassOil, regional corn for ethanol, regional sugar for ethanol
- Only 3 inputs: regional soybean, regional corn, regional sugarcrop
- Total: 1,661 rows for 31 provinces

**National data available**:
- 9 sectors: FoodDemand_Staples, FoodDemand_NonStaples, FeedCrops, NonFoodDemand_Crops, etc.
- Comprehensive demand categories
- Total: 1,024 rows

**Conclusion**: Cannot use provincial crop demand as allocation basis because it doesn't exist for most crops!

---

## Revised Allocation Strategies

### Option 1: Use Population as Proxy (Simplest)

**Assumption**: Crop production is proportional to population

**Pros**:
- Simple and straightforward
- Population data likely available in GCAM
- Reasonable for food crops

**Cons**:
- Not accurate for feed crops or industrial crops
- Ignores regional agricultural specialization

**Implementation**:
```r
provincial_share = provincial_population / national_population
provincial_production = national_production × provincial_share
```

---

### Option 2: Use GDP as Proxy

**Assumption**: Crop production is proportional to economic activity

**Pros**:
- Better for industrial crops
- Accounts for economic development

**Cons**:
- May not be accurate for food crops
- GDP data may not be available

---

### Option 3: Use Agricultural Land Area (Best)

**Assumption**: Crop production is proportional to agricultural land area

**Pros**:
- Most accurate for agricultural production
- Directly related to farming capacity
- GCAM has land allocation data

**Cons**:
- Need to extract land area data from GCAM
- May need to aggregate different land types

**Query**: "land allocation by crop and water source"

---

### Option 4: Use Historical Statistical Data

**Assumption**: Use actual provincial production shares from statistical yearbooks

**Pros**:
- Most accurate
- Based on real data

**Cons**:
- Requires external data source
- May not be available for future years
- Assumes constant shares over time

---

## Recommended Approach

**Primary Method**: Use agricultural land area from GCAM (Option 3)

**Fallback Method**: Use population if land data is insufficient (Option 1)

**Validation**: Compare with statistical yearbook data if available (Option 4)

---

## Implementation Plan

### Step 1: Check Land Allocation Data

Query: "land allocation by crop and water source"

Check if this provides provincial-level land area by crop type.

### Step 2: Implement Land-Based Allocation

If land data is available:
```r
provincial_land_share = provincial_crop_land / national_crop_land
provincial_production = national_production × provincial_land_share
```

### Step 3: Implement Population-Based Fallback

If land data is not available or insufficient:
```r
# Get population data from GCAM
# Calculate population shares
# Allocate production
```

### Step 4: Validate Results

Compare allocated production with:
- Statistical yearbook data (if available)
- Known agricultural production patterns
- Regional specialization (e.g., rice in south, wheat in north)

---

## Next Actions

1. ✅ Identified the problem with demand data
2. ⏭️ Check land allocation data structure
3. ⏭️ Implement land-based allocation
4. ⏭️ Test and validate
5. ⏭️ Document assumptions and limitations

---

**Updated**: 2026-04-19
