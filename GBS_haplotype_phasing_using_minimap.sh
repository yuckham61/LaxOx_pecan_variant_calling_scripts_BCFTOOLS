#!/bin/bash
#SBATCH --job-name=Haplotype_phasing_minimap                    
#SBATCH --partition=batch                           
#SBATCH --ntasks=1                                  
#SBATCH --cpus-per-task=8                           
#SBATCH --mem=32G                                    
#SBATCH --time=2-12:00:00                             
#SBATCH --output=/scratch/ad16566/Khyathi_data/logs/GO_%j.out
#SBATCH --error=/scratch/ad16566/Khyathi_data/logs/GO_%j.err
#SBATCH --mail-user=ad16566@uga.edu            
#SBATCH --mail-type=END                     

set -e  


#Set output directory variable
OUTDIR="/scratch/ad16566/Khyathi_data"
REFDIR="/scratch/ad16566/Khyathi_data/reference_genome"
COMBDIR="$OUTDIR/LaxOa_combined_reference"
RAWDIR="$OUTDIR/raw_data"
PAF="$OUTDIR/minimap2_results/paf"
FILTPAF="$OUTDIR/minimap2_results/filtered_paf"
MARKERDIR="$OUTDIR/minimap2_results/markers"

# Make sub-directory
mkdir -p "$OUTDIR/logs"
mkdir -p "$FILTPAF"
mkdir -p "$MARKERDIR"

# Load modules
# Load minimap
module load minimap2/2.29-GCCcore-13.3.0



# Got bunch of instruction from DR. Lovell, and started working with this pipeline on 07/23/2026
# Previously used BWA mem for alignment, but should have used minimap
#################################################################################################################################
# COMBINE ALL 4 GENOME ASSEMBLIES TO ONE FASTA using [cultivarName]_[hapName]_[ChrID]

#OUT="$COMBDIR/combined_reference.fasta"
#> "$OUT"

#awk '/^>/ { print ">Lakota_Major_" substr($0,2); next } { print }' \
#    "$REFDIR/Carya_illinoinensis_var_Lakota_Major.mainGenome.fasta" >> "$OUT"

#awk '/^>scaffold/ { skip=1; next }
#     /^>Chr/      { skip=0; print ">Lakota_Mahan_" substr($0,2); next }
#     !skip        { print }' \
#    "$REFDIR/Carya_illinoinensis_var_Lakota_Mahan.mainGenome.fasta" >> "$OUT"
#
#awk '/^>scaffold/ { skip=1; next }
#     /^>Chr/      { skip=0; print ">Oaxaca_Hap1_" substr($0,2); next }
#     !skip        { print }' \
#    "$REFDIR/Carya_illinoinensis_var_87MX3.HAP1.mainGenome.fasta" >> "$OUT"
#
#awk '/^>scaffold/ { skip=1; next }
#     /^>Chr/      { skip=0; print ">Oaxaca_Hap2_" substr($0,2); next }
#     !skip        { print }' \
#    "$REFDIR/Carya_illinoinensis_var_87MX3.HAP2.mainGenome.fasta" >> "$OUT"

## At the end of this, there should be the single reference file with [cultivarName]_[hapName]_[ChrID]
# I have checked the sequence number, scaffaold and header, everything looks good while concating. 


# Index the concatenated reference file
# Index the complete genome of C_illinoinensisOaxaca_genomics using minimap
#minimap2 -x sr -t 8 -d "$COMBDIR/combined_reference.mmi" "$COMBDIR/combined_reference.fasta"


###################################################################################################################
# Align the reads to the combined reference fasta
#ALIGN GBS READS TO COMBINED REFERENCE USING MINIMAP2
# -x sr = short read preset
# -p .99 = only report secondary alignments within 99% of best score
# Filter the reads on the basis of mapping quality
# Filter: keep only MAPQ == 60 (uniquely mapping reads)
#Keeping the secondary alignment

for file in "$RAWDIR"/*.txt.trimmed_seqs.txt
do
    sample=$(basename "$file" .txt.trimmed_seqs.txt)

    minimap2 -x sr -p .99 -t 8 \
        "$COMBDIR/combined_reference.mmi" \
        "$file" | \
        awk '$12 == 60' \
        > "$PAF/${sample}.filtered.paf"

done



# and removing all the reads with secondary alignments

#for file in "$RAWDIR"/*.txt.trimmed_seqs.txt
#do
#    sample=$(basename "$file" .txt.trimmed_seqs.txt)
#
#    minimap2 -x sr -p .99 -t 8 \
#        "$COMBDIR/combined_reference.mmi" \
#        "$file" | \
#        awk '$12 == 60 && $0 !~ /tp:A:S/' \
#        > "$FILTPAF/${sample}.filtered.paf"
#
#done


# In TERMINAL
# ls -lhrt minimap2_results/filtered_paf/*.paf | awk '{print $5, $9}' | sort -k1 -h | head -10

# To look at haplotype distribution in one sample
#awk '{print $6}' minimap2_results/filtered_paf/GaLxO_0001_s14_PstI_Comb_seqs.filtered.paf | \
#    sed 's/_Chr[0-9]*//' | \
#    sort | uniq -c | sort -rn

##############################################################################################################
# Convert each filtered PAF to a marker table
# Columns: sample, haplotype, chromosome, position
# Deduplicated and sorted by chromosome and position
#{This is breaking the reference alignment into chromosome and haplotype, and then sorting them into order from name, haplotype, chr, and numerical position }
#for file in "$FILTPAF"/*.filtered.paf
#do
#    sample=$(basename "$file" .filtered.paf)
#
#    awk '{
#        split($6, a, "_Chr")
#        print sample "\t" a[1] "\t" "Chr" a[2] "\t" $8
#    }' sample="$sample" "$file" | \
#    sort -k1,1 -k2,2 -k3,3 -k4,4n | \
#    uniq \
#    > "$MARKERDIR/${sample}.markers.txt"
#
#    done


    # Combine all samples into one big marker table with header
#echo -e "sample\thaplotype\tchr\tposition" > "$MARKERDIR/all_samples_markers.txt"
#cat "$MARKERDIR"/*.markers.txt >> "$MARKERDIR/all_samples_markers.txt"

## In TERMINAL
# Count the number of total marker
#wc -l minimap2_results/markers/all_samples_markers.txt


# How many unique position genome-wide
#awk 'NR>1 {print $3"\t"$4}' minimap2_results/markers/all_samples_markers.txt | \
#  sort -k1,1 -k2,2n | uniq | wc -l

# Count how many markers per chromosome on average 
#awk 'NR>1 {print $3}' minimap2_results/markers/all_samples_markers.txt | \
#    sort | uniq -c | sort -k2,2

# per Haplotypes
#awk 'NR>1 {print $2}' minimap2_results/markers/all_samples_markers.txt | \
#    sort | uniq -c 

#####################################################################################