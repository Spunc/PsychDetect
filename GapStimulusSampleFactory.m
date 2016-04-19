classdef GapStimulusSampleFactory < AudioObjectSampleFactory
%GAPSTIMULUSSAMPLEFACTORY creates gaps in continuous background sound.
%   This class is an AudioObjectSampleFactory that inserts gaps in a
%   continuous background sound (e. g. white noise).
%   Attention: The gate duration may be at most as long as the shortest
%   gap.

% Author: Lasse Osterhagen
    
properties
    % Sample frequency
    sF
    % Length of gate in s
    gateDuration
end

properties (Access = private)
    % Cosine gate of duration gateDuration for sound onset
    cosGate
    % At which sample of the cosine gate is the sound onset defined?
    soundOnset
    % At which sample of the flipped cosine gate is the sound offset
    % defined?
    soundOffset
end

methods

    function this = GapStimulusSampleFactory(sF_config, gateDuration)
        % GapStimulusSampleFactory(sF, gateDuration)
        % Arguments:
        % sF - sample frequency
        % gateDuration - duration of the cosine gate in s
        %
        % GapStimulusSampleFactory(config)
        % Arguments:
        % config - a configuration struct with all parameters as
        %   fieldnames
        if nargin == 1
            assert(isstruct(sF_config), 'GapStimulusSampleFactory:ValueError', ...
                'Single argument must be a struct.');
            sF = sF_config.sF;
            gateDuration = sF_config.gateDuration;
        else
            sF = sF_config;
        end
        this.sF = sF;
        this.gateDuration = gateDuration;
        this.recalculateGate();
    end

    function set.sF(this, value)
        % Property set function for sample frequency
        this.sF = value;
        this.recalculateGate;
    end

    function set.gateDuration(this, value)
        % Property set function for gate duration
        this.gateDuration = value;
        this.recalculateGate;
    end

    function numSamples = calcRequiredSamples(this, stimulus)
        % Get number of audio samples required for this stimulus.
        % The number of samples needed depends on the gap itself and the
        % gate size.
        numSamples = round(stimulus.duration*this.sF+ ...
            2*(this.soundOffset-1));
    end

    function samples = makeAudioObjectSamples(this, stimulus, samples)
        % Insert a gap into input samples.
        % The input samples will be modified so that the gap stimulus will
        % be inserted at the beginning of the samples. Provide at least as
        % many samples as are required for the stimulus. To get the number
        % of required samples, call calcRequiredSamples().
        if stimulus.duration < this.gateDuration
            throw(MException('GapStimulusSampleFactory:ValueError', ...
                'Gap length must be at least as long as the gate duration.'));
        end
        if length(samples) < this.calcRequiredSamples(stimulus)
            throw(MException('GapStimulusSampleFactory:ValueError', ...
                'Length of rawSamples shorter than required.'));
        end
        rampLength = length(this.cosGate);
        % Make offset ramp
        flippedGate = 1-this.cosGate;
        samples(1,1:rampLength) = ...
            samples(1,1:rampLength).*flippedGate;
        % Make zeros
        zerosSize = round(stimulus.duration*this.sF- ...
            2*(this.soundOnset-1));
        samples(1,rampLength+1:rampLength+zerosSize) = 0;
        % Make offset ramp
        samples(1,rampLength+zerosSize+1:2*rampLength+zerosSize) = ...
            samples(1,rampLength+zerosSize+1:2*rampLength+zerosSize).* ...
            this.cosGate;
    end

end

methods (Access = private)

    function recalculateGate(this)
        % When the geteLength or the sample frequency changes, cosGate and
        % gapOnset have to be recalculated.
        cosGateSize = this.sF * this.gateDuration;
        this.cosGate = (cos(linspace(pi, 2*pi, cosGateSize))+1)*.5;
        % We do not need the first and the last values (0 and 1)
        if cosGateSize >= 2
            this.cosGate(end) = [];
            this.cosGate(1) = [];
        end
        % Define gate onset at half the amplitude aperture
        this.soundOnset = find(this.cosGate >= 0.5, 1);
        if isempty(this.soundOnset)
            % Then the first sample is already the onset.
            this.soundOnset = 1;
        end
        this.soundOffset = find((1-this.cosGate) < 0.5, 1);
        if isempty(this.soundOffset)
            % Then the first sample is already the offset.
            this.soundOffset = 1;
        end
    end

end

end
