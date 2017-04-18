# Flying Gaussian Tutorial on alanine dipeptide

This tutorial shows how to use the [Flying Gaussian method](http://dx.doi.org/10.1021/acs.jctc.6b00551) in modified [Plumed](http://www.plumed.org). A favourite molecular toy system alanine dipeptide in water will be used as a model system. First compile Plumed (version 2.2.0 tested) with file `/src/bias/MetaD.cpp` replaced by *this file*. Compile with MPI support (I used OpenMPI 2.0.1 compiled with GCC). Next, compile Gromacs (I used version 5.1.1) with Plumed (compile with double precision and again with MPI support). This tutorial assumes you have executables of the Flying-Gaussian-hacked Plumed in your path, otherwise place a full path before Gromacs executables.

The simulation can start from this structure of alanine dipeptide (obtained by deleting and renaming atoms from some protein structure). Topology can be build by:
```bash
gmx_mpi_d pdb2gmx -f AceAlaNme.pdb -o AceAlaNme -p AceAlaNme
```
Chose force field 6 (AMBER99SB-ILDN protein, nucleic AMBER94 (Lindorff-Larsen et al...) and water model 1 (TIP3P TIP 3-point, recommended). In fact AMBER99SB and AMBER99-ILDN are identical since the ILDN correction is applied on longer side chains. Next, create a box and fill it with water.
```bash
gmx_mpi_d editconf -f AceAlaNme.gro -o box -c -box 3 3 3
gmx_mpi_d solvate -cp box -cs -o solvated -p AceAlaNme.top
```
I used two rounds of energy minimization, 20ps MD at constant volume and 30 K and 200ps MD at constant pressure and 300 K. This was followed by 200ps MD at constant volume and 300 K. I ran equilibrations on 8 cores:
export OMP_NUM_THREADS=1
```bash
gmx_mpi_d grompp -f em1 -c solvated -p AceAlaNme -o em1 -maxwarn 666
mpirun -np 8 gmx_mpi_d mdrun -s em1 -o em1 -e em1 -g em1 -c after_em1
gmx_mpi_d grompp -f em2 -c after_em1 -p AceAlaNme -o em2 -maxwarn 666
mpirun -np 8 gmx_mpi_d mdrun -s em2 -o em2 -e em2 -g em2 -c after_em2
gmx_mpi_d grompp -f mdv1 -c after_em2 -p AceAlaNme -o mdv1 -maxwarn 666
mpirun -np 8 gmx_mpi_d mdrun -s mdv1 -o mdv1 -e mdv1 -g mdv1 -c after_mdv1
gmx_mpi_d grompp -f mdp1 -c after_mdv1 -p AceAlaNme -o mdp1 -maxwarn 666
mpirun -np 8 gmx_mpi_d mdrun -s mdp1 -o mdp1 -e mdp1 -g mdp1 -c after_mdp1
gmx_mpi_d grompp -f mdv2 -c after_mdp1 -p AceAlaNme -o mdv2 -maxwarn 666
mpirun -np 8 gmx_mpi_d mdrun -s mdv2 -o mdv2 -e mdv2 -g mdv2 -c after_mdv2
```
Snapshots of this simulation (sampled every 10 ps) were used as starting structures for the Flying Gaussian method. These snapshots can be retrieved by a simple script (add path before gmx_mpi_d if necessary) and run by typing:
```bash
./disectit.py
```
Flying Gaussian method was tested with 10-128 walkers. Here is example with 20 walkers (you need 20 CPU cores). It is necessary to generate more starting structures if you want to use more walkers by prolonging the simulation mdv2 and/or modifying the disectit.py script. When ready, initialize your MPI for given number of processes and run by:
```bash
for i in `seq 0 19`;
do
gmx_mpi_d grompp -f fg -c frame$i -p AceAlaNme -o mtd1_$i -maxwarn 666
rm mdout.mdp
done

mpirun -np 20 gmx_mpi_d mdrun -s mtd1_ -o mtd1_ -e mtd1_ -g mtd1_ /
            -c after_mtd1_ -plumed plumed -multi 20
```
The plumed.dat file containsthe definition of Ramachandran dihedrals and the line:
METAD ARG=phi,psi SIGMA=0.3,0.3 HEIGHT=4 PACE=1 WALKERS_MPI FLYING_GAUSSIAN FILE=HILLS LABEL=restraint
which invokes the Flying Gaussian method (keyword FLYING_GAUSSIAN) with updates of hills in every step (PACE=1). It works with MPI parallelization only (WALKERS_MPI). Heights of hills are 4 kJ/mol (the bias potential can hypothetically reach 20x4=80 kJ/mol for same CV values of all hills). Increasing of hill heights may lead to over-biasing and crashes, however, higher bias potential can be usually reached by increasing the number of walkers without any problem. Widths are similar to classical metadynamics.

After finishing the simulation create a subdirectory otfr for on-the-fly reweighting. In this directory run this script. It will generate files fes0.txt to fes500.txt with the progress of calculated free energy surface. They contain three columns: phi-bin number, psi-bin number and free energy (free energy of unpopulated bins is set to maxfe). They can be visualized by this R script by running:
```bash
R --no-save < getfes.R
```
(they start by fes001.png). Evolution of the bias potential can be visualized by this script:
```bash
R --no-save < getbias.R
```
Finally you can make movies by mencoder:
```bash
mencoder -ovc lavc -lavcopts vcodec=mpeg4:vpass=1:vbitrate=1620000:mbd=2:keyint=132:v4mv:vqmin=3:lumi_mask=0.07:dark_mask=0.10:naq:vqcomp=0.7:vqblur=0.2:mpeg_quant -mf type=png:fps=25 -nosound -o fes.avi mf://fes*.png

mencoder -ovc lavc -lavcopts vcodec=mpeg4:vpass=1:vbitrate=1620000:mbd=2:keyint=132:v4mv:vqmin=3:lumi_mask=0.07:dark_mask=0.10:naq:vqcomp=0.7:vqblur=0.2:mpeg_quant -mf type=png:fps=25 -nosound -o bias.avi mf://bias*.png
(everything from vcodec=mpeg4:.. to ..:mpeg_quant must not be broken by spaces or new lines, copy and paste this command to a text editor to make sure it is not broken) or by other software.
```
You should obtain movie similar to this one and this one. You can play with hill heights (higher hills may cause crash), hills of height set to zero (standard MD), you can count the number of transitions between minima etc. Happy flying with Flying Gaussian!
