#!/usr/bin/python

import os

path_to_gmx = ""

for i in range(20):
  command = path_to_gmx + "gmx_mpi_d trjconv -s after_mdp1 -f mdv2 -o frame"
  command = command + str(i)
  command = command + ".gro -b "
  command = command + str(10.0*float(i+1)-0.1)
  command = command + " -e "
  command = command + str(10.0*float(i+1)+0.1)
  command = command + " << EOF\n0\nEOF"
  print command
  os.system(command)


