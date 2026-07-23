#!/bin/bash
#SBATCH --job-name=Haplotype_phasing_minimap                    
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
