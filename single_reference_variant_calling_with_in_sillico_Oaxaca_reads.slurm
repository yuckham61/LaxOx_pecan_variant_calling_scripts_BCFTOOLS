#!/bin/bash
#SBATCH --job-name=single_ref_in_silico_variant_call
#SBATCH --partition=batch
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=20
#SBATCH --mem=8G
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

# Load HTSlib/1.23.1-GCC-13.3.0
module load HTSlib/1.23.1-GCC-13.3.0

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
#bcftools mpileup -f "$REF_FASTA" \
#    -q 20 -Q 10 \
#    -d 250 \
#    -R results/joint_calls/gbs_marker_positions.bed \
#    --annotate FORMAT/AD,FORMAT/DP \
#    results/in_silico_oaxaca_bam/Oaxaca_H1.primary.sorted.bam \
#    results/in_silico_oaxaca_bam/Oaxaca_H2.primary.sorted.bam \
#    -Ou | \
#bcftools call -m --ploidy 1 \
#    -Oz -o results/Oaxaca_at_GBS_targeted.vcf.gz

#bcftools index -t results/Oaxaca_at_GBS_targeted.vcf.gz

###########################################################
# Extract the simple table
#bcftools query -f '%CHROM\t%POS\t%REF\t%ALT[\t%GT]\n' results/Oaxaca_at_GBS_targeted.vcf.gz > results/oaxaca_h1h2_raw.tsv


# Convert the haplotype based information to vcf format
#awk 'BEGIN{OFS="\t"; print "CHROM","POS","REF","ALT","OAXACA_GT"}
#     $5!="." && $6!="." {
#         if ($5 <= $6) gt=$5"/"$6; else gt=$6"/"$5;
#         print $1,$2,$3,$4,gt
#     }' results/oaxaca_h1h2_raw.tsv > results/oaxaca_genotypes.tsv


# Turn this into a proper VCF file
#awk 'BEGIN{OFS="\t"}
#     NR==1 {next}
#     {print $1, $2, ".", $3, $4, ".", ".", ".", "GT", $5}' results/oaxaca_genotypes.tsv > results/Oaxaca_diploid_body.vcf


# Put on the header of the vcf to the vcf of Oaxaca
#bcftools view -h results/joint_calls/filtered_progeny_final.vcf | grep "^##contig" > results/contig_lines.txt

#{
#echo "##fileformat=VCFv4.2"
#cat results/contig_lines.txt
#echo '##FORMAT=<ID=GT,Number=1,Type=String,Description="Genotype">'
#echo -e "#CHROM\tPOS\tID\tREF\tALT\tQUAL\tFILTER\tINFO\tFORMAT\tOaxaca"
#cat results/Oaxaca_diploid_body.vcf
#} > results/Oaxaca_diploid.vcf


# Compress and index
#bgzip results/Oaxaca_diploid.vcf
#tabix -p vcf results/Oaxaca_diploid.vcf.gz

###################################################
# Merge the Oaxaca file to the existing file
#bgzip -c results/joint_calls/filtered_progeny_final.vcf > results/joint_calls/filtered_progeny_final.vcf.gz
tabix -p vcf results/joint_calls/filtered_progeny_final.vcf.gz

bcftools merge -Oz -o results/final_combined.vcf.gz \
    results/joint_calls/filtered_progeny_final.vcf.gz \
    results/Oaxaca_diploid.vcf.gz

bcftools index -t results/final_combined.vcf.gz