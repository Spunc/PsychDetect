classdef ToneStimulus < Stimulus
%TONESTIMULUS is a stimulus that represents a sine tone.
%   Input arguments:
%       id=0,
%       startDelay=0,               % sec
%       target=Target.Yes_Reward,
%       'duration', 0.500,          % sec
%       'frequency', 10000,         % Hz
%       'level', 60                 % dB

% Author: Lasse Osterhagen

properties
    % Tone frequency of the tone [default=10000 Hz]
    frequency
    % dB level of the tone [default=60 dB]
    level
end

methods

    function this = ToneStimulus(varargin)
        p = inputParser;
        addOptional(p, 'id', 0, @isnumeric);
        checkPositiveNumber = @(x) isnumeric(x) && x>=0;
        addOptional(p, 'startDelay', 0, checkPositiveNumber);
        addOptional(p, 'target', Target.Yes_Reward, @(x) isa(x, 'Target'));
        addParameter(p, 'duration', .5, checkPositiveNumber);
        addParameter(p, 'frequency', 10000, checkPositiveNumber);
        addParameter(p, 'level', 60, @isnumeric);
        parse(p, varargin{:});
        this = this@Stimulus(p.Results.id, p.Results.startDelay, ...
            p.Results.duration, p.Results.target);
        this.frequency = p.Results.frequency;
        this.level = p.Results.level;
    end

end

methods(Access = protected)

    function eventData = getEventData(this)
        eventData = [getEventData@Stimulus(this);
            {'Level', this.level;
            'Frequency', this.frequency}];
    end

end

end
