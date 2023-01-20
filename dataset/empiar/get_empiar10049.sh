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

DATA_DIR=~/scratch/data/cryoem

if [ ! -d "${DATA_DIR}/empiar10049" ]; then
    mkdir -p $DATA_DIR/empiar10049
fi
echo "====== Downloading CTF data ======"
wget --show-progress https://github.com/zhonge/cryodrgn_empiar/blob/main/empiar10049/inputs/ctf.pkl?raw=true \
    -O $DATA_DIR/empiar10049/ctf.pkl
echo "================ Downloading pose file ==============="
wget --show-progress https://github.com/zhonge/cryodrgn_empiar/blob/main/empiar10049/inputs/cryosparc_P53_J26_006_particles.cs?raw=true \
    -O $DATA_DIR/empiar10049/cryosparc_P53_J26_006_particles.cs
wget --show-progress https://github.com/zhonge/cryodrgn_empiar/blob/main/empiar10049/inputs/poses.pkl?raw=true \
    -O $DATA_DIR/empiar10049/poses.pkl
echo "================= Downloading raw mrc ================"
wget --show-progress -r -x -nH --cut-dirs=3 --no-parent \
    ftp://ftp.ebi.ac.uk/empiar/world_availability/10049/data/ \
    -P $DATA_DIR/empiar10049/

echo
# ---------------------------------------------------------------------
echo "Job finished with exit code $? at: `date`"
