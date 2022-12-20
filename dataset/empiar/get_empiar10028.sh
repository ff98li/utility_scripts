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

DATA_DIR=~/scratch/data/cryoem ## change to your data directory

if [ ! -d "${DATA_DIR}/empiar10028" ]; then
    mkdir -p $DATA_DIR/empiar10028
fi
echo "====== Downloading published filtered particles ======"
wget --show-progress https://github.com/zhonge/cryodrgn_empiar/blob/main/empiar10028/inputs/filtered.ind.pkl?raw=true \
    -O $DATA_DIR/empiar10028/filtered_ind.pkl
echo "================ Downloading pose file ==============="
wget --show-progress https://github.com/zhonge/cryodrgn_empiar/blob/main/empiar10028/inputs/cryosparc_P11_J4_003_particles.cs?raw=true \
    -O $DATA_DIR/empiar10028/cryosparc_P11_J4_003_particles.cs
echo "================= Downloading raw mrc ================"
wget --show-progress -m -q -nd ftp://ftp.ebi.ac.uk/empiar/world_availability/10028/data/Particles/shiny_2sets.star \
    -P $DATA_DIR/empiar10028

wget --show-progress -r --no-parent -m -q -nd  ftp://ftp.ebi.ac.uk/empiar/world_availability/10028/data/Particles/MRC_0601/\
    -P $DATA_DIR/empiar10028/MRC_0601

wget --show-progress -r --no-parent -m -q -nd  ftp://ftp.ebi.ac.uk/empiar/world_availability/10028/data/Particles/MRC_1901/\
    -P $DATA_DIR/empiar10028/MRC_1901

echo
# ---------------------------------------------------------------------
echo "Job finished with exit code $? at: `date`"
