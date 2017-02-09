function trialsStr = extractStimuli(eventLog)
%EXTRACTSTIMULI extracts the stimuli from an eventLog cell array.
%   eventLog is the raw output data of a PsychDetect experiment as it is
%   saved to a .mat file.
%   The output of the function will be an array of structs that contains 
%   all stimuli played.

% Author: Lasse Osterhagen

trialIdx = cellfun(@(x) strcmp(x{1}, 'NewTrial'), eventLog);
trials = eventLog(trialIdx);
trialsStr = cellfun(@(x) cell2struct(x(:,2), x(:,1), 1), trials);

end
