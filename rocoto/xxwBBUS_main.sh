#!/bin/sh
#BSUB -J wsr_dell_all_2020112000_ws_in
#BSUB -o /gpfs/dell2/ptmp/Xianwu.Xue/o/wsr_dell_all/com/output/dev/20201120/wsr_main_00.%J
#BSUB -n 48
#BSUB -R span[ptile=16]
#BSUB -q dev2
#BSUB -W 0:45
#BSUB -L /bin/sh
#BSUB -P GEN-T2O

set -x
module purge


#04/23/21 15:33:44 UTC :: gefs.xml :: Submitted wsr_main using '/bin/sh /tmp/bsub.wrapper20210423-183891-1a85imr 2>&1' with input {{#!/bin/sh
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
export PDY='20201120'
export cyc='00'
export cyc_fcst='00'
export SOURCEDIR='/gpfs/dell2/emc/retros/noscrub/Xianwu.Xue/For_WSR/wsr_dell_all'
export job='wsr_dell_all_2020112000_ws_in'
export GEFS_NTASKS='48'
export GEFS_NCORES_PER_NODE='16'
export GEFS_TPP='1'
export GEFS_PPN='16'
export GEFS_NODES='3'
#export ROCOTO_TASK_GEO='{(0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15)(16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31)(32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47)}'


#bsub -J wsr_dell_all_2020112000_ws_in -P GEN-T2O -o /gpfs/dell2/ptmp/Xianwu.Xue/o/wsr_dell_all/com/output/dev/20201120/wsr_main_00.%J -W 0:45 -q dev -R span[ptile=16] -n 48 /gpfs/dell3/usrx/local/dev/emc_rocoto/complete/sbin/lsfwrapper.sh /gpfs/dell2/emc/retros/noscrub/Xianwu.Xue/For_WSR/wsr_dell_all/rocoto/bin/wcoss_dell_p3/wsr_main.sh}}

/gpfs/dell2/emc/retros/noscrub/Xianwu.Xue/For_WSR/wsr_dell_all/rocoto/bin/wcoss_dell_p3/wsr_main.sh

~                                                                                                                                                              

