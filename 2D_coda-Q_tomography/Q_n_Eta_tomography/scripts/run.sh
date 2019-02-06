#!/bin/bash

w_dir="/home/shubham/work/Coda_Q_SS/2D_coda-Q_tomography/Q_n_Eta_tomography"

#run python script to calculate weightage area of ellipse in each square
python $w_dir/scripts/weight.py

#compile fortran file to calculate backprojection tomography
#gfortran -o $w_dir/back_tomo $w_dir/back_proj_tomo.f90

#calculate the total number of event-receiver paths we have
N=`cat sorted_cata.txt | wc -l`

#run for all frequencies in a one go
for i in 01 02 03 05 08 10 12 14
do
echo
echo "working on frequency" $i
$w_dir/bin/back_proj_tomo $i $N
done

#run python script to find Q0 and eta tomography
python $w_dir/scripts/q0_calc.py
