#!/bin/bash
#SBATCH --job-name=Haplotype_splitting                    
#SBATCH --partition=batch                           
#SBATCH --ntasks=1                                  
#SBATCH --cpus-per-task=4                           
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
HAPDIR="$OUTDIR/GBS_haplotype_phasing_results/haplotype_bam"

# Make sub-directory
mkdir -p "$OUTDIR/logs"
mkdir -p "$COMBDIR"
mkdir -p "$BAMDIR"
mkdir -p "$OUTDIR/GBS_haplotype_phasing_results"
mkdir -p "$FILTDIR"
mkdir -p "$HAPDIR"


# Load modules
# Load BWA
module load BWA/0.7.18-GCCcore-13.3.0

#Load SAMtools
module load SAMtools/1.21-GCC-13.3.0


############################################################################################################
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
# Index the complete genome of C_illinoinensisOaxaca_genomics
#bwa index "$OUTDIR/LaxOa_combined_reference/combined_reference.fasta"

#######################################################################################
#MAP EACH LIBRARY TO THIS COMBINED REFERENCE

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

########################################################################################
# KEEP ONLY READS THAT PERFECTLY HIT EXACTLY ONE OF THE TWO CULTIVAR (ONLY LAKOTA OR OAXACA)

#STEP 3: Filter reads by cultivar specificity
# Keep only reads that are:
# 1. MAPQ > 0 (uniquely mapping)
# 2. No XA tag (no alternative alignments)
# 3. Mapping to only one cultivar (Lakota OR Oaxaca)

#for file in "$BAMDIR"/*.sorted.bam
#do
#    sample=$(basename "$file" .sorted.bam)
#
#    # Lakota-specific reads
#    samtools view -h -q 1 "$file" | \
#        grep -v "XA:Z:" | \
#        awk 'substr($1,1,1)=="@" || $3 ~ /^Lakota/' | \
#        samtools sort -@ 8 -o "$FILTDIR/${sample}.Lakota.bam"
#    samtools index "$FILTDIR/${sample}.Lakota.bam"
#
#    # Oaxaca-specific reads
#    samtools view -h -q 1 "$file" | \
#        grep -v "XA:Z:" | \
#        awk 'substr($1,1,1)=="@" || $3 ~ /^Oaxaca/' | \
#        samtools sort -@ 8 -o "$FILTDIR/${sample}.Oaxaca.bam"
#    samtools index "$FILTDIR/${sample}.Oaxaca.bam"
#
#done


## After separating reads to Lakota and Oaxaca specific, we need to check the files
# Run this in terminal

# Check the files
#ls GBS_haplotype_phasing_results/filtered_bam/ | head -20


# Count total files
# ls GBS_haplotype_phasing_results/filtered_bam/*.bam | wc -l


# Count reads counts for one specific samples
# samtools view -c GBS_haplotype_phasing_results/filtered_bam/GaLxO_0001_s14_PstI_Comb_seqs.Lakota.bam
# samtools view -c GBS_haplotype_phasing_results/filtered_bam/GaLxO_0001_s14_PstI_Comb_seqs.Oaxaca.bam

# Check if files are suspiciously small
#ls -lhrt GBS_haplotype_phasing_results/filtered_bam/*.bam | awk '{print $5, $9}' | sort -k1 -h | head -10

########################################################################################
# SPLITING READS BETWEEN MAHAN and MAJOR of LAKOTA and HAP1 & HAP2 of OAXACA

# We are using MAPQ >= 20, looking at the distribution of map quality reads and spliting lakota reads to Mahan and major, and Hap1 & Hap2 of Oaxaca


#. Get the list of Lakota BAMs 
#We are using MAPQ >= 20, looking at the distribution of map quality reads and spliting lakota reads to Mahan and major, and Hap1 & Hap2 of Oaxaca

# Note: GaLxO_0291 was already processed by accident - it will simply be overwritten, which is fine
#
#for LAKOTA_FILE in "$FILTDIR"/*.Lakota.bam
#do
#    SAMPLE=$(basename "$LAKOTA_FILE" .Lakota.bam)
#    OAXACA_FILE="$FILTDIR/${SAMPLE}.Oaxaca.bam"
#
#    # ── Split Lakota into Major vs Mahan, MAPQ >= 20 ──────────
#    samtools view -h -q 20 "$LAKOTA_FILE" | \
#        awk 'substr($1,1,1)=="@" || $3 ~ /^Lakota_Major/' | \
#        samtools sort -@ 4 -o "$HAPDIR/${SAMPLE}.Major.bam"
#    samtools index "$HAPDIR/${SAMPLE}.Major.bam"
#
#    samtools view -h -q 20 "$LAKOTA_FILE" | \
#        awk 'substr($1,1,1)=="@" || $3 ~ /^Lakota_Mahan/' | \
#        samtools sort -@ 4 -o "$HAPDIR/${SAMPLE}.Mahan.bam"
#    samtools index "$HAPDIR/${SAMPLE}.Mahan.bam"
#
#    # ── Split Oaxaca into Hap1 vs Hap2, MAPQ >= 20 ────────────
#    samtools view -h -q 20 "$OAXACA_FILE" | \
#        awk 'substr($1,1,1)=="@" || $3 ~ /^Oaxaca_Hap1/' | \
#        samtools sort -@ 4 -o "$HAPDIR/${SAMPLE}.Hap1.bam"
#    samtools index "$HAPDIR/${SAMPLE}.Hap1.bam"
#
#    samtools view -h -q 20 "$OAXACA_FILE" | \
#        awk 'substr($1,1,1)=="@" || $3 ~ /^Oaxaca_Hap2/' | \
#        samtools sort -@ 4 -o "$HAPDIR/${SAMPLE}.Hap2.bam"
#    samtools index "$HAPDIR/${SAMPLE}.Hap2.bam"
#
#done

# Again to look at the read counts
# In terminal

# To look at the bam file
# samtools view -c GBS_haplotype_phasing_results/haplotype_bam/GaLxO_0001_s14_PstI_Comb_seqs.Major.bam

# To look at the file size
#ls -la GBS_haplotype_phasing_results/haplotype_bam/*.bam | sort -k5 -n | head -20

# To look at the distribution of reads across genome-wide coverage
#samtools idxstats GBS_haplotype_phasing_results/haplotype_bam/GaLxO_0001_s14_PstI_Comb_seqs.Major.bam


# Even Spacing of reads along each chromosome
#samtools depth GBS_haplotype_phasing_results/haplotype_bam/GaLxO_0001_s14_PstI_Comb_seqs.Major.bam awk '{print $1}' | uniq -c 


# To see where the reads are coming from
#for hap in Major Mahan Hap1 Hap2
#do
#    echo "=== $hap ==="
#    samtools idxstats GBS_haplotype_phasing_results/haplotype_bam/GaLxO_0001_s14_PstI_Comb_seqs.${hap}.bam | grep "Chr12"
#done
#




########################################################################################################################################
