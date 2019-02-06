import os
import numpy as np
from math import sqrt


def linreg(X, Y): #Equation: Y = AX + B
	if len(X) != len(Y):
		raise ValueError, 'unequal length'
	N = len(X); 
	Sx = Sy = Sxx = Syy = Sxy = 0.0
	for x, y in map(None, X, Y):
		Sx = Sx + x
		Sy = Sy + y
		Sxx = Sxx + x*x
		Syy = Syy + y*y
		Sxy = Sxy + x*y
	det = Sxx * N - Sx * Sx
	a, b = (Sxy * N - Sy * Sx)/det, (Sxx * Sy - Sx * Sxy)/det
	meanerror = residual = 0.0
	for x, y in map(None, X, Y):
		meanerror = meanerror + (y - Sy/N)**2
		residual = residual + (y - a * x - b)**2
	RR = 1 - residual/meanerror
	ss = residual / (N-2)
	Var_a, Var_b = ss * N / det, ss * Sxx / det

#    print "y=ax+b"
#    print "N= %d" % N
#    print "a= %g \\pm t_{%d;\\alpha/2} %g" % (a, N-2, sqrt(Var_a))
#    print "b= %g \\pm t_{%d;\\alpha/2} %g" % (b, N-2, sqrt(Var_b))
#    print "R^2= %g" % RR
#    print "s^2= %g" % ss
	return a, b, sqrt(Var_a), sqrt(Var_b), RR, ss
	

long = []
lat = []
qc = []

cor_fq = [1.0, 2.0, 3.0, 5.0, 8.0, 10.0, 12.0, 14.0]
filename = os.popen("ls *_output.txt").readlines()

for file in filename:
	tmp = []
	fopen = open(file[:-1])
	for line in fopen:
		tmp.append(float(line.split()[2]))
	qc.append(tmp)
	fopen.close()

fopen = open(filename[0][:-1])

for line in fopen:
	long.append(float(line.split()[0]))
	lat.append(float(line.split()[1]))
	
fopen.close()

qc = np.array(qc)
qc = qc.T
lqc = np.log(qc)
lfq = np.log(cor_fq)
linfit = []

for i in range(len(qc)):
	linfit.append(linreg(lfq, lqc[i]))
linfit=np.array(linfit).T

fopen = open("Q_result.txt","w")

q = np.exp(linfit[1])
n = linfit[0]
for i in range(len(q)):
	print >> fopen, "%5.02f\t%5.02f\t%07.02f"%(long[i], lat[i], q[i])
fopen.close()

fopen = open("n_result.txt","w")

for i in range(len(n)):
	print >> fopen, "%5.02f\t%5.02f\t%05.03f"%(long[i], lat[i], n[i])

fopen.close()

#fopen = open("all_results.txt")

#fopen.close()

