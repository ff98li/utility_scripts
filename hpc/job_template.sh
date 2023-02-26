#!/bin/bash
#SBATCH --gres=gpu:1
#SBATCH --cpus-per-task=32
#SBATCH --mem=32G
#SBATCH --time=1-14:51:48
#SBATCH --job-name=job_template
#SBATCH --output=./job_template.out
# ---------------------------------------------------------------------
START_T=`date +%s`
echo "Starting run at: $START_T"
# ---------------------------------------------------------------------
## Load your modules
module load python/3.9
echo "Python module 3.9 loaded"
source ~/env/bin/activate
echo "Virtual environment activated"
module load cuda
# ---------------------------------------------------------------------
## Run your jobs
WD=`pwd`
echo "Current working directory: $WD"
sleep 19
# ---------------------------------------------------------------------
END_T=`date +%s`
echo "Job finished with exit code $? at: $END_T"
elapsed=$((END_T - START_T))
days=$((elapsed / 86400))
hours=$(( (elapsed / 3600) % 24 ))
minutes=$(( (elapsed / 60) % 60 ))
seconds=$(( elapsed % 60 ))
printf "Time elapsed: %d days %02d:%02d:%02d\n" "$days" "$hours" "$minutes" "$seconds"
