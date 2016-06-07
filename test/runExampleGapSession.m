function runExampleGapSession()
%RUNEXAMPLEGAPSESSION demonstrates a gap detection experiment.
%   The function will open two windows:
%   1. The experiment control window lets you start, stop, and save an
%   experimental session.
%   2. The key press interface GUI, which is the input device for the
%   subject to allow him to react upon stimuli. Actually, it is a
%   simulation for a photo sensor connected to an Arduino.
%
%   To run an experiment, proceed as follows:
%   1. Click on "Start" in the control window. The sound device will then
%   start to play background noise.
%   2. Set the focus on the key press interface GUI.
%   3. Hold down the space key to initiate a trial.
%   4. After a random delay, a gap stimulus will be inserted into the
%   background noise.
%   5. When you here a stimulus, release the space key.
%   6. Again, press hold down the space key for the next trial.
%   7. At the end of the experiment, the background noise will stop.
%   8. You can save the experimental data by clicking on "Save".

% Author: Lasse Osterhagen

addpath('../gui/');

subjectID = 't001';
filePathPrefix = [subjectID, '_'];

load('ecTestGapExperimentConfig.mat')
ec = depInj.createObjFromTree(ecConfig);

lb = LogBook();
lb.addObservable(ec, 'Running');
lb.addObservable(ec, 'Stopped');
lb.addObservable(ec, 'Ascend');
lb.addObservable(ec, 'Descend');
lb.addObservable(ec, 'NewTrial');
lb.addObservable(ec, 'ManuallySkipped');

ExperimentGUI(ec, subjectID, filePathPrefix, lb);
