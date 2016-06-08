classdef (Abstract) SampleSource < handle
%SAMPLESOURCE Abstract interface for sample sources.
%   A sample source provides continuous samples that can be used as
%   background sound in which stimuli will be inserted.

% Author: Lasse Osterhagen

methods (Abstract)
    samples = getSamples(this, numSamples)
end
    
end
