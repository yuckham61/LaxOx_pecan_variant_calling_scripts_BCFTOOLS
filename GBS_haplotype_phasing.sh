#!/bin/bash
#SBATCH --job-name=BWA_alignment                     
#SBATCH --partition=batch                           
#SBATCH --ntasks=1                                  
#SBATCH --cpus-per-task=2                           
#SBATCH --mem=8G                                    
#SBATCH --time=2-12:00:00                              
#SBATCH --output=/scratch/ad16566/Khyathi_data/logs/GO_%j.out
#SBATCH --error=/scratch/ad16566/Khyathi_data/logs/GO_%j.err
#SBATCH --mail-user=ad16566@uga.edj             
#SBATCH --mail-type=END                     

set -e  

#Set output directory variable
OUTDIR="/scratch/ad16566/Khyathi_data"
REFDIR="/scratch/ad16566/Khyathi_data/reference_genome"
COMBDIR="$OUTDIR/LaxOa_combined_reference"
BAMDIR="$OUTDIR/GBS_haplotype_phasing_results/bam"
FILTDIR="$OUTDIR/GBS_haplotype_phasing_results/filtered_bam"


# Make sub-directory
mkdir -p "$OUTDIR/logs"
mkdir -p "$COMBDIR"
mkdir -p "$BAMDIR"
mkdir -p "$OUTDIR/GBS_haplotype_phasing_results"
mkdir -p "$FILTDIR"

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
#bwa index "$OUTDIR/LaxOa_combined_reference/combined_reference.fasta"

# Alignment of the GBS to the concatenated reference genome
#for file in "$OUTDIR/raw_data"/*.txt.trimmed_seqs.txt
#do
#Remove path and suffix to get clean output files
#sample=$(basename "$file" .txt.trimmed_seqs.txt)
#
#    bwa mem -t 8 \
#        "$COMBDIR/combined_reference.fasta" \
#        "$file" | \
#        samtools sort -@ 8 -o "$BAMDIR/${sample}.sorted.bam"
#
#    samtools index "$BAMDIR/${sample}.sorted.bam"
#
#done

### After the bam files are created
# RUN THIS IN TERMINAL

# To view the file
# samtools view GBS_haplotype_phasing_results/bam/GaLxO_0001_s14_PstI_Comb_seqs.sorted.bam| head -n 30


#  need to make sure the length of bam files are not abnormally low
#ls -lhrt GBS_haplotype_phasing_results/bam/*.bam | awk '{print $5, $9}' | sort -k1 -h | head -10
# Everything is good interms of length


# Need to check the stats of alignment using SAMtools
#samtools flagstat GBS_haplotype_phasing_results/bam/GaLxO_0001_s14_PstI_Comb_seqs.sorted.bam

# Total number of reads in the bam file
#samtools view -c GBS_haplotype_phasing_results/bam/GaLxO_0001_s14_PstI_Comb_seqs.sorted.bam

# Total number with no multiple alignment "MAPQ > 0:"
# samtools view -c -q 1 GBS_haplotype_phasing_results/bam/GaLxO_0001_s14_PstI_Comb_seqs.sorted.bam

# Total number with no multiple alignment "MAPQ > 0:" and no XA tag:"
# samtools view -q 1 GBS_haplotype_phasing_results/bam/GaLxO_0001_s14_PstI_Comb_seqs.sorted.bam | grep -v "XA:Z:" | wc -l


#STEP 3: Filter reads by cultivar specificity
# Keep only reads that are:
# 1. MAPQ > 0 (uniquely mapping)
# 2. No XA tag (no alternative alignments)
# 3. Mapping to only one cultivar (Lakota OR Oaxaca)

for file in "$BAMDIR"/*.sorted.bam
do
    sample=$(basename "$file" .sorted.bam)

    # Lakota-specific reads
    samtools view -h -q 1 "$file" | \
        grep -v "XA:Z:" | \
        awk 'substr($1,1,1)=="@" || $3 ~ /^Lakota/' | \
        samtools sort -@ 8 -o "$FILTDIR/${sample}.Lakota.bam"
    samtools index "$FILTDIR/${sample}.Lakota.bam"

    # Oaxaca-specific reads
    samtools view -h -q 1 "$file" | \
        grep -v "XA:Z:" | \
        awk 'substr($1,1,1)=="@" || $3 ~ /^Oaxaca/' | \
        samtools sort -@ 8 -o "$FILTDIR/${sample}.Oaxaca.bam"
    samtools index "$FILTDIR/${sample}.Oaxaca.bam"

done