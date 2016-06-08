classdef FilesSampleSource < SampleSource
%FILESSAMPLESOURCE provides continuous samples from at least two files.
%   These samples typically are used as a sound background (e. g.
%   background noise) in a signal detection paradigm.
%   Just before all samples of a file are consumed, cossfading between the
%   current and the next file will be initiated. If the end of the last
%   file is reached, its samples will be cross-faded with those of the
%   first file. In that way, the SampleSource will never run out of
%   samples.

% Author: Lasse Osterhagen
    
properties
    % Sample frequency
    sF
    % Length of gate in s
    crossFadeDuration
end

properties (SetAccess = private)
    % Cellmatrix: {'filename1', numDoubles1; 'filename2', numDoubles2;
    % etc.}
    fileSpecifications
end


properties (Access = private)
    % File id of the sound file from which samples will be loaded.
    fileID
    % Cosine gate of duration crossFadeDuration for sound onset
    cosGate
    % At which sample of the cosine gate is the sound onset defined?
    soundOnset
    % At which sample of the flipped cosine gate is the sound offset
    % defined?
    soundOffset
end

properties (Access = private)
    % index of the file that is open at the moment
    currentFileIndex = 1;

    % Following some variables for the estimation of samples/trial.
    % This estimation is needed to get samples from the next file early
    % enough to guarantee correct crossfading.
    estimatedSamples = 0;
    estimationWeight = 0;
end

properties (Constant)
    % Size of Double in Bytes
    doubleSize = 8;
end

methods
    
    function this = FilesSampleSource(fileNames_config, sF, ...
            crossFadeDuration)
        % FilesSampleSource(fileNames, sF, crossFadeDuration)
        % Arguments:
        % fileNames - a cell array of file name strings that
        %   identify sound files that contain samples of double precision,
        %   ranging from -1 to 1, written in binary format.
        % sF - sample frequency
        % crossFadeDuration - time in s that samples of two files will be
        %   cross-faded
        %
        % ContinuousSampleSource(config)
        % Arguments:
        % config - a configuration struct with all parameters as
        %   fieldnames
        if nargin == 1 % config struct
            fileNames = fileNames_config.fileNames;
            sF = fileNames_config.sF;
            crossFadeDuration = ...
                fileNames_config.crossFadeDuration;
        else % argument list
            fileNames = fileNames_config;
        end
        numFiles = length(fileNames);
        this.fileSpecifications = cell(numFiles, 2);
        for index=1:numFiles
            this.fileSpecifications(index,1) = fileNames(index);
            fileSpec = dir(fileNames{index});
            % Determine number of doubles inside the file
            this.fileSpecifications{index,2} = ...
                fileSpec.bytes/this.doubleSize;
        end
        this.fileID = fopen(this.fileSpecifications{this.currentFileIndex,1});
        this.sF = sF;
        this.crossFadeDuration = crossFadeDuration;
        this.recalculateGate;
    end

    function delete(this)
        fclose(this.fileID);
    end

    function set.sF(this, value)
        % Property set function for sample frequency
        % cosGates and gapOn/Offset are dependent
        this.sF = value;
        this.recalculateGate;
    end

    function set.crossFadeDuration(this, value)
        % Property set function for gate duration
        % cosGates and gapOn/Offset are dependent
        this.crossFadeDuration = value;
        this.recalculateGate;
    end

    function samples = getSamples(this, numSamples)
        % Get numSamples samples from the associated file(s)

        % Update the estimated samples/trial
        this.estimatedSamples = ...
           round((this.estimatedSamples*this.estimationWeight + ...
           numSamples)/(this.estimationWeight+1));
        this.estimationWeight = this.estimationWeight+1;

        samples = fread(this.fileID, numSamples, 'double');

        % Determine the number of remaining doubles in the current file
        remainingDoubles = this.fileSpecifications{this.currentFileIndex,2} - ...
           ftell(this.fileID)/this.doubleSize;
        if remainingDoubles < 2*this.estimatedSamples % there should be at
                        % at least twice as many samples as are
                        % estimated.
           % Cross fade to samples of new file
           fclose(this.fileID);
           this.currentFileIndex = mod(this.currentFileIndex, ...
               length(this.fileSpecifications)) + 1;
           this.fileID = fopen(this.fileSpecifications{this.currentFileIndex,1});
           numCrossFadeSamples = length(this.cosGate);
           newFileSamples = fread(this.fileID, numCrossFadeSamples, 'double');
           samples(end-numCrossFadeSamples+1:end) = ...
               samples(end-numCrossFadeSamples+1:end).*(1-this.cosGate) + ...
               newFileSamples.*(this.cosGate);
        end
        samples = samples';
    end

end

methods (Access = private)

    function recalculateGate(this)
        % When the gateLength or the sample frequency changes, the
        % cosGate has to be recalculated.
        cosGateSize = this.sF * this.crossFadeDuration;
        this.cosGate = ((cos(linspace(pi, 2*pi, cosGateSize))+1)*.5)';
        if isempty(this.cosGate)
           this.cosGate = [0 1];
        end
        % Define gate onset at one half of the amplitude aperture
        this.soundOnset = find(this.cosGate >= 0.5, 1);
        this.soundOffset = find((1-this.cosGate) < 0.5, 1);
    end
    
end

end
