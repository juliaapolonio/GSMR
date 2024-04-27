#!/bin/bash

# Format 1000Genomes pfile to GSMR reference

#### Source of 1000 Genomes link: https://dougspeed.com/1000-genomes-project/
#### Source of code: https://cran.r-project.org/web/packages/snpsettest/vignettes/reference_1000Genomes.html

# The links in here may be changed in future
# "-O" to specify output file name
wget -O all_phase3.psam "https://www.dropbox.com/s/6ppo144ikdzery5/phase3_corrected.psam"
wget -O all_phase3.pgen.zst "https://www.dropbox.com/s/y6ytfoybz48dc0u/all_phase3.pgen.zst"
wget -O all_phase3.pvar.zst "https://www.dropbox.com/s/odlexvo8fummcvt/all_phase3.pvar.zst"

# Decompress pgen.zst to pgen
plink2 --zst-decompress all_phase3.pgen.zst > all_phase3.pgen

# "vzs" modifier to directly operate with pvar.zst
# "--chr 1-22" excludes all variants not on the listed chromosomes
# "--output-chr 26" uses numeric chromosome codes
# "--max-alleles 2": PLINK 1 binary does not allow multi-allelic variants
# "--rm-dup" removes duplicate-ID variants
# "--set-missing-var-id" replaces missing IDs with a pattern
plink2 --pfile all_phase3 vzs \
       --chr 1-22 \
       --output-chr 26 \
       --max-alleles 2 \
       --rm-dup exclude-mismatch \
       --set-missing-var-ids '@_#_$1_$2' \
       --make-pgen \
       --out all_phase3_autosomes
# Prepare sub-population filter file
awk 'NR == 1 || $5 == "EUR" {print $1}' all_phase3.psam > EUR_1kg_samples.txt

# Generate sub-population fileset
plink2 --pfile all_phase3_autosomes \
       --keep EUR_1kg_samples.txt \
       --make-pgen \
       --out EUR_phase3_autosomes

# pgen to bed
# "--maf 0.005" remove most monomorphic SNPs 
# (still may have some when all samples are heterozyguous -> maf=0.5)
plink2 --pfile EUR_phase3_autosomes \
       --maf 0.005 \
       --make-bed \
       --out EUR_phase3_autosomes
       
# Split bed/bim/fam by chromosome
for i in {1..22}
do plink2 --bfile EUR_phase3_autosomes --chr $i --make-bed --out EUR_phase3_chr$i
done

#----------------------- Create GCTA input file
# Create "gsmr_ref_data.txt" with path to reference files
for i in {1..22}
do echo "/data/home/julia.amorim/scripts/data/references/plink_bfile/EUR_phase3_chr$i" >> /data/home/julia.amorim/scripts/data/references/plink_bfile/gsmr_ref_data.txt
done
