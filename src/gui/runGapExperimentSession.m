function runGapExperimentSession(kind)
%RUNGAPTRAININGSESSION opens a GUI to run a gap training session.
%   Arguments:
%   kind - a string identifying the kind of experiment:
%       'simple' [default] - simple gap detection experiment
%       'laser' - with laser stimulation

% Author: Lasse Osterhagen

% Determine kind of experiment and load the proper configuration files
if nargin < 1
    kind = 'simple';
end

switch kind
    case 'simple'
        audioConfigFile = 'basicGapAudioPlayerConfig.mat';
    case 'laser'
        audioConfigFile = 'laserGapAudioPlayerConfig.mat';
end

% Constants:
maxReactionTime = 1;
experimentSaveDir = ['gap', filesep(), 'experiment', filesep()];

% Load computer specific configuration.
% 'computerConfig.mat' must contain a struct named 'computerConfig' with
% the following fields:
%   saveDir - path to directory for saving training data
% The file must be placed in '~/experiment_config'.
load([depInj.getHomePath(), 'experiment_config', filesep(), 'computerConfig']);

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
load(audioConfigFile);

% Create ExperimentController config
load('arduinoConfig')
ecConfig.pins = arduinoConfig.pins;
ecConfig.ioDevice = ArduinoDevice();     % Windows only
ecConfig.audioPlayer = depInj.createObjFromTree(audioPlayerConfig);
ecConfig.maxReactionTime = maxReactionTime;
ecConfig.audioObjectGenerator = aoGenerator;
ec = ExperimentController(ecConfig);
ec.setReinsertTrials(true);

% Register LogBook
lb = LogBook();
lb.addObservable(ec, 'Running');
lb.addObservable(ec, 'Stopped');
lb.addObservable(ec, 'Ascend');
lb.addObservable(ec, 'Descend');
lb.addObservable(ec, 'NewTrial');
lb.addObservable(ec, 'ManuallySkipped');

ExperimentGUI(ec, subjectID, filePathPrefix, lb);
