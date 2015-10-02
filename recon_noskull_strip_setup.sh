#!/usr/bin/bash

# This script is for setting up the directories for a Free Surfer
# auto_recon_all job, where the brain mask is already made and being subed into the
# processing stream.  SEE auto_recon_wrapper_one_sub.sh

root_dir=$1
sub=$2


case="/fs/ncanda-share/pipeline/cases"


root="${root_dir}/${sub}_head"
mkdir -p "$root/${sub}/mri/orig"
ln -s "${FREESURFER_HOME}/subjects/fsaverage"  ${root}/fsaverage 

mri_convert -i ${case}/${sub}/standard/baseline/structural/stripped/t1_brain.nii.gz -o ${root}/${sub}/mri/orig/001.mgz
