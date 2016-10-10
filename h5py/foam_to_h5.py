import os
import sys
import gzip
import argparse

import h5py
import numpy as np
import mpi4py
from mpi4py import MPI

parser = argparse.ArgumentParser(description='Foam time to h5py')
parser.add_argument('foam_path', type=str, help='Path to OpenFOAM case')
parser.add_argument('time', type=str, help='Time to convert')
parser.add_argument('output', type=str, help='hdf5 output file')
args = parser.parse_args()

comm = MPI.COMM_WORLD

def find_data_path():
    if comm.size > 1:
        proc_path = os.path.join(args.foam_path,
                                 'processor{0}'.format(comm.rank))
        assert os.path.exists(proc_path)
        if comm.rank == 0:
            not_exist_path = os.path.join(args.foam_path,
                                          'processor{0}'.format(comm.size))
            assert not os.path.exists(not_exist_path)
    else:
        proc_path = args.foam_path
    data_path = os.path.join(proc_path, args.time)
    assert os.path.exists(data_path)
    return data_path

def split_line_parenthesis(line):
    sub_lines = line.split('(')
    split_line = []
    split_depth = []
    depth = 0
    for sub_line in sub_lines:
        split_sub_line = sub_line.split(')')
        split_line.extend(split_sub_line)
        split_depth.append(depth - np.arange(len(split_sub_line)))
        depth += 2 - len(split_sub_line)
    return split_line, np.hstack(split_depth)

class DataLoader:
    def __init__(self, data_path):
        self.data_path = data_path

    def __call__(self, filename):
        filename = os.path.join(self.data_path, filename)
        if not filename.endswith('.gz'):
            return np.empty(0)
        f = gzip.open(filename)
        data = []
        line_beginning_depth = 0
        for line in f:
            split_line, split_depth = split_line_parenthesis(line)
            assert len(split_line) == len(split_depth)
            for sub_line, sub_depth in zip(split_line, split_depth):
                if line_beginning_depth + sub_depth > 0:
                    data.extend(sub_line.strip().split())
            line_beginning_depth += split_depth[-1]
        assert line_beginning_depth == 0
        return np.array(data, float)

data_path = find_data_path()
data = list(map(DataLoader(data_path), os.listdir(data_path)))
data = np.hstack(data)

data_size = np.zeros(comm.size, int)
data_size[comm.rank] = data.size
comm.Allreduce(MPI.IN_PLACE, data_size, MPI.SUM)
i_start = data_size[:comm.rank].sum()
i_end = data_size[:comm.rank+1].sum()

handle = h5py.File(args.output, 'w', driver='mpio', comm=comm)
d = handle.create_dataset('field', shape=(data_size.sum(),), dtype='d')
d[i_start:i_end] = data
handle.close()

print(comm.rank, data.shape, i_start, i_end)
