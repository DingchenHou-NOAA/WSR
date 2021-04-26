#!/bin/ksh
####################################################################################  UNIX Script Documentation Block
#                      .                                             .
# Script name:         wsr_createcmc.sh
# Script description:  Extract ensemble information from grib files
#
# Author:        Yucheng Song       Org: EMC         Date: 2006-12-10
#
# Abstract: This script exploits the MPMD feature and generate files
#  from GENS products
#
# Script history log:
# 2006-12-10  Yucheng Song Implemented MPMD version for WSR project
# 2007-12-10  Yucheng Song Added new features of MPMD
# 2008-07-16  Yucheng Song configured this for T-PARC usage 

set -x

curdate=${PDY:?}00

# allow date offset for retrospective runs
DateOffset=${DateOffset:-00}
ensdate=$(${NDATE:?} $DateOffset $curdate)
WORK_ETKF=${WORK_ETKF:-$GESdir}
mkdir -p ${WORK_ETKF}
WORK_ENS=$DATA/work_cmc/${ensdate}

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
	# CMC  ENSEMBLE #
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

	cmcdir1=${DATA}/cmce.${PDY1}/${eh1}/pgrba
	cmcdir2=${DATA}/cmce.${PDY2}/${eh2}/pgrba
	cmcdir3=${DATA}/cmce.${PDY3}/${eh3}/pgrba
	cmcdir4=${DATA}/cmce.${PDY4}/${eh4}/pgrba

	i=1
	while [[ $i -le $ntimes ]]
	do
		WORK=${WORK_ENS}/${lt[$i]}
		mkdir -p $WORK
		cd $WORK
		#  for eh in $eh1 $eh2 $eh3 $eh4
		for eh in $eh1 $eh3
		do
			if [[ $eh -eq $eh1 ]];then cmcdir=$cmcdir1;lta=`expr 00 + ${lt[$i]}`; fi
			if [[ $eh -eq $eh2 ]];then cmcdir=$cmcdir2;lta=`expr 06 + ${lt[$i]}`; fi
			if [[ $eh -eq $eh3 ]];then cmcdir=$cmcdir3;lta=`expr 12 + ${lt[$i]}`; fi
			if [[ $eh -eq $eh4 ]];then cmcdir=$cmcdir4;lta=`expr 18 + ${lt[$i]}`; fi
			   [[ $eh -eq $eh1 ]] && fnum_lt=10000
			   [[ $eh -eq $eh2 ]] && fnum_lt=20000
			   [[ $eh -eq $eh3 ]] && fnum_lt=30000
			   [[ $eh -eq $eh4 ]] && fnum_lt=40000
			   [[ $lta -le 9 ]] && lta=0$lta

			###################################
			# Copygb to convert - default     #
			###################################

			if [[ $icopygb -eq 1 ]]; then
				(( itask = 0 ))
				/bin/rm ncopy.*
				nm=0
				while [[ $nm -le $memcm_eh ]]
				do
					[[ $nm -le 9 ]] && nm=0$nm
					ensfile_lt=${cmcdir}/cmc_gep${nm}.t${eh}z.pgrbaf$lta
					[[ $nm -eq 00 ]] && ensfile_lt=${cmcdir}/cmc_gec00.t${eh}z.pgrbaf$lta
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
					if (( itask <= memcm_eh)); then
						echo "sh -xa ncopy.$itask" >>poescript
					else
						echo "date" >>poescript
					fi
					(( itask = itask + 1 ))
 
				done
				#poe -cmdfile poescript -stdoutmode ordered -ilevel 3
				#$wsrmpexec -cmdfile poescript -stdoutmode ordered -ilevel 3
				$wsrmpexec  -n 32 -ppn 32 --cpu-bind core --configfile  poescript
			fi



			(( itask = 0 ))
			(( varid = 1 ))
			/bin/rm ccmd.*
			while  (( varid <= nvar ))
			do
				fnum=${fnum_lt}
				nm=0
				cmdfile=ccmd.$itask
				while [[ $nm -le $memcm_eh ]]
				do
					[[ $nm -le 9 ]] && nm=0$nm
					ensfile_lt=${cmcdir}/cmc_gep${nm}.t${eh}z.pgrbaf$lta
					[[ $nm -eq 00 ]] && ensfile_lt=${cmcdir}/cmc_gec00.t${eh}z.pgrbaf$lta
					usefile=gens${nm}.t${eh}z.pgrbaf$lta
					cat <<- EOF >>$cmdfile
						${WGRIB:?} -s -ncep_opn $usefile | grep "${var[$varid]}" | ${WGRIB:?} -i -ncep_opn -text $usefile -o ${WORK}/fort.${fnum}
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

			>ccmd.file
			chmod a+x ccmd.file
			(( itask = 0 ))
			while (( itask < MP_PROCS ))
			do
				ls -al ccmd.$itask
				if (( itask <= nvar )); then
					echo "sh -xa $WORK/ccmd.$itask" >>ccmd.file
				else
					echo "date" >>ccmd.file
				fi
				(( itask = itask + 1 ))
			done

			#poe -cmdfile ccmd.file -stdoutmode ordered -ilevel 3
			#$wsrmpexec -cmdfile ccmd.file -stdoutmode ordered -ilevel 3
			$wsrmpexec  -n 32 -ppn 32 --cpu-bind core --configfile  ccmd.file
		done
		i=$(expr $i + 1)
	done

fi

#############################
# Create combined ensemble  #
#############################
export MP_PROCS=21
echo "Creating CMC ens.d ..."
((mem1=memcm_eh+1))
((mem0=2*mem1))
iens=3
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
		cat <<- EOF >>$cmdfile
			cd ${WORK_ENS}/${lt[$i]}
			#rm read.parm vble.dat
			echo "$iens ${lt[$i]} $mem1 $mem0 $nvar $idim $jdim" > read.parm
			#rm -rf  fort.112
			$EXECwsr/wsr_reformat <read.parm
			cp vble.dat ${WORK_ETKF}/cm${ensdate}_${lt[$i]}_ens.d
		EOF
		chmod a+x $cmdfile
   fi
   ((i+=1))
done

################################
# Do some padding if necessary #
################################

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
 
   #poe -cmdfile reform.file -stdoutmode ordered -ilevel 3
   #$wsrmpexec -cmdfile reform.file -stdoutmode ordered -ilevel 3
chmod a+x reform.file
$wsrmpexec  -n 32 -ppn 32 --cpu-bind core --configfile reform.file
# /bin/rm reform.*
export MP_PROCS=16

exit 0
