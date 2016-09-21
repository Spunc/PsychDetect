function runTrainingSession(kind)
%RUNTRAININGSESSION opens a GUI to run a detection training session.
%   Arguments:
%   kind - 'gap' for gap-in-noise detection training [default];
%          'tone' for tone-in-noise detection training.

% Author: Lasse Osterhagen

if nargin < 1
    kind = 'gap';
end

switch kind
    case 'gap'
        defaultTrainingParamFile = 'basicGapTrainingConfig.json';
        audioPlayerConfig = loadjson('basicGapAudioPlayerConfig.json');
    case 'tone'
        defaultTrainingParamFile = 'basicToneTrainingConfig.json';
        audioPlayerConfig = loadjson('basicToneAudioPlayerConfig.json');
    otherwise
        error('Unknown training type');
end

% Load global audio config
globalAudioConfig = loadjson('globalConfig.json');

% Load computer specific configuration.
% 'computerConfig.mat' must contain a struct named 'computerConfig' with
% the following fields:
%   saveDir - path to directory for saving training data
% The file should be placed in '~/experiment_config'.
load([depInj.getHomePath(), 'experiment_config', filesep(), 'computerConfig']);

% Get subject ID
subjectID = cell2mat(inputdlg('Subject ID:', 'Startup'));
if isempty(subjectID)
    disp('Startup cancelled.');
    return;
end

% Try loading existing parameters
filePathPrefix = strcat(computerConfig.saveDir, kind, filesep(), 'training', ...
    filesep(), subjectID, '_');
fileParam = strcat(filePathPrefix, 'param.mat');
if exist(fileParam, 'file')
    load(fileParam);
    disp('Training parameters loaded.');
else
    trainingConfig = loadjson(defaultTrainingParamFile);
end

% Create ExperimentController config
arduinoConfig = loadjson('arduinoConfig.json');
ecConfig.pins = arduinoConfig.pins;
ecConfig.ioDevice = ArduinoDevice();     % Windows only
if strcmp(kind, 'tone')
    % AudioObjectSampleFactory for tone must be updated according to
    % duration/frequencies of training parameters
    durFreqSet = combvec(trainingConfig.stimTrainerConfig.durations, ...
        trainingConfig.stimTrainerConfig.frequencies)';
    audioPlayerConfig.audioObjSamFacMap.values{1}.durFreqSet = durFreqSet;
end
ecConfig.audioPlayer = depInj.createObjFromTree(audioPlayerConfig, ...
    globalAudioConfig);
ecConfig.maxReactionTime = trainingConfig.maxReactionTime;
ecConfig.audioObjectGenerator = depInj.createObjFromTree( ...
    trainingConfig.stimTrainerConfig, globalAudioConfig);
ec = ExperimentController(ecConfig);

% Register LogBook
lb = LogBook();
lb.addObservable(ec, 'Running');
lb.addObservable(ec, 'Stopped');
lb.addObservable(ec, 'Ascend');
lb.addObservable(ec, 'Descend');
lb.addObservable(ec, 'NewTrial');
lb.addObservable(ec, 'ManuallySkipped');

% Show GUI
switch kind
    case 'gap'
        GapTrainingGUI(ec, subjectID, filePathPrefix, lb);
    case 'tone'
        ToneTrainingGUI(ec, ecConfig.audioPlayer, subjectID, filePathPrefix, ...
            lb);
end

