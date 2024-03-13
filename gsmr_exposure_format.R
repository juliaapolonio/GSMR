#!/usr/bin/env Rscript
args = commandArgs(trailingOnly=TRUE)

# Libraries
library(vroom)
library(dplyr)

# Load data
input_path = args[1]
output_path = args[2]

dep <- vroom("/data/home/julia.amorim/scripts/data/outputs/mtag/dep_new_trait_1.txt", col_select = c("SNP", "FRQ"))
mdga1 <- vroom(input_path, skip = 1, col_names = F)

# Correct parsing problems
colnames(mdga1) <- c("ID", "SNP","CHR", "position", "A1", "A2", "b", "se", "p", "N")

# inner join to get frequency info
out <- mdga1 %>%
  inner_join(dep, by = "SNP")

# Select and rename columns
# SNP A1  A2  freq    b   se  p   N
out <- out %>%
  dplyr::select(SNP, A1, A2, freq=FRQ, b, se, p, N) %>%
  distinct(SNP, .keep_all = TRUE)

# Write file
vroom_write(out, output_path)
