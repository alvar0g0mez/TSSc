# The point of this file is to process the 2 datasets from the original article where they published the library of essential genes


# File Li_et_al_S1 - contains general information about the strains, my interest is mostly in the temperatures at which they show sick or lethal effects
# However, this info is all in a text column, so I will extract that and put it in some new columns as numbers so they are easy to check
# The way this works is: 
# If there are both lethal and sick temperatures, we first separate them (otherwise we just keep whichever it is as it came, sick or lethal)
# Then for each, lethal or sick, we check if there is a "~" separating upper and lower boundary, if there is, we grab both
# If there isn't and only one temperature is provided, we keep it as the lower boundary, and write "Not_provided" for the upper boundary
# Those rows for which we didn't have either sick or lethal temperatures, we just write NAs in both upper and lower boundaries of that temp




# File Li_et_al_S3 - growth data (different variables) at different temperatures, not sure if I need to do something with this one








# Libraries
library(dplyr)
library(tidyr)
library(xlsx)
library(stringr)
library(data.table)



# Load data - Idk why it reads a bunch of empty rows at the end of the dataframe, let me remove those
li_1 <- read.xlsx("C:/MyStuff/TSSC/Data/From articles/Li_et_al_2011/Li_et_al_S1.xls", 1, startRow = 2) %>%
  filter(!is.na(Strain.ID))



# Process Li_et_al_S1

## Extract lethal and sick temps and make a column for each - I AM IGNORING THE ~ IN THIS COLUMN, REMEMBER THAT!!!
lethal_temp <- c()
sick_temp <- c()

# Separate temperature into lethal and sick
for (i in 1:nrow(li_1)) {
  temp <- li_1$ts.on.SC[i]
  if (grepl(";", temp)) {
    lethal_temp <- c(lethal_temp, substr(temp, 1, str_locate(temp, ";")[1]-1))
    sick_temp <- c(sick_temp, substr(temp, str_locate(temp, ";")[1]+1, nchar(temp)))
  }
  else if (grepl("Lethal", temp, ignore.case = T)) {
    lethal_temp <- c(lethal_temp, temp)
    sick_temp <- c(sick_temp, NA)
  }
  else if (grepl("Sick", temp, ignore.case = T)) {
    sick_temp <- c(sick_temp, temp)
    lethal_temp <- c(lethal_temp, NA)
  }
}


# Separate both lethal and sick temperatures into the lower and upper limits of their range
# IF THERE IS ONLY ONE TEMP., IT'S PUT INTO "LOWER"! AND "UPPER" CONTAINS "NOT_PROVIDED"
lethal_temp_lower <- c()
lethal_temp_upper <- c()
sick_temp_lower <- c()
sick_temp_upper <- c()

for (i in 1:nrow(li_1)) {
  lethal <- lethal_temp[i]
  sick <- sick_temp[i]
  
  # Deal with lethal temp
  if (!is.na(lethal) & grepl("~", lethal)) {
    lethal_1 <- substr(lethal, 1, str_locate(lethal, "~")[1]-1)
    lethal_2 <- substr(lethal, str_locate(lethal, "~")[1], nchar(lethal))
    
    lethal_temp_lower <- c(lethal_temp_lower, substr(lethal_1, str_locate(lethal_1, "at ")[2]+1, str_locate(lethal_1, "C")[1]-2))
    lethal_temp_upper <- c(lethal_temp_upper, substr(lethal_2, str_locate(lethal_2, "~ ")[2]+1, str_locate(lethal_2, "C")[1]-2))
  }
  else if (!is.na(lethal)) {
    lethal_temp_lower <- c(lethal_temp_lower, substr(lethal, str_locate(lethal, "at ")[2]+1, str_locate(lethal, "C")[1]-2))
    lethal_temp_upper <- c(lethal_temp_upper, "Not_provided")
  }
  else {
    lethal_temp_lower <- c(lethal_temp_lower, NA)
    lethal_temp_upper <- c(lethal_temp_upper, NA)
  }
  
  # Deal with sick temp
  if (!is.na(sick) & grepl("~", sick)) {
    sick_1 <- substr(sick, 1, str_locate(sick, "~")[1]-1)
    sick_2 <- substr(sick, str_locate(sick, "~")[1], nchar(sick))
    
    sick_temp_lower <- c(sick_temp_lower, substr(sick_1, str_locate(sick_1, "at ")[2]+1, str_locate(sick_1, "C")[1]-2))
    sick_temp_upper <- c(sick_temp_upper, substr(sick_2, str_locate(sick_2, "~ ")[2]+1, str_locate(sick_2, "C")[1]-2))
  }
  else if (!is.na(sick)) {
    sick_temp_lower <- c(sick_temp_lower, substr(sick, str_locate(sick, "at ")[2]+1, str_locate(sick, "C")[1]-2))
    sick_temp_upper <- c(sick_temp_upper, "Not_provided")
  }
  else {
    sick_temp_lower <- c(sick_temp_lower, NA)
    sick_temp_upper <- c(sick_temp_upper, NA)
  }
}


# Add the newly created columns to the dataframe and rewrite it to the directory
li_1$lethal_temp_lower <- lethal_temp_lower
li_1$lethal_temp_upper <- lethal_temp_upper
li_1$sick_temp_lower <- sick_temp_lower
li_1$sick_temp_upper <- sick_temp_upper

fwrite(li_1, "C:/MyStuff/TSSC/Data/From articles/Li_et_al_2011/Li_et_al_S1.csv", sep=",")


# Remove unnecessary variables
rm(i, lethal, lethal_1, lethal_2, lethal_temp, lethal_temp_lower, lethal_temp_upper, sick, sick_1, sick_2, sick_temp,
   sick_temp_lower, sick_temp_upper, temp)












