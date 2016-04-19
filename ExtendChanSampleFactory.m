classdef ExtendChanSampleFactory < AudioObjectSampleFactory
% Decorator that can be used to extend the number of audio output
% channels of an AudioObjectSampleFactory to the number of output
% channels in use by an AudioPlayer. Those additional audio channels
% will all be zeroed.
% Example: If an AudioObjectSampleFactory only provides samples for
% the sound channel (channel 1), but there are additional audio channel
% (e. g. for lasers) that must be fed into the AudioPlayer, this class
% creates additional zero-valued rows in outMatrix, when a call to
% makeAudioObjectSamples() has been made.

% Author: Lasse Osterhagen

properties
    % The AudioObjectSampleFactory that is decorated
    sampleFactory
    % Number of channels needed (inclusive sound channel, exclusive
    % trigger channel)
    numChannels
end

methods

    function this = ExtendChanSampleFactory(audioSampleFactory_config, numChannels)
        % ExtendChanSampleFactory(audioSampleFactory, gateDuration)
        % Arguments:
        % audioSampleFactory - AudioObjectSampleFactory that should be
        %   decorated
        % numChannels - number of output channels
        %
        % ExtendChanSampleFactory(config)
        % Arguments:
        % config - a configuration struct with all parameters as
        %   fieldnames
        if nargin == 1
            assert(isstruct(audioSampleFactory_config), 'ExtendChanSampleFactory:ValueError', ...
                'Single argument must be a struct.');
            audioSampleFactory = audioSampleFactory_config.audioSampleFactory;
            numChannels = audioSampleFactory_config.numChannels;
        else
            audioSampleFactory = audioSampleFactory_config;
        end
        this.sampleFactory = audioSampleFactory;
        this.numChannels = numChannels;
    end

    function outMatrix = makeAudioObjectSamples(this, audioObject, ...
        rawSamples)
        % Create audioObject samples. The number of output channels
        % is equal to this.numChannels.
        % If this.numChannels is smaller than the number of rows
        % provided by the enclosed AudioObjectSampleFactory, only the
        % first numChannels rows will be returned.
        createdSamples = this.sampleFactory.makeAudioObjectSamples( ...
            audioObject, rawSamples);
        createdRows = size(createdSamples, 1);
        insertRows = min(createdRows, this.numChannels);
        outMatrix = zeros(this.numChannels, length(rawSamples));
        outMatrix(1:insertRows,:) = createdSamples(1:insertRows,:);
    end

    function numSamples = calcRequiredSamples(this, audioObject)
        % Calculated the number of raw audio samples needed to create
        % audioObject.
        % This decorator just delegates this function to the enclosed
        % AudioObjectSampleFactory.
        numSamples = this.sampleFactory.calcRequiredSamples(audioObject);
    end

end

end

