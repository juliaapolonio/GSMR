
# Add second line of all .gsmr files into a single document
for file in ./*.gsmr; do sed -n '2p' "$file" >> "results_hillary.txt"; done

# Add heading Exposure        Outcome bxy     se      p       nsnp to file
echo -e "Exposure\tOutcome\tbxy\tse\tp\tnsnp" | cat - "results_hillary.txt" > "results_hillary.txt"