#!/bin/bash
# 
# install wsr executables for dell
#
dirpwd=`pwd`
execlist="calcperts calcspread circlevr dtsset flights_allnorms rawin_allnorms reformat"
execlist="$execlist sig_pac sigvar_allnorms summ_allnorms tcoeffuvt tgr_special xvvest_allnorms"
echo execlist=$execlist
echo
execdir=../exec
if [[ -d $execdir ]]; then
  dtg=`date +%Y%m%d%H%M%S`
  mv $execdir $execdir.$dtg
  rc=$?
else
  rc=0
fi
if (( rc == 0 )); then
  mkdir -p $execdir
  if (( rc != 0 )); then
    echo mkdir -p $execdir FAILED rc=$?
    exit
  fi
else
  echo mv $execdir $execdir.$dtg FAILED rc=$?
  exit
fi
execdir=../$execdir
echo execdir=$execdir from inside sorc
echo
ns=0
nf=0
failstring=
for exec in $execlist
do
  echo "`date`   $exec   begin"
  sorcdir=wsr_${exec}.fd
  cd $sorcdir
  rc=$?
  if (( rc == 0 )); then
    wexec=wsr_$exec
    ls -al $wexec
    rc=$?
    if (( rc == 0 )); then
      echo mv $wexec $execdir before
      mv $wexec $execdir
      rc=$?
      echo mv $wexec $execdir after
    fi
    echo in $sorcdir
    if (( rc == 0 )); then
      ls -al $execdir/$wexec
      echo install $wexec succeeded
      (( ns = ns + 1 ))
    else
      echo install $wexec FAILED rc=$?
      (( nf = nf + 1 ))
      failstring="$failstring $exec"
    fi
  else
    echo cd $sorcdir FAILED rc=$rc
  fi
  cd $dirpwd
  echo "`date`   $exec   end"
  echo
done
echo install succeeded for $ns codes
echo install failed for $nf codes $failstring
echo

exit
done

