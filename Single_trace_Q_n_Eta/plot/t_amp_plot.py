import matplotlib.pyplot as plt
import matplotlib as mpl
import math
import scipy
import numpy as np


info = open('info_new.txt')
filename = []
m1 = []
m2 = []
sd_a = []
sd_b = []
Q = []
Qe = []
f = []
for jojo in info:
	filename.append(str(jojo.split()[0]))
	Q.append(float(jojo.split()[1]))
	Qe.append(float(jojo.split()[2]))
	f.append(float(jojo.split()[3]))
	m1.append(float(jojo.split()[4]))
	m2.append(float(jojo.split()[5]))
	sd_a.append(float(jojo.split()[6]))
	sd_b.append(float(jojo.split()[7]))
	
info.close()

for i in range(len(filename)):
	data_list = open(filename[i])
	print Q[i], f[i]
	time = []
	amp = []
	l_amp = []

	for line in data_list:
		time.append(float(line.split()[0]))
		amp.append(float(line.split()[1]))
		l_amp.append(float(line.split()[2]))

	plt.clf()
	fig = plt.gcf()
	fig.set_size_inches(8,4.5)
	mpl.rc('font', size = 10)
	title = r"$Qc = %7.02f\ \pm\ %5.02f;\ f = %4.01f$" %(Q[i], Qe[i], f[i])
	plt.title(title, size = 14)
	plt.xlim(min(time)-2.0, max(time)+2.0)
	plt.ylim(min(amp)-1.5, max(amp)+1.5)
	plt.xlabel(r"$t_{rms}$")
	plt.ylabel(r"$ln(A_{rms})\ +\ \beta*ln(t_{rms})$")
	plt.plot(time, amp, "k*", label = r"$ln(A_{rms})\ +\ \beta*ln(t_{rms})\ vs\ t_{rms}$")
	plt.plot(time, l_amp, "k-", label = r"$[%06.04f\ \pm\ %06.04f]*t_{rms}\ +\ [%06.04f\ \pm\ %06.04f]$" %(m1[i],sd_a[i],m2[i],sd_b[i]))
	plt.legend(loc=0, prop={'size':10})
	plt.savefig("fig_"+filename[i]+".eps", dpi = 500)














