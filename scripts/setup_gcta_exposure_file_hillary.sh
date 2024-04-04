#!/bin/bash

#----------------------- Download and format Hillary pQTL data

## Download pQTL files from this study: https://www.nature.com/articles/s41467-019-11177-x
# Files can be found on this link: https://datashare.ed.ac.uk/handle/10283/3408
wget -P data/ "https://datashare.ed.ac.uk/download/DS_10283_3408.zip"

unzip DS_10283_3408.zip
mv ./* pqtl/
rm DS_10283_3408.zip
rm license_text
rm READme_GWAS.pdf

cd pqtl/

## Format all pQTLs to GCTA-COJO format:
# SNP A1  A2  freq    b   se  p   N
dir="./"
for filename in "$dir"/*
 do Rscript ~/scripts/r/gsmr_exposure_format.R $dir/$filename $dir/format/$filename
done


#----------------------- Create GSMR input

cd format/

## Create "gsmr_exposure.txt" with path to exposure files
dir="./"
for filename in "$dir"/*
do 
    file=$(basename "$filename")  # Extracting just the filename
    abs_path=$(realpath "$dir$file")  # Getting the absolute path
    echo "$file $abs_path" >> gsmr_exposure_hillary.txt
done

mkdir split
cd split/

## Split "gsmr_exposure.txt" in lots of files of a given chunk size according to your RAM limit
# Change lines_per_file according to the chunk size you prefer (usage is approx 20GB of RAM per file):
input_file="gsmr_exposure_hillary.txt"
lines_per_file=5

# Split the file
split --lines=$lines_per_file "$input_file" "$input_file.part"

# Rename the output files 
count=1
for file in "$output_prefix"*part*
do
    mv "$file" "$output_prefix$count.txt"
    ((count++))
done