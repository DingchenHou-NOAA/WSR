#!/bin/sh
#BSUB -J wsr_dell_all_2021032500_ws_ep
#BSUB -o /gpfs/dell2/ptmp/Xianwu.Xue/o/wsr_dell_all/com/output/dev/20210325/wsr_prep_00.%J
#BSUB -n 16
#BSUB -R span[ptile=16]
#BSUB -R 'affinity[core(1)]'
#BSUB -q dev2
#BSUB -W 01:20
#BSUB -L /bin/sh
#BSUB -P GEN-T2O

set -x
module purge


export envir='dev'
export RUN_ENVIR='dev'
export WHERE_AM_I='wcoss_dell_p3'
export GEFS_ROCOTO='/gpfs/dell2/emc/retros/noscrub/Xianwu.Xue/For_WSR/wsr_dell_all/rocoto'
export WORKDIR='/gpfs/dell2/ptmp/Xianwu.Xue/o/wsr_dell_all'
export EXPID='wsr_dell_all'
export KEEP_DIR='/gpfs/dell2/emc/retros/noscrub/Xianwu.Xue/GEFS/wsr_dell_all'
export HPSS_DIR='/NCEPDEV/emc-ensemble/2year/Xianwu.Xue/GEFS_DELL3/wsr_dell_all'
export INIT_DIR='/gpfs/dell2/emc/retros/noscrub/Xianwu.Xue/GEFS_INIT/fv3_cold_init'
export DIRS_TO_KEEP='ensstat,pgrb2ap5,pgrb2bp5,pgrb22p5'
export DIRS_TO_ARCHIVE='ensstat,pgrb2ap5,pgrb2bp5,pgrb22p5'
export DIRS_TO_KEEP_WAVE='gridded, station, restart'
export DIRS_TO_ARCHIVE_WAVE='gridded, station, restart'
export gefs_cych='24'
export PDY='20210325'
export cyc='00'
export cyc_fcst='00'
export SOURCEDIR='/gpfs/dell2/emc/retros/noscrub/Xianwu.Xue/For_WSR/wsr_dell_all'
export job='wsr_dell_all_2021032500_ws_ep'
export GEFS_NTASKS='16'
export GEFS_NCORES_PER_NODE='16'
export GEFS_TPP='1'
export GEFS_PPN='16'
export GEFS_NODES='1'
export ROCOTO_TASK_GEO='{(0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15)}'
#bsub -J wsr_dell_all_2021032500_ws_ep -P GEN-T2O -o /gpfs/dell2/ptmp/Xianwu.Xue/o/wsr_dell_all/com/output/dev/20210325/wsr_prep_00.%J -W 1:20 -q dev -R span[ptile=16] -n 16

/gpfs/dell2/emc/retros/noscrub/Xianwu.Xue/For_WSR/wsr_dell_all/rocoto/bin/wcoss_dell_p3/wsr_prep.sh

