#!/bin/bash

#################################################################################################
#
# Shell script to calculate Q0 and eta for single trace
# In order to calculate Q0 and eta:
# 	cd data
# 	./../run.sh
# it will calculate Q0 and eta for an event and write all the data in file 'Q_plot.txt'

#################################################################################################

#compiling fortran files
#gfortran -o ../scripts/Q_f_calc ../scripts/Q_f_calc.f90
#gfortran -o ../scripts/Q0_eta_calc ../scripts/Q0_eta_calc.f90
#w_dir=`pwd`
w_dir="/home/shubham/work/Coda_Q_SS/Single_trace_Q_n_Eta"

echo -e "\e[1;33mEnter lapse time window length\e[0m"
read lapse_time

echo -e "\e[1;33mDo you want plots? [y/n]\e[0m"
read resp

#enter the directory
for dir in 2* #loop 1
do
cd $dir

#set lapse time
#lapse_time=60

rm -f info.txt info_new.txt Q_data.txt 

#start loop in files
for file in v_*?HZ #loop 2
do

#getting P and S marker time
p_time=`sachead $file T1 | awk -F" " '{print $2}'`
s_time=`sachead $file T0 | awk -F" " '{print $2}'`



#beginning and end time of lapse window
amp_b_time=`echo $s_time | awk '{print $1 * 2.0}' | awk -F"." '{print $1}'`
amp_e_time=`echo $amp_b_time | awk -v jojo=$lapse_time '{print $1 + jojo}' | awk -F"." '{print $1}'` 

#reading frequency file
cat $w_dir/freq_file | while read f	#loop 3
#for f in 01 02 05 08 10 12 14	
do

#cut frequencies
fb=`echo $f | awk '{print $1-$1/3}'`
fe=`echo $f | awk '{print $1+$1/3}'`

#filter seismogram traces
dummy=`sac<<!
r $file
rtr
rmean
bp bu c $fb $fe n 3
w prepend f_${f}_
q
!`

#converting SAC to ASCII format
dummy=`sac2xy f_${f}_${file} f_${f}_${file}.xy`

#taking modulous of amplitude
cat f_${f}_${file}.xy | awk '{print $1 "    " sqrt($2*$2)}' > a_${f}_${file}.xy

#cutting file along the begin and end time of lapse window
cat a_${f}_${file}.xy | awk -v jojo=$amp_b_time '{ if($1 >= jojo) print $1, $2}' | awk -v jojo1=$amp_e_time '{ if($1 <= jojo1) print $1"    "$2}' > c_${f}_${file}.xy
 
file_len=`cat c_${f}_${file}.xy | wc -l`

# fortran program for calculating Q(f) here------------------------------
$w_dir/bin/Q_f_calc <<EOF
c_${f}_${file}.xy
$file_len
$f
EOF
echo -e "Q(f) calculated for \e[1;32m${f}_${file}\e[0m !!"
#this fortran script is making 2 files temp and temp2
#temp contains ""t_rms, log_amp_rms, m1*log_amp_rms + m2"" where m1 and m2 are slope and intercept calculated from linear regression
#temp2 contains ""Q, Qe, freq, m1, m2, sqrt(Var_a), sqrt(Var_b), RR, ss""
#-------------------------------------------------------------------------

#here file "p_${f}_${file}.xy" is for plotting t_rms Vs Log_amp_rms
cat temp > p_${f}_${file}.xy
ss=`cat temp2` 
echo p_${f}_${file}.xy $ss >> info.txt #combining all parameters in this file
rm temp temp2 c_${f}_${file}* f_${f}_${file}* a_${f}_${file}.xy

done #loop 3 end 

###################################################################################################################
#here we will check for negative Q values of Q with very large error
#if Q is negative then it will be discarded and rest of the Q will be used
#if remaining Q after discarding are less than 5 then it will not go for calculating Q0 and eta

#reading file
cat info.txt | while read line
do
#fname=`echo $line | awk -F" " '{print $1}' | awk -F"_" '{print $3"_"$4"_"$5"_"$6}' | awk -F"." '{print $1"."$2}'`  

#if [ $fname == $file ]
#then
	Qhalf=`echo $line | awk -F" " '{print $2*0.5}'| awk -F"." '{print $1}'`
	Qe=`echo $line | awk -F" " '{print $3}'| awk -F"." '{print $1}'`
	
	if [ "$Qhalf" -ge "$Qe" ]
	then
	echo $line >> temp3
	fi
#fi

done

info_len=`cat temp3 | wc -l`

#checking for more than 5 data
if [ $info_len -ge 5 ]
then

# fortran program for calculating Q0 and eta here---------------------
$w_dir/bin/Q0_eta_calc <<EOF
temp3
$info_len
EOF
#fortran end here it will give two files temp4 and temp5
#temp4 contains ""log_f, log_Q, m1*log_f + m2, Var_log_Q, SD_log_Q""
#temp5 contains ""Q0, err_Q0, eta, err_eta, m1, m2, Var_a, Var_b""
#---------------------------------------------------------------------
echo
echo -e "Q0 calculated for \e[1;36m$file\e[0m with Lapsetime \e[1;36m$lapse_time\e[0m"
echo
#making temporary files permenent
cat temp4 > final_${file}.xy
cat temp3 >> info_new.txt
 
ss1=`cat temp5`
echo final_${file}.xy $ss1 >> Q_data.txt
rm -f temp5 temp3 temp4 info.txt

else 
echo -e "\e[1;31mQ is negative for $file... discarding...\e[0m"
echo $file >> ../no_plot
rm -f temp5 temp3 temp4 info.txt
fi
####################################################################################################################

done #loop 2 end

if [ $resp = "y" ] || [ $resp = "Y" ]; then

#plotting t_rms Vs log_amp_rms (this is optional, this can be turned off)
python $w_dir/plot/t_amp_plot.py
echo
echo -e "\e[1;32mt Vs Amp plotting done!!\e[0m"
echo

#plotting log_f Vs log_Q (this is also optional, this can be turned off)
if [ -f Q_data.txt ]
then
python $w_dir/plot/f_Q_plot.py
echo -e "\e[1;32mLog_freq Vs Log_Q plotting done!!\e[0m"
echo
fi

else
echo -e "\e[1;31mNot plotting\e[0m"
fi

rm -f final*xy

cd ..
done #loop 1 end






