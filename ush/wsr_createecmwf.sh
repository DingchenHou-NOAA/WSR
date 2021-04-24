#!/bin/ksh
##!/bin/sh
####################################################################################  UNIX Script Documentation Block
#                      .                                             .
# Script name:         wsr_createecmwf.sh
# Script description:  Extract ensemble information from grib files
#
# Author:        Yucheng Song       Org: EMC         Date: 2006-12-10
#
# Abstract: This script exploits the MPMD feature and generate files
#  from GENS products
#
# Script history log:
# 2006-12-10  Yucheng Song Implemented MPMD version for WSR project


sizeof() {
ls -ld "$1" | awk '{printf("%d\n",$5)}'
}
#NDATE=/nwprod/util/exec/ndate
#WGRIB=/nwprod/util/exec/wgrib
#COPYGB=/nwprod/util/exec/copygb
#curdate=`date '+%Y%m%d'`00
#ensdate=${curdate}
curdate=${PDY:?}00

# allow date offset for retrospective runs
DateOffset=${DateOffset:-00}
ensdate=$(${NDATE:?} $DateOffset $curdate)
WORK_ETKF=${WORK_ETKF:-$GESdir}
mkdir -p ${WORK_ETKF}
WORK_ENS=$DATA/work_ecm/${ensdate}

msleep=240
tsleep=60

ltloop1=`expr ${ltime1} / $fhint`
ltloop2=`expr ${ltime2} / $fhint`
tint=$ltloop1
i=1
while [[ ${tint} -le ${ltloop2} ]]
do
    fhr=$(expr ${tint} \* $fhint)
    tint=$(expr ${tint} + 1)
    date[$i]=$(${NDATE:?} +$fhr ${ensdate})
    echo ${date[$i]}
    ((i+=1))
done

((ntimes=i-1))

###########################################
# List of variables we want
###########################################
 (( nvar = 20 ))
            var[1]=":U:850 mb:"
            var[2]=":U:500 mb:"
            var[3]=":U:200 mb:"
            var[4]=":V:850 mb:"
            var[5]=":V:500 mb:"
            var[6]=":V:200 mb:"
            var[7]=":T:850 mb:"
            var[8]=":T:500 mb:"
            var[9]=":T:200 mb:"
            var[10]=":TP:"
            var[11]=":MSL:"
            var[12]=":GH:500 mb:"
            var[13]=":U:700 mb:"
            var[14]=":V:700 mb:"
            var[15]=":T:700 mb:"
#           var[16]=":T:925 mb:"
            var[16]="T:850 mb:"
            var[17]=":R:850 mb:"
            var[18]=":R:700 mb:"
            var[19]=":R:500 mb:"
#           var[20]=":PWAT:"
            var[20]=":R:500 mb:"

############################
# CALCULATE lt : LEAD TIME #
############################
dloop=${ensdate}
i=1
while [[ $i -le $ntimes ]]
do
   lt[$i]=00
   while [[ ${dloop} -lt ${date[$i]} ]]
   do
      lt[$i]=`expr ${lt[$i]} + $fhint`
      dloop=$(${NDATE:?} +${lt[$i]} ${ensdate})
   done
   i=`expr $i + 1`
done

if [[ $ifort -eq 1 ]]; then
#################
# ECMWF ENSEMBLE#
#################

date1=${ensdate}
date2=$(${NDATE:?} -6 ${ensdate})
date3=$(${NDATE:?} -12 ${ensdate})
date4=$(${NDATE:?} -18 ${ensdate})

PDY1=`echo $date1 | cut -c1-8`
PDY2=`echo $date2 | cut -c1-8`
PDY3=`echo $date3 | cut -c1-8`
PDY4=`echo $date4 | cut -c1-8`

eh1=`echo $date1 | cut -c9-10`
eh2=`echo $date2 | cut -c9-10`
eh3=`echo $date3 | cut -c9-10`
eh4=`echo $date4 | cut -c9-10`

[ -z "$DCOMROOT" ] && DCOMROOT=/dcom
#ecdir1=/dcom/us007003/${PDY1}/wgrbbul/ecmwf
#ecdir2=/dcom/us007003/${PDY2}/wgrbbul/ecmwf
#ecdir3=/dcom/us007003/${PDY3}/wgrbbul/ecmwf
#ecdir4=/dcom/us007003/${PDY4}/wgrbbul/ecmwf
ecdir1=${DCOMROOT}/prod/${PDY1}/wgrbbul/ecmwf
ecdir2=${DCOMROOT}/prod/${PDY2}/wgrbbul/ecmwf
ecdir3=${DCOMROOT}/prod/${PDY3}/wgrbbul/ecmwf
ecdir4=${DCOMROOT}/prod/${PDY4}/wgrbbul/ecmwf

i=1
while [[ $i -le $ntimes ]]
do
   ECDATE2[$i]=$(echo ${date[$i]} | cut -c5-10)
   echo ${ECDATE2[$i]}
   WORK=${WORK_ENS}/${lt[$i]}
   mkdir -p $WORK
   cd $WORK
#   for eh in $eh1 $eh3
    for eh in $eh1 
   do
       case "$eh" in
       "$eh1") 
        ecdir=$ecdir1; lta=$(expr 00 + ${lt[$i]});fnum_lt=10000
        ECDATE1=$(echo $date1 | cut -c5-10)
        ;;
       "$eh2") 
        ecdir=$ecdir2; lta=$(expr 06 + ${lt[$i]});fnum_lt=20000 
        ECDATE1=$(echo $date2 | cut -c5-10)
        ;;
       "$eh3") 
        ecdir=$ecdir3; lta=$(expr 12 + ${lt[$i]});fnum_lt=30000 
        ECDATE1=$(echo $date3 | cut -c5-10)
        ;;
       "$eh4") 
        ecdir=$ecdir4; lta=$(expr 18 + ${lt[$i]});fnum_lt=40000
        ECDATE1=$(echo $date4 | cut -c5-10)
        ;;
       *     ) 
       echo "Not yet implemented!"
        ;;
       esac
        [[ $lta -le 9 ]] && lta=0$lta

###################################
# Copygb to convert - default     #
###################################
       ensfile_lt=${ecdir}/DCE${ECDATE1}00${ECDATE2[$i]}001

       ls -l $ensfile_lt
       nsleep=0
       until [[ -s ${ensfile_lt} ]]; do
         [[ $((nsleep+=1)) -gt $msleep ]] && exit 1
           sleep $tsleep
       done
       filesiz=$(sizeof ${ensfile_lt})
    if [[ filesiz -ge 135000000 ]]; then 

       > ecens.inv 
       ${WGRIB:?} -s -PDS $ensfile_lt  >> ecens.inv

       (( itask = 0 ))
       (( varid = 1 ))
       /bin/rm ecmd.*
       while  (( varid <= nvar ))  
       do
         fnum=${fnum_lt}
         nm=0
         cmdfile=ecmd.$itask
         while [[ $nm -le $memec_eh ]]
         do
           [[ $nm -le 9 ]] && nm=0$nm
           hex=$(echo "obase=16;ibase=10; $nm" | bc)
           [[ $nm -le 15 ]] && hex=0${hex}
           
           cat << EOF >> $cmdfile
          /bin/egrep -i "${var[varid]}.*${hex}3300*" ecens.inv |cut -f1-2 -d :|${WGRIB:?} -i -grib $ensfile_lt -o ${WORK}/pgb.${fnum}
           if [[ $icopygb -eq 1 ]]; then
            ${COPYGB:?} -g2 -i1 -x pgb.${fnum} pgb_use.${fnum} 
            #rm pgb.${fnum}
            mv pgb_use.${fnum} pgb.${fnum}
           fi
           ${WGRIB:?} -s pgb.${fnum} |grep "${var[varid]}"|${WGRIB:?}  -i -text pgb.${fnum} -o fort.${fnum}
           #rm pgb.${fnum}
EOF
           fnum=$(expr $fnum + 1)
           nm=$(expr $nm + 1)
         done
         chmod a+x $cmdfile

         fnum_lt=$(expr 500 + $fnum_lt)
         (( varid = varid + 1 ))

         (( itask = itask + 1 ))
          if (( itask == MP_PROCS )); then
             (( itask = 0 ))
          fi

       done
         >ecmd.file
          chmod a+x ecmd.file
		  #echo "#!/bin/sh" >>ecmd.file
          (( itask = 0 ))
          while (( itask < MP_PROCS ))
          do
           ls -al ecmd.$itask
           if (( itask <= nvar )); then
           echo "sh -xa ecmd.$itask" >>ecmd.file
           else
           echo "date" >>ecmd.file
           fi
           (( itask = itask + 1 ))
          done

         #/usr/bin/poe -cmdfile ecmd.file -stdoutmode ordered -ilevel 3
         #$wsrmpexec -cmdfile ecmd.file -stdoutmode ordered -ilevel 3
         #$wsrmpexec  -n 32 -ppn 32 --cpu-bind core --configfile ecmd.file
		sh -xa ecmd.file
         #/bin/rm DCE*
    fi

   done
   i=$(expr $i + 1)
done

fi

#exit 0
#############################
# Create combined ensemble  #
#############################
export MP_PROCS=21
echo "Creating ECMWF ens.d ..."
     ((mem1=memec_eh+1))
     ((mem0=1*mem1))
      iens=2
cd ${WORK_ENS}
>reform.file
i=1
while [[ $i -le $ntimes ]]
do
   if [[ -d ${WORK_ENS}/${lt[$i]} ]]; then
     if (( i <= MP_PROCS)); then
     cmdfile=reform.$i
     else
     cmdfile=reform.$((i-MP_PROCS))
     fi
     cat << EEOF >>$cmdfile
     cd ${WORK_ENS}/${lt[$i]}
     #rm read.parm vble.dat
     echo "$iens ${lt[$i]} $mem1 $mem0 $nvar $idim $jdim" > read.parm
     #rm -rf  fort.112
     $EXECwsr/wsr_reformat <read.parm
     mv vble.dat ${WORK_ETKF}/ec${ensdate}_${lt[$i]}_ens.d
EEOF
   chmod a+x $cmdfile
   fi
   ((i+=1))
done
          ((itask = 1))
         while (( itask <= MP_PROCS ))
         do
           if(( itask <= ntimes )); then
             echo "sh -xua reform.$itask" >> reform.file
           else
             echo "date" >>reform.file
           fi
           ((itask+=1))
         done
  
   #/usr/bin/poe -cmdfile reform.file -stdoutmode ordered -ilevel 3
   #$wsrmpexec -cmdfile reform.file -stdoutmode ordered -ilevel 3
   #$wsrmpexec  -n 32 -ppn 32 --cpu-bind core --configfile reform.file
	sh -xa reform.file

   #/bin/rm reform.*
export MP_PROCS=16
exit
