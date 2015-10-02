#!/usr/bin/bash
# works with mosaic 
# after closing, the next instance is opened

path=$1

# check if this is a phantom subject
if [ $(echo ${path} | grep -E  "[A-Z]-9{5}|0{5}.*") ];then
    triplanar ${path}/*t1*/image.nii.gz || triplanar ${path}/*fmri*/image130.nii.gz || triplanar ${path}/*mprage*/image.nii.gz
    exit 0
fi


triplanar ${path}/*t2*/image.nii.gz

triplanar ${path}/*t1*/image.nii.gz || triplanar ${path}/*mprage*/image.nii.gz

triplanar ${path}/*dti*500*/image5.nii.gz

triplanar ${path}/*dti*1000*/image06.nii.gz

triplanar ${path}/*rs*fmri*/image130.nii.gz

triplanar ${path}/*map*/image1.nii.gz || triplanar ${path}
