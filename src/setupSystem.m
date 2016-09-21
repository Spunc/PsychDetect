function setupSystem(saveFileDir)
%SETUPSYSTEM sets up the system for use of PsychDetect.
%   Arguments:
%   saveFileDir - full path to base directory to which experimental data
%       will be saved. [default: 'HOME/experiment_data']
%
%   setupSystem will create a directory 'experiment_config' within your
%   home directory to which configuration files will be saved. If you do
%   not specify the parameter 'saveFileDir', another directory
%   'experiment_data' will be created within your home directory to which
%   experimental data will be saved.

% Check existence of toolbox dependencies
if isempty(help('PsychportAudio'))
    error('Psychtoolbox (www.psychtoolbox.org) missing');
end
if isempty(help('loadjson'))
    error(['jsonlab toolbox missing. ', ...
        'Check www.iso2mesh.sourceforge.net and install the missing toolbox.']);
end

% Make sure, last char of saveFileDir is a correct filesep char
if saveFileDir(end) == '/' || saveFileDir(end) == '\'
    saveFileDir(end) = filesep();
else
    saveFileDir(end+1) = filesep();
end

path2ExpConf = [depInj.getHomePath(), 'experiment_config', filesep()];

% Create 'experiment_config/'
checkCreate(path2ExpConf, ...
    'Cannot create directory ''experiment_config'' within home directory.');

% Create saveFileDir
checkCreate(saveFileDir, ...
    ['Cannot create directory ''', saveFileDir, char(39), '.']);

% Create subdirectories within saveFileDir
defaultErrMsg = ['Cannot create subdirectories within ', ...
    char(39), saveFileDir, char(39), '.'];
checkCreate([saveFileDir, 'gap'], defaultErrMsg);
checkCreate([saveFileDir, 'gap', filesep(), 'training'], defaultErrMsg);
checkCreate([saveFileDir, 'gap', filesep(), 'experiment'], defaultErrMsg);
checkCreate([saveFileDir, 'tone'], defaultErrMsg);
checkCreate([saveFileDir, 'tone', filesep(), 'training'], defaultErrMsg);
checkCreate([saveFileDir, 'tone', filesep(), 'experiment'], defaultErrMsg);
checkCreate([saveFileDir, 'custom', filesep(), 'experiment'], defaultErrMsg);

% Create struct variable 'computerConfig' and save it within
% 'experiment_config'.
computerConfig.saveDir = saveFileDir; %#ok<STRNU>
save([path2ExpConf, 'computerConfig'], 'computerConfig');

end

function checkCreate(dirPath, errormsg)
%CHECKCREATE helper function that checks whether a directory exists and if
%not, tries to create that directory.

switch exist(dirPath, 'file')
    case 0
        if ~mkdir(dirPath)
            error(errormsg);
        end
    case 7
        % do nothing
    otherwise
        error(errormsg);
end

end