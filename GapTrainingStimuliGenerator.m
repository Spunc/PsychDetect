classdef GapTrainingStimuliGenerator < AudioObjectGenerator
%GAPINTERVALDELAYGENERATOR creates GapStimuli for training.
%   This AudioObjectGenerator creates GapStimuli with a normally distributes
%   gap duration, for which mean and std can be specified.
%   The normal distribution will be cut off at gapDurationBounds.
%   The start delay is uniformly distributes between startDelayBounds.

% Author: Lasse Osterhagen

properties
    % Gap duration [mean, std]
    gapDuration
    % Gap duration bounds [min, max]
    gapDurationBounds = [.001, 999]; % init values used for initialization
    % Start delay bounds
    startDelayBounds
end

properties (Access = private)
    % Running id
    id = 1
end

methods

    function this = GapTrainingStimuliGenerator(config)
        % GapTrainingStimuliGenerator(config)
        % Arguments:
        % config - configuration struct with all parameters as fieldnames
        %   (including: gapDuration, gapDurationBounds, startDelayBounds)
        this.gapDuration = config.gapDuration;
        this.gapDurationBounds = config.gapDurationBounds;
        this.startDelayBounds = config.startDelayBounds;
        rng('shuffle'); % Seed the random number generator
    end

    function gapStimulus = next(this)
        gapDur = max(min(this.gapDuration(1)+ ...
            randn*this.gapDuration(2), this.gapDurationBounds(2)), ...
            this.gapDurationBounds(1));
        startDel = (this.startDelayBounds(2)-this.startDelayBounds(1))* ...
            rand+this.startDelayBounds(1);
        gapStimulus = GapStimulus(this.id, startDel, 'duration', gapDur);
        this.id = this.id+1;
    end

    function bool = hasNext(~)
        bool = true;
    end

    function set.gapDuration(this, value)
        checkPositiveNumber(value)
        if value(1) < this.gapDurationBounds(1) || ...
                value(1) > this.gapDurationBounds(2) %#ok<*MCSUP>
            error('The mean gap duration must lie between the duration bounds.');
        else
            this.gapDuration = value;
        end
    end

    function set.gapDurationBounds(this, value)
        checkPositiveNumber(value);
        checkInterval(value);
        if value(1) > this.gapDuration(1) || ...
                value(2) < this.gapDuration(1)
            error('The bounds must comprise the mean gap duration.');
        else
            this.gapDurationBounds = value;
        end
    end

    function set.startDelayBounds(this, value)
        checkPositiveNumber(value);
        checkInterval(value);
        this.startDelayBounds = value;
    end

end

end

