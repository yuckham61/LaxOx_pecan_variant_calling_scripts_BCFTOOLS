#!/bin/bash
#SBATCH --job-name=single_ref_in_silico_variant_call
#SBATCH --partition=batch
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=10
#SBATCH --mem=32G
#SBATCH --time=2-10:00:00
#SBATCH --output=logs/%x_%j.out
#SBATCH --error=logs/%x_%j.err


set -e  #Stop scripts if command fails

##############################################################################################################

# Make variable
OUTDIR="/scratch/ad16566/Khyathi_data"
REFDIR="/scratch/ad16566/Khyathi_data/data/genomes"
REF_FASTA="$REFDIR/Carya_illinoinensis_var_Lakota_Major.mainGenome.fasta"


# Make directory
mkdir -p "$OUTDIR/logs" 
mkdir -p "$OUTDIR/results/in_silico_sam"    
mkdir -p "$OUTDIR/results/in_silico_bam"
mkdir -p "$OUTDIR/results/joint_calls"



###############################################################################################################

# Load module bwa
module load BWA/0.7.18-GCCcore-13.3.0

# Load Samtools
module load SAMtools/1.21-GCC-13.3.0

# Load BCFtools
module load BCFtools/1.23.1-GCC-13.3.0

# Load VCFtools
module load VCFtools/0.1.16-GCC-13.3.0

##############################################################################################################

# Index the complete genome of C_illinoinensisOaxaca_genomics
#bwa index "$REFDIR/Carya_illinoinensis_var_Lakota_Major.mainGenome.fasta"


# After indexing, allignment needs to be done
#for file in "$OUTDIR"/raw_data/*.txt.trimmed_seqs.txt
#do
#Remove path and suffix to get clean output files
#sample=$(basename "$file" .txt.trimmed_seqs.txt)

#bwa mem -t 40 -R "@RG\tID:${sample}\tSM:${sample}" "$REF_FASTA" "$file" > "$OUTDIR/results/in_silico_sam"/${sample}.sam

 # Convert sam file to bam file 
#samtools view -@ 40 -b "$OUTDIR/results/in_silico_sam"/${sample}.sam > "$OUTDIR/results/in_silico_sam"/${sample}.bam 

# Convert sam file to bam file
#samtools sort -@ 40 "$OUTDIR/results/in_silico_sam"/${sample}.bam -o "$OUTDIR/results/in_silico_bam"/${sample}.sorted.bam 

# Sorting the bam files for indexing and visualization
#samtools index -@ 40 "$OUTDIR/results/in_silico_bam"/${sample}.sorted.bam
#done


# List all BAMs (Lakota parent + 272 progeny, all in same directory)
#ls "$OUTDIR"/results/in_silico_bam/*.sorted.bam > "$OUTDIR"/results/joint_calls/all_bams_list.txt

# Joint variant calling across all samples
#bcftools mpileup -f "$REF_FASTA" \
#    -q 30 -Q 20 \
#    --annotate FORMAT/AD,FORMAT/DP \
#    -b "$OUTDIR"/results/joint_calls/all_bams_list.txt \
#    -Ou | \
#bcftools call -mv --ploidy 2 \
#    -Oz -o "$OUTDIR"/results/joint_calls/progeny_joint_calls.vcf.gz

#bcftools index -t "$OUTDIR"/results/joint_calls/progeny_joint_calls.vcf.gz


###############################################################################
# Filtering vcf files
#vcftools --gzvcf "$OUTDIR"/results/joint_calls/progeny_joint_calls.vcf.gz \
#    --remove-indels \
#    --min-alleles 2 --max-alleles 2 \
#    --maf 0.05 \
#    --minQ 20 \
#    --minDP 10 \
#    --max-missing 0.75 \
#    --recode --recode-INFO-all \
#    --out "$OUTDIR"/results/joint_calls/filtered


################################################################################################
# In-silico oaxaca genome coordinate
#grep -v "^#" "$OUTDIR"/results/joint_calls/filtered_progeny_final.vcf | awk 'BEGIN{OFS="\t"} {print $1, $2-1, $2}' > "$OUTDIR"/results/joint_calls/gbs_marker_positions.bed

# Genome-wide targeted haploid calling
bcftools mpileup -f "$REF_FASTA" \
    -q 20 -Q 10 \
    --annotate FORMAT/AD,FORMAT/DP \
    "$OUTDIR"/results/in_silico_oaxaca_bam/Oaxaca_H1.primary.sorted.bam \
    "$OUTDIR"/results/in_silico_oaxaca_bam/Oaxaca_H2.primary.sorted.bam \
    -Ou | \
bcftools call -m --ploidy 1 \
    -Oz -o "$OUTDIR"/results/Oaxaca_all_sites.vcf.gz

bcftools index -t "$OUTDIR"/results/Oaxaca_all_sites.vcf.gz

# Restrict to GBS marker positions as a separate, fast filtering step
bcftools view -R "$OUTDIR"/results/joint_calls/gbs_marker_positions.bed \
    "$OUTDIR"/results/Oaxaca_all_sites.vcf.gz \
    -Oz -o "$OUTDIR"/results/Oaxaca_at_GBS_targeted.vcf.gz

bcftools index -t "$OUTDIR"/results/Oaxaca_at_GBS_targeted.vcf.gz