function runDetectionExperimentSession(kind, configurationFile)
%RUNDETECTIONSEXPERIMENTSESSION opens a GUI to run a detection experiment session.
%   Arguments:
%   kind - a string identifying the kind of experiment:
%       'gap' [default] - simple gap detection experiment
%       'tone' - simple tone detection experiment
%       'laserGap' - gap detection experiment with laser stimulation
%       'custom' - use a custom configuration file
%   configurationFile - a custom configuration file; must be specified, if
%       kind=='custom'. This file must contain a struct named
%       'audioPlayerConfig' with fields according to the dependency
%       injection policy.

% Author: Lasse Osterhagen

% Set default argument
if nargin < 1
    kind = 'gap';
end

% Get subject ID
subjectID = cell2mat(inputdlg('Subject ID:', 'Startup'));
if isempty(subjectID)
    disp('Startup cancelled.');
    return;
end

% Load the experiment array and take the last 2 chars of
% the name as experiment identifier
[f, p] = uigetfile('*.mat', ['Select ', kind, 'stimulus array']);
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
experimentID = f(end-5:end-4);

% General parameters:
maxReactionTime = 1;
ecReinsert = true; % default: repeat early-jump trials at the end of the session
experimentSaveDir = [kind, filesep(), 'experiment', filesep()];

% Determine kind of experiment and create corresponding
% ExperimentController
switch kind
    case 'gap'
        load('basicGapAudioPlayerConfig.mat')    
    case 'laserGap'
        load('laserGapAudioPlayerConfig.mat')
        ecReinsert = false; % do not repeat early-jump trials in blocked design experiments.
    case 'tone'
        % Load config struct for ToneStimulusSampleFactory
        load('basicToneAudioPlayerConfig.mat')
        % Parameter of ToneStimulusSampleFactory depend on experimentArray
        durFreqSet = extractDurFreqSetFromExpAr(experimentArray);
        audioPlayerConfig.audioObjSamFacMap.values{1}.durFreqSet = durFreqSet;   
    case 'custom'
        if nargin < 2
            error('No custom configuration file specified.')
        end
        load(configurationFile)
end

% Load computer specific configuration.
% 'computerConfig.mat' must contain a struct named 'computerConfig' with
% the following fields:
%   saveDir - path to directory for saving training data
% The file must be placed in '~/experiment_config'.
load([depInj.getHomePath(), 'experiment_config', filesep(), 'computerConfig']);

filePathPrefix = strcat(computerConfig.saveDir, experimentSaveDir, ...
    subjectID, '_', experimentID, '_');

% Create ArrayAOGenerator
aoGenerator = ArrayAOGenerator(experimentArray);

% Create ExperimentController config
load('arduinoConfig')
ecConfig.pins = arduinoConfig.pins;
ecConfig.ioDevice = ArduinoDevice();     % Windows only
ecConfig.maxReactionTime = maxReactionTime;
ecConfig.audioPlayer = depInj.createObjFromTree(audioPlayerConfig);
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
