Start_path = ['.' filesep 'MartinecPajdla'];

addpath ([Start_path filesep 'fill_mm'])
addpath ([Start_path filesep 'fill_mm_test'])
addpath ([Start_path filesep 'utils'])

global OutputDir Matlab_data;
Matlab_data = [ str_cut(Start_path) 'Matlab_data' filesep];
OutputDir   = [ Matlab_data 'output' filesep];
