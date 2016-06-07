% Manually test ExperimentController
% Requires an Arduino to be connected to the computer.

% Author: Lasse Osterhagen

load('ecGapTrainingConfig.mat')
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
