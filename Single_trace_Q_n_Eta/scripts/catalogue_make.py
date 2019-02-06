import matplotlib.pyplot as plt
import matplotlib as mpl
import math
import scipy
import numpy as np
import decimal as dc


info = open('info_new.txt')
f_file = open('freq_file')
Q_file = open('Q_data.txt')
data_file = open('data.txt')
fopen = open('pre_cata.txt', 'w')

Q0 = []
Q0e = []
n = []
ne = []
m1 = []
m2 = []
file1 = []
for jojo in Q_file:
	file1.append(str(jojo.split()[0]))
	Q0.append(float(jojo.split()[1]))
	Q0e.append(float(jojo.split()[2]))
	n.append(float(jojo.split()[3]))
	ne.append(float(jojo.split()[4]))
	m1.append(float(jojo.split()[5]))
	m2.append(float(jojo.split()[6]))
Q_file.close()

freq = []
for jojo1 in f_file:
	freq.append(float(jojo1.split()[0]))
f_file.close()

Q = []
Qe = []
f = []
file2 = []
for jojo in info:
	file2.append(str(jojo.split()[0]))
	Q.append(float(jojo.split()[1]))
	Qe.append(float(jojo.split()[2]))
	f.append(float(jojo.split()[3]))
	
info.close()

data = []
for jojo2 in data_file:
		data.append(jojo2.split()[0:])
data_file.close()
#data = np.array(data, dtype=dc.Decimal)
#print data
for i in range(len(file1)):
	ff = []
	QQ = []
	QQe = []
	tmp = []
	#print i
	for j in range(len(file2)):

		if file2[j].split('_',3)[3] == file1[i].split('_',2)[2]:
			ff.append(f[j])
			QQ.append(Q[j])
			QQe.append(Qe[j])
			#print "ooooooo"
	QQ1 = []
	QQ1e = []
	if len(ff) != len(freq):
		#print file1[i], len(ff), len(freq)
		ss = 0
		for y in range(len(freq)):
			if freq[y] not in ff:
				QQ1.append(np.exp(m2[i]+m1[i]*np.log(freq[y])))
				QQ1e.append(0.0)
				#print QQ1
			else:
				QQ1.append(QQ[ss])
				QQ1e.append(QQe[ss])
				ss+=1
				#print QQ1
		for x in range(len(freq)):
			tmp.append([freq[x],QQ1[x],QQ1e[x]])
		tmp = np.array(tmp, dtype=dc.Decimal)
		#print tmp
		print >> fopen, file1[i].split('_',2)[2], Q0[i], Q0e[i], " ".join(data[i]), " ".join("%s %s %s"%(c[0],c[1],c[2]) for c in tmp)
	else:
		#print file1[i], len(ff), len(freq)
		for x in range(len(ff)):
			tmp.append([ff[x],QQ[x],QQe[x]])
		tmp = np.array(tmp, dtype=dc.Decimal)
		#print tmp
		print >> fopen, file1[i].split('_',2)[2], Q0[i], Q0e[i], " ".join(data[i]), " ".join("%s %s %s"%(c[0],c[1],c[2]) for c in tmp)

fopen.close()



























