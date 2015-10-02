#!/usr/bin/bash

check_last_op(){
if [[ $? -gt 0 ]]
  then
    echo -e "operation failed \n"
    exit 1
fi   
}

# make a vector field warp map from the shiftmap
# using the resting state 4D data set as the ref for dimensions.

# $1 = rs_4D.nii.gz
# $2 = shiftmap.nii.gz
# $3 = intensity_correction_vol.nii.gz
# $4 output name
# $5 root dir

cd $5
check_last_op

echo -e "Running convertwarp \n"
convertwarp -r $1 -s $2 -o warp_field
check_last_op

# apply the warp correction to the resting state data, fsl will operate on the 4D file
# there are interp choices too.

echo -e "Running applywarp \n"
applywarp -i $1 -r $1 -o unwarped_rs_4D -w warp_field.nii.gz --interp=spline
check_last_op

#coregister the resting state volumes ONLY for the purpose of getting the 
# .mat affine matrices.

# dof=6 is default, cost=normcorr is default
# Since we are not using the output just the affines, interp shouldn't matter

echo -e "Running mcflirt \n"
mcflirt -in unwarped_rs_4D.nii.gz  -cost normcorr  -mats -dof 6 
check_last_op

#outputs:  "unwarped_rs_4D_mcf.mat" and "unwarped_rs_4D_mcf.nii.gz"

echo -e "Changing the name of the directory containing the affines. \n"
mv unwarped_rs_4D_mcf.mat CoregistrationAffines
check_last_op

echo -e "Removing un-needed outputs from mcflirt. \n"
rm unwarped_rs_4D.nii.gz
rm unwarped_rs_4D_mcf.nii.gz


#split the 4D set into single volumes, so that the applywarp
#command can be applied to each file separately.

mkdir Vols
check_last_op

echo -e "Split the 4D into vols \n"
fslsplit $1 Vols/vol -t
check_last_op

# make a shell variable array to store the volume file names 

vol_list=`ls Vols/vol*.nii.gz`

echo -e "Applying the warp and affine and intensity correction on each vol. "

# main loop for apply the warp and mat to each 
count=0

#temp dir for the vols output from loop below
mkdir UnwarpedVols
mkdir IntenCoregVols

for volume in ${vol_list[@]}; 
  do 
    mat=$(printf 'CoregistrationAffines/MAT_%04d' $count)
    applywarp -i $volume -r $volume -o "UnwarpedVols/vol_unwarp_temp_$count" -w warp_field.nii.gz --postmat=$mat
    check_last_op

    # apply intensity correction image to the unwarped temp vol
    #first apply the affine matrix to the inten corr image
    
    flirt -in $3 -ref $volume -applyxfm -init $mat -out "IntenCoregVols/inten_corr_coreg_$count"        
    check_last_op
    
    fname=$(basename $volume)
    output="UnwarpedVols/${fname%.nii.gz}_unwarped_coreg_inten_corr"
    fslmaths "UnwarpedVols/vol_unwarp_temp_$count.nii.gz" -mul "IntenCoregVols/inten_corr_coreg_$count.nii.gz"   $output
    check_last_op
    
    # increment the counter for the MAT_???? file name
    count=`expr $count + 1`

  done

#put them all back into a 4D file for later processing steps
vol_list=`ls UnwarpedVols | grep -E vol[0-9]{4}_unwarped_coreg_inten_corr.nii.gz`

cd UnwarpedVols
check_last_op

echo -e "Merging unwarped vol into a 4D file. \n"
fslmerge -t ../rs_4D_unwarped_coreg $vol_list
check_last_op

# change path for the output
echo -e "Changing final 4D file name to outfile path arg.\n"
mv ../rs_4D_unwarped_coreg.nii.gz $4


# Doc for mcflirt concerning the -meanvol flag

#MCFLIRT loads the time-series in its entirity and will default to the middle volume as an initial template image. A coarse 8mm search for the motion 
#parameters is then carried out using the cost function specified followed by two subsequent searches at 4mm using increasingly tighter tolerances. 
#All optimizations use trilinear interpolation.

#As part of the initial 8mm search, an identity transformation is assumed between the middle volume and the adjacent volume. The transformation found in 
#this first search is then used as the estimate for the transformation between the middle volume and the volume beyond the adjacent one. This scheme should 
#lead to much faster optimization and greater accuracy for the majority of studies where subject motion is minimal. In the pathalogical cases, this scheme 
#does not penalise the quality of the final correction.

#If mean registration is used, the curent motion correction parameters are applied to the time-series, the volumes are averaged to create a new template 
#image and the same 3-stage correction is carried out using this new mean image as a template. 
