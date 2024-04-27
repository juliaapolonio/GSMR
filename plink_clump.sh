#!/bin/bash

# Manually clump sumstats using plink 1.9

plink --bfile /storages/acari/julia.amorim/references/plink_bfile/1KG_phase3_EUR  \
--clump broad_depression_clumping_sumstats.txt \
--clump-field Pvalue \
--clump-p1 5e-8 \
--clump-p2 5e-8 \
--clump-r2 0.01 \
--clump-kb 1000 \
--out gwas_BD
