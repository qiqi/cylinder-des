import re

boundary_file = 'constant/polyMesh/boundary'
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
