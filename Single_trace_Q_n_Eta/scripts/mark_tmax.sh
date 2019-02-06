for dir in 20*
do
cd $dir
for file in v_*.?HZ
do

sac2xy $file ${file}.xy

p_time=`sachead $file T1 | awk -F" " '{print $2}'`

cat ${file}.xy | awk '{print $1, $2}'| awk -v ss="$p_time" '{if ($1 >= ss+5) print $1, $2}' | awk '{if ($1 <= 300) print $1, $2}' >> t_${file}.xy

Tmax=`awk '$2 > max { max = $2; output = $1 } END { print output }' t_${file}.xy`
echo $Tmax "------------"

sac<<!
r $file
rtr
rmean
ch T4 $Tmax kt4 Amax
wh
q
!

rm t_${file}.xy ${file}.xy

done
cd ..
done
