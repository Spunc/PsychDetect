function runDetectionExperimentSession(kind, configurationFile)
%RUNDETECTIONSEXPERIMENTSESSION opens a GUI to run a detection experiment session.
%   Arguments:
%   kind - a string identifying the kind of experiment:
%       'gap' [default] - simple gap detection experiment
%       'laserGap' - gap detection experiment with laser stimulation
%       'custom' - use a custom configuration file
%   configurationFile - a custom configuration file; must be specified, if
%       kind=='custom'. This file must contain a struct named
%       'audioPlayerConfig' with fields according to the dependency
%       injection policy.

% Author: Lasse Osterhagen

% Determine kind of experiment and load the proper configuration files
if nargin < 1
    kind = 'simple';
end

switch kind
    case 'gap'
        audioConfigFile = 'basicGapAudioPlayerConfig.mat';
        ecReinsert = true;
    case 'laserGap'
        audioConfigFile = 'laserGapAudioPlayerConfig.mat';
        ecReinsert = false; % Do not reinsert early-jump trials in blocked design experiments.
    case 'custom'
        if nargin < 2
            error('No custom configuration file specified.')
        end
        audioConfigFile = configurationFile;
end

% Constants:
maxReactionTime = 1;
experimentSaveDir = [kind, filesep(), 'experiment', filesep()];

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

% Load audioPlayer configuration file, which must contain a struct named
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
ec.setReinsertTrials(ecReinsert);

% Register LogBook
lb = LogBook();
lb.addObservable(ec, 'Running');
lb.addObservable(ec, 'Stopped');
lb.addObservable(ec, 'Ascend');
lb.addObservable(ec, 'Descend');
lb.addObservable(ec, 'NewTrial');
lb.addObservable(ec, 'ManuallySkipped');

ExperimentGUI(ec, subjectID, filePathPrefix, lb);
