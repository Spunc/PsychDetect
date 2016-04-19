classdef SineSampleSource < SampleSource
%SINESAMPLESOURCE provides samples from a single sine.
%   This is a very simple wavetable oscillator. For simplicity, the output
%   frequency is the nearest to the desired frequency that results in
%   an integer wavetable length.

% Author: Lasse Osterhagen

properties (SetAccess = private)
    % Wave table of the sine
    waveTable
    % Number of samples in the wave table
    wtSamples
    % Current position in the wave table
    cursorPos = 0; % points one before the next sample
end

methods

    function this = SineSampleSource(sF_config, sineFreq, amplitude)
        % SineSampleSource(sF, sineFreq, amplitude, waveTableLen, numOutputs)
        % Arguments:
        % sF - sample frequency
        % sineFreq - frequency of the sine (only integer values allowed)
        % amplitude - amplitude of the sine (0-1)
        %
        % SineSampleSource(config)
        % Arguments:
        % config - a configuration struct with all parameters as
        %   fieldnames
        
        if nargin == 1
            assert(isstruct(sF_config), 'SineSampleSource:ValueError', ...
                'Single argument must be a struct.');
            sF = sF_config.sF;
            sineFreq = sF_config.sineFreq;
            amplitude = sF_config.amplitude;
        else
            sF = sF_config;
        end
        targetFreq = sF/(round(sF/sineFreq));
        disp(['Target frequency is: ', num2str(targetFreq), ' Hz.']);
        wtLen = sF/targetFreq;
        t = 0:1/sF:wtLen/sF-1/sF;
        this.waveTable = amplitude*sin(2*pi*sineFreq*t);
        this.wtSamples = wtLen;
    end

    function samples = getSamples(this, numSamples)
        chunksNeeded = ceil(numSamples/this.wtSamples);
        samples = repmat(circshift(this.waveTable, [1, -this.cursorPos]), 1, chunksNeeded);
        this.cursorPos = mod(this.cursorPos+numSamples, this.wtSamples);
        samples = samples(1:numSamples);
    end
end
    
end

