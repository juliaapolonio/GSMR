

reads = Channel.fromPath('/storages/acari/julia.amorim/qtls/eqtl/eQTLGen/format/*.txt.gz')
// reads.dump(tag: "bla")
reference = Channel.fromPath("/storages/acari/julia.amorim/references/plink_bfile/EUR_phase3_chr*")
reference.map { it -> it.getBaseName() }.unique().collectFile(name: "gsmr.input.txt", newLine:true).collect().set { ref_file }
reference.collect().set { collected_ref }
outcome = "/storages/acari/julia.amorim/qtls/SDEP_rsID.txt"

process GCTA_GSMR {
    label 'GCTA_GSMR'
    publishDir "${params.outdir}/results", mode: 'copy'
    container "quay.io/biocontainers/gcta:1.94.1--h9ee0642_0"

    input: 
    path(exposure)
    path(reference)
    path(outcome)
    path(reffile)

    output:
    path "${exposure.getBaseName(2)}_${outcome.baseName}.log", emit: gsmr_log
    path "${exposure.getBaseName(2)}_${outcome.baseName}.gsmr", emit: gsmr_res, optional: true
    path "${exposure.getBaseName(2)}_${outcome.baseName}.eff_plot.gz", emit: gsmr_effplt, optional: true

    script:
    """
    if [[ $exposure == *.gz ]]; then
        gunzip "$exposure"
    fi

    echo  "${exposure.getBaseName(2)} ${exposure.getBaseName(1)}" > ${exposure.getBaseName(2)}.input.txt
    echo "BDEP $outcome" > outcome.txt

    gcta  \
    --mbfile $reffile  \
    --gsmr-file ${exposure.getBaseName(2)}.input.txt outcome.txt \
    --gsmr-direction 0   \
    --gsmr-snp-min 1   \
    --diff-freq 0.5   \
    --gwas-thresh 5e-8   \
    --clump-r2 0.05   \
    --heidi-thresh 0.01   \
    --effect-plot   \
    --out "${exposure.getBaseName(2)}_${outcome.baseName}"
    """
}

workflow {
    result = GCTA_GSMR(reads, collected_ref, outcome, ref_file)
}
