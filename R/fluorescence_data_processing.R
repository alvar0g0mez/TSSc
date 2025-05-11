
# Packages
library(xlsx)
library(data.table)
library(dplyr)
library(tidyr)
library(readxl)


# Set up environment
working_from = "home"

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


# Save it as .csv
fwrite(raw_1, paste(base_dir, "Data/Boone_lab/Fluorescence/raw_1.csv", sep = ""))
fwrite(raw_2, paste(base_dir, "Data/Boone_lab/Fluorescence/raw_2.csv", sep = ""))
fwrite(raw_3, paste(base_dir, "Data/Boone_lab/Fluorescence/raw_3.csv", sep = ""))










































