#!/bin/bash

# Run GCTA's GSMR from command line

./gcta-1.94.1-linux-kernel-3-x86_64/gcta-1.94.1   \
--mbfile /storages/acari/julia.amorim/references/plink_bfile/gsmr_ref_data.txt   \
--gsmr-file /storages/acari/julia.amorim/qtls/pqtl/format/split/1.txt data/gsmr_outcome_broad_DEP.txt   \
--gsmr-direction 0   \
--gsmr-snp-min 1   \
--diff-freq 0.5   \
--gwas-thresh 5e-8   \
--clump-r2 0.05   \
--heidi-thresh 0.01   \
--effect-plot   \
--out data/gsmr_hillary_result_1
