import matplotlib.pyplot as plt
import matplotlib as mpl
import math
import scipy
import numpy as np


info = open('Q_data.txt')
filename = []
Q0 = []
err_Q0 = []
eta = []
err_eta = []
m2 = []
Var_b = []
for jojo in info:
	filename.append(str(jojo.split()[0]))
	Q0.append(float(jojo.split()[1]))
	err_Q0.append(float(jojo.split()[2]))
	eta.append(float(jojo.split()[3]))
	err_eta.append(float(jojo.split()[4]))
	m2.append(float(jojo.split()[6]))
	Var_b.append(float(jojo.split()[8]))
info.close()

for i in range(len(filename)):
	data_list = open(filename[i])
	print Q0[i]

	l_f = []
	l_Q = []
	Q_fit = []
	S_l_Q = []
	for line in data_list:
		l_f.append(float(line.split()[0]))
		l_Q.append(float(line.split()[1]))
		Q_fit.append(float(line.split()[2]))
		S_l_Q.append(float(line.split()[4]))

	

	title = r"$Q_0\ =\ %7.02f\ \pm\ %5.02f;\ \eta\ =\ %05.03f\ \pm\ %05.03f$" %(Q0[i], err_Q0[i], eta[i], err_eta[i])
	plt.clf()
	fig = plt.gcf()
	fig.set_size_inches(8,4.5)
	mpl.rc('font', size = 10)
	plt.title(title, size = 14)
	plt.xlabel("ln(f)")
	plt.ylabel("ln(Q(f))")
	plt.xlim(min(l_f)-1.0, max(l_f)+1.0)
	plt.ylim(min(l_Q)-1.0, max(l_Q)+1.0)	
	plt.errorbar(l_f, l_Q, yerr=S_l_Q, fmt='k*', label = "ln(Q(f)) vs ln(f)")
	plt.plot(l_f,Q_fit, 'k-',label = r"$[%06.04f\ \pm\ %06.04f]*ln(f)\ +\ [%06.04f\ \pm\ %06.04f]$" %(eta[i], err_eta[i], m2[i], Var_b[i]))
	plt.legend(loc=0, prop={'size':8})
	plt.savefig(filename[i]+".eps", dpi=500)








