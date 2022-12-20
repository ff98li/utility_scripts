#!/bin/bash
# ---------------------------------------------------------------------
echo "Current working directory: `pwd`"
echo "Starting run at: `date`"
# ---------------------------------------------------------------------
## get pre-refined poses from cryoDRGN repo
echo "Downloading the raw data. This may take a couple of hours!"
echo
echo
echo "======================================================"

$DATA_DIR=~/scratch/data ## change to your data directory

if [ ! -d $DATA_DIR/empiar10076 ]; then
    mkdir -p $DATA_DIR/empiar10076
fi
echo "====== Downloading published filtered particles ======"
wget --show-progress https://github.com/zhonge/cryodrgn_empiar/blob/main/empiar10076/inputs/filtered.ind.pkl?raw=true \
    -O $DATA_DIR/empiar10076/filtered_ind.pkl
echo "================ Downloading pose file ==============="
wget --show-progress https://github.com/zhonge/cryodrgn_empiar/blob/main/empiar10076/inputs/cryosparc_P4_J33_004_particles.cs?raw=true \
    -O $DATA_DIR/empiar10076/cryosparc_P4_J33_004_particles.cs
echo "================= Downloading raw mrc ================"
wget --show-progress -m -q -nd ftp://ftp.ebi.ac.uk/empiar/world_availability/10076/data/L17Combine_weight_local.mrc \
    -O $DATA_DIR/empiar10076/L17Combine_weight_local.mrcs
echo "================= Downloading EM par ================"
wget --show-progress -m -q -nd https://ftp.ebi.ac.uk/empiar/world_availability/10076/data/Parameters.star \
    -O $DATA_DIR/empiar10076/Parameters.star
echo
# ---------------------------------------------------------------------
echo "Job finished with exit code $? at: `date`"
