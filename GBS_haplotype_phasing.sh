#!/bin/bash
#SBATCH --job-name=haplotype_phasing                     
#SBATCH --partition=batch                           
#SBATCH --ntasks=1                                  
#SBATCH --cpus-per-task=8                           
#SBATCH --mem=32G                                    
#SBATCH --time=2-12:00:00                              
#SBATCH --output=/scratch/ad16566/Khyathi_data/logs/GO_%j.out
#SBATCH --error=/scratch/ad16566/Khyathi_data/logs/GO_%j.err
#SBATCH --mail-user=ad16566@uga.edj             
#SBATCH --mail-type=END                     

set -e  

#Set output directory variable
OUTDIR="/scratch/ad16566/Khyathi_data/"
REFDIR="/scratch/ad16566/Khyathi_data/reference_genome"
COMBDIR="$OUTDIR/LaxOa_combined_reference"




# Make sub-directory
mkdir -p "$OUTDIR/logs"
mkdir -p "$COMBDIR"
mkdir -p "$OUTDIR/GBS_haplotype_phasing_results/sam"



# Load modules
# Load BWA
module load BWA/0.7.18-GCCcore-13.3.0

#Load SAMtools
module load SAMtools/1.21-GCC-13.3.0


############################################################################################################
# Concate all the chromsome from each of the reference fasta to a single file using [cultivarName]_[hapName]_[ChrID]

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
# Index the complete genome of C_illinoinensisOaxaca_genomics
bwa index "$OUTDIR/LaxOa_combined_reference/combined_reference.fasta"

# Alignment of the GBS to the concatenated reference genome
for file in raw_data/*.txt.trimmed_seqs.txt
do
#Remove path and suffix to get clean output files
sample=$(basename "$file" .txt.trimmed_seqs.txt)

bwa mem -t 8 "$OUTDIR/LaxOa_combined_reference/combined_reference.fasta" "$file" > "$OUTDIR/GBS_haplotype_phasing_results/sam/${sample}.sam"

done

# 