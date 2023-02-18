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

if [ ! -d "${DATA_DIR}/relion_tut" ]; then
    mkdir -p $DATA_DIR/relion_tut
fi

wget --show-progress \
    ftp://ftp.mrc-lmb.cam.ac.uk/pub/scheres/relion30_tutorial_data.tar \
    -O $DATA_DIR/relion_tut/relion30_tutorial_data.tar

wget --show-progress \
    ftp://ftp.mrc-lmb.cam.ac.uk/pub/scheres/relion31_tutorial_precalculated_results.tar.gz \
    -O $DATA_DIR/relion_tut/relion31_tutorial_precalculated_results.tar.gz

tar -xf \
    $DATA_DIR/relion_tut/relion30_tutorial_data.tar \
    -C $DATA_DIR/relion_tut

tar -zxf \
    $DATA_DIR/relion_tut/relion31_tutorial_precalculated_results.tar.gz \
    -C $DATA_DIR/relion_tut

echo
# ---------------------------------------------------------------------
echo "Job finished with exit code $? at: `date`"
