#!/bin/bash
#SBATCH --job-name=re_sam2bam
#SBATCH --partition=batch
#SBATCH --nodes=1
#SBATCH --ntasks=4
#SBATCH --cpus-per-task=20
#SBATCH --mem=32G
#SBATCH --time=2-10:00:00
#SBATCH --output=logs/%x_%j.out
#SBATCH --error=logs/%x_%j.err


set -e  #Stop scripts if command fails

# Set the URL of the genome FASTA
#genome_url="ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCA/016/808/215/GCA_016808215.1_C.illinoinensisOaxaca_v1/GCA_016808215.1_C.illinoinensisOaxaca_v1_genomic.fna.gz"


#To download the genome from the url
#wget -O data/genomes/C_illinoinensisOaxaca_genomic.fna.gz $genome_url

# Decompress the genome
#gunzip data/genomes/C_illinoinensisOaxaca_genomic.fna.gz

# Make folder
#mkdir data/genomes
mkdir -p results/re_sam
mkdir -p logs
mkdir -p results/bam
mkdir -p results/bcf
mkdir -p results/vcf

# Load all the required modules

# Load BWA
module load BWA/0.7.18-GCCcore-13.3.0

# Load SAMtools
module load SAMtools/1.21-GCC-13.3.0

#Load bcftools
module load BCFtools/1.21-GCC-13.3.0

# Index the complete genome of C_illinoinensisOaxaca_genomics
bwa index data/genomes/Carya_illinoinensis_var_87MX3.HAP1.mainGenome.fasta

# After indexing, allignment needs to be done
for file in raw_data/*.txt.trimmed_seqs.txt
do

#Remove path and suffix to get clean output files
sample=$(basename "$file" .txt.trimmed_seqs.txt)

echo "processing $sample"

bwa mem -t 40 data/genomes/Carya_illinoinensis_var_87MX3.HAP1.mainGenome.fasta "$file" > results/re_sam/${sample}.sam


# Convert sam file to bam file
samtools view -@40 -b results/re_sam/$sample.sam > results/bam/$sample.bam


# Sorting the bam files for indexing and visualization
samtools sort -@40 results/bam/${sample}.bam -o results/bam/${sample}.sorted.bam

# Indexing the sorted bam files
samtools index results/bam/${sample}.sorted.bam

# Generate bcf file
bcftools mpileup -O b -o results/bcf/${sample}.bcf -f data/genomes/Carya_illinoinensis_var_87MX3.HAP1.mainGenome.fasta results/bam/${sample}.sorted.bam

# Generate vcf file
bcftools call --ploidy 2 -m -v -o results/vcf/${sample}.vcf results/bcf/${sample}.bcf


done 



