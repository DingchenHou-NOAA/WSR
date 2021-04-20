#!/bin/sh
#PBS -N wsr_20201120_ws_ep
##PBS -o /lfs/h1/emc/ptmp/Xianwu.Xue/o/wsr_port2wcoss2/com/output/dev/20201120/wsr_prep_00.%J
#PBS -j oe
#PBS -l select=1:ncpus=32
##PBS -R span[ptile=16]
##PBS -R 'affinity[core(1)]'
#PBS -q workq
#PBS -l walltime=3:20:00
##PBS -L /bin/sh
#PBS -A GEN-T2O

set -x
module purge


export envir='dev'
export RUN_ENVIR='dev'
export WHERE_AM_I='acorn'
export GEFS_ROCOTO='/lfs/h1/emc/ens/noscrub/Xianwu.Xue/wsr/wsr_port2wcoss2/rocoto'
export WORKDIR='/lfs/h1/emc/ptmp/Xianwu.Xue/o/wsr_port2wcoss2'
export EXPID='wsr_port2wcoss2'
export gefs_cych='24'
export PDY='20201120'
export cyc='00'
export cyc_fcst='00'
export SOURCEDIR='/lfs/h1/emc/ens/noscrub/Xianwu.Xue/wsr/wsr_port2wcoss2'
export job='wsr_port2wcoss2_${PDY}_ws_ep'
export GEFS_NTASKS='16'
export GEFS_NCORES_PER_NODE='16'
export GEFS_TPP='1'
export GEFS_PPN='16'
export GEFS_NODES='1'
#export ROCOTO_TASK_GEO='{(0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15)}'
#bsub -J wsr_dell_all_2021032500_ws_ep -P GEN-T2O -o /gpfs/dell2/ptmp/Xianwu.Xue/o/wsr_dell_all/com/output/dev/20210325/wsr_prep_00.%J -W 1:20 -q dev -R span[ptile=16] -n 16

/lfs/h1/emc/ens/noscrub/Xianwu.Xue/wsr/wsr_port2wcoss2/rocoto/bin/acorn/wsr_prep.sh

