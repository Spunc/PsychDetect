classdef (Abstract) PsychPortAudioPlayer < AudioPlayer
%PSYCHPORTAUDIOPLAYER is a PsychPortAudio implementation of AudioPlayer.
%   This abstract class can be used as starting point to PsychPortAudio
%   implementations of AudioPlayer. It wraps initialization code of
%   PsychPortAudio to create a class with a proper interface and to deal
%   with resource management (i. e. requesting and releasing a sound
%   device).

% Author: Lasse Osterhagen

properties (SetAccess = private)
    % Sample frequency
    sF
    % A row vector containing the indices (starting from 0) of the
    % soundcard channels to be used
    channelMapping
end

properties (Access = protected)
    % Handle to PsychPortAudio object
    pahandle
end
    
properties (Dependent, SetAccess = private)
    % Number of used sound channels on audio device
    numChannels
end

methods

    function this = PsychPortAudioPlayer(sF_config, channelMapping)
        % PsychPortAudioPlayer(sF, channelMapping)
        % Arguments:
        % sF - sample frequency
        % channelMapping - ordered row vector with indices of used
        %   channels of the audio device
        %
        % AudioPlayer(config)
        % config - a configuration struct with all parameters as
        % fieldnames
        if nargin == 1
            sF = sF_config.sF;
            channelMapping = sF_config.channelMapping;
        else
            sF = sF_config;
        end
        this.sF = sF;
        this.channelMapping = channelMapping;
        this.init()
    end

    function delete(this)
        PsychPortAudio('Close', this.pahandle);
        disp('PsychPortAudio closed.');
    end

    function value = get.numChannels(this)
        value = length(this.channelMapping);
    end

end 

methods (Access = private)

    function init(this)
        % Initialize AudioPlayer
        InitializePsychSound();
        % Provide some debug output
        PsychPortAudio('Verbosity', 10);
        % pahandle = PsychPortAudio('Open' [, deviceid][, mode]
        % [, reqlatencyclass][, freq][, channels][, buffersize]
        % [, suggestedLatency][, selectchannels][, specialFlags=0]);
        this.pahandle = PsychPortAudio('Open', [], 1, ...
            1, this.sF, this.numChannels, [], ...
            [], this.channelMapping);
    end

end

end

