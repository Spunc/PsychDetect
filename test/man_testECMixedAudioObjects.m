% Manually test a setup with GapStimuli and LaserBlockCtrl intermixed.
% Uses an Arduino to trigger AudioObjects

% Author: Lasse Osterhagen

load('ecAOArrayGapLaserConfig.mat');
e = depInj.createObjFromTree(ecConfig);
lb = LogBook();
lb.addObservable(e, 'Running');
lb.addObservable(e, 'Stopped');
lb.addObservable(e, 'Ascend');
lb.addObservable(e, 'Descend');
lb.addObservable(e, 'NewTrial');
e.start();

% At the end, call:
% delete(e);
