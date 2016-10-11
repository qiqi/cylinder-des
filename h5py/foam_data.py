import os
import gzip

import numpy as np

def find_data_path(comm, path, time, mkdir=False):
    if mkdir:
        if comm.rank == 0 and not os.path.exists(path):
            os.mkdir(path)
        comm.Barrier()
    if comm.size > 1:
        proc_path = os.path.join(path,
                                 'processor{0}'.format(comm.rank))
        if mkdir:
            if not os.path.exists(proc_path):
                os.mkdir(proc_path)
        else:
            assert os.path.exists(proc_path)
        if comm.rank == 0:
            not_exist_path = os.path.join(path,
                                          'processor{0}'.format(comm.size))
            assert not os.path.exists(not_exist_path)
    else:
        proc_path = path
    data_path = os.path.join(proc_path, time)
    if mkdir:
        if not os.path.exists(data_path):
            os.mkdir(data_path)
    else:
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

class FileParser:
    def __init__(self, data_path):
        self.data_path = data_path

    def parse(self, filename):
        filename = os.path.join(self.data_path, filename)
        if not filename.endswith('.gz'):
            return
        f = gzip.open(filename)
        line_beginning_depth = 0
        for line in f:
            split_line, split_depth = split_line_parenthesis(line)
            line_beginning_depth += split_depth[-1]
            yield split_line, split_depth + line_beginning_depth
        assert line_beginning_depth == 0

class DataLoader:
    def __init__(self, data_path):
        self.parser = FileParser(data_path)

    def __call__(self, filename):
        data = []
        for split_line, split_depth in self.parser.parse(filename):
            for sub_line, sub_depth in zip(split_line, split_depth):
                if sub_depth > 0:
                    data.extend(sub_line.strip().split())
        return np.array(data, float)


def join_line_parenthesis(split_line, split_depth):
    line = split_line[0]
    for i in range(1, len(split_line)):
        if split_depth[i] > split_depth[i-1]:
            line += '('
        else:
            line += ')'
        line += split_line[i]
    return line

class DataWriter:
    def __init__(self, ref_path, target_path):
        self.parser = FileParser(ref_path)
        self.target_path = target_path

    def __call__(self, data, filename):
        data_ptr = 0
        with gzip.open(os.path.join(self.target_path, filename), 'wb') as f:
            for split_line, split_depth in self.parser.parse(filename):
                assert len(split_line) == len(split_depth)
                for i in range(len(split_line)):
                    if split_depth[i] > 0:
                        ni = len(split_line[i].strip().split())
                        data_i = ['{0:.18g}'.format(d)
                                  for d in data[data_ptr:data_ptr+ni]]
                        data_ptr += ni
                        if '\n' in split_line[i]:
                            split_line[i] = ' '.join(data_i) + '\n'
                        else:
                            split_line[i] = ' '.join(data_i)
                f.write(join_line_parenthesis(split_line, split_depth))
        return data[:data_ptr]
