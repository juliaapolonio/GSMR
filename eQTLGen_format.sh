#!/bin/bash

# Format eQTLGen data to GSMR format

## Download eQTL files 
# Blood full cis-eQTLs from https://www.eqtlgen.org/phase1.html Both "significant cis-eQTLs" and "SMR-formatted cis-eQTLs" are needed
wget -P /data/home/julia.amorim/scripts/data/qtls/eqtl "https://molgenis26.gcc.rug.nl/downloads/eqtlgen/cis-eqtl/2019-12-11-cis-eQTLsFDR0.05-ProbeLevel-CohortInfoRemoved-BonferroniAdded.txt.gz"
wget -P /data/home/julia.amorim/scripts/data/qtls/eqtl "https://molgenis26.gcc.rug.nl/downloads/eqtlgen/cis-eqtl/SMR_formatted/cis-eQTL-SMR_20191212.tar.gz"

## Format eQTLs from .BEDS to sumstats
tar -xvf cis-eQTL-SMR_20191212.tar.gz
gunzip 2019-12-11-cis-eQTLsFDR0.05-ProbeLevel-CohortInfoRemoved-BonferroniAdded.txt.gz
gunzip cis-eQTLs-full_eQTLGen_AF_incl_nr_formatted_20191212.new.txt_besd-dense.esi.gz

# Add AF from original .esi file to eQTLGen file
mv cis-eQTLs-full_eQTLGen_AF_incl_nr_formatted_20191212.new.txt_besd-dense.esi   \
cis-eQTLs-full_eQTLGen_AF_incl_nr_formatted_20191212.new.txt_besd-dense.esi_rsID

awk '(NR==FNR){a[$2]=$0; next}
                   {
                      if(a[$2]){print $0,a[$2]}
                      else{print $0,"no match"}
                   }' cis-eQTLs-full_eQTLGen_AF_incl_nr_formatted_20191212.new.txt_besd-dense.esi_rsID   \
                   2019-12-11-cis-eQTLsFDR0.05-ProbeLevel-CohortInfoRemoved-BonferroniAdded.txt | sed '/no match/d' > ciseQTLGen_freq_tmp.txt

# Calculate beta and se 
awk '{$23=$7/sqrt(2*$22*(1-$22)*($13+$7^2)); $24=1/sqrt(2*$22*(1-$22)*($13+$7^2));   \
print "chr" $3 ":" $4 ":" $6 ":" $5 "\t" $5 "\t" $6 "\t" $22 "\t" $23 "\t" $24 "\t" $1 "\t" $13 "\t" $8 "\t" $9}'   \
ciseQTLGen_freq_tmp.txt  > ciseQTLGen_freq_tmp2.txt 

# Add column names
echo -e "SNP\tA1\tA2\tfreq\tb\tse\tp\tN\tensemble\tgenesymbol" | cat - ciseQTLGen_freq_tmp2.txt   \
| tr ' ' '\t' | cut -f1,2,3,4,5,6,7,8,9,10  > ciseQTLGen_freq_GSMR_b37.txt

rm *tmp*

# Split by gene name, process by first gene letter and generate one GSMR file for each gene. It may take a while to run
cat ciseQTLGen_freq_GSMR_b37.txt | awk '{print > $10"_eQTLGen_b37_GSMR.txt"}'

for filename in *_eQTLGen_b37_GSMR.txt
 do
    b=${filename%%_eQTLGen_b37_GSMR.txt}
     cat $filename | awk '{print $1 "\t" $2 "\t" $3 "\t" $4 "\t" $5 "\t" $6 "\t" $7 "\t" $8}' | tr 'e ' 'E' | sed 's/^chr\|%$//g'  \
     | awk '$1!="NA"' |awk '$2!="NA"' | awk '$3!="NA"' | awk '$4!="NA"' | awk '$5!="NA"' | awk '$6!="NA"'   \
     | awk '$7!="NA"' | awk '$5!=0' | awk '$6!=0' | awk '($7 + 0) <1E-5' | tr ' ' '\t' > "$b"_tmp1.txt
 done

for filename in *_tmp1.txt 
 do
    b=${filename%%_tmp1.txt}
    echo -e "SNP\tA1\tA2\tfreq\tb\tse\tp\tN" | cat - $filename | cut -d $'\t' -f1-8 | awk '!seen[$1,$2,$3]++' | sed "s/^chr//g" | gzip > "$b"_GSMR.txt.gz   
 done

# # Create "eQTLGen_exposure_variants_extract.txt" with a list of all variants present across all files and remove duplicates
# gunzip -c *GSMR.txt.gz | awk '!duplicate[$1]++' | awk '{ print $1}'|  sed '1d' > eQTLGen_exposure_variants_extract.txt

# # Extract above list from outcomes (i.e. IBD, CD, UC)
#  for filename in ../../BDEP_format*  
#   do
#      b=${filename%%_format.txt}
#      echo -e "SNP\tA1\tA2\tfreq\tb\tse\tp\tn" | cat - <(cat $filename | grep -w -f eQTLGen_exposure_variants_extract.txt)    \
#      > "$b"_GSMR_eQTLGen_DEP.txt          
#   done

rm *tmp*
rm *_eQTLGen_b37_GSMR.txt

# Change SNP format from chr:pos:a1:a2 format to rsID
for filename in *.txt*
 do Rscript ~/scripts/r/format_eqtlgen.R ./$filename ./format/$filename
done

# Split "gsmr_exposure.txt" in lots of files of a given chunk size according to your RAM limit
# Change lines_per_file according to the chunk size you prefer (usage is approx 20GB of RAM per file):
input_file="gsmr_exposure_eqtl.txt"
lines_per_file=10

# Split the file
split --lines=$lines_per_file "$input_file" "$input_file.part"

# Rename the output files
count=1
for file in "$output_prefix"*
do
    mv "$file" "$output_prefix$count.txt"
    ((count++))
done
