#!/usr/bin/bash

# This shell script is for running free surfer recon_all with
# pre-made brain mask.

check_last_op(){
if [[ $? -gt 0 ]]
  then
    echo -e "operation failed \n"
    exit 1
fi   
}

echo "HOST:"
hostname

echo "SUB:"
echo $sub_id

sub_id=$2
path="$1/${sub_id}"

echo $path

cd $path
check_last_op

echo -e "\nfirst recon call\n"
recon-all -sd $path -autorecon1 -noskullstrip -s $sub_id
check_last_op

echo -e "link 1\n"
cp ${sub_id}/mri/T1.mgz ${sub_id}/mri/brainmask.auto.mgz
check_last_op

echo -e "link 2\n"
cp  ${sub_id}/mri/brainmask.auto.mgz ${sub_id}/mri/brainmask.mgz
check_last_op

echo -e "calling autorecon2 and autorecon3\n"
recon-all -sd $path -autorecon2 -autorecon3 -s $sub_id
check_last_op

