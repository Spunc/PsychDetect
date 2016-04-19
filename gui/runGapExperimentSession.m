function runGapExperimentSession()
%RUNGAPTRAININGSESSION opens a GUI to run a gap training session.

% Author: Lasse Osterhagen

% Constants:
maxReactionTime = 1;
experimentSaveDir = ['gap', filesep(), 'experiment', filesep()];

% Load computer specific configuration.
% 'computerConfig.mat' must contain a struct named 'computerConfig' with
% the following fields:
%   saveDir - path to directory for saving training data
% The file must be placed in '~/experiment_config'.
load([getHomePath(), 'experiment_config', filesep(), 'computerConfig']);

% Get subject ID
subjectID = cell2mat(inputdlg('Subject ID:', 'Startup'));
if isempty(subjectID)
    disp('Startup cancelled.');
    return;
end

% Load the experiment array and take the last 3 chars of
% the name as experiment identifier
[f, p] = uigetfile('*.mat', 'Select GapStimulus array');
if f == 0
    disp('Startup cancelled.');
    return;
end
load([p, f]);
if exist('experimentArray', 'var')
    assert(isa(experimentArray, 'AudioObject'), ...
        'experimentArray is not of type AudioObject.');
else
    error('Selected file must contain an array named experimentArray.');
end
experimentID = f(end-6:end-4);
filePathPrefix = strcat(computerConfig.saveDir, experimentSaveDir, ...
    subjectID, '_', experimentID, '_');

% Create ArrayAOGenerator
aoGenerator = ArrayAOGenerator(experimentArray);

% Load audioPlayer configuration
% 'basicGapAudioPlayerConfig' must contain a struct named
% 'audioPlayerConfig' with fields according to the dependency-injection
% policy.
load('basicGapAudioPlayerConfig');

% Create ExperimentController config
load('arduinoConfig')
ecConfig.pins = arduinoConfig.pins;
ecConfig.arduino = ArduinoDevice();     % Windows only
ecConfig.audioPlayer = createObjFromTree(audioPlayerConfig);
ecConfig.maxReactionTime = maxReactionTime;
ecConfig.audioObjectGenerator = aoGenerator;
ec = ExperimentController(ecConfig);

% Register LogBook
lb = LogBook();
lb.addObservable(ec, 'Running');
lb.addObservable(ec, 'Stopped');
lb.addObservable(ec, 'Ascend');
lb.addObservable(ec, 'Descend');
lb.addObservable(ec, 'NewTrial');
lb.addObservable(ec, 'ManuallySkipped');

ExperimentGUI(ec, subjectID, filePathPrefix, lb);
