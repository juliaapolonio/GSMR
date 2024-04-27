#!/bin/bash

# Since each exposure x outcome pair is run at a time, the result files are separated. Use this to join

# Add heading Exposure        Outcome bxy     se      p       nsnp to file
echo -e "Exposure\tOutcome\tbxy\tse\tp\tnsnp" > "results_bdep_eqtlgen.txt"

# Add second line of all .gsmr files into a single document
for file in ./*.gsmr; do sed -n '2p' "$file" >> "results_bdep_eqtlgen.txt"; done
