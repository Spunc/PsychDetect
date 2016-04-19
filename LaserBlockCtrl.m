classdef LaserBlockCtrl < AudioObject
%LASERBLOCKCTRL is an AudioObject for controlling a Laser.
%   Input arguments:
%       id,
%       channel,        % from channel mapping
%       duration,       % sec
%       dcAmplitude     % sample value (0 to 1)
%
%   The purpose of this class is to let the AudioPlayer play (DC-) samples
%   of a predefined intensity for a predefined amount of time at the sound
%   channel that is connected to the laser.
%   The channel number is not the physical channel at the sound device, but
%   one of the consecutive mapped channels.
%   This functionality works only if the sound device provides DC output at
%   the specified channel. dcAmplitude can be specified with values within the 
%   normal float sound sample range (0 to 1). The mapping between sample value
%   and DC output voltage should be measured.

% Author: Lasse Osterhagen

properties
    % Sound channel of the laser (the mapped channel no) [default=1]
    channel
    % DC amplitude (intensity) as sample value
    dcAmplitude
end

methods

    function this = LaserBlockCtrl(varargin)
        p = inputParser;
        addRequired(p, 'id');
        addRequired(p, 'channel', @(x) isnumeric(x) && x>0);
        addRequired(p, 'duration', @(x) isnumeric(x) && x>=0);
        addOptional(p, 'dcAmplitude', 1, @(x) isnumeric(x) && x>=0 && x<=1);
        parse(p, varargin{:});
        this.id = p.Results.id;
        this.channel = p.Results.channel;
        this.duration = p.Results.duration;
        this.dcAmplitude = p.Results.dcAmplitude;
    end

end

methods (Access = protected)

    function eventData = getEventData(this)
        % Provides laser control specification as attribute - value pairs.
        % Default (in addition to AudioObject, which provides
        %   {'Type', class(this)}:
        % {
        % 'Channel', this.channel;
        % 'Duration', this.duration;
        % 'DCAmplitude', this.dcAmplitude
        % }
        eventData = {'Channel', this.channel;
                    'Duration', this.duration;
                    'DCAmplitude', this.dcAmplitude};
    end

end

end
