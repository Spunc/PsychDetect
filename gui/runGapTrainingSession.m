function runGapTrainingSession()
%RUNGAPTRAININGSESSION opens a GUI to run a gap training session.

% Author: Lasse Osterhagen

% Constants:
gapTrainingDir = ['gap', filesep(), 'training', filesep()];

% Load computer specific configuration.
% 'computerConfig.mat' must contain a struct named 'computerConfig' with
% the following fields:
%   saveDir - path to directory for saving training data
% The file should be placed in '~/experiment_config'.
load([getHomePath(), 'experiment_config', filesep(), 'computerConfig']);

% Get subject ID
subjectID = cell2mat(inputdlg('Subject ID:', 'Startup'));
if isempty(subjectID)
    disp('Startup cancelled.');
    return;
end

% Try loading existing parameters
% 'XXXX_param.mat' (if existent) must contain a struct 'trainingConfig'
% with the following fields:
%   maxReactionTime - positive number
%   stimTrainerConfig - a struct with the fields:
%       gapDuration: [mean, std],
%       gapDurationBounds: [lowerBound, upperBound],
%       startDelayBounds: [lowerBound, upperBound]
filePathPrefix = strcat(computerConfig.saveDir, gapTrainingDir, subjectID, '_');
fileParam = strcat(filePathPrefix, 'param.mat');
if exist(fileParam, 'file')
    load(fileParam);
    disp('Training parameters loaded.');
else
    load('basicGapTrainingConfig');
end

% Load audioPlayer configuration
% 'basicGapAudioPlayerConfig' must contain a struct named
% 'audioPlayerConfig' with fields according to the dependency-injection
% policy.
load('basicGapAudioPlayerConfig');

% Create ExperimentController config
load('arduinoConfig')
ecConfig.pins = arduinoConfig.pins;
ecConfig.ioDevice = ArduinoDevice();     % Windows only
ecConfig.audioPlayer = depInj.createObjFromTree(audioPlayerConfig);
ecConfig.maxReactionTime = trainingConfig.maxReactionTime;
ecConfig.audioObjectGenerator = depInj.createObjFromTree( ...
    trainingConfig.stimTrainerConfig);
ec = ExperimentController(ecConfig);

% Register LogBook
lb = LogBook();
lb.addObservable(ec, 'Running');
lb.addObservable(ec, 'Stopped');
lb.addObservable(ec, 'Ascend');
lb.addObservable(ec, 'Descend');
lb.addObservable(ec, 'NewTrial');
lb.addObservable(ec, 'ManuallySkipped');

GapTrainingGUI(ec, subjectID, filePathPrefix, lb);
