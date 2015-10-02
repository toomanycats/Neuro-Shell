# python paths for cluster jobs using my python tools

## adding in reverse order, b/c one machine at this time, corpus1, WeiWei's, has an old version of
## nibabel and I want to over ride it. 
## The system searches paths from beg to end, and stops when it's found, so we
## want these paths to be first

export PYTHONPATH=/fs/cl10/dpc/CopyOfRepoForCluster/python/Modules:$PYTHONPATH
export PYTHONPATH=/fs/cl10/dpc/CopyOfRepoForCluster/python/Configs:$PYTHONPATH
export PYTHONPATH=/fs/cl10/dpc/CopyOfRepoForCluster/python/Scripts:$PYTHONPATH
export PYTHONPATH=/fs/cl10/dpc/CopyOfRepoForCluster/python/Pypelines:$PYTHONPATH
export PYTHONPATH=/fs/cl10/dpc/CopyOfRepoForCluster:$PYTHONPATH

#Volterra Series: PyLysis
export PYTHONPATH=/fs/cl10/dpc/CopyOfRepoForCluster/PyLysis:$PYTHONPATH

# PySQL
export PYTHONPATH=/fs/cl10/dpc/CopyOfRepoForCluster/MySQL_python-1.2.4b4-py2.7-linux-x86_64.egg:$PYTHONPATH

### C paths ###
### NFFT for use with any cluster machine ### 
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/fs/cl10/dpc/CopyOfRepoForCluster/NFFT/lib
# home made bash scripts
export PATH=$PATH:/fs/cl10/dpc/CopyOfRepoForCluster/bash
# NFFT simple_test and others, FSL
export PATH=$PATH:/fs/cl10/dpc/CopyOfRepoForCluster
# CMTK
export PATH=$PATH:/fs/p00/torsten/x86_64/cmtk3/bin
# AFNI
export PATH=$PATH:/fs/cl10/dpc/CopyOfRepoForCluster/afni/linux_openmp_64

FSLDIR=/fs/cl10/dpc/CopyOfRepoForCluster/fsl
. ${FSLDIR}/etc/fslconf/fsl.sh
PATH=${FSLDIR}/bin:${PATH}
export FSLDIR PATH

### Keeps any open MP programs from grabbing too many CPU's. 
## if OPM_NUM_PPN is empty, then warnings are raised.

if [ -z "$PBS_NUM_PPN" ];then  
	export OMP_NUM_THREADS=1

else
	export OMP_NUM_THREADS=${PBS_NUM_PPN};
fi

