#!/bin/bash

rm -f ellipse_para.dat sorted_cata.txt 
w_dir="/home/shubham/work/Coda_Q_SS/Single_trace_Q_n_Eta"

cat cata.txt | while read line
do

file=`echo $line | awk -F" " '{print $1}'`
elat=`echo $line | awk -F" " '{print $4}'`
elong=`echo $line | awk -F" " '{print $5}'`
slat=`echo $line | awk -F" " '{print $6}'`
slong=`echo $line | awk -F" " '{print $7}'`
tmax1=`echo $line | awk -F" " '{print $8}'`

tmax=`echo $tmax1 | awk '{print $1 + 30}'`
majxis=`echo $tmax | awk '{print $1 * 3.5 * 0.00899928005}'`
c_lat=`echo $elat $slat | awk '{print ($1 + $2) * 0.5}'`
c_long=`echo $elong $slong | awk '{print ($1 + $2) * 0.5}'`

tmp=`python $w_dir/scripts/azcalc.py <<EOF
$elat $elong
$slat $slong
EOF`
echo $tmp
t=`echo $tmp | awk -F" " '{print $1}'| awk -F"=" '{print $2}'`
az=`echo $tmp | awk -F" " '{print $4}'| awk -F"=" '{print $2}'`

minxis1=`echo $majxis $t | awk '{print sqrt(($1 * $1 * 0.25)-($2 * $2 * 0.25))}'`
minxis=`echo $minxis1 | awk '{print $1*2}'`

mj=`echo $majxis | awk -F"." '{print $1}'`
if [ $mj -le 8 ]
then
echo $file $elat $elong $slat $slong $c_lat $c_long $t $majxis $minxis $az >> ellipse_para.dat
echo $line >> sorted_cata.txt
fi
done
