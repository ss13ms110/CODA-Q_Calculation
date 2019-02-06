#!/bin/bash
rm -f innsuff.dat suff.dat
for dir in 2*
do
cd $dir

for file in v_*
do

t1=`sachead $file T4 | awk -F" " '{print $2*2}'`
t2=`echo $t1 | awk '{print $1+40.0}'`
c1=`sachead $file T1 | awk -F" " '{print $2}'`
c2=`echo $c1 | awk '{print $1-10.0}'`
echo $file
echo $t1, $t2, $c1, $c2

tc=`echo $t1 | awk -F"." '{print $1}'`

if [ $tc -le 500 ]
then

rm -f tmp*
dummy=`sac <<!
r $file
rtr 
rmean
cut $t1 $t2
r
taper type cosine width 0.1
w tmp
cut off
r tmp
fft
wsp am

r $file
cut $c2 $c1
r
taper type cosine width 0.1
w tmpN
cut off
r tmpN
fft
wsp am
quit
!`

#converting to ASCII format
sac2xy tmp.am tmp.am.xy
sac2xy tmpN.am tmpN.am.xy

cat tmp.am.xy | awk '{if ($1 > 0.25) print $1 " " $2}' | awk '{if ($1 < 20.0) print $1 " " $2}' > tmp1
cat tmpN.am.xy | awk '{if ($1 > 0.25) print $1 " " $2}' | awk '{if ($1 < 20.0) print $1 " " $2}' > tmpN1

file_len=`cat tmp1 | wc -l`
rms1=`rms<<EOF
tmp1
$file_len
EOF`

file_len=`cat tmpN1 | wc -l`
rmsN=`rms<<EOF
tmpN1
$file_len
EOF`

snr=`echo $rms1 $rmsN | awk '{print $1/$2}' | awk -F"." '{print $1}'`

if [ $snr -lt 4 ]
then
	echo $file $snr >> ../innsuff.dat
else
	echo $file $snr >> ../suff.dat
fi

rm -r tmp*
else
echo "-------------------ELIMINATING-------------------"
echo $file $snr >> ../innsuff.dat
rm $file
fi
done
cd ..
done
