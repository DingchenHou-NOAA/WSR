#####################################################
# Script: wsr_creategfs_1p0.sh
# Abstract: convert GEFS from 0.5d grib2 to 1.0d grib2
#####################################################
set -x

cd $DATA

#NDATE=/nwprod/util/exec/ndate
#COPYGB2=/nwprod/util/exec/copygb2
#CNVGRIB=/nwprod/util/exec/cnvgrib

grid2="0 6 0 0 0 0 0 0 360 181 0 0 90000000 0 48 -90000000 359000000 1000000 1000000 0"

hourlist="000 006 012 018 024 030 036 042 048 054 060 066 072 078 084 090 096 \
          102 108 114 120 126 132 138 144 150 156 162 168 174 180 186 192 198 204 \
          210 216 222 228 234 240 246 252 258 264 270 276 282 288 294 300 306 312 \
          318 324 330 336 342 348 354 360 366 372 378 384" 

memberlist="p01 p02 p03 p04 p05 p06 p07 p08 p09 p10 \
            p11 p12 p13 p14 p15 p16 p17 p18 p19 p20 \
            p21 p22 p23 p24 p25 p26 p27 p28 p29 p30 c00"

#curdate=`date '+%Y%m%d'`00
#ensdate=$(${NDATE:?} $DateOffset $curdate)
ensdate=$PDY$cyc

date1=${ensdate}
date2=$(${NDATE:?} -6 ${ensdate})
date3=$(${NDATE:?} -12 ${ensdate})
date4=$(${NDATE:?} -18 ${ensdate})

echo $date1 $date2 $date3 $date4

# JY for CDATE in $date1 $date2 $date3 $date4; do
#### for CDATE in $date1  $date3; do
for CDATE in $date1 $date2 $date3 $date4; do

  PDY=`echo $CDATE | cut -c1-8`
  cyc=`echo $CDATE | cut -c9-10`
  echo " day " $PDY$cyc

  mkdir -p $DATA/gefs.$PDY/$cyc/pgrb2a1p0    # 1.0d GRIB2 tmp output

# interpolate 0.5d GEFS ensmebla GRIB2 to 1.0d GRIB2  
#
  for mem in ${memberlist}; do
    if [ -s poe_copygb_${mem}.$PDY$cyc ]; then
      rm poe_copygb_${mem}.$PDY$cyc
    fi
    for nfhrs in $hourlist; do
      infile=${COMINgens}/gefs.${PDY}/$cyc/atmos/pgrb2ap5/ge${mem}.t${cyc}z.pgrb2a.0p50.f${nfhrs}    
      outfile=$DATA/gefs.$PDY/$cyc/pgrb2a1p0/ge${mem}.t${cyc}z.pgrb2a.1p00.f${nfhrs}            
      if [ -s $infile ]; then 
        echo "${COPYGB2:?} -g \" $grid2 \" -x $infile $outfile" >> poe_copygb_${mem}.$PDY$cyc
      else
        echo " echo "There is no $infile, Skip" "           >> poe_copygb_${mem}.$PDY$cyc
      fi
    done
    chmod +x poe_copygb_${mem}.$PDY$cyc
    startmsg

	#cd $PBS_O_WORKDIR
	
    $wsrmpexec -n 32 -ppn 32 --cpu-bind core --configfile poe_copygb_${mem}.$PDY$cyc
    export err=$?; err_chk
  done

done

set +x
echo " "
echo "Leaving script wsr_creategfs_1p0.sh"
echo " "
set -x

