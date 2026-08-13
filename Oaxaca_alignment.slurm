#!/bin/bash
#SBATCH --job-name=Oaxaca_alignment
#SBATCH --partition=batch
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=40
#SBATCH --mem=64G
#SBATCH --time=2-10:00:00
#SBATCH --output=logs/%x_%j.out
#SBATCH --error=logs/%x_%j.err

set -e

# Make variable
OUTDIR="/scratch/ad16566/Khyathi_data"
REFDIR="/scratch/ad16566/Khyathi_data/data/genomes"
REF_FASTA="$REFDIR/Carya_illinoinensis_var_Lakota_Major.mainGenome.fasta"
OAXACA_DIR="$OUTDIR/reference_genome"
OAXACA_HAP1="$OAXACA_DIR/Carya_illinoinensis_var_87MX3.HAP1.mainGenome.fasta"
OAXACA_HAP2="$OAXACA_DIR/Carya_illinoinensis_var_87MX3.HAP2.mainGenome.fasta"
OAXACA_BAM_DIR="$OUTDIR/results/in_silico_oaxaca_bam"


# Create directories
mkdir -p "$OAXACA_BAM_DIR"
mkdir -p "$OUTDIR/logs"


#Load module minimap2
module load minimap2/2.29-GCCcore-13.3.0

# Load samtools
module load SAMtools/1.21-GCC-13.3.0 

# load BCFtools
module load BCFtools/1.23.1-GCC-13.3.0



# Align Oaxaca Hap1 to Lakota Major reference
#minimap2 -t 40 -ax asm5 \
#    -R "@RG\tID:Oaxaca_H1\tSM:Oaxaca_H1" \
#    "$REF_FASTA" "$OAXACA_HAP1" \
#    > "$OAXACA_BAM_DIR/Oaxaca_H1.sam"

#samtools view -@ 40 -b \
#    "$OAXACA_BAM_DIR/Oaxaca_H1.sam" \
#    -o "$OAXACA_BAM_DIR/Oaxaca_H1.bam"

#samtools sort -@ 40 \
#    -o "$OAXACA_BAM_DIR/Oaxaca_H1.sorted.bam" \
#    "$OAXACA_BAM_DIR/Oaxaca_H1.bam"

#samtools index -@ 20 \
#    "$OAXACA_BAM_DIR/Oaxaca_H1.sorted.bam"

# Oaxaca Hap2

#minimap2 -t 40 -ax asm5 \
#    -R "@RG\tID:Oaxaca_H2\tSM:Oaxaca_H2" \
#    "$REF_FASTA" "$OAXACA_HAP2" \
#    > "$OAXACA_BAM_DIR/Oaxaca_H2.sam"

#samtools view -@ 40 -b \
#    "$OAXACA_BAM_DIR/Oaxaca_H2.sam" \
#    -o "$OAXACA_BAM_DIR/Oaxaca_H2.bam"
#
#samtools sort -@ 40 \
#    -o "$OAXACA_BAM_DIR/Oaxaca_H2.sorted.bam" \
#    "$OAXACA_BAM_DIR/Oaxaca_H2.bam"

#samtools index -@ 20 \
#    "$OAXACA_BAM_DIR/Oaxaca_H2.sorted.bam"


######################################################

# Filter to primary alignment only 
samtools view -@ 40 -b -F 0x100 results/in_silico_oaxaca_bam/Oaxaca_H1.sorted.bam \
    -o results/in_silico_oaxaca_bam/Oaxaca_H1.primary.bam
samtools view -@ 40 -b -F 0x100 results/in_silico_oaxaca_bam/Oaxaca_H2.sorted.bam \
    -o results/in_silico_oaxaca_bam/Oaxaca_H2.primary.bam

samtools sort -@ 40 -o results/in_silico_oaxaca_bam/Oaxaca_H1.primary.sorted.bam results/in_silico_oaxaca_bam/Oaxaca_H1.primary.bam
samtools sort -@ 40 -o results/in_silico_oaxaca_bam/Oaxaca_H2.primary.sorted.bam results/in_silico_oaxaca_bam/Oaxaca_H2.primary.bam

samtools index results/in_silico_oaxaca_bam/Oaxaca_H1.primary.sorted.bam
samtools index results/in_silico_oaxaca_bam/Oaxaca_H2.primary.sorted.bam

