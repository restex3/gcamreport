# Analyze missing GAINS variables and determine if they can be generated

library(gcamreport)

# Load GAINS requirements
gains_map <- read.csv('E:/GCAM/GCAM_tools/gcam2gains/GCAM_GAINS_SEC_ACT_MAP.csv', stringsAsFactors=FALSE)
required_vars <- sort(unique(gains_map$SOURCE_VARIABLE))

# Load latest output
output <- read.csv('E:/GCAM/GCAM_tools/gcamreport/output/gains_complete.csv', stringsAsFactors=FALSE)
available_vars <- unique(output$Variable)

# Find missing
missing_vars <- setdiff(required_vars, available_vars)

cat('=== MISSING GAINS VARIABLES ANALYSIS ===\n\n')
cat('Total required:', length(required_vars), '\n')
cat('Total available:', length(intersect(required_vars, available_vars)), '\n')
cat('Total missing:', length(missing_vars), '\n')
cat('Coverage:', sprintf('%.1f%%', 100 * length(intersect(required_vars, available_vars)) / length(required_vars)), '\n\n')

# Categorize missing variables
cat('=== CATEGORIZED MISSING VARIABLES ===\n\n')

# Category 1: Primary Energy Convert (likely not in GCAM)
convert_vars <- grep('Convert', missing_vars, value=TRUE)
if (length(convert_vars) > 0) {
  cat('1. Primary Energy|*|Convert (', length(convert_vars), ') - LIKELY NOT IN GCAM\n', sep='')
  cat('   These represent energy conversion processes (refining, etc.)\n')
  cat('   GCAM may not track these separately from primary energy consumption\n')
  for (v in convert_vars) cat('   -', v, '\n')
  cat('\n')
}

# Category 2: Off-road Construction (may need different sector name)
offroad_vars <- grep('Off-road', missing_vars, value=TRUE)
if (length(offroad_vars) > 0) {
  cat('2. Off-road|Construction (', length(offroad_vars), ') - MAPPING ISSUE\n', sep='')
  cat('   These should map to "construction energy use" sector\n')
  cat('   Need to verify mapping is working correctly\n')
  for (v in offroad_vars) cat('   -', v, '\n')
  cat('\n')
}

# Category 3: Residential and Commercial aggregations
rescom_vars <- grep('Residential and Commercial', missing_vars, value=TRUE)
if (length(rescom_vars) > 0) {
  cat('3. Residential and Commercial (', length(rescom_vars), ') - AGGREGATION ISSUE\n', sep='')
  cat('   These should be aggregated from Residential + Commercial\n')
  cat('   Need to verify aggregation is working correctly\n')
  for (v in rescom_vars) cat('   -', v, '\n')
  cat('\n')
}

# Category 4: Land Cover
land_vars <- grep('Land Cover', missing_vars, value=TRUE)
if (length(land_vars) > 0) {
  cat('4. Land Cover (', length(land_vars), ') - AGGREGATION NEEDED\n', sep='')
  cat('   These may need custom aggregation logic\n')
  for (v in land_vars) cat('   -', v, '\n')
  cat('\n')
}

# Category 5: Non-Energy Use
nonenergy_vars <- grep('Non-Energy Use', missing_vars, value=TRUE)
if (length(nonenergy_vars) > 0) {
  cat('5. Non-Energy Use (', length(nonenergy_vars), ') - MAPPING ISSUE\n', sep='')
  cat('   These should map to feedstock sectors\n')
  for (v in nonenergy_vars) cat('   -', v, '\n')
  cat('\n')
}

# Category 6: Other
other_vars <- setdiff(missing_vars, c(convert_vars, offroad_vars, rescom_vars, land_vars, nonenergy_vars))
if (length(other_vars) > 0) {
  cat('6. Other (', length(other_vars), ')\n', sep='')
  for (v in other_vars) cat('   -', v, '\n')
  cat('\n')
}

cat('=== RECOMMENDATIONS ===\n\n')
cat('1. Primary Energy|*|Convert: Accept as unavailable (4 vars)\n')
cat('2. Off-road|Construction: Debug mapping (5 vars)\n')
cat('3. Residential and Commercial: Debug aggregation (3 vars)\n')
cat('4. Land Cover: Implement custom aggregation (1-2 vars)\n')
cat('5. Non-Energy Use: Debug mapping (1-2 vars)\n')
cat('6. Other: Investigate individually\n\n')

cat('Expected achievable coverage: ~85-90%\n')
