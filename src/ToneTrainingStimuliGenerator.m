classdef ToneTrainingStimuliGenerator < AudioObjectGenerator
%TONETRAININGSTIMULIGENERATOR creates ToneStimuli for training.
%   This AudioObjectGenerator creates ToneStimuli from a fixed set of
%   frequencies and a fixed set of durations. A generated ToneStimulus
%   will be a pairing of a randomly choosen frequency and a randomly
%   choosen duration.
%   The level of the tones follow a normal distribution for which mean and
%   std can be specified.
%   The start delay is uniformly distributed between startDelayBounds.

% Author: Lasse Osterhagen

properties
    % Array of possible durations
    durations
    % Array of possible frequencies
    frequencies
    % Level of tone [mean, std]
    level
    % Level bounds [min, max] init values used for initialization
    levelBounds = [0, 100];
    % Start delay bounds
    startDelayBounds
end

properties (SetAccess = protected)
    % Running id
    id = 1
end

methods

    function this = ToneTrainingStimuliGenerator(config)
        % ToneIntervalDelayGenerator(config)
        % Arguments:
        % config - configuration struct with all parameters as fieldnames
        %   (including: durations, frequencies, level, levelBounds,
        %   startDelayBounds)
        this.durations = config.durations;
        this.frequencies = config.frequencies;
        this.level = config.level;
        this.levelBounds = config.levelBounds;
        this.startDelayBounds = config.startDelayBounds;
        rng('shuffle'); % Seed the random number generator
    end

    function toneStimulus = next(this)
        dur = this.durations(randi(length(this.durations)));
        freq = this.frequencies(randi(length(this.frequencies)));
        lvl = max(min(this.level(1)+ ...
            randn*this.level(2), this.levelBounds(2)), ...
            this.levelBounds(1));
        startDel = (this.startDelayBounds(2)-this.startDelayBounds(1))* ...
            rand+this.startDelayBounds(1);
        toneStimulus = ToneStimulus(this.id, startDel, 'duration', dur, ...
            'frequency', freq, 'level', lvl);
        this.id = this.id+1;
    end

    function bool = hasNext(~)
        bool = true;
    end

    function set.level(this, value)
        checkPositiveNumber(value)
        if value(1) < this.levelBounds(1) || ...
                value(1) > this.levelBounds(2) %#ok<*MCSUP>
            error(['The mean level must lie between ', ...
                'the level bounds.']);
        else
            this.level = value;
        end
    end

    function set.levelBounds(this, value)
        checkPositiveNumber(value);
        checkInterval(value);
        if value(1) > this.level(1) || ...
                value(2) < this.level(1)
            error('The bounds must comprise the mean level.');
        else
            this.levelBounds = value;
        end
    end

    function set.startDelayBounds(this, value)
        checkPositiveNumber(value);
        checkInterval(value);
        this.startDelayBounds = value;
    end

    function set.durations(this, value)
        checkPositiveNumber(value);
        this.durations = value;
    end

    function set.frequencies(this, value)
        checkPositiveNumber(value);
        this.frequencies = value;
    end 

end

end
