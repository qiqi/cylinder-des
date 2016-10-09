import os
import re
import shutil
import subprocess

cwd = os.path.abspath(os.getcwd())
openfoam = '/opt/openfoam4/platforms/linux64GccDPInt32Opt'
mesh_dir = os.path.join(cwd, 'mesh')
foam_dir = os.path.join(cwd, 'foam')

with open(os.path.join(mesh_dir, 'gmsh.out'), 'wt', 1) as f:
    subprocess.check_call(['/usr/bin/gmsh', '-3', 'cyl.geo'],
                          cwd=mesh_dir, stdout=f, stderr=f)
gmsh_file = os.path.join(mesh_dir, 'cyl.msh')

gmshToFoam = os.path.join(openfoam, 'bin', 'gmshToFoam')
with open(os.path.join(foam_dir, 'gmshToFoam.out'), 'wt', 1) as f:
    subprocess.check_call([gmshToFoam, gmsh_file],
                          cwd=foam_dir, stdout=f, stderr=f)

for f in os.listdir(foam_dir):
    if f not in ('0', 'constant', 'system'):
        f = os.path.join(foam_dir, f)
        if os.path.isdir(f):
            shutil.rmtree(f)
        else:
            os.remove(f)

boundary_file = os.path.join(foam_dir, 'constant/polyMesh/boundary')
boundary = open(boundary_file).read()
subs = {
    'far': '''
        type            cyclic;
        neighbourPatch  near;''',
    'near': '''
        type            cyclic;
        neighbourPatch  far;''',
    'wall': '''
        type            wall;'''
}
regex = '[\s]*{0}[\s]+{{[\s]+type[\s]+patch;[\s]+physicalType[\s]+patch;'
repl = '\n    {0}\n    {{{1}'
for patch_name, content in subs.items():
    boundary = re.sub(regex.format(patch_name),
                      repl.format(patch_name, content),
                      boundary)
with open(boundary_file, 'wt') as f:
    f.write(boundary)

pisoFoam = os.path.join(openfoam, 'bin', 'pisoFoam')
with open(os.path.join(foam_dir, 'pisoFoam.out'), 'wt', 1) as f:
    subprocess.check_call(pisoFoam, cwd=foam_dir, stdout=f, stderr=f)
