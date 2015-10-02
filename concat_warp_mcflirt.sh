#!/usr/bin/bash

# if error occurs, then remove the temp dir, since it's 
# sitting in memory. A large series of failures could bring down the machine
function cleanup_temp {
    rm -rf ${tmpdir}
    echo "cleaning up"
}

## root output dir
OUTPUT_PATH=$1
SUB_ID=$2

NCANDA_DIR=/fs/ncanda-share/pipeline/cases/${SUB_ID}/standard/baseline
RESTING_DIR=${NCANDA_DIR}/restingstate

tmpdir=$(mktemp -d)
trap cleanup_temp EXIT SIGINT SIGHUP ERR

### make bold 4D file ###
bold_4d=${tmpdir}/bold_4d_native.nii.gz

list=$(ls ${RESTING_DIR}/native/rs-fMRI/bold-???.nii.gz)

fslmerge -t ${bold_4d} ${list} 

### mcflirt ###
tmp_mcflirt_out=${tmpdir}/bold_4d_mcf 
mcflirt -in ${bold_4d} -o  $tmp_mcflirt_out -refvol 0 -mats -plots  # no ext on output, so that mats output is normal

### register the mean temp output from mcflirt, to the
### magnitude image from the fieldmap sequence

mag=${RESTING_DIR}/fieldmap/magnitude_average.nii.gz
bold_2_mag_xfm=${tmpdir}/bold_2_mag.mat

temp_mcflirted_mean=${tmpdir}/mcflirt_mean.nii.gz

fslmaths $tmp_mcflirt_out -Tmean $temp_mcflirted_mean

flirt -in $temp_mcflirted_mean -ref $mag -dof 12 -cost normmi -omat $bold_2_mag_xfm

### mats output ###
mats_path=${OUTPUT_PATH}/motion_params.mat
par_path=${PUTPUT_PATH}/motion_params.par

cp -R ${tmpdir}/bold_4d_mcf.mat ${mats_path}
cp  ${tmpdir}/bold_4d_mcf.par ${par_path}

### bold output ###
final_bold=${OUTPUT_PATH}/bold_mcf_unw.nii.gz

### local copy of target for speed ###
target=${tmpdir}/target.nii.gz
cp ${RESTING_DIR}/native/rs-fMRI/bold-001.nii.gz ${target} 


### going to use the fieldmap warp file already created
### copy for speed 
fieldmap_warp=${tmpdir}/fieldmap_warp.nii.gz
cp ${RESTING_DIR}/fieldmap/fieldmap_warp.nii.gz ${fieldmap_warp}

# main loop for apply the warp and mat to each 
count=0
final_volumes=""

concat_mat=${tmpdir}/concat_mag_mcf_xfm.mat

for volume in ${list}; do 
	
    mat=$(printf '%s/MAT_%04d' ${mats_path} ${count})
	#convert_xfm -omat <outmat_AtoC> -concat <mat_BtoC> <mat_AtoB> 
	convert_xfm -omat $concat_mat -concat  $mat $bold_2_mag_xfm
	
    applywarp -i $volume -r $target -o ${tmpdir}/vol${count} -w ${fieldmap_warp} --premat=$concat_mat --interp=spline
	
	final_volumes+="${tmpdir}/vol${count}.nii.gz "

	# increment the counter for the MAT_???? file name
	count=$(expr $count + 1)

done

fslmerge -tr ${final_bold} ${final_volumes} 2.2

exit 0
   















