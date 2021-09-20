%%
clear; close all; clc
restoredefaultpath
addpath('/data3/Niko/EEG-Many-Pipelines/toolboxes/eeglab2021.0/');
addpath('./functions')
eeglab nogui

%%
script02_recode_triggers;
script03_prep_simple;
script04_runica;
script05_cleanica;
script06_grandaverage;
script07_wavelet;