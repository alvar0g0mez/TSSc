
# Set up
working_from = "charite"

if (working_from == "home") {
  base_dir = "/home/alvaro/MyStuff/"
} else
  if (working_from == "charite") {
    base_dir = "C:/MyStuff/"
  }


# Libraries
library(dplyr)
library(tidyr)
library(xlsx)
library(data.table)





##################################################################################

# 0. Load data
growth_agar <- as.data.frame(fread(paste(base_dir, "TSSC/Data/Boone_lab/Growth/Mine/Processed_by_them/growth_agar.tsv", sep="")))
sick_strains_when_sent <- as.data.frame(read.xlsx(paste(base_dir, "TSSC/Data/Boone_lab/Sick_strains/20250131_TSV8-coordinates_very_sick_strains.xlsx", sep=""), 2))
no_growth_after_pinning <- as.data.frame(read.xlsx(paste(base_dir, "TSSC/Data/Boone_lab/Sick_strains/20250131_TSV8-coordinates_very_sick_strains.xlsx", sep=""), 3))
synthetases <- as.data.frame(fread(paste(base_dir, "TSSC/Data/synthetases/trna_synthetases.csv", sep="")))


# Growth agar is just as I got it from them
# Sick strains I think it also comes from them, the strains that had barely grown when they sent them
# "no growth after pinning" are the ones that were not supposed to be sick, but which didn't grow after Wenxi pinned them - Wenxi made this Excel 
# Synthetases - this dataframe is from the tRNA_KOs project, but I want to add a column here saying which TS alleles are for a tRNA synthetase





# 1. Put all this information together into a single dataframe
sick_strains_when_sent <- sick_strains_when_sent %>%
  filter(actually_healthy_after_pinning == "No") %>%
  mutate(Well_ID = paste(plate, row, column, sep="_"))

no_growth_after_pinning <- no_growth_after_pinning %>%
  mutate(Well_ID = paste(plate, row, column, sep="_"))

sample_layout <- growth_agar %>%
  dplyr::select(Plate384, Row384, Col384, Sys.Name, Std.Name, TS.allele, Lab.ID, Notes, SB.notes) %>%
  mutate(Well_ID = paste(Plate384, Row384, Col384, sep="_"),
         sick_when_sent = case_when(Well_ID %in% sick_strains_when_sent$Well_ID ~ "Yes",
                                    TRUE ~ "No"),
         no_growth_after_pinning = case_when(Well_ID %in% no_growth_after_pinning$Well_ID ~ "Yes",    # These are non-sick strains which didn't grow for Wenxi
                                           TRUE ~ "No"),
         Available = case_when((sick_when_sent == "No" & no_growth_after_pinning == "No") ~ "Yes",
                               TRUE ~ "No"),
         Synthetase = case_when(Sys.Name %in% synthetases$Gene.secondaryIdentifier ~ "Yes",
                                TRUE ~ "No")) 

# 2. Add a column with with well IDs in the "traditional" manner - for platetools
sample_layout <- sample_layout %>%
  mutate(Well_ID_non_unique = case_when(nchar(as.character(Col384)) == 1 ~ paste(LETTERS[Row384], 0, Col384, sep=""),
                                        TRUE ~ paste(LETTERS[Row384], Col384, sep="")))

# 3. Add a column from yeastmine with the gene definition
yeastmine <- as.data.frame(fread(paste(base_dir, "tRNA_KOs/Data/alliancemine_results_2024-11-20T11-19-04.tsv", sep=""))) %>%
  dplyr::select(Gene.name, Gene.secondaryIdentifier) %>%
  dplyr::rename(Sys.Name = Gene.secondaryIdentifier)
sample_layout <- left_join(sample_layout, yeastmine, by = "Sys.Name")


# 4. Save this dataframe 
fwrite(sample_layout, paste(base_dir, "TSSC/Data/Boone_lab/sample_layout.csv", sep=""))





# Clean up environment
rm(list = ls())
