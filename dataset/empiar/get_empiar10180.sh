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

if [ ! -d "${DATA_DIR}/empiar10180" ]; then
    mkdir -p $DATA_DIR/empiar10180
fi
echo "====== Downloading published filtered particles ======"
wget --show-progress https://github.com/zhonge/cryodrgn_empiar/raw/main/empiar10180/inputs/filtered.ind.pkl?raw=true \
    -O $DATA_DIR/empiar10180/filtered_ind.pkl
echo "================ Downloading CTF file ==============="
wget --show-progress https://github.com/zhonge/cryodrgn_empiar/blob/main/empiar10180/inputs/ctf.pkl?raw=true \
    -O $DATA_DIR/empiar10180/ctf.pkl
echo "================ Downloading pose file ==============="
wget --show-progress https://github.com/zhonge/cryodrgn_empiar/blob/main/empiar10180/inputs/poses.pkl?raw=true \
    -O $DATA_DIR/empiar10180/poses.pkl
echo "================= Downloading raw mrc ================"
wget --show-progress -r -x -nH --cut-dirs=3 --no-parent \
    ftp://ftp.ebi.ac.uk/empiar/world_availability/10180/data/ \
    -P $DATA_DIR/empiar10180/

echo
# ---------------------------------------------------------------------
echo "Job finished with exit code $? at: `date`"
