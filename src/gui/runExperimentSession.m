function runExperimentSession(kind, configurationFile)
%RUNEXPERIMENTSESSION opens a GUI to run a detection experiment session.
%   Arguments:
%   kind - a string identifying the kind of experiment:
%       'gap' - simple gap detection experiment [default]
%       'laserGap' - gap detection experiment with laser stimulation
%       'custom' - use a custom configuration file
%   configurationFile - a custom configuration file; must be specified, if
%       kind=='custom'. This must be a json-format file containing a struct
%       named 'audioPlayerConfig' which is a template for the construction
%       of an AudioPlayer according to the dependency injection policy.
%       Besides, it must contain a variable named 'ecReinsert' which is
%       boolean and specifies whether early-jump trials should be at the
%       end of the experiment array. (This is only usefull in non-blocked
%       designs.)

% Author: Lasse Osterhagen

% Determine kind of experiment and load the proper configuration files
if nargin < 1
    kind = 'gap';
end
switch kind
    case 'gap'
        audioPlayerConfig = loadjson('basicGapAudioPlayerConfig.json');
        ecReinsert = true;
    case 'laserGap'
        audioPlayerConfig = loadjson('basicLaserGapAudioPlayerConfig.json');
        ecReinsert = false; % Do not reinsert early-jump trials in blocked design experiments.
    case 'custom'
        if nargin < 2
            error('No custom configuration file specified.')
        end
        customConfig = loadjson(configurationFile);
        if ~isfield(customConfig, {'audioPlayerConfig', 'ecReinsert'})
            error(['Incomplete custom configuration file.', char(10), ...
                'Must contain ''audioPlayerConfig'' and ''ecReinsert''.']);
        end
        audioPlayerConfig = customConfig.audioPlayerConfig;
        ecReinsert = customConfig.ecReinsert;
    otherwise
        error('Unknown experiment type');
end

globalAudioConfig = loadjson('globalConfig.json');

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
[f, p] = uigetfile('*.mat', ['Select ', kind, ' stimulus array']);
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

% Create ExperimentController config
arduinoConfig = loadjson('arduinoConfig.json');
ecConfig.pins = arduinoConfig.pins;
ecConfig.ioDevice = ArduinoDevice();     % Windows only
ecConfig.audioPlayer = depInj.createObjFromTree(audioPlayerConfig, ...
    globalAudioConfig);
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
