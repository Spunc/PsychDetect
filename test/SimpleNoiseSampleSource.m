classdef SimpleNoiseSampleSource < SampleSource
%SIMPLENOISESAMPLESOURCE generates uniform distributed white noise.
%   This is a very simple sample source for test purposes only. It should
%   not be used in psychophysic experiments, because the level and the
%   frequency distribution will depend on the sound equipment on site.

% Author: Lasse Osterhagen

properties
    amplitude
    numOutputs
end

methods
    
    function this = SimpleNoiseSampleSource(amplitude_config, numOutputs)
        % SimpleNoiseSampleSource(amplitude, numOutputs)
        % Arguments:
        % amplitude - the amplitude of the noise (0-1)
        % numOutputs - the number of output channels
        %
        % SimpleNoiseSampleSource(config)
        % Arguments:
        % config - a configuration struct with all parameters as
        %   fieldnames
        if nargin == 1
            assert(isstruct(amplitude_config), ...
                'SimpleNoiseSampleSource:ValueError', ...
                'Single argument must be a struct.');
            amplitude = amplitude_config.amplitude;
            numOutputs = amplitude_config.numOutputs;
        else
            amplitude = amplitude_config;
        end
        this.amplitude = amplitude;
        this.numOutputs = numOutputs;
    end
    
    function samples = getSamples(this, numSamples)
        samples = (rand(this.numOutputs, numSamples)-.5).*2*this.amplitude;
    end
        
end
    
end

