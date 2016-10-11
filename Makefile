default:	foam/constant/polyMesh/boundary foam/system/decomposeParDict foam/processor0/constant/polyMesh/boundary

NP=$(shell cat mpi_size)

mesh/cyl.msh:	mesh/cyl.geo
	cd mesh; gmsh -3 cyl.geo > gmsh.out

foam/constant/polyMesh/boundary:	mesh/cyl.msh foam/boundary.py
	cd foam; gmshToFoam ../mesh/cyl.msh > gmshToFoam.out; python boundary.py

foam/system/decomposeParDict:	foam/decomposePar.py mpi_size
	cd foam; python decomposePar.py

foam/processor0/constant/polyMesh/boundary:	foam/constant/polyMesh/boundary foam/system/decomposeParDict
	cd foam; rm -rf processor*; decomposePar > decomposePar.out

run:	foam/constant/polyMesh/boundary foam/processor0/constant/polyMesh/boundary foam/system/decomposeParDict
	cd foam; rm -rf 0.* 1* 2* 3* 4* 5* 6* 7* 8* 9*; mpiexec -np $(NP) pisoFoam -parallel > pisoFoam.out

# Tiny mesh for debugging
mesh/tiny.msh:	mesh/tiny.geo
	cd mesh; gmsh -3 tiny.geo > gmsh.out

tiny:	foam/*.py foam/system/* foam/0/*
	rm -rf tiny; mkdir tiny; cp foam/*.py tiny; cp -r foam/system tiny; cp -r foam/0 tiny; mkdir tiny/constant; cp -r foam/constant/*Properties tiny/constant

tiny/constant/polyMesh/boundary:	mesh/tiny.msh tiny/boundary.py
	cd tiny; gmshToFoam ../mesh/tiny.msh > gmshToFoam.out; python boundary.py

tiny/constant/polyMesh/boundary:	mesh/tiny.msh tiny/boundary.py
	cd tiny; gmshToFoam ../mesh/tiny.msh > gmshToFoam.out; python boundary.py

tiny/system/decomposeParDict:	tiny/decomposePar.py mpi_size
	cd tiny; python decomposePar.py

tiny/processor0/constant/polyMesh/boundary:	tiny/constant/polyMesh/boundary tiny/system/decomposeParDict
	cd tiny; rm -rf processor*; decomposePar > decomposePar.out

run-tiny:	tiny/constant/polyMesh/boundary tiny/processor0/constant/polyMesh/boundary tiny/system/decomposeParDict
	cd tiny; rm -rf 0.* 1* 2* 3* 4* 5* 6* 7* 8* 9*; mpiexec -np $(NP) pisoFoam -parallel > pisoFoam.out

