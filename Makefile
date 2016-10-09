default:	foam/constant/polyMesh/boundary

mesh/cyl.msh:	mesh/cyl.geo
	cd mesh; gmsh -3 cyl.geo > gmsh.out

foam/constant/polyMesh/boundary:	mesh/cyl.msh
	cd foam; gmshToFoam ../mesh/cyl.msh > gmshToFoam.out; python boundary.py

run:	foam/constant/polyMesh/boundary
	cd foam; rm -rf 0.* 1* 2* 3* 4* 5* 6* 7* 8* 9*; pisoFoam > pisoFoam.out
