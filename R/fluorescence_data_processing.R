
# Packages
library(xlsx)
library(data.table)
library(dplyr)
library(tidyr)
library(readxl)


# Set up environment
working_from = "charite"

if (working_from == "home") {
  base_dir = "/home/alvaro/MyStuff/TSSc/"
} else
  if (working_from == "charite") {
    base_dir = "C:/MyStuff/TSSC/"
  }



# Load original data
raw_1 <- read_xlsx(paste(base_dir, "Data/Boone_lab/Fluorescence/het_diploid_intensities_forMC.xlsx", sep=""), sheet = 2)
raw_2 <- read_xlsx(paste(base_dir, "Data/Boone_lab/Fluorescence/het_diploid_intensities_forMC.xlsx", sep=""), sheet = 3)
raw_3 <- read_xlsx(paste(base_dir, "Data/Boone_lab/Fluorescence/het_diploid_intensities_forMC.xlsx", sep=""), sheet = 4)


## Remove all columns I'm not using - I DON'T THINK I'LL KEEP THIS, JUST TO MAKE MY TASK OF UNDERSTANDING WHAT'S GOING ON NOW EASIER
#raw_1 <- raw_1 %>%
#  dplyr::select(-c(undetectable_cells_mNG, undetectable_cells_mScar, average_intensity_mNG, average_intensity_mScar,
#                   std_intensity_mNG, std_intensity_mScar))
#raw_2 <- raw_2 %>%
#  dplyr::select(-c(undetectable_cells_mNG, undetectable_cells_mScar, average_intensity_mNG, average_intensity_mScar,
#                   std_intensity_mNG, std_intensity_mScar))
#raw_3 <- raw_3 %>%
#  dplyr::select(-c(undetectable_cells_mNG, undetectable_cells_mScar, average_intensity_mNG, average_intensity_mScar,
#                   std_intensity_mNG, std_intensity_mScar))
#


# Clean up this data
## First filter out those for which the corresponding WT was not present - I don't know why they have values for them, but technically they shouldn't have them
raw_1 <- raw_1 %>%
  filter(FILTER_wt_detectable == "y")
raw_2 <- raw_2 %>%
  filter(FILTER_wt_detectable == "y")
raw_3 <- raw_3 %>%
  filter(FILTER_wt_detectable == "y")

## Next remove those with way too large values for the final ratio - DON'T KNOW IF I WANT TO KEEP THIS HERE PERMANENTLY
raw_1 <- raw_1 %>%
  filter(`het:hom_mNG:mScar_ratio` < 5)
raw_2 <- raw_2 %>%
  filter(`het:hom_mNG:mScar_ratio` < 5)
raw_3 <- raw_3 %>%
  filter(`het:hom_mNG:mScar_ratio` < 5)


# Come up with a column where the final ratio for each strain is normalized to that at time 0 in that strain - need to do it with a function I think
come_up_with_normalized_to_t0_column <- function(df) {
  new_column <- c()
  df$`het:hom_mNG:mScar_ratio` <- as.numeric(df$`het:hom_mNG:mScar_ratio`)
  df <- df %>%
    filter(!(is.infinite(`het:hom_mNG:mScar_ratio`)))
  for (i in 1:nrow(df)) {
    t <- df$TimeAt37[i]
    ratio <- df$`het:hom_mNG:mScar_ratio`[i]
    gene <- df$Gene[i]
    status <- df$Status[i]
    plate <- df$Plate[i]
    strain_id <- df$StrainID[i]
    het_hom_ratio_status <- df$`het:hom_mNG:mScar_ratio_status`[i]
    r <- df$Row[i]
    c <- df$Column[i]
    
    if (is.na(ratio)) {
      new_column <- c(new_column, NA)
    }
    else {
      # Find the reference for this sample - tbh should work with just plate, row, and column, but oh well
      temp <- df %>%
        filter(TimeAt37 == 0,
               Gene == gene, 
               Status == status,
               Plate == plate,
               StrainID == strain_id,
               `het:hom_mNG:mScar_ratio_status` == het_hom_ratio_status,
               Column == c, 
               Row == r)
      ref_value <- temp$`het:hom_mNG:mScar_ratio`[1]
      new_column <- c(new_column, ratio/ref_value)
    }
  }
  df$ratio_norm_to_t0 <- new_column
  df <- df %>%
    filter(!(is.infinite(ratio_norm_to_t0)))
  return(df)
}

raw_1 <- come_up_with_normalized_to_t0_column(raw_1)
raw_2 <- come_up_with_normalized_to_t0_column(raw_2)
raw_3 <- come_up_with_normalized_to_t0_column(raw_3)


# Save it as .csv
fwrite(raw_1, paste(base_dir, "Data/Boone_lab/Fluorescence/raw_1.csv", sep = ""))
fwrite(raw_2, paste(base_dir, "Data/Boone_lab/Fluorescence/raw_2.csv", sep = ""))
fwrite(raw_3, paste(base_dir, "Data/Boone_lab/Fluorescence/raw_3.csv", sep = ""))





check <- raw_1 %>%
  filter(TimeAt37 == 0)
summary(check$ratio_norm_to_t0)

strains_with_crazy_values_r1 <- unique(raw_1$StrainID[raw_1$TimeAt37 == 0 & raw_1$ratio_norm_to_t0 > 20])

check <- raw_1[raw_1$StrainID %in% strains_with_crazy_values_r1,]



















