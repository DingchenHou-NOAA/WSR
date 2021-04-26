#!/bin/ksh
################################################################################
####  UNIX Script Documentation Block
#                      .                                             .
# Script name:         wsr_creategfs.sh
# Script description:  Extract ensemble information from grib files 
#
# Author:        Yucheng Song       Org: EMC         Date: 2006-12-10
#
# Abstract: This script exploits the MPMD feature and generate files 
#  from GENS products 
#
# Script history log:
# 2006-12-10  Yucheng Song Implemented MPMD version for WSR project

set -x

curdate=${PDY:?}00

# allow date offset for retrospective runs
DateOffset=${DateOffset:-00}
ensdate=$(${NDATE:?} $DateOffset $curdate)
WORK_ETKF=${WORK_ETKF:-$GESdir}
mkdir -p ${WORK_ETKF}
WORK_ENS=$DATA/work_gfs/${ensdate}

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
var[1]=":UGRD:850 mb:"
var[2]=":UGRD:500 mb:"
var[3]=":UGRD:200 mb:"
var[4]=":VGRD:850 mb:"
var[5]=":VGRD:500 mb:"
var[6]=":VGRD:200 mb:"
var[7]=":TMP:850 mb:"
var[8]=":TMP:500 mb:"
var[9]=":TMP:200 mb:"
var[10]=":APCP:"
var[11]=":PRMSL:"
var[12]=":HGT:500 mb:"
var[13]=":UGRD:700 mb:"
var[14]=":VGRD:700 mb:"
var[15]=":TMP:700 mb:"
var[16]=":TMP:925 mb:"
var[17]=":RH:850 mb:"
var[18]=":RH:700 mb:"
var[19]=":RH:500 mb:"
var[20]=":PWAT:"

################################
# CALCULATE lt : LEAD TIME HRS #
################################
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
	# NCEP ENSEMBLE #
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

	ncdir1=${DATA}/gefs.${PDY1}/${eh1}/pgrb2a1p0
	ncdir2=${DATA}/gefs.${PDY2}/${eh2}/pgrb2a1p0
	ncdir3=${DATA}/gefs.${PDY3}/${eh3}/pgrb2a1p0
	ncdir4=${DATA}/gefs.${PDY4}/${eh4}/pgrb2a1p0

	i=1
	while [[ $i -le $ntimes ]]
	do
		WORK=${WORK_ENS}/${lt[$i]}
		mkdir -p $WORK
		cd $WORK
		for eh in $eh1 $eh2 $eh3 $eh4
		do
			if [[ $eh -eq $eh1 ]]; then ncdir=$ncdir1; lta=`expr 00 + ${lt[$i]}`; fi
			if [[ $eh -eq $eh2 ]]; then ncdir=$ncdir2; lta=`expr 06 + ${lt[$i]}`; fi
			if [[ $eh -eq $eh3 ]]; then ncdir=$ncdir3; lta=`expr 12 + ${lt[$i]}`; fi
			if [[ $eh -eq $eh4 ]]; then ncdir=$ncdir4; lta=`expr 18 + ${lt[$i]}`; fi
			   [[ $eh -eq $eh1 ]] && fnum_lt=10000
			   [[ $eh -eq $eh2 ]] && fnum_lt=20000
			   [[ $eh -eq $eh3 ]] && fnum_lt=30000
			   [[ $eh -eq $eh4 ]] && fnum_lt=40000
			   [[ $lta -le 9 ]] && lta=0$lta

			lta_3=$lta    # three digit fcst hours
			[[ $lta_3 -le 99 ]] && lta_3=0$lta_3
			lta=$lta_3
			###################################
			# Copygb to convert - default     #
			###################################

			if [[ $icopygb -eq 1 ]]; then
				(( itask = 0 ))
				/bin/rm ncopy.*
				nm=0
				while [[ $nm -le $memrf_eh ]]
				do
					[[ $nm -le 9 ]] && nm=0$nm
					ensfile_lt2=${ncdir}/gep${nm}.t${eh}z.pgrb2a.1p00.f$lta
					[[ $nm -eq 00 ]] && ensfile_lt2=${ncdir}/gec00.t${eh}z.pgrb2a.1p00.f$lta

					ensfile_lt=ge${nm}.t${eh}z.pgrbaf$lta
					echo "${CNVGRIB:?} -g21 $ensfile_lt2 $ensfile_lt" >>ncopy.$itask
					usefile=gens${nm}.t${eh}z.pgrbaf$lta
					echo "${COPYGB:?} -g2 -i1 -x ${ensfile_lt} $usefile" >>ncopy.$itask
					chmod a+x ncopy.$itask
					(( itask = itask + 1 ))
					if (( itask == MP_PROCS )); then
						(( itask = 0 ))
					fi
					nm=$(expr $nm + 1)
				done

				>poescript
				chmod a+x poescript
				(( itask = 0 ))
				while (( itask < MP_PROCS ))
				do
					ls -al ncopy.$itask
					if (( itask <= memrf_eh )); then
						echo "sh -xa ncopy.$itask" >>poescript
					else
						echo "date" >>poescript
				   fi
				   (( itask = itask + 1 ))

				done
				#poe -cmdfile poescript -stdoutmode ordered -ilevel 3
				#$wsrmpexec -cmdfile poescript -stdoutmode ordered -ilevel 3
				$wsrmpexec -n 32 -ppn 32 --cpu-bind core --configfile poescript
			fi

			(( itask = 0 ))
			(( varid = 1 ))
			/bin/rm ncmd.*
			while  (( varid <= nvar ))
			do
				fnum=${fnum_lt}
				nm=0
				cmdfile=ncmd.$itask
				while [[ $nm -le $memrf_eh ]]
				do
					[[ $nm -le 9 ]] && nm=0$nm
					ensfile_lt=${ncdir}/gep${nm}.t${eh}z.pgrbaf$lta
					[[ $nm -eq 00 ]] && ensfile_lt=${ncdir}/gec00.t${eh}z.pgrbaf$lta
					usefile=gens${nm}.t${eh}z.pgrbaf$lta
					cat >>$cmdfile <<- EOF
						${WGRIB:?} -s -ncep_opn $usefile | grep "${var[varid]}" |${WGRIB:?} -i -ncep_opn -text $usefile  -o ${WORK}/fort.${fnum}
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
			>ncmd.file
			chmod a+x ncmd.file
			(( itask = 0 ))
			while (( itask < MP_PROCS ))
			do
				ls -al ncmd.$itask
				if (( itask <= nvar )); then
					echo "sh -xa ncmd.$itask" >>ncmd.file
				else
					echo "date" >>ncmd.file
				fi
				(( itask = itask + 1 ))
			done

			#poe  -cmdfile ncmd.file  -stdoutmode ordered -ilevel 2
			#$wsrmpexec  -cmdfile ncmd.file  -stdoutmode ordered -ilevel 2
			$wsrmpexec   -n 32 -ppn 32 --cpu-bind core --configfile ncmd.file
			/bin/rm gens*.t${eh}z.pgrbaf$lta
		done
		i=$(expr $i + 1)

	done

fi
#############################
# Create combined ensemble  # 
#############################
echo "Creating NCEP ens.d ..."
((mem1=memrf_eh+1))
((mem0=4*mem1))
iens=1

export MP_PROCS=21
cd ${WORK_ENS}
>reform.file
i=1
while [[ $i -le $ntimes ]]
do
	if [[ -d ${WORK_ENS}/${lt[$i]} ]]; then
		if (( i <= MP_PROCS)); then
			cmdfile=reform.$i
			>$cmdfile
		else
			cmdfile=reform.$((i-MP_PROCS))
		fi
		chmod a+x $cmdfile
		cat <<- EEOF >>$cmdfile
			cd ${WORK_ENS}/${lt[$i]}
			#rm read.parm vble.dat
			echo "$iens ${lt[$i]} $mem1 $mem0 $nvar $idim $jdim" > read.parm
			#rm -rf  fort.112
			$EXECwsr/wsr_reformat <read.parm
			mv vble.dat ${WORK_ETKF}/nc${ensdate}_${lt[$i]}_ens.d
			EEOF

	fi
	((i+=1))
done

((itask = 1))
while (( itask <= MP_PROCS ))
do
	if(( itask <= ntimes )); then
		echo "sh -xa reform.$itask" >> reform.file
	else
		echo "date" >>reform.file
	fi
	((itask+=1))
done

#/usr/bin/poe -cmdfile reform.file -stdoutmode ordered -ilevel 3
#$wsrmpexec -cmdfile reform.file -stdoutmode ordered -ilevel 3
$wsrmpexec  -n 32 -ppn 32 --cpu-bind core --configfile reform.file
# /bin/rm reform.*
export MP_PROCS=16

exit
