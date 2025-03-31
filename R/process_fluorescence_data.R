
# Packages
library(xlsx)
library(data.table)
library(dplyr)
library(tidyr)


# Set up environment
working_from = "home"

if (working_from == "home") {
  base_dir = "/home/alvaro/MyStuff/TSSc/"
} else
  if (working_from == "charite") {
    base_dir = "C:/MyStuff/TSSC/"
  }



# Load original data
flu <- read.xlsx(file = paste(base_dir, "Data/Fluorescence/het_diploid_intensities_forMC.xlsx", sep = ""), sheetIndex = 1)













































