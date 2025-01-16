 #!/bin/bash

module load CCEnv; module load StdEnv/2023; module load apptainer;

# Array of image names and corresponding yml files
declare -A envs=(
    ["artic"]="artic.yml"
    ["extras"]="extras.yml"
    ["irida_uploader"]="irida_uploader.yml"
    ["ncovtools"]="ncovtools.yml"
    ["nextclade"]="nextclade.yml"
    ["snpdist"]="snpdist.yml"
)

# Loop through each image
for env in "${!envs[@]}"; do
    # Copy the appropriate yml file to environment.yml
    cp "${envs[$env]}" environment.yml
    
    # Build the Singularity image using apptainer
    apptainer build --fakeroot "${env}.sif" base-conda.def
    
    echo "Built ${env}.sif successfully."
done