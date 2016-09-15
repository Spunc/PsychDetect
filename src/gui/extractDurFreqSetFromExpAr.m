function durFreqSet = extractDurFreqSetFromExpAr(expAr)
%EXTRACTDURFREQSETFROMEXPAR extracts the duration/frequency set for
%ToneStimulus objects from an experimentArray
%   Arguments:
%   expAr - the experimentArray

% Author: Lasse Osterhagen

% Get all ToneStimulus objects
tar = expAr(arrayfun(@(x) isa(x, 'ToneStimulus'), expAr));
% Get the set of duration/frequency combinations
durFreq = [ [tar.duration]', [tar.frequency]' ];
durFreqSet = unique(durFreq, 'rows');

end
