#!/bin/ksh

## @ job_name = jwsr_grads
## @ output = /stmpp1/wsr_grads.o$(jobid)
## @ error = /stmpp1/wsr_grads.o$(jobid)
## @ shell = /bin/sh
## @ job_type = serial
## @ class = 1
## @ min_processors = 1
## @ max_processors = 1
## @ wall_clock_limit = 00:30:00
## @ notification = never
## @ queue

set -x 
### USER SETUP

#. ${NWROOT:-/gpfs/dell1/nco/ops/nw${envir:-prod}}/versions/wsr.ver

# for production, name this script wsr_grds.sh
# for testing, name this script wsr_grds_test.sh
#              and set up test destinations for your LOGNAME below

####################################
# set up test mode if required
####################################

scriptname=`basename $0`
case $scriptname in
  (wsr_grds.sh)
    testmode=no
  ;;
  (wsr_grds_test.sh)
    testmode=yes
  ;;
  (*)
    echo no testmode setting for scriptname=$scriptname
    exit
  ;;
esac

if [[ $testmode = yes ]]; then

  # these test settings are only used when testmode=yes

  case $LOGNAME in
    (SDM)
      # these are the production locations, edit them to use test locations
      testenvir=para
      testemail=sdm@noaa.gov
      testuser=wx12sd
      testrzdm=ncorzdm
      testdirectory=/home/people/nco/www/htdocs/pmb/sdm_wsr
      export PRINTSDM=NO
      export sdmprinter=hp26_sdm
      useexpid=no
    ;;
    (nwprod)
      # these are the production locations, edit them to use test locations
      testenvir=para
      testemail=ncep.list.spa-helpdesk@noaa.gov
      testuser=nwprod
      testrzdm=ncorzdm
      testdirectory=/home/people/nco/www/htdocs/pmb/nwprod_wsr
      export PRINTSDM=NO
      export sdmprinter=hp26_sdm
      useexpid=no
    ;;
    (Xianwu.Xue)
      testenvir=dev
      testemail=Xianwu.Xue@noaa.gov
      testuser=xianwu.xue
      testrzdm=emcrzdm
      testdirectory=/home/www/emc/htdocs/gmb/xianwu.xue/wsr_sdm
      export PRINTSDM=YES
      export sdmprinter=
      useexpid=yes
      testtmpdir=/lfs/h1/emc/ptmp/$LOGNAME/o #/gpfs/dell2/ptmp/$LOGNAME/o
      expid=wsr_port2wcoss2 #wsr_rocoto
      envir=$testenvir
      testbase=null
      HOMEwsr=`pwd`/../
      FIXwsr=`pwd`/../fix
      GESdir=$testtmpdir/$expid/nwges/$envir/wsr
      COMIN=$testtmpdir/$expid/com/wsr/$envir
      ETKFOUT=$testtmpdir/$expid
    ;;
    (Richard.Wobus)
      testenvir=dev
      testemail=richard.wobus@noaa.gov
      testuser=wd20rw
      testrzdm=emcrzdm
      testdirectory=/home/people/emc/www/htdocs/gmb/rwobus/sdm_wsr
      export PRINTSDM=NO
      export sdmprinter=
      useexpid=yes
      testtmpdir=/gpfs/dell3/ptmp/$LOGNAME/o
    ;;
    (*)
      echo Please add test settings to $0 for LOGNAME=$LOGNAME
      exit
    ;;
  esac

  echo LOGNAME=$LOGNAME
  echo testenvir=$testenvir
  echo testemail=$testemail
  echo testuser=$testuser
  echo testrzdm=$testrzdm
  echo testdirectory=$testdirectory
  echo PRINTSDM=$PRINTSDM
  echo sdmprinter=$sdmprinter
  echo useexpid=$useexpid
  echo testtmpdir=$testtmpdir

  export envir=$testenvir
  echo envir=$envir

  if [[ $useexpid = yes ]]; then

    export wsr_ver=v3.2.0

    dfile=$0
    dfb=`basename $dfile`
    dfd=`dirname $dfile`
    if [[ "$dfd" = '.' ]]; then
      dfd=`pwd`
    fi
    #dfd=/nwprod/ush
    expid=${expid:-null}
    dfdtestdone=no
    dfdt=$dfd
    while [[ $dfdtestdone = no ]]
    do
      dfdtd=`dirname $dfdt`
      if [[ "$dfdtd" = '.' ]]; then
	dfdtd=`pwd`
      fi
      dfdtb=`basename $dfdt`
      if [[ $dfdtb = '/' ]]; then
	dfdtestdone=yes
	expid=${expid:-test}
      else
	dfdfound=no
	case $dfdtb in
	  (nwdev)  dfdfound=yes ;;
	  (nwpara) dfdfound=yes ;;
	  (nwtest) dfdfound=yes ;;
	esac
	if [[ $dfdfound = yes ]]; then
	  expid=`basename $dfdtd`
	  dfdtestdone=yes
	else
	  dfdt=$dfdtd
	fi
      fi
    done

    # specify expid here if the procedure above does not choose it appropriately

    echo expid=$expid

    export GESdir=${GESdir:-/gpfs/dell3/ptmp/$LOGNAME/o/$expid/nwges/$envir/wsr}
    export COMIN=${COMIN:-/gpfs/dell3/ptmp/$LOGNAME/o/$expid/com/wsr/$envir}
    export ETKFOUT=${ETKFOUT:-/gpfs/dell3/ptmp/$LOGNAME/o/$expid}

    #testbase=/ensemble/save/$LOGNAME/nw$envir
    #testbase=/ensemble/save/$LOGNAME/s/$expid/nw$envir
    testbase=${testbase:-/gpfs/dell2/emc/modeling/noscrub/$LOGNAME/s/$expid/nw$envir}
    #. $testbase/wsr*/versions/wsr.ver
    #export HOMEwsr=$testbase/wsr.${wsr_ver}/ush
    export HOMEwsr=${HOMEwsr:-$testbase/wsr.${wsr_ver}}
    export FIXwsr=${FIXwsr:-$testbase/wsr.${wsr_ver}/fix}

    testtmpdir=$testtmpdir/$expid
    export pid=$$
    dtg=`date +%Y%m%d%H%M%S`
    export DATA=$testtmpdir/wsr/tmp/wsr.${pid}.$dtg

    echo GESdir=$GESdir
    echo COMIN=$COMIN
    echo ETKFOUT=$ETKFOUT
    echo testbase=$testbase
    echo HOMEwsr=$HOMEwsr
    echo FIXwsr=$FIXwsr
    echo testtmpdir=$testtmpdir
    echo DATA=$DATA

  fi

  echo before sorted environment
  env | sort
  echo after sorted environment

  echo testmode=$testmode

fi
####################################
# end set up test mode
####################################

#. ${NWROOT:-/gpfs/dell1/nco/ops/nw${envir:-prod}}/versions/wsr.ver
if [[ $useexpid = no ]]; then
. /gpfs/dell1/nco/ops/nw${envir:-prod}/versions/wsr.ver
fi

#shellname=ksh
# . /usrx/local/Modules/3.2.9/init/$shellname
. /usrx/local/prod/modules/default/init/sh

module use /usrx/local/dev/modulefiles
module load  GrADS/2.2.0
module list 

export job=wsr_main

export envir=${envir:-prod}
export GESdir=${GESdir:-/gpfs/dell1/nco/ops/nwges/$envir/wsr}
export COMIN=${COMIN:-/gpfs/dell1/nco/ops/com/wsr/$envir}
# ETKFOUT is the home dir where ET KF results
export ETKFOUT=${ETKFOUT:-/gpfs/dell1/nco/ops}
export RAWINSONDES=${RAWINSONDES:-"YES"}
if [[ $testmode = no ]]; then
  export PRINTSDM=${PRINTSDM:-YES}
else
  export PRINTSDM=${PRINTSDM:-NO}
fi
export HOMEwsr=${HOMEwsr:-/gpfs/dell1/nco/ops/nw$envir/wsr.${wsr_ver:?}}
export FIXwsr=${FIXwsr:-$HOMEwsr/fix}
export sdmprinter=${sdmprinter:-hp26_sdm}
#######################################################
# use gxps at $HOMEwsr/grads/gxps
# replaced by gxprint in grads and mv here/
######################################################
#export PATH=.:$PATH:$HOMEwsr/grads

echo GESdir=$GESdir
echo COMIN=$COMIN
echo ETKFOUT=$ETKFOUT
echo RAWINDSONDES=$RAWINSONDES
echo PRINTSDM=$PRINTSDM
echo HOMEwsr=$HOMEwsr
echo FIXwsr=$FIXwsr
echo sdmprinter=$sdmprinter

### END USER SETUP #########

export pid=$$
export DATA=${DATA:-/gpfs/dell1/ptmp/$LOGNAME/wsr/tmp/${job}.${pid}}

#echo stop here for testing
#echo before sorted environment
#env | sort
#echo after sorted environment
#exit

mkdir -p $DATA
cd $DATA
rm -rf $DATA/*

PDY=`head -1 $GESdir/targdata.d`
cases=`head -2 $GESdir/targdata.d | tail -1`
. $ETKFOUT/com/wsr/${envir}/wsr.$PDY/case1.env

#cp $HOMEwsr/fix/wsr_track.* .
# JY if [[ $testmode = no ]]; then
# JY   cp /nw${envir}/fix/wsr_track.* .
# JY else
  cp $FIXwsr/wsr_track.* .
# JY fi
cp $HOMEwsr/grads/*.gs $DATA/.

i=1
while test ${i} -le ${cases}
do
   . $ETKFOUT/com/wsr/${envir}/wsr.$PDY/case${i}.env

   #########################################
   # GRAPHICS START UP
   #########################################
   cp ${COMIN}/case${i}.circlevr.d circlevr.d
   cp ${COMIN}/case${i}.targ1.gr targ1.d.gr 

   cat $FIXwsr/wsr_targ_flexctl1 > wsr_targ_flex.ctl
   #cat $FIXwsr/wsr_targ_flexctl1 | sed -e"s/OPTIONS template/OPTIONS big_endian template/" > wsr_targ_flex.ctl
   echo "XDEF    ${nlon} linear    ${lon1} 5.000" >> wsr_targ_flex.ctl
   echo "YDEF    ${nlat} linear    ${lat1} 5.000" >> wsr_targ_flex.ctl
   cat $FIXwsr/wsr_targ_flexctl2 >> wsr_targ_flex.ctl

   if [ ${searchareacode} -eq 1 ]
   then 

       read ndrops1 < wsr_track.${fl1}
       echo $ndrops1 > dropplot1.d
       tail -n$ndrops1 wsr_track.${fl1} | awk '{ if($1 < 0) print s=$1+360.,$2;else print s=$1,$2}' >> dropplot1.d


       read ndrops2 < wsr_track.${fl2}
       echo $ndrops2 > dropplot2.d
       tail -n$ndrops2 wsr_track.${fl2} | awk '{ if($1 < 0) print s=$1+360.,$2;else print s=$1,$2}' >> dropplot2.d

       read ndrops3 < wsr_track.${fl3}
       echo $ndrops3 > dropplot3.d
       tail -n$ndrops3 wsr_track.${fl3} | awk '{ if($1 < 0) print s=$1+360.,$2;else print s=$1,$2}' >> dropplot3.d
       if [[ ${RAWINSONDES} = YES ]]
       then
       read nstations < ${COMIN}/case${i}.rawinpoints.d 
       echo $nstations > stationplot.d
       read sigmax <${COMIN}/case${i}.rawinpoints.d
       echo sigmax >> stationplot.d
       read sigmin <${COMIN}/case${i}.rawinpoints.d
       echo sigmin >> stationplot.d
       tail -n$nstations ${COMIN}/case${i}.rawinpoints.d >> stationplot.d

       fi
   fi

   if [ ${searchareacode} -eq 1 ]
   then
       if [[ ${RAWINSONDES} = YES ]]
       then
       grads -blc "wsr_targ_special5.gs ${hr1} ${hr2} ${ensdategr} ${lon1} ${lon2} ${lat1} ${lat2} ${ensemble} ${mem} ${ndrops1} ${ndrops2} ${ndrops3} ${fl1} ${fl2} ${fl3} ${vrlonewest} ${vrlat} ${radvr} ${vnormgr} ${i}"
       else 
       grads -blc "wsr_targ_special4.gs ${hr1} ${hr2} ${ensdategr} ${lon1} ${lon2} ${lat1} ${lat2} ${ensemble} ${mem} ${ndrops1} ${ndrops2} ${ndrops3} ${fl1} ${fl2} ${fl3} ${vrlonewest} ${vrlat} ${radvr} ${vnormgr} ${i}"
       fi
									  

   else
      grads -blc "wsr_targ_notracks.2.gs ${hr1} ${hr2} ${ensdategr} ${lon1} ${lon2} ${lat1} ${lat2} ${ensemble} ${mem} ${vrlonewest} ${vrlat} ${radvr} ${vnormgr} ${i}"
   fi

   #gxps -ic ec.out -o Plot${case_id}_${vrlat}N${vrlonewest}_summary_${lt1}_${lt2}.ps
   mv        ec.ps     Plot${case_id}_${vrlat}N${vrlonewest}_summary_${lt1}_${lt2}.ps
   if test "$PRINTSDM" = "YES"
   then
    lpr -h -"$sdmprinter" Plot${case_id}_${vrlat}N${vrlonewest}_summary_${lt1}_${lt2}.ps
   fi

   mv gifimage.png Plot${case_id}_${vrlat}N${vrlonewest}_summary_${lt1}_${lt2}.png
                                                                          #echo test exit after first grads call
                                                                          #exit

   if [ ${searchareacode} -eq 1 ]
   then
       cp $COMIN/case${i}.flights.d flights.d
#
# Add an edit of the NANQs from the flights.d file -
#
      cat $COMIN/case${i}.flights.d | sed 's/NaNQ/.000/' > flights.d


       if [[ ${RAWINSONDES} = YES ]]
       then
       cat $COMIN/case${i}.rawinhist.d | sed 's/NaNQ/.000/' > rawinhist.d
       grads -blc "wsr_rawhist.gs ${ensemble} ${xmin2} ${xmax2} ${ymin2} ${ymax2} ${xlow} ${xint} ${yint} ${ensdategr} ${obsdate} ${veridate} ${vrlonewest} ${vrlat} ${radvr} ${mem} ${vnormgr} ${i}"
       mv gifimage.png VR_${vrlat}N${vrlonewest}_rawinsondes_${lt1}_${lt2}.png
       fi

       grads -blc "wsr_flihist.1.gs ${ensemble} ${xmin} ${xmax} ${ymin1} ${ymax1} ${xlow} ${xint} ${yint} ${ensdategr} ${obsdate} ${veridate} ${vrlonewest} ${vrlat} ${radvr} ${mem} ${vnormgr} ${fl1} ${fl2} ${fl3} ${i}"

       #gxps -ci ec.out -o VR_${vrlat}N${vrlonewest}_flights_${lt1}_${lt2}.ps
       mv        ec.ps     VR_${vrlat}N${vrlonewest}_flights_${lt1}_${lt2}.ps
       if test "$PRINTSDM" = "YES"
       then
          if [ $lt1 -eq 48 || $lt1 -eq 24 ] 
          then
          lpr -h -P"$sdmprinter" VR_${vrlat}N${vrlonewest}_flights_${lt1}_${lt2}.ps
          fi
       fi

       mv gifimage.png VR_${vrlat}N${vrlonewest}_flights_${lt1}_${lt2}.png

   fi

   i=`expr ${i} + 1`

done

if [ ${searchareacode} -eq 0 ]
then
    
i=1
while test ${i} -le ${cases}
do
    . $ETKFOUT/com/wsr/${envir}/wsr.$PDY/notwsr_case${i}.env

    ltdiffsteps=`expr ${ltdiff} / 12`
    if [ ${ltdiffsteps} -lt 7 ]
    then
        ltdiffsteps=7
    fi

    cp ${COMIN}/notwsr_case${i}.dropplot.d dropplot.d
    cp ${COMIN}/notwsr_case${i}.circlevr${i}.d circlevr${i}.d

    ctr=0
    while [ ${ctr} -le ${ltdiffsteps} ]
    do
	ctraddone=`expr ${ctr} + 1`
        cp ${COMIN}/notwsr_case${i}.sig${ctraddone}.ctl sig${ctraddone}.ctl
        #cat ${COMIN}/notwsr_case${i}.sig${ctraddone}.ctl | sed -e"s/OPTIONS template/OPTIONS big_endian template/" > sig${ctraddone}.ctl
        cp ${COMIN}/notwsr_case${i}.sig${ctraddone}.d.gr sig${ctraddone}.d.gr
        ctr=`expr ${ctr} + 1`
    done

    grads -bpc "wsr_sigvar_notwsr_8panel.gs ${ensdate} ${obsdate} ${ltdiff} 9 ${vnormgr} ${i}"

    #gxps -ic ec.out -o sigvar_case${case_id}.ps
    mv        ec.ps     sigvar_case${case_id}.ps
    if test $PRINTSDM = "YES"
    then
        lpr -h -P"$sdmprinter" sigvar_case{$case_id}.ps
    fi

    mv gifimage.png sigvar_case${case_id}.png

    if [ ${ltdiff} -gt 84 ]
    then
         grads -bpc "wsr_sigvar_notwsr_8panel_more.gs ${ensdate} ${obsdate} ${ltdiff} ${vnormgr} ${i}"
 
         #gxps -ic ec.out -o sigvar_case${case_id}_more.ps
         mv        ec.ps     sigvar_case${case_id}_more.ps
         if test $PRINTSDM = "YES"
         then
             lpr -h -P"$sdmprinter" sigvar_case${case_id}_more.ps
         fi

         mv gifimage.png sigvar_case${case_id}_more.png
    fi
    
    i=`expr ${i} + 1`
done

else

. $ETKFOUT/com/wsr/${envir}/wsr.$PDY/ltinfo.env

mk[2]=`expr ${mk2} - 1`
mk[3]=`expr ${mk3} - 1`
mk[4]=`expr ${mk4} - 1`
mk[5]=`expr ${mk5} - 1`
mk[6]=`expr ${mk6} - 1`
mk[7]=`expr ${mk7} - 1`
mk[8]=`expr ${mk8} - 1`
mk[9]=`expr ${mk9} - 1`
mk[10]=`expr ${mk10} - 1`

z=1
while test ${z} -le ${cases}
do
    lt1[z]=\$lt1case${z}
    lt2[z]=\$lt2case${z}
    z=`expr ${z} + 1`
done

j=`expr ${minlt1} / 12`
finish=`expr ${maxlt1} / 12`

while test ${j} -le ${finish}
do
   lt1=`expr ${j} \* 12`
mark=0 
ct=1
maxtotlt2=0
while test ${ct} -le ${cases}
do
    lt1val=`eval echo ${lt1[$ct]}`
    lt2val=`eval echo ${lt2[$ct]}`
    if [ ${lt1} -eq $lt1val ]
    then
        mark=1
        if [ $lt2val -gt ${maxtotlt2} ]
        then
            maxtotlt2=$lt2val
        fi
    fi
ct=`expr $ct + 1`
done

if [ $mark -eq 1 ]
then

   ltdiff=`expr ${maxtotlt2} - ${lt1}`
   ltdiffsteps=`expr ${ltdiff} / 12`
   if [ ${ltdiffsteps} -lt 7 ]
   then
           ltdiffsteps=7
   fi

   k=1
   while test ${k} -le ${mk[$j]}
   do

      . $ETKFOUT/com/wsr/${envir}/wsr.$PDY/flight${k}_${lt1}.env

      ctr=0
      while [ ${ctr} -le ${ltdiffsteps} ]
      do
  	  ctraddone=`expr ${ctr} + 1`
          cp ${COMIN}/flight${k}_${lt1}.sig${ctraddone}.ctl sig${ctraddone}.ctl
          #cat ${COMIN}/flight${k}_${lt1}.sig${ctraddone}.ctl | sed -e"s/OPTIONS template/OPTIONS big_endian template/" > sig${ctraddone}.ctl
	  cp ${COMIN}/flight${k}_${lt1}.sig${ctraddone}.d.gr sig${ctraddone}.d.gr
          ctr=`expr ${ctr} + 1`
      done

      cp ${COMIN}/flight${k}_${lt1}.dropplot.d dropplot.d

      i=1
      while test ${i} -le ${cases}
      do
         cp ${COMIN}/flight${k}_${lt1}.circlevr${i}.d circlevr${i}.d
         i=`expr ${i} + 1`
      done

      grads -bpc "wsr_sigvar_8panel.gs ${ensdate} ${obsdate} ${ifl} ${ndrops} ${ensemble} ${mem} ${vercase[1]} ${vercase[2]} ${vercase[3]} ${vercase[4]} ${vtime[1]} ${vtime[2]} ${vtime[3]} ${vtime[4]} ${vnormgr}"

      #gxps -ic ec.out -o sigvar_${lt1}_flight${ifl}.ps
      mv        ec.ps     sigvar_${lt1}_flight${ifl}.ps
      if test $PRINTSDM = "YES"
      then
         if [[ $lt1 -eq 24 || $lt1 -eq 48 || $lt1 -eq 72 ]] 
         then
         lpr -h -P"$sdmprinter" sigvar_${lt1}_flight${ifl}.ps
         fi
      fi

      mv gifimage.png sigvar_${lt1}_flight${ifl}.png
 
      if [ ${ltdiff} -gt 84 ]
      then

           grads -bpc "wsr_sigvar_8panel_more.gs ${ensdate} ${obsdate} ${ifl} ${ltdiff} ${ensemble} ${mem} ${vercase[1]} ${vercase[2]} ${vercase[3]} ${vercase[4]} ${vtime[1]} ${vtime[2]} ${vtime[3]} ${vtime[4]} ${vnormgr}"

           #gxps -ic ec.out -o sigvar_${lt1}_flight${ifl}_more.ps
           mv        ec.ps     sigvar_${lt1}_flight${ifl}_more.ps
           if test $PRINTSDM = "YES"
           then
               if [[ $lt1 -eq 24 || $lt1 -eq 48 || $lt1 -eq 72 ]]
               then
	       lpr -h -P"$sdmprinter" sigvar_${lt1}_flight${ifl}_more.ps
               fi 
           fi

           mv gifimage.png sigvar_${lt1}_flight${ifl}_more.png
      fi

      k=`expr ${k} + 1`
   done
 
   fi

   j=`expr ${j} + 1`
done

#lpr -h -P"$sdmprinter" done.txt

fi

#ping -c1 emc1
#pingerr=$?
#if test $pingerr -eq 0
#then
#ftp rzdm << ftpEOF
#cd /home/people/emc/www/htdocs/gmb/targobs/target/graphics
#mkdir $PDY
#cd $PDY
#bin
#prompt
#mput *.png
#bye
#ftpEOF

if [[ $testmode = no ]]; then

  ssh -l wx12sd ncorzdm "rm -rf  /home/people/nco/www/htdocs/pmb/sdm_wsr/graphics/${PDY}"
  ssh -l wx12sd ncorzdm "mkdir -p /home/people/nco/www/htdocs/pmb/sdm_wsr/graphics/${PDY}"
# uncomment these if needed
# ssh -l wx12sd ncorzdm "cp /home/people/nco/www/htdocs/pmb/sdm_wsr/graphics/allow.cfg /home/people/nco/www/htdocs/pmb/sdm_wsr/graphics/${PDY}"
# ssh -l wx12sd ncorzdm "cp /home/people/nco/www/htdocs/pmb/sdm_wsr/graphics/index.php /home/people/nco/www/htdocs/pmb/sdm_wsr/graphics/${PDY}"
  ssh -l wx12sd ncorzdm "cp $HOMEwsr/grads/allow.cfg /home/people/nco/www/htdocs/pmb/sdm_wsr/graphics/${PDY}"
  ssh -l wx12sd ncorzdm "cp $HOMEwsr/grads/index.php /home/people/nco/www/htdocs/pmb/sdm_wsr/graphics/${PDY}"
  scp *.png wx12sd@ncorzdm:/home/people/nco/www/htdocs/pmb/sdm_wsr/graphics/${PDY}

else

  ssh -l $testuser $testrzdm "rm -rf  $testdirectory/test$expid/graphics/${PDY}"
  ssh -l $testuser $testrzdm "mkdir -p $testdirectory/test$expid/graphics/${PDY}"
  scp *.png $testuser@$testrzdm:$testdirectory/test$expid/graphics/${PDY}

fi

#fi

#ssh -l ysong rzdm "mkdir -p /home/people/emc/www/htdocs/gmb/tparc/special/trop1_${PDY}_${ensemble}"
#scp *.png ysong@rzdm:/home/people/emc/www/htdocs/gmb/tparc/special/trop1_${PDY}_${ensemble}

#cp /nfsuser/g01/wx20ys/tobs/wsr/tmp/*.gr /nfsuser/g01/wx20ys/tobs/wsr/${PDY}/.
#cp /nfsuser/g01/wx20ys/tobs/wsr/tmp/*.d /nfsuser/g01/wx20ys/tobs/wsr/${PDY}/.

#rm -rf $DATA
set +x
echo "###############################################"
echo "#           Finished Processing               #"
echo "###############################################"
echo TEST EXIT HERE
env | sort
echo TEST EXIT after env
pwd
ls -alt
echo TEST EXIT after ls
exit

