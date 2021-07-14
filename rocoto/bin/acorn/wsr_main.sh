#!/bin/ksh

set -x
ulimit -s unlimited
ulimit -a

# module_ver.h
. $SOURCEDIR/versions/wsr_acorn.ver

# Load modules
module list
module purge

source /apps/prod/lmodules/startLmod
module load envvar/$envvar_ver
module load intel/$intel_ver PrgEnv-intel
module load intel/$intel_ver/cray-mpich/$mpich_ver #impi/$impi_ver
module load cray-pals/1.0.8

module load prod_util/$prod_util_ver
module load prod_envir/$prod_envir_ver

#module load CFP/$CFP_ver
#export USE_CFP=YES

module list

# For Development
. $GEFS_ROCOTO/bin/acorn/common.sh

# Export List

# CALL executable job script here
export MP_SHARED_MEMORY=yes
export MP_TASK_AFFINITY=core
export MP_EUIDEVICE=sn_all
export MP_EUILIB=us

$SOURCEDIR/jobs/JWSR_MAIN

################################################################################
# TASKSCRIPT DOCUMENTATION BLOCK
#
# PURPOSE:  Executes the job that creates the Winter Storm Recon Files.

