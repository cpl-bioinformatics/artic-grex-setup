#!/bin/bash

#SBATCH --job-name=covid_ncovtools
#SBATCH --ntasks=1
#SBATCH --nodes=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=32G
#SBATCH --time=20:00
#SBATCH --partition=skylake

start_time=$(date +%s)
echo "Starting run at: date"

module load CCEnv; module load StdEnv/2023; module load apptainer; module load nextflow;

PROJECT_DIR="/home/jodiqiao/projects/github/ncov2019-artic-nf"
DATA_DIR="/home/jodiqiao/projects/data"

export NXF_SINGULARITY_CACHEDIR=${PROJECT_DIR}/work/singularity

nextflow run ${PROJECT_DIR}/main.nf \
    -profile singularity \
    --medaka \
    --medaka_model r1041_e82_400bps_sup_v4.3.0 \
    --prefix "run" \
    --basecalled_fastq ${DATA_DIR}/ayo_pipeline_testfiles/ \
    --sequencing_technology "GridION" \
    --scheme_version "freed" \
    --min_length 800 \
    --max_length 1600 \
    --outdir ${PROJECT_DIR}/results/ \
    -resume

cd ${PROJECT_DIR}/results
git clone https://github.com/jts/ncov-tools.git
cd ncov-tools
git clone https://github.com/phac-nml/primer-schemes.git
cp ${PROJECT_DIR}/work/singularity/ncov-config/config.yaml ${PROJECT_DIR}/results/ncov-tools/config.yaml

echo "Ncov tools build_snpeff_db step:"

apptainer exec --fakeroot --bind $HOME/:$HOME/ --overlay ${PROJECT_DIR}/work/singularity/overlay.img ${PROJECT_DIR}/work/singularity/ncovtools.sif snakemake -s workflow/Snakefile --cores 1 build_snpeff_db

echo "Ncov tools all_final_report step:"

apptainer exec --fakeroot --bind $HOME/:$HOME/ --overlay ${PROJECT_DIR}/work/singularity/overlay.img ${PROJECT_DIR}/work/singularity/ncovtools.sif snakemake -s workflow/Snakefile all_final_report --cores 1

end_time=$(date +%s)
elapsed_time=$((end_time - start_time))

# Calculate hours, minutes, and seconds
hours=$((elapsed_time / 3600))
minutes=$(( (elapsed_time % 3600) / 60 ))
seconds=$((elapsed_time % 60))

echo "Program finished with exit code $? at: date"
printf "Elapsed time: %02d:%02d:%02d\n" $hours $minutes $seconds