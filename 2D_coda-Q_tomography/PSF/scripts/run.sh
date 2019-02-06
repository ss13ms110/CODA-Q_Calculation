#!/bin/bash

w_dir="/home/shubham/work/Coda_Q_SS/2D_coda-Q_tomography/PSF/"

echo "Do you have the output of the Tomography?"
echo
echo "01_weightage.txt, sorted_cata.txt, Gmatrix.txt and box"
echo
echo "If not break now..."
sleep 2

if [ -f 01_weightage.txt ] && [ -f sorted_cata.txt ] && [ -f Gmatrix.txt ] && [ -f box ]; then

#cp $w_dir/../tomo/Gmatrix.txt $w_dir
#cp $w_dir/../tomo/01_weightage.txt $w_dir

N=`cat sorted_cata.txt | wc -l`
echo
echo "Making checker..."
#run checker file to calculate input checker
$w_dir/bin/check_make_psf

echo
echo "Doing forward calculatons..."
#run forward calculation
$w_dir/bin/forward_calc_psf $N

echo
echo "Doing backward calculations to recover the checker..."
#run backward model to recover the checker
$w_dir/bin/back_proj_calc_psf $N
echo
echo "DONE!!!"

else
echo "WARNING: Any or all Input files: 01_weightage.txt sorted_cata.txt Gmatrix.txt box NOT PRESENT. Exiting"

fi

