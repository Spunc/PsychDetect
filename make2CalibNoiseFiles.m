function make2CalibNoiseFiles(calib, varargin)
%MAKE2CALIBNOISEFILES creates two bandpass filtered noise files.
%   Arguments:
%   calib - calibration structure
%   dur - duration in seconds [600]
%   level - target level [60]
%   sF - sample frequency [192e3]
%   cutoff - [4e3 60e3]

% This file depends on 'makeSomeNoise.m'.

% Author: Lasse Osterhagen

p = inputParser;
addOptional(p, 'dur', 600, @(x) validateattributes(x, {'numeric'}, {'positive'}));
addOptional(p, 'level', 60, @(x)validateattributes(x, {'numeric'}, {'nonnegative'}));
addOptional(p, 'sF', 192e3, @(x)validateattributes(x, {'numeric'}, {'positive'}));
addOptional(p, 'cutoff', [4e3, 60e3], ...
    @(x)validateattributes(x, {'numeric'}, {'nonnegative'},{'numel', 2}));
parse(p, varargin{:});

rng('shuffle');
for index=1:2
    noise = makeSomeNoise(calib, p.Results.sF, p.Results.level, ...
        p.Results.dur, p.Results.cutoff, 0);
    fileName = ['calibNoise', num2str(index), '.dat'];
    fid = fopen(['resources', filesep, fileName], 'w');
    fwrite(fid, noise, 'double');
    fclose(fid);
    clear noise
end
