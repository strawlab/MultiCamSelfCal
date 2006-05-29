Start_path = './MartinecPajdla';

addpath ([Start_path '/fill_mm'])
addpath ([Start_path '/fill_mm_test'])
addpath ([Start_path '/utils'])

global OutputDir Matlab_data;
Matlab_data = [ str_cut(Start_path) 'Matlab_data/' ];
OutputDir   = [ Matlab_data 'output/' ];
