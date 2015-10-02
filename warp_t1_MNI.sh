#!/usr/bin/bash

## not sure if this helps
export CMTK_NUM_THREADS=4

## This version of the script, is to warp to MNI space instead of SRI24.
### Start right after the MR Bias correction and Stripping are done ###

function finish {
    echo "something bad happened"
    exit 1
}
trap finish ERR SIGHUP SIGINT

SUB_ID=$1

WORKDIR=/fs/corpus6/dpc/MNI_warp/${SUB_ID}
RESTING_DIR=/fs/ncanda-share/pipeline/cases/${SUB_ID}/standard/baseline/restingstate

bold_mean_def=/fs/cl10/dpc/Data/Resting_Dev/${SUB_ID}/bold_mean.nii.gz
bold_mean=${2:-${bold_mean_def}}

MNI_t1_2mm=/fs/corpus6/dpc/atlas/avg152T1.nii 
t1=$WORKDIR/t1_brain_skull.nii.gz
bold_mean_MNI=$WORKDIR/bold_mean_MNI.nii.gz
T1_MNI=$WORKDIR/T1_MNI.nii.gz

t1_MNI_affine=${WORKDIR}/t1_MNI.affine
bold_T1_affine=${WORKDIR}/bold_T1.affine

t1_MNI_warp=${WORKDIR}/t1_MNI.warp

if ! [ -e $WORKDIR ];then
    mkdir -p $WORKDIR
fi

t1_brain=/fs/ncanda-share/pipeline/cases/${SUB_ID}/standard/baseline/structural/stripped/t1_brain.nii.gz
t1_skull=/fs/ncanda-share/pipeline/cases/${SUB_ID}/standard/baseline/structural/stripped/t1_skull.nii.gz

fslmaths $t1_brain -add $t1_skull $t1

echo "affine registration"

# [options] ReferenceImage [FloatingImage] 
registrationx --dofs 6,9,12 --auto-multi-levels 4 --ncc --init com -o ${t1_MNI_affine}  ${MNI_t1_2mm} ${t1}

#t1_MNI_warp_args="--exploration 16 --coarsest 4 --sampling 2 --accuracy 0.1 --grid-spacing 40 --refine 4 --delay-refine --energy-weight 1e-3"  
t1_MNI_warp_args="--exploration 16 --coarsest 4 --sampling 2 --accuracy 0.1 --grid-spacing 40 --refine 2 --delay-refine --energy-weight 1e-3 --fast"   

echo "nonlinear warp"

# [options] ReferenceImage [FloatingImage] [InitialXform] 
warp $t1_MNI_warp_args -o $t1_MNI_warp  $MNI_t1_2mm  $t1  $t1_MNI_affine 

reformatx -o $T1_MNI --floating $t1 $MNI_t1_2mm  $t1_MNI_warp

### Resting state application ###

registrationx --dofs 6,9,12 --auto-multi-levels 4 --nmi --init com -o $bold_T1_affine $t1 $bold_mean

reformatx -o $bold_mean_MNI --floating $bold_mean  $T1_MNI  $t1_MNI_warp  $bold_T1_affine


