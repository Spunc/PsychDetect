function arduinoPorts = findArduinoPorts()
%FINDARDUINOPORTS find COM-ports auf connected Arduino devices
%   This function returns a cell-array of strings with all Arduino
%   COM-ports that could be found on the computer.
%
%   Attention: This function is platform dependent and works on Windows
%   only. It depends on 'listComPorts.exe' from the usbSearch tools
%   developed by Tod E. Kurt. See extLib/usbSearch/README.txt

% Author: Lasse Osterhagen

% Get path extLib\usbSearch\listComPorts.exe
mFileFullPath = mfilename('fullpath');
path = mFileFullPath(1:strfind(mFileFullPath, 'findArduinoPorts')-1);
path = [path, 'extLib\usbSearch\listComPorts.exe'];
[~, comPorts] = system(path);
% split at newline:
comPorts = textscan(comPorts, '%s', 'delimiter', '\n');
comPorts = comPorts{1};
arduinoPorts = cell.empty;
for index=1:length(comPorts)
    if strfind(lower(comPorts{index}), 'arduino')
        arduinoPorts{end+1} = comPorts{index}(1:4); %#ok<AGROW>
    end
end
