#!/bin/bash
#SBATCH --job-name=re_sam2bam
#SBATCH --partition=batch
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=20
#SBATCH --mem=32G
#SBATCH --time=10:00:00
#SBATCH --output=logs/%x_%j.out
#SBATCH --error=logs/%x_%j.err


set -e  #Stop scripts if command fails

##############################################################################################################

# Make folder
mkdir -p reference_results








###############################################################################################################

# Load module
module load minimap2/2.28-GCCcore-13.2.0

# Load Samtools
module load SAMtools/1.21-GCC-13.3.0


##############################################################################################################

# Run minimap2 alignment

minimap2 -x asm5 -t 20 \
	reference_genome/Carya_illinoinensis_var_87MX3.HAP1.mainGenome.fasta \
	reference_genome/Carya_illinoinensis_var_87MX3.HAP2.mainGenome.fasta | samtools sort -@ 10 -o reference_results/87MX3Hap2_to_Hap1.sorted.bam


