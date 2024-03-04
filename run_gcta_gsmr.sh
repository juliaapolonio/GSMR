#f.Run GSMR for eQTL
./gcta-1.94.1-linux-kernel-3-x86_64/gcta-1.94.1   \
--mbfile /data/home/julia.amorim/scripts/data/references/plink_bfile/gsmr_ref_data.txt   \
--gsmr-file /data/home/julia.amorim/scripts/data/references/splitted_exposure_eqtlgen/2.txt /data/home/julia.amorim/scripts/data/references/gsmr_outcome_broad_DEP.txt   \
--gsmr-direction 0   \
--gsmr-snp-min 1   \
--diff-freq 0.5   \
--gwas-thresh 5e-8   \
--clump-r2 0.05   \
--heidi-thresh 0.01   \
--effect-plot   \
--out /data/home/julia.amorim/scripts/data/outputs/gsmr/gsmr_eQTLGen_result_2