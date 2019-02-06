#program for calculating distance(deg & Km), azimuth and backazimuth between event and station
#written by Shubham Sharma on 27-01-2017

import math as m
import sys

#print "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
#print "Enter lat-long of Event and Station in decimal. \n(North-East: +ve & South-West: -ve)"
#print "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
event = raw_input()
if event == "" or event == " " or any(c.isalpha() for c in event):
	sys.exit("Terminating the program. Not proper input provided")
	
sta = raw_input()
if sta == "" or sta == " " or any(c.isalpha() for c in sta):
	sys.exit("Terminating the program. Not proper input provided")

e_lat, e_long = map(float,event.split(" "))
s_lat, s_long = map(float,sta.split(" "))
ee_lat = e_lat
ss_lat = s_lat

#check for the range
if abs(e_lat) > 90.0:
	sys.exit("Please give valid latitude of event between -90 to 90 Deg.")	
if abs(e_long) > 180.0:
	sys.exit("Please give valid longitude of event between -180 to 180 Deg.")
if abs(s_lat) > 90.0:
	sys.exit("Please give valid latitude of station between -90 to 90 Deg.")
if abs(s_long) > 180.0:
	sys.exit("Please give valid longitude of station between -180 to 180 Deg.")
s1 = m.pi/180.0
s2 = 180.0/m.pi

#convert to geocentric latitude
e_lat = m.atan(0.99330562001*m.tan(e_lat*m.pi/180.0))*s2
s_lat = m.atan(0.99330562001*m.tan(s_lat*m.pi/180.0))*s2

#check for extreme cases
if e_long == s_long or abs(e_lat) == 90.0 or abs(s_lat) == 90:	
	delta = abs(s_lat - e_lat)
	dist = delta*111.11
	if s_lat == max(s_lat,e_lat):
		baz = 180.0
		az = 0.0
	else:
		az = 180.0
		baz = 360.0
		
#if sta long is greater than event long
elif s_long > e_long:
	delta = m.cos((90-e_lat)*s1)*m.cos((90-s_lat)*s1) + m.sin((90-e_lat)*s1)*m.sin((90-s_lat)*s1)*m.cos((s_long-e_long)*s1)
	delta = m.acos(delta)*s2
	dist = delta*111.11
	#jojo1 = m.asin(round(m.sin((90-e_lat)*s1)*m.sin((s_long-e_long)*s1)/m.sin(delta*s1),5))
	jojo1 = (m.cos((90-e_lat)*s1) - m.cos((90-s_lat)*s1)*m.cos(delta*s1))/(m.sin((90-s_lat)*s1)*m.sin(delta*s1))
	jojo1 = m.acos(jojo1)
	#jojo2 = m.asin(round(m.sin((90-s_lat)*s1)*m.sin((s_long-e_long)*s1)/m.sin(delta*s1),5))
	jojo2 = (m.cos((90-s_lat)*s1) - m.cos((90-e_lat)*s1)*m.cos(delta*s1))/(m.sin((90-e_lat)*s1)*m.sin(delta*s1))
	jojo2 = m.acos(jojo2)
	if abs(s_long) > 90.0 or abs(e_long) > 90.0:
		baz = jojo1*s2
		az = 360.0 - jojo2*s2
	else:
		baz = 360.0 - jojo1*s2
		az = jojo2*s2

else:
	delta = m.cos((90-s_lat)*s1)*m.cos((90-e_lat)*s1) + m.sin((90-s_lat)*s1)*m.sin((90-e_lat)*s1)*m.cos((e_long-s_long)*s1)
	delta = m.acos(delta)*s2
	dist = delta*111.11
	#jojo1 = m.asin(round(m.sin((90-s_lat)*s1)*m.sin((e_long-s_long)*s1)/m.sin(delta*s1),5))
	jojo1 = (m.cos((90-e_lat)*s1) - m.cos((90-s_lat)*s1)*m.cos(delta*s1))/(m.sin((90-s_lat)*s1)*m.sin(delta*s1))
	jojo1 = m.acos(jojo1)
	#jojo2 = m.asin(round(m.sin((90-e_lat)*s1)*m.sin((e_long-s_long)*s1)/m.sin(delta*s1),5))
	jojo2 = (m.cos((90-s_lat)*s1) - m.cos((90-e_lat)*s1)*m.cos(delta*s1))/(m.sin((90-e_lat)*s1)*m.sin(delta*s1))
	jojo2 = m.acos(jojo2)
	if abs(s_long) > 90.0 or abs(e_long) > 90.0:
		baz = 360.0 - jojo1*s2
		az = jojo2*s2
	else:
		baz = jojo1*s2
		az = 360.0 - jojo2*s2	

	
#printing results
"""
print "\n-------------Result is here-------------"
print "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
print "Event lat=%.4f & long=%.4f | Station lat=%.4f & long=%.4f"%(ee_lat, e_long, ss_lat, s_long)
print "Distance(deg) ---> %.3f"%delta
print "Distance(Km) ---> %.3f"%dist
print "BAz ---> %.3f"%baz
print "Az ---> %.3f"%az
print "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
print "-----------------end--------------------"
"""

print "Dist(deg)=%.3f	Dist(Km)=%.3f	Baz=%.3f	Az=%.3f"%(delta, dist, baz, az)
