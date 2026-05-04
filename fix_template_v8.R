# 修复 GCAM-China 8.0 Template
# 添加缺失的 Primary Energy Electricity 变量映射

library(gcamreport)

# 加载 templates
template_v71 <- template_vGCAMChina7.1
template_v8 <- template_vGCAMChina8.0

cat("Original V8 template rows:", nrow(template_v8), "\n")

# 找出需要添加的 Primary Energy Electricity 变量
elec_vars_to_add <- template_v71[
  template_v71$Internal_variable == 'primary_energy_electricity_clean' &
  !is.na(template_v71$Internal_variable),
]

cat("Variables to add:", nrow(elec_vars_to_add), "\n")

# 添加到 V8 template
template_vGCAMChina8.0 <- rbind(template_v8, elec_vars_to_add)

# 去重
template_vGCAMChina8.0 <- template_vGCAMChina8.0[!duplicated(template_vGCAMChina8.0$Variable), ]

cat("Updated V8 template rows:", nrow(template_vGCAMChina8.0), "\n")

# 保存
save(template_vGCAMChina8.0, file = "data/template_vGCAMChina8.0.rda")

cat("\nTemplate updated successfully!\n")
cat("Added variables:\n")
for(v in elec_vars_to_add$Variable) {
  cat("  -", v, "\n")
}
