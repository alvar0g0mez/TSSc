
# Libraries
library(data.table)
library(dplyr)
library(tidyr)


# Set up
working_from = "charite"

if (working_from == "home") {
  base_dir = "/home/alvaro/MyStuff/"
} else
  if (working_from == "charite") {
    base_dir = "C:/MyStuff/"
  }


# Load data
source(paste(base_dir, "tRNA_KOs/Code/R/Mine/0.general_use_functions.R", sep=""))
synthetases_from_chatgpt <- as.data.frame(fread(paste(base_dir, "TSSC/Data/synthetases/synthetases_chatgpt.csv", sep="")))
yeastmine <- as.data.frame(fread(paste(base_dir, "tRNA_KOs/Data/alliancemine_results_2024-11-20T11-19-04.tsv", sep="")))
chu_synths <- as.data.frame(fread(paste(base_dir, "tRNA_KOs/Data/Other/Articles/chu_2011/S3.csv", sep="")))[1:20,] 



# Create the original synthetases dataframe, by using grepl() on the YeastMine dataset
## Subset this into a new dataframe with only info of tRNA synthases/synthetases (remove "kinase" because there is one that says "tRNA synthase-associated kinase")
synthetases <- yeastmine[(grepl("trna synthase", yeastmine$Gene.name, ignore.case = T)|grepl("trna synthetase", yeastmine$Gene.name, ignore.case = T)) &
                           !grepl("kinase", yeastmine$Gene.name, ignore.case = T),]

## Add a column with information on:
##   - Whether each synthetase is mitochondrial or not 
##   - Whether it is a synthase or a synthetase
##   - Whether it is the actual enzyme or a cofactor
synthetases <- synthetases %>%
  mutate(mitochondrial = case_when(grepl("mitochondrial", Gene.name, ignore.case = T) ~ "Yes",
                                   TRUE ~ "No"),
         type = case_when(grepl("synthase", Gene.name, ignore.case = T) ~ "synthase",
                          grepl("synthetase", Gene.name, ignore.case = T) ~ "synthetase"),
         cofactor_or_enzyme = case_when(grepl("cofactor", Gene.name, ignore.case = T) ~ "cofactor",
                                        TRUE ~ "enzyme"))


# Process the information on synthetases from Chut et al., 2011 (actually from van der Haar et al., 2008) so that it can be matched to that in the YeastMine dataset
## Before I match standard to systematic names, I need to extend the rows with multiple standard names into several rows, each with one of the systematic names, since they are all meaningful and different
chu_synths_new <- data.frame(matrix(ncol = ncol(chu_synths), nrow = 0))
colnames(chu_synths_new) <- colnames(chu_synths)
for (i in 1:nrow(chu_synths)) {
  std_name <- chu_synths$Synthetase[i]
  if (grepl("/", std_name)) {
    std_names <- str_split_1(std_name, "/")
    for (j in 1:length(std_names)) {
      new_row <- chu_synths[i, ]
      new_row$Synthetase[1] <- std_names[j]
      chu_synths_new <- rbind(chu_synths_new, new_row)
    }
  }
  else {
    new_row <- chu_synths[i,]
    chu_synths_new <- rbind(chu_synths_new, new_row)
  }
}
chu_synths_new <- chu_synths_new %>%
  dplyr::rename(gene_names = Synthetase)


## Get a column with systematic gene names in the synthetase dataframe (they only have the standard naming)
chu_synths_new <- match_systematic_and_standard_protein_names(data = chu_synths_new,
                                                              yeastmine = yeastmine,
                                                              input = "standard", 
                                                              simplify = F, 
                                                              add_extra_columns = F)


## Merge this with the k_cat and other synthetase info from van der Haar et al., 2008
check <- left_join(synthetases, chu_synths_new, by = "Gene.secondaryIdentifier") %>%
  dplyr::select(-Gene.briefDescription)

## Try to get a column with the amino acid that is loaded by each synthetase based on chu_synths_new
temp <- chu_synths_new %>%
  dplyr::select(Amino_acid_3_letter, Gene.secondaryIdentifier)
synthetases <- left_join(synthetases, temp, by = "Gene.secondaryIdentifier")

## Some of them need to be added manually because they are not included in chu_synths_new (got them from SGD myself)
synthetases$Amino_acid_3_letter[synthetases$Gene.symbol == "GRS2"] <- "Gly"
synthetases$Amino_acid_3_letter[synthetases$Gene.symbol == "ISM1"] <- "Ile"
synthetases$Amino_acid_3_letter[synthetases$Gene.symbol == "MSR1"] <- "Arg"
synthetases$Amino_acid_3_letter[synthetases$Gene.symbol == "MST1"] <- "Thr"
synthetases$Amino_acid_3_letter[synthetases$Gene.symbol == "MSW1"] <- "Trp"
synthetases$Amino_acid_3_letter[synthetases$Gene.symbol == "MSM1"] <- "Met"
synthetases$Amino_acid_3_letter[synthetases$Gene.symbol == "MSK1"] <- "Lys"
synthetases$Amino_acid_3_letter[synthetases$Gene.symbol == "MSE1"] <- "Glu"
synthetases$Amino_acid_3_letter[synthetases$Gene.symbol == "MSY1"] <- "Tyr"
synthetases$Amino_acid_3_letter[synthetases$Gene.symbol == "MSD1"] <- "Asp"
synthetases$Amino_acid_3_letter[synthetases$Gene.symbol == "MSF1"] <- "Phe"

synthetases <- synthetases %>%
  dplyr::select(-Gene.briefDescription)





# Now check which ones I was missing compared to the synthetases provided by ChatGPT
synthetases_from_chatgpt[!(synthetases_from_chatgpt$`Systematic Name` %in% synthetases$Gene.secondaryIdentifier),]
synthetases_from_chatgpt_in_yeastmine <- yeastmine[((yeastmine$Gene.secondaryIdentifier %in% synthetases_from_chatgpt$`Systematic Name`) & 
                                                      !(yeastmine$Gene.secondaryIdentifier %in% synthetases$Gene.secondaryIdentifier)),]

## Manually label each one of these as truly a synthetase or a ChatGPT allucination - by checking in SGD manually
## THE FACT THAT THIS IS DONE MANUALLY MEANS THAT I WILL HAVE TO CHECK IT IF I UPDATE THE YEASTMINE DATAFRAME!
synthetase_names <- c("YHR020W", "YHR068W", "YDR341C", "YGL009C", "YGL234W", "YGR124W", "YGR169C", "YLR071C",
                      "YOR015W", "YOR234C", "YOR243C", "YPL106C", "YPR145W")
checked_manually_if_its_a_synthetase <- c("yes", "nope", "yes", "nope", "nope", "nope", "yes", "nope", 
                                          "nope", "nope", "yes", "nope", "nope")
names(checked_manually_if_its_a_synthetase) <- synthetase_names
synthetases_from_chatgpt_in_yeastmine$checked_manually_if_its_a_synthetase <- checked_manually_if_its_a_synthetase
fwrite(synthetases_from_chatgpt_in_yeastmine, paste(base_dir, "TSSC/Data/synthetases/synths_from_chatgpt_not_in_original_dataset.csv", sep = ""))

# Add those which are real ones to the final synthetases dataframe I am creating
temp_1 <- synthetases_from_chatgpt_in_yeastmine %>%
  filter(checked_manually_if_its_a_synthetase == "yes")
temp_2 <- yeastmine[yeastmine$Gene.secondaryIdentifier %in% temp_1$Gene.secondaryIdentifier,] 

## Need to add the final columns to this one so that it can be added to the final dataframe
temp_2 <- temp_2 %>%
  dplyr::select(-Gene.briefDescription) %>%
  dplyr::mutate(mitochondrial = c("No", "No", "Yes", "No"),
                type = c("synthetase", "synthetase", "synthase", "synthase"),
                cofactor_or_enzyme = c("enzyme", "enzyme", "enzyme", "enzyme"))
temp <- chu_synths_new %>%
  dplyr::select(Amino_acid_3_letter, Gene.secondaryIdentifier)
temp_2 <- left_join(temp_2, temp, by = "Gene.secondaryIdentifier")
synthetases <- rbind(synthetases, temp_2)






# Come up with a list where I save the information of all synthetases having paralogs, so I can put that info in the final dataset
paralogs <- list("YDR341C" = c("YHR091C"),
                 "YHR091C" = c("YDR341C"),
                 "YBR121C" = c("YPR081C"),
                 "YPR081C" = c("YBR121C"))
paralog <- c()
for (i in 1:nrow(synthetases)) {
  gene <- synthetases$Gene.secondaryIdentifier[i]
  if (gene %in% names(paralogs)) {
    paralog <- c(paralog, paralogs[[gene]][1])
  }
  else {
    paralog <- c(paralog, NA)
  }
}
synthetases$paralog <- paralog




# I think this is it for now, save the final version of the dataset
fwrite(synthetases, paste(base_dir, "TSSC/Data/synthetases/trna_synthetases.csv", sep=""))


# Clean up environment
rm(list = ls())


























