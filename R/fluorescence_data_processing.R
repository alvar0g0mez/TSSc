
# Packages
library(xlsx)
library(data.table)
library(dplyr)
library(tidyr)


# Set up environment
working_from = "charite"

if (working_from == "home") {
  base_dir = "/home/alvaro/MyStuff/TSSc/"
} else
  if (working_from == "charite") {
    base_dir = "C:/MyStuff/TSSC/"
  }



# Load original data
raw_1 <- as.data.frame(fread(paste(base_dir, "Data/Boone_lab/Fluorescence/raw_1.csv", sep = "")))
raw_2 <- as.data.frame(fread(paste(base_dir, "Data/Boone_lab/Fluorescence/raw_2.csv", sep = "")))
raw_3 <- as.data.frame(fread(paste(base_dir, "Data/Boone_lab/Fluorescence/raw_3.csv", sep = "")))



# Put together replicates
full_fluorescence <- rbind(rbind(raw_1, raw_2), raw_3)









































