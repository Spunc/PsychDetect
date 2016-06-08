classdef ToneStimulusSampleFactory < AudioObjectSampleFactory
%TONESTIMULUSLEVELSAMPLEFACTORY creates tones in continuous background sound.
%   This class is an AudioObjectSampleFactory that inserts tones in a
%   continuous background sound (e. g. white noise).
%   It can only create samples for ToneStimuli from a fixed set of
%   frequencies and durations. Boths sets have to be predefined as
%   parameters of this class.
%   It needs a calibration struct as input argument, so that the correct
%   voltage amplitude for the desired output level (dB SPL) can be
%   calculated.

% Author: Lasse Osterhagen

properties (SetAccess = private)
    % Sample frequency
    sF
    % Length of gate in s
    gateDuration
    % Reverence dB SPL
    refdB    
end

properties (Access = private)
    % Set of tone durations
    durations
    % Set of tone frequencies
    frequencies       
    % Cell matrix of sine wave tables. Rows: durations; columns: frequencies
    waveTables
    % Reverence amplitudes of frequencies
    refAmplitudes
end

methods

    function this = ToneStimulusSampleFactory(sF_config, gateDuration, ...
            durFreqSet, calib)
        % ToneStimulusSampleFactory(sF, gateDuration, durFreqSet, calib)
        % Arguments:
        % sF - sample frequency
        % gateDuration - duration of the cosine gate in s for fading
        % durFreqSet - the set of tone duration and tone frequency
        %   combinations that this SampleFactory will produce. Specify a
        %   matrix with each row being a set member, durations in the first
        %   column and frequencies and the second colum.
        % calib - a calibration struct with reference voltage values.
        %   The struct must contain the following fields:
        %       'freq' - an array of frequencies for which reference
        %          voltages exist.
        %       'voltage' - an array of reference voltages corresponding to
        %           the array in 'freq', that will produce the reference dB
        %           SPL level.
        %       'refdB' - the reference dB SPL.
        %
        % ToneStimulusSampleFactory(config)
        % Arguments:
        % config - a configuration struct with all parameters as
        %   fieldnames
        
        % handle required inputs
        if nargin == 1
            assert(isstruct(sF_config), 'ToneStimulusSampleFactory:ValueError', ...
                'Single argument must be a struct.');
            sF = sF_config.sF;
            gateDuration = sF_config.gateDuration;
            durFreqSet = sF_config.durFreqSet;
            calib = sF_config.calib;
        else
            sF = sF_config;
        end
        % Some validation (not exhaustive)
        validateattributes(durFreqSet, {'numeric'}, {'positive', 'ncols',2}, ...
            'ToneStimulusSampleFactory', 'durFreqSet', 3);
        assert(isstruct(calib) && all(isfield(calib, ...
            {'freq', 'voltage', 'refdB'})), 'ToneStimulusSampleFactory:ValueError', ...
            'calib must be a struct containg the fields freq, voltage, and refdB.');
        
        this.sF = sF;
        this.gateDuration = gateDuration;
        this.refdB = calib.refdB;
        this.createwaveTables(durFreqSet, calib);
    end

    function numSamples = calcRequiredSamples(this, stimulus)
        % A stimulus needs a specific amount of samples that depends
        % on the size of the wavetable that corresponds to the
        % stimulus. This size is needed to provide enough raw
        % samples to the function makeStimulusSamples.
        [rowIndex,colIndex] = this.getWavetableIndices(stimulus);
        numSamples = length(this.waveTables{rowIndex,colIndex});
    end
    
    function outMatrix = makeAudioObjectSamples(this, toneStimulus, rawSamples)
        % Create a stimulus sample matrix (outMatrix) from raw sound
        % samples (rawSamples) with stimulus properties defined in
        % stimulus.
        if length(rawSamples) < this.calcRequiredSamples(toneStimulus)
            throw(MException('ToneStimulusSampleFactory:ValueError', ...
                'Length of rawSamples shorter than required.'));
        end
        [rowIndex,colIndex] = this.getWavetableIndices(toneStimulus);
        outMatrix = rawSamples;
        % Calculate the amplitude according to the calibration and
        % stimulus values
        amplitude = this.refAmplitudes(colIndex)*10^ ...
            ((toneStimulus.level-this.refdB)/20);
        scaledSineWave = this.waveTables{rowIndex,colIndex}* amplitude;
        outMatrix(1:length(scaledSineWave)) = ...
            outMatrix(1:length(scaledSineWave)) + scaledSineWave;
    end

end

methods (Access = private)
    
    function createwaveTables(this, durFreqSet, calib)
        % This function creates the wave tables for all tones to play.
        this.durations = unique(durFreqSet(:,1));
        this.frequencies = unique(durFreqSet(:,2));
        
        % Create the cosine gate
        cosGateSize = this.sF*this.gateDuration;
        cosGate = (cos(linspace(pi, 2*pi, cosGateSize))+1)*.5;
        % We do not need the first and the last values (0 and 1)
        if cosGateSize >=2
            cosGate(end) = [];
            cosGate(1) = [];
        end
        cosGateSize = length(cosGate);
        soundOnset = find(cosGate >= 0.5, 1);
        
        % Create wave tables
        this.waveTables = cell(length(this.durations), ...
            length(this.frequencies));
        sizeDurFreqSet = size(durFreqSet);
        for index=1:sizeDurFreqSet(1)
            dur = durFreqSet(index, 1);
            freq = durFreqSet(index, 2);
            tableSize = floor(dur*this.sF+2*(soundOnset-1));
            timeAxis = (0:tableSize-1)/this.sF;
            rowIndex = find(this.durations == dur, 1);
            colIndex = find(this.frequencies == freq, 1);
            % Tone
            this.waveTables{rowIndex, colIndex} = ...
                sin(2*pi*freq*timeAxis);
            % Fade in
            this.waveTables{rowIndex, colIndex}(1:cosGateSize) = ...
                this.waveTables{rowIndex, colIndex}(1:cosGateSize).* ...
                cosGate;
            % Fade out
            this.waveTables{rowIndex, colIndex}(end-cosGateSize+1:end) = ...
                this.waveTables{rowIndex, colIndex}(end-cosGateSize+1:end).* ...
                (1-cosGate);
        end
        
        % For all frequencies to play, find the closest corresponding
        % reference voltages and copy them to this.refAmplitudes
        calibIndices = knnsearch(calib.freq', this.frequencies);
        this.refAmplitudes = calib.voltage(calibIndices);
    end

    function [rowIndex, colIndex] = getWavetableIndices(this, toneStimulus)
        % Get the wave table indices for a specific stimulus
        rowIndex = find(this.durations == toneStimulus.duration, 1);        
        colIndex = find(this.frequencies == toneStimulus.frequency, 1);
        if isempty(rowIndex) || isempty(colIndex) || ...
                isempty(this.waveTables{rowIndex, colIndex})
            throw(MException('ToneStimulusSampleFactory:ValueError', ...
                ['No corresponding wavetable to specified stimulus: ', ...
                'frequency: ', num2str(toneStimulus.frequency), '; duration: ', ...
                num2str(toneStimulus.duration)]));
        end
    end

end

end
