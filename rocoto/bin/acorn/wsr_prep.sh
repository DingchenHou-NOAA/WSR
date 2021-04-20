#!/bin/ksh

set -x
ulimit -s unlimited
ulimit -a

# module_ver.h
. $SOURCEDIR/versions/wsr_acorn.ver

# Load modules
#. /usrx/local/prod/lmod/lmod/init/ksh
module list
module purge

source /apps/prod/lmodules/startLmod
module load envvar/$envvar_ver
module load intel/$intel_ver PrgEnv-intel
module load intel/$intel_ver/cray-mpich/$mpich_ver #impi/$impi_ver
module load cray-pals/1.0.8

module load prod_util/$prod_util_ver
module load prod_envir/$prod_envir_ver

module load grib_util/$grib_util_ver

module load cce/11.0.2
module load gcc/10.2.0
module load libjpeg/9c

module load lsf/$lsf_ver

module load CFP/$CFP_ver
export USE_CFP=YES

module list

# For Development
. $GEFS_ROCOTO/bin/acorn/common.sh

# Export List
export MP_EUIDEVICE=sn_all
export MP_EUILIB=us
export MP_TASK_AFFINITY=core

export MP_PGMMODEL=mpmd
export MP_CSS_INTERRUPT=yes

# CALL executable job script here
$SOURCEDIR/jobs/JWSR_PREP

