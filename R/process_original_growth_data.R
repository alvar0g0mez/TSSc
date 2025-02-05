# The goal of this file is to process their .xlsx data and leave it in a nice format for me to analyze afterwards,
# setting more comfortable colnames, merging the separate datasets per temperature into a single one, and saving these
# new versions as .tsv to a new directory. 





### Process liquid medium data

# Load the 2 dataframes
liquid_22 <- read.xlsx("C:/MyStuff/TSSC/Data/Growth/Original data//liquid_final/all_auc_combined_liquid_20241216.xlsx", 1)
liquid_26 <- read.xlsx("C:/MyStuff/TSSC/Data/Growth/Original data/liquid_final/all_auc_combined_liquid_20241216.xlsx", 2)

# Fix colnames
colnames(liquid_22)[colnames(liquid_22) == "set1"] <- "Rep_1_AUC_22"
colnames(liquid_22)[colnames(liquid_22) == "set2"] <- "Rep_2_AUC_22"
colnames(liquid_22)[colnames(liquid_22) == "Average_AuC"] <- "Avg_AUC_22"
colnames(liquid_22)[colnames(liquid_22) == "Relative.AuC..Average.AuC.control.mean.AuC."] <- "Relative_AUC_to_control_mean_22"
colnames(liquid_22)[colnames(liquid_22) == "Relative.AuC..Average.AuC.plate.mean.AuC."] <- "Relative_AUC_to_plate_mean_22" 

colnames(liquid_26)[colnames(liquid_26) == "set1"] <- "Rep_1_AUC_26"
colnames(liquid_26)[colnames(liquid_26) == "set2"] <- "Rep_2_AUC_26"
colnames(liquid_26)[colnames(liquid_26) == "Average_AuC"] <- "Avg_AUC_26"
colnames(liquid_26)[colnames(liquid_26) == "Relative.AuC..Average.AuC.control.mean.AuC."] <- "Relative_AUC_to_control_mean_26"
colnames(liquid_26)[colnames(liquid_26) == "Relative.AuC..Average.AuC.plate.mean.AuC."] <- "Relative_AUC_to_plate_mean_26" 

# Merge datasets
final_liquid <- full_join(liquid_22, liquid_26, by = c("platenum", "dilution", "coordinate", "Sys.Name", "Std..Name", "ts.allele", "Lab.ID", "Notes", "SB.notes"))

# Fix some colnames that were common to the 2 datasets, that's why I didn't fix them before
colnames(final_liquid)[colnames(final_liquid) == "platenum"] <- "Platenum"
colnames(final_liquid)[colnames(final_liquid) == "dilution"] <- "Dilution"
colnames(final_liquid)[colnames(final_liquid) == "coordinate"] <- "Coordinate"
colnames(final_liquid)[colnames(final_liquid) == "Std..Name"] <- "Std.Name"
colnames(final_liquid)[colnames(final_liquid) == "ts.allele"] <- "TS.allele"

# Save final version of the dataset
fwrite(final_liquid, "C:/MyStuff/TSSC/Data/Growth/My versions/growth_liquid.tsv")







### Process agar medium data
# Load the 2 dataframes
agar_22 <- read.xlsx("C:/MyStuff/TSSC/Data/Growth/Original data//agar_final/auc_combined_agar_20241220.xlsx", 1)
agar_26 <- read.xlsx("C:/MyStuff/TSSC/Data/Growth/Original data/agar_final/auc_combined_agar_20241220.xlsx", 2)

# Fix colnames
colnames(agar_22)[colnames(agar_22) == "X1"] <- "Rep_1_AUC_22"
colnames(agar_22)[colnames(agar_22) == "X2"] <- "Rep_2_AUC_22"
colnames(agar_22)[colnames(agar_22) == "Average_AuC"] <- "Avg_AUC_22"
colnames(agar_22)[colnames(agar_22) == "Relative.AuC..Average.AuC.control.mean.AuC."] <- "Relative_AUC_to_control_mean_22"
colnames(agar_22)[colnames(agar_22) == "Relative.AuC..Average.AuC.plate.mean.AuC."] <- "Relative_AUC_to_plate_mean_22" 

colnames(agar_26)[colnames(agar_26) == "X1"] <- "Rep_1_AUC_26"
colnames(agar_26)[colnames(agar_26) == "X2"] <- "Rep_2_AUC_26"
colnames(agar_26)[colnames(agar_26) == "Average_AuC"] <- "Avg_AUC_26"
colnames(agar_26)[colnames(agar_26) == "Relative.AuC..Average.AuC.control.mean.AuC."] <- "Relative_AUC_to_control_mean_26"
colnames(agar_26)[colnames(agar_26) == "Relative.AuC..Average.AuC.plate.mean.AuC."] <- "Relative_AUC_to_plate_mean_26" 

# Remove temperature column - not meaningful anymore
agar_22 <- agar_22 %>% select(-temperature)
agar_26 <- agar_26 %>% select(-temperature)

# Merge datasets
final_agar <- full_join(agar_22, agar_26, by = c("plate384", "row384", "col384", "Sys..Name", "Std..Name", "ts.allele", "Lab.ID", "Notes", "SB.notes"))

# Fix some colnames that were common to the 2 datasets, that's why I didn't fix them before
colnames(final_agar)[colnames(final_agar) == "plate384"] <- "Plate384"
colnames(final_agar)[colnames(final_agar) == "row384"] <- "Row384"
colnames(final_agar)[colnames(final_agar) == "col384"] <- "Col384"
colnames(final_agar)[colnames(final_agar) == "Sys..Name"] <- "Sys.Name"
colnames(final_agar)[colnames(final_agar) == "Std..Name"] <- "Std.Name"
colnames(final_agar)[colnames(final_agar) == "ts.allele"] <- "TS.allele"

# Save final version of the dataset
fwrite(final_agar, "C:/MyStuff/TSSC/Data/Growth/My versions/growth_agar.tsv")
