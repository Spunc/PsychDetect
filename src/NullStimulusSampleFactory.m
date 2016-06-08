classdef NullStimulusSampleFactory < AudioObjectSampleFactory
% NULLSTIMULUSSAMPLEFACTORY creates audio samples for NullStimuli.
%   It just returns the raw samples it got from the SampleSource.

% Author: Lasse Osterhagen

methods

    function this = NullStimulusSampleFactory(~)
        % Empty contructor to allow use by dependency-injection framework
    end

    function outMatrix = makeAudioObjectSamples(~, ~, ...
        rawSamples)
        outMatrix = rawSamples;
    end

    function numSamples = calcRequiredSamples(~, ~)
        numSamples = 0;
    end

end

end

