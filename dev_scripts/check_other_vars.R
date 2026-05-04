library(gcamreport)
template <- get('template_vGCAMChina8.0')
tv <- unique(template$Variable)

cat('=== FE Industry|Other children ===\n')
io <- grep('Final Energy\\|Industry\\|Other', tv, value=TRUE)
for(v in head(sort(io), 30)) cat('  ', v, '\n')
cat(sprintf('  ... %d total\n\n', length(io)))

cat('=== FE R&C|Other children ===\n')
roc <- grep('Residential and Commercial\\|Other', tv, value=TRUE)
for(v in sort(roc)) cat('  ', v, '\n')
cat(sprintf('  ... %d total\n\n', length(roc)))

cat('=== Coke/Feedstock/Steel/Inputs ===\n')
sc <- grep('Coke|Feedstock.*Steel|Inputs.*Steel|Inputs.*Iron', tv, value=TRUE, ignore.case=TRUE)
for(v in sc) cat('  ', v, '\n')

cat('\n=== Other industry vars from FE map ===\n')
oi <- grep('Other industry', tv, value=TRUE, ignore.case=TRUE)
for(v in head(sort(oi), 15)) cat('  ', v, '\n')
cat(sprintf('  ... %d total\n', length(oi)))
