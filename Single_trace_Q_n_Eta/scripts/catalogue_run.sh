#!/bin/bash

w_dir="/home/shubham/work/Coda_Q_SS/Single_trace_Q_n_Eta"
echo "Working..."
echo
for d in 2*
do 

cd $d
rm -f data.txt
cp $w_dir/freq_file ./
for f in v_*?HZ
do

elat=`sachead $f EVLA | awk -F" " '{print $2}'`
elong=`sachead $f EVLO | awk -F" " '{print $2}'`
slat=`sachead $f STLA | awk -F" " '{print $2}'`
slong=`sachead $f STLO | awk -F" " '{print $2}'`
ts=`sachead $f T0 | awk -F" " '{print $2}' | awk '{print $1*2.0}'`
depth=`sachead $f EVDP | awk -F" " '{print $2}'`
dist=`sachead $f DIST | awk -F" " '{print $2}'`
echo $elat $elong $slat $slong $ts $dist $depth  >> data.txt

done

if [ -f info_new.txt ]
then
python $w_dir/scripts/catalogue_make.py
fi
cd .. 
done

echo
echo "making final catalogue 'cata.txt'..."

rm -f cata.txt
for d in 2*
do

if [ -f $d/pre_cata.txt ]
then
cat $d/pre_cata.txt >> cata.txt
rm -f $d/pre_cata.txt
fi

done
echo
echo "catalogue complete!!"
echo
