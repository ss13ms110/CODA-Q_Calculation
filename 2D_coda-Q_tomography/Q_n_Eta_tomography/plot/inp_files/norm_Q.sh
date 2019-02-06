#!/bin/bash

rm -f avg_txt
for i in 01 02 03 05 08 10 12 14
do
f=`echo ${i}_output.txt`

fl=${i}_out.txt

num=`cat $f | wc -l`
av=`cat $f | awk '{print $3}' | paste -sd+ - | bc | awk -v var=$num '{print $1/var}'`

cat $f | awk -v var2=$av '{print $1"  "$2"  "(($3-var2)/var2)*100}' > $fl
echo $av "  " $i>> avg_txt 
done

for f in n_result.txt Q_result.txt 
do

ss=`echo $f | awk -F_ '{print $1}'`
fl=${ss}_out.txt

num=`cat $f | wc -l`
av=`cat $f | awk '{print $3}' | paste -sd+ - | bc | awk -v var=$num '{print $1/var}'`

cat $f | awk -v var2=$av '{print $1"  "$2"  "(($3-var2)/var2)*100}' > $fl 
done
