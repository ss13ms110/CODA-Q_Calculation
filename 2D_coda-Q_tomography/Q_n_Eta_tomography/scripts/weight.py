import math
import numpy as np
import matplotlib.pyplot as plt
import shapely.geometry as sgeo
import decimal as dc
#import Image
import os
import matplotlib
import pylab as pyl
from numpy import linspace
from scipy import pi,sin,cos
import timeit
start = timeit.default_timer()

#NE_479
grdsz = 0.2   # grid size
xran = np.arange(82, 100, grdsz)
yran = np.arange(19, 35, grdsz)

xnum = len(xran)-1
ynum = len(yran)-1
lapse = 60.0/2.0
#--------------------------------------------------
def Grid(x,y):
	grid = []
	for i in range(len(y)):
		tmp = []
		for j in range(len(x)):
			tmp.append([x[j], y[i]])
		grid.append(tmp)
	return grid

fopen = open("Qrange.txt","w")
fopen.close()

def EllipseEq(x,y, x1, y1, x2, y2, a):
	return (math.sqrt((x-x1)**2.0 + (y-y1)**2.0) + math.sqrt((x-x2)**2.0 + (y-y2)**2.0) - (2.0*a))

# sort corners in counter-clockwise direction
def PolygonSort(corners):
    # calculate centroid of the polygon
    n = len(corners) # of corners
    #cx = float(sum(x for x, y in corners)) / n
    #cy = float(sum(y for x, y in corners)) / n
    cx = cy = 0.0
    for x, y in corners:
	cx += x
	cy += y
    cx /=float(n)
    cy /= float(n)
    # create a new list of corners which includes angles
    cornersWithAngles = []
    for x, y in corners:
        dx = x - cx
        dy = y - cy
        an = (math.atan2(dy, dx) + 2.0 * math.pi) % (2.0 * math.pi)
        cornersWithAngles.append((dx, dy,an))
    # sort it using the angles
    cornersWithAngles.sort(key = lambda tup: tup[2])
    return cornersWithAngles
#--------------------------------------------------
fopen = open("sorted_cata.txt")

filen = []
Slat = []
Slong = []
Rlat = []
Rlong = []
ts2 = []
dist = []
dep = []
Q0 = []
eta = []

data = []

for line in fopen:
    if line[0] != "#":
	filen.append(str(line.split()[0]))
	Slong.append(float(line.split()[4]))
	Slat.append(float(line.split()[3]))
	Rlat.append(float(line.split()[5]))
	Rlong.append(float(line.split()[6]))
	ts2.append(float(line.split()[7]))
	dist.append(float(line.split()[8]))
	dep.append(float(line.split()[9]))
	Q0.append(float(line.split()[1]))
	eta.append(float(line.split()[2]))
	data.append(line.split()[10:])
fopen.close()

Slong = np.array(Slong, dtype=dc.Decimal)
Slat = np.array(Slat, dtype=dc.Decimal)
Rlat = np.array(Rlat, dtype=dc.Decimal)
Rlong = np.array(Rlong, dtype=dc.Decimal)
ts2 = np.array(ts2, dtype=dc.Decimal)
dist = np.array(dist, dtype=dc.Decimal)
dep = np.array(dep, dtype=dc.Decimal)
Q0 = np.array(Q0)
eta = np.array(eta)


cor_fq = []
Qc = []
sQc = []

for y in range(0,len(data[0]),3):
	tmp1=[]
	tmp2 = []
	for x in range(len(data)):
		tmp1.append(float(data[x][y+1]))
		tmp2.append(float(data[x][y+2]))
	Qc.append(tmp1)
	sQc.append(tmp2)	
	if len(data[0])/3 != len(cor_fq) and float(data[0][y]) not in cor_fq:
		cor_fq.append(float(data[x-1][y]))
print cor_fq
sa = []
sb = []
phi = []
fopen=open("measure_axis.txt","w")
for i in range(len(ts2)):
	tmp = (ts2[i]+lapse)*3.5/(2.0)
	print >> fopen,"%f"%(tmp)
	sb.append(math.sqrt(tmp**2.0 - (dist[i]/2.0)**2.0)/111.11)
	sa.append(tmp/111.11)
sa=np.array(sa, dtype=dc.Decimal)
sb=np.array(sb, dtype=dc.Decimal)

midlat = (Slat+Rlat)/2.0
midlong = (Slong+Rlong)/2.0

ellx = []
elly = []
grid = Grid(xran, yran)

fopen = open("Gmatrix.txt","w")
#ss=open("st", "w")
maxx = -10.0
maxy = -10.0
minx = 100.0
miny = 100.0
endptsx = []
endptsy = []
poly = sgeo.Polygon([grid[0][0], grid[0][1], grid[1][1], grid[1][0]])
print poly.bounds
Nd = len(midlat)

for i in range(len(midlat)):
	theta = math.atan(((Slat[i]-Rlat[i])/(Slong[i]-Rlong[i])))
	total_points = 30000
	tick = 0
	tmpx = []
	tmpy = []
	elchk = []
	tick = np.arange(total_points)*2.0/np.float(total_points)
	tmpx = np.array(midlong[i]+((sa[i]*np.cos(tick*np.pi)*np.cos(theta))-(sb[i]*np.sin(tick*np.pi)*np.sin(theta))), dtype=dc.Decimal)
	tmpy = np.array(midlat[i]+((sa[i]*np.cos(tick*np.pi)*np.sin(theta))+(sb[i]*np.sin(tick*np.pi)*np.cos(theta))), dtype=dc.Decimal)
	
	ellx.append(tmpx)
	elly.append(tmpy)
	corn = zip(tmpx, tmpy)
	wt = grdsz*grdsz
	sum = 0.0
	gridwt = np.zeros((len(grid)-1,len(grid[0])-1))

	for k in range(len(grid)-1):
		tmp = []
		for l in range(len(grid[k])-1):
			p=0
			polypts = []	# List of grid points inside ellipse
			if EllipseEq(grid[k][l][0], grid[k][l][1], Slong[i], Slat[i], Rlong[i], Rlat[i], sa[i]) < 0:
				polypts.append(grid[k][l])
			if EllipseEq(grid[k][l+1][0], grid[k][l+1][1], Slong[i], Slat[i], Rlong[i], Rlat[i], sa[i]) < 0:
				polypts.append(grid[k][l+1])
			if EllipseEq(grid[k+1][l+1][0], grid[k+1][l+1][1], Slong[i], Slat[i], Rlong[i], Rlat[i], sa[i]) < 0:
				polypts.append(grid[k+1][l+1])
			if EllipseEq(grid[k+1][l][0], grid[k+1][l][1], Slong[i], Slat[i], Rlong[i], Rlat[i], sa[i]) < 0:
				polypts.append(grid[k+1][l])
			
			if len(polypts) == 0:	
				gridwt[k,l]=0.0
			elif len(polypts) == 4:
				sqgrid = sgeo.Polygon(polypts)
				gridwt[k,l]=sqgrid.area
			elif len(polypts) != 0 and len(polypts) <4 :
				sqgrid = sgeo.Polygon([grid[k][l],grid[k][l+1],grid[k+1][l+1],grid[k+1][l]])
				bounds = sqgrid.bounds
				
				for x,y in corn:
					if x > bounds[0] and y > bounds[1] and x < bounds[2] and y < bounds[3]:
						polypts.append([x,y])
				if len(polypts) >= 3:
					polypts = PolygonSort(polypts)
					polygon = sgeo.Polygon(polypts)
					gridwt[k,l]=polygon.area

	sum=np.sum(gridwt)
	polygon = sgeo.Polygon(corn)
	stop = timeit.default_timer()
	
	gridwt = np.reshape(gridwt,len(gridwt)*len(gridwt[0]))
	nwt = gridwt/np.sum(gridwt)

	if i%1 == 0:
		print filen[i], len(gridwt), len(Q0), i, " Total Run Time = ",stop - start
	"""hj=0	
	for sd in range(41):
		for sk in range(47):
			print >> ss, grid[sd][sk], gridwt[hj], hj
			hj+=1
	print len(gridwt), "---------", len(grid[0])"""
	fopen.write("\t".join("%013.010f"%(c) for c in gridwt)+"\t%013.010f"%sum+"\n")


print np.max(ellx), np.min(ellx), np.max(elly), np.min(elly)
fopen.close()
#cor_fq = [1]
for fq in range(len(cor_fq)):
	
	#fopen =  open("weightage.txt","w")
	fopen =  open("%02d"%int(cor_fq[fq])+"_weightage.txt","w")
	
	print >> fopen, "%s\t%s" %(xnum,ynum)
	gridpt = []
	
	for k in range(len(grid)-1):
		tmppt = []
		for l in range(len(grid[k])-1):
			tmppt.append([(grid[k][l][0]+grid[k][l+1][0]+grid[k+1][l][0]+grid[k+1][l+1][0])/4.0,(grid[k][l][1]+grid[k][l+1][1]+grid[k+1][l][1]+grid[k+1][l+1][1])/4.0])
		gridpt.append(tmppt)
	gridpt = np.reshape(gridpt, (len(gridpt)*len(gridpt[0]),2))
	#fopen.write("\t".join("%s"%(c[0]) for c in d2tod1(gridpt))+"\n")
	fopen.write("\t".join("%s"%(c[0]) for c in gridpt)+"\n")
	fopen.write("\t".join("%s"%(c[1]) for c in gridpt)+"\n")
	fopen.write("\t".join("%s"%c for c in Qc[fq])+"\n")
	fopen.write("\t".join("%s"%c for c in eta)+"\n")
	fopen.close()

	stop = timeit.default_timer()
	
	#print "\n Total Run Time = ",stop - start, "-----------"
	#print "------Passs on to Back_Projection-------"
	#os.system("./a.out %02d %d"%(int(cor_fq[fq]), Nd))
	#os.system("./a.out %02d"%int(cor_fq[fq]))
	#os.system("./a.out")
















