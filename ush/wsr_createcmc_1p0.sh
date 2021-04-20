#####################################################
# Script: wsr_createcmc_1p0.sh
# Abstract: convert CMC from 0.5d grib2 to 1.0d grib1
# Author: Bo Cui
# Sept. 07, 2018
#####################################################
set -x

cd $DATA

#NDATE=/nwprod/util/exec/ndate
#COPYGB2=/nwprod/util/exec/copygb2
#CNVGRIB=/nwprod/util/exec/cnvgrib

grid2="0 6 0 0 0 0 0 0 360 181 0 0 90000000 0 48 -90000000 359000000 1000000 1000000 0"

hourlist=" 00  12  24  36  48  60  72  84  96 \
          108 120 132 144 156 168 180 192 204 \
          216 228 240 252" 

memberlist="p01 p02 p03 p04 p05 p06 p07 p08 p09 p10 \
            p11 p12 p13 p14 p15 p16 p17 p18 p19 p20 c00"

#curdate=`date '+%Y%m%d'`00
#ensdate=$(${NDATE:?} $DateOffset $curdate)
ensdate=$PDY$cyc

date1=${ensdate}
date2=$(${NDATE:?} -6 ${ensdate})
date3=$(${NDATE:?} -12 ${ensdate})
date4=$(${NDATE:?} -18 ${ensdate})

echo $date1 $date2 $date3 $date4

# JY for CDATE in $date1 $date2 $date3 $date4; do
for CDATE in $date1  $date3; do

  PDY=`echo $CDATE | cut -c1-8`
  cyc=`echo $CDATE | cut -c9-10`
  echo " day " $PDY$cyc

  mkdir -p $DATA/cmce.$PDY/$cyc/pgrb2a
  mkdir -p $DATA/cmce.$PDY/$cyc/pgrba

# interpolate 0.5d CMC ensmebla GRIB2 to 1.0d GRIB2  
#
  for mem in ${memberlist}; do
    if [ -s poe_copygb_${mem}.$PDY$cyc ]; then
      rm poe_copygb_${mem}.$PDY$cyc
    fi
    for nfhrs in $hourlist; do
      infile=${COMINcmce}/cmce.${PDY}/$cyc/pgrb2ap5/cmc_ge${mem}.t${cyc}z.pgrb2a.0p50.f${nfhrs}    
      if [ $nfhrs -lt 100 ]; then
        infile=${COMINcmce}/cmce.${PDY}/$cyc/pgrb2ap5/cmc_ge${mem}.t${cyc}z.pgrb2a.0p50.f0${nfhrs}    
      fi
      outfile=$DATA/cmce.$PDY/$cyc/pgrb2a/cmc_ge${mem}.t${cyc}z.pgrb2a.f${nfhrs}            
      if [ -s $infile ]; then 
        echo "${COPYGB2:?} -g \" $grid2 \" -x $infile $outfile" >> poe_copygb_${mem}.$PDY$cyc
      else
        echo " echo "There is no $infile, Skip" "           >> poe_copygb_${mem}.$PDY$cyc
      fi
    done
    chmod +x poe_copygb_${mem}.$PDY$cyc
    startmsg
    $wsrmpexec  -n 32 -ppn 32 --cpu-bind core --configfile poe_copygb_${mem}.$PDY$cyc
    export err=$?; err_chk
  done


# convert 1.0d CMC ensmebla GRIB2 to 1.0d GRIB1  
#
  for mem in ${memberlist}; do
    if [ -s poe_cnvgrib_${mem}.$PDY$cyc ]; then
      rm poe_cnvgrib_${mem}.$PDY$cyc
    fi
    for nfhrs in $hourlist; do
      infile=$DATA/cmce.${PDY}/$cyc/pgrb2a/cmc_ge${mem}.t${cyc}z.pgrb2a.f${nfhrs}    
      # JY outfile=$DATA/cmce.$PDY/$cyc/pgrba/cmc_ge${mem}.t${cyc}z.pgrba.f${nfhrs}            
      outfile=$DATA/cmce.$PDY/$cyc/pgrba/cmc_ge${mem}.t${cyc}z.pgrbaf${nfhrs}            
      if [ -s $infile ]; then 
        echo "${CNVGRIB:?} -g21 $infile $outfile"      >> poe_cnvgrib_${mem}.$PDY$cyc
      else
        echo " echo "There is no $infile; Skip" "  >> poe_cnvgrib_${mem}.$PDY$cyc
      fi
    done
    chmod +x poe_cnvgrib_${mem}.$PDY$cyc
    startmsg
    $wsrmpexec -n 32 -ppn 32 --cpu-bind core --configfile poe_cnvgrib_${mem}.$PDY$cyc
    export err=$?; err_chk
  done

done

set +x
echo " "
echo "Leaving script wsr_createcmc_1p0.sh"
echo " "
set -x

