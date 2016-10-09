default:	foam/constant/polyMesh/boundary foam/system/decomposeParDict foam/processor0/constant/polyMesh/boundary

mesh/cyl.msh:	mesh/cyl.geo
	cd mesh; gmsh -3 cyl.geo > gmsh.out

foam/constant/polyMesh/boundary:	mesh/cyl.msh foam/boundary.py
	cd foam; gmshToFoam ../mesh/cyl.msh > gmshToFoam.out; python boundary.py

foam/system/decomposeParDict:	foam/decomposePar.py mpi_size
	cd foam; python decomposePar.py

foam/processor0/constant/polyMesh/boundary:	foam/constant/polyMesh/boundary foam/system/decomposeParDict
	cd foam; decomposePar > decomposePar.out

NP=$(shell cat mpi_size)

run:	foam/constant/polyMesh/boundary foam/processor0/constant/polyMesh/boundary foam/system/decomposeParDict
	cd foam; rm -rf 0.* 1* 2* 3* 4* 5* 6* 7* 8* 9*; mpiexec -np $(NP) pisoFoam -parallel > pisoFoam.out
