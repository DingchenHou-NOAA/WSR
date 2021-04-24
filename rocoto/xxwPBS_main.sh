#!/bin/sh
#PBS -N wsr_20201120_ws_in
##PBS -o /lfs/h1/emc/ptmp/Xianwu.Xue/o/wsr_port2wcoss2/com/output/dev/20201120/wsr_main_00.%J
#PBS -j oe
#PBS -l select=1:ncpus=48
##PBS -R span[ptile=16]
#PBS -q workq
#PBS -l walltime=0:45:00
##PBS -L /bin/sh
#PBS -A GEN-T2O

set -x
module purge


#04/23/21 15:33:44 UTC :: gefs.xml :: Submitted wsr_main using '/bin/sh /tmp/bsub.wrapper20210423-183891-1a85imr 2>&1' with input {{#!/bin/sh
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
export job=wsr_dell_all_${PDY}${cyc}_ws_in


#bsub -J wsr_dell_all_2020112000_ws_in -P GEN-T2O -o /gpfs/dell2/ptmp/Xianwu.Xue/o/wsr_dell_all/com/output/dev/20201120/wsr_main_00.%J -W 0:45 -q dev -R span[ptile=16] -n 48 /gpfs/dell3/usrx/local/dev/emc_rocoto/complete/sbin/lsfwrapper.sh /gpfs/dell2/emc/retros/noscrub/Xianwu.Xue/For_WSR/wsr_dell_all/rocoto/bin/wcoss_dell_p3/wsr_main.sh}}

/lfs/h1/emc/ens/noscrub/Xianwu.Xue/wsr/wsr_port2wcoss2/rocoto/bin/acorn/wsr_main.sh

~                                                                                                                                                              

