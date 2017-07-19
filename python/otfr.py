#!/usr/bin/python

import math

nwalkers = 20
nxbins   = 48
nybins   = 48
skip     = 100
xmin     = -math.pi
xmax     =  math.pi
ymin     = -math.pi
ymax     =  math.pi
temp     = 300.0
maxfe    = 100.0

data = []
for i in range(nwalkers):
  ifilename = "../COLVAR."+str(i)
  ifile = open(ifilename, "r").readlines()
  walker = []
  for line in ifile:
    if line[0]!="#":
      sline = str.split(line)
      walker.append([float(sline[1]), float(sline[2]), float(sline[3])])
  data.append(walker)

def onestep(step):
  pop = []
  sumpop = 0.0
  for i in range(nxbins):
    popline = []
    for j in range(nybins):
      popline.append(0.0)
    pop.append(popline)
  for walker in data:
    for i in range(skip,100*step):
      x = int(float(nxbins)*(walker[i][0]-xmin)/(xmax-xmin))
      y = int(float(nybins)*(walker[i][1]-ymin)/(ymax-ymin))
      pot = walker[i][2]
      addpop = math.exp(1000.0*pot/8.314/temp)
      pop[x][y] = pop[x][y] + addpop
      sumpop = sumpop + addpop
  fes = []
  fesmin = 1000000000.0
  for i in range(nxbins):
    fesline = []
    for j in range(nybins):
      if pop[i][j] > 0.0:
        fe = -8.314*temp*math.log(pop[i][j]/sumpop)/1000.0
      else:
        fe = maxfe
      if fe < fesmin:
        fesmin = fe
      fesline.append(fe)
    fes.append(fesline)
  ofilename = "fes"+str(step)+".txt"
  ofile = open(ofilename, "w")
  for i in range(nxbins):
    for j in range(nybins):
      ofile.write(" %i %i %f\n" % (i, j, fes[i][j]-fesmin))
  ofile.close()

for i in range(501):
  onestep(i)

