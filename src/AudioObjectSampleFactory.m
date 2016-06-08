classdef (Abstract) AudioObjectSampleFactory < handle
%AUDIOOBJECTSAMPLEFACTORY creates audio sample matrices from AudioObjects.

% Author: Lasse Osterhagen

methods (Abstract)

    outMatrix = makeAudioObjectSamples(this, audioObject, rawSamples)
    % Modifies the rawSamples so that the AudioObject will be included.
    % The minimum number of samples needed to represent the AudioObject can
    % be determined by the function calcRequiredSamples(). If more
    % rawSamples than neede are provided, the remaining rawSamples will be
    % left unmodified.

    numSamples = calcRequiredSamples(this, audioObject)
    % Calculates the number of samples that are required for the
    % audioObject to fit in.

end

end

