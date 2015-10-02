#!/usr/bin/bash

check_last_op(){
if [[ $? -gt 0 ]]
  then
    echo -e "operation failed \n"
    exit 1
fi   
}

sub_id=$2
path="$1/${sub_id}_head"
cd $path
check_last_op

echo -e "calling autorecon3\n"
recon-all -sd $path  -autorecon3 -s $sub_id
check_last_op

