classdef ExperimentController < handle
%EXPERIMENTCONTROLLER controls the execution of an exerimental session.
%   It controls the interplay between AudioPlayer, AudioObjectGenerator and
%   InputOutputDevice.

% Author: Lasse Osterhagen

properties (Access = private)
    % I/O device
    ioDevice
    % AudioPlayer as sound device
    audioPlayer
    % Event listener that reacts on events sent by the I/O device
    ioListener
    % Struct with all possible states
    states
end

properties (SetAccess = private)
    % AudioObjectGenerator for generating AudioObjects (trials)
    audioObjectGenerator
    % The current state of the experiment
    currentState    
    % Current state of the sensor pin
    sensorPinValue = 0;
end

properties
    % Pins of the I/O device (Arduino)
    pins
    % Maximum time in s in which the subject needs to react upon a target
    maxReactionTime
end

events
    % Experiment started
    Running
    % Experiment stopped
    Stopped
    % Subject ascended the platform
    Ascend
    % Subject descended the platform
    Descend
    % A new trial was played
    NewTrial
    % A reward has been released
    Reward
    % The current (bufferd) trial was skipped manually
    ManuallySkipped
end

methods

    function this = ExperimentController(config)
        % ExperimentController(config)
        % Arguments:
        % config - a configuration struct with all parameters as
        %   fieldnames (including: pins, ioDevice, audioPlayer,
        %   audioObjectGenerator)
        this.pins = config.pins;
        this.ioDevice = config.ioDevice;
        this.audioPlayer = config.audioPlayer;
        this.audioObjectGenerator = config.audioObjectGenerator;
        
        % Init states
        this.states.readyDebounce = ReadyDebounceState(this);
        this.states.trial = TrialState(this, ...
            this.audioObjectGenerator, config.maxReactionTime);
        % Set timeout span to maxReactionTime
        this.states.timeout = TimeoutState(this, config.maxReactionTime);
        this.currentState = 'stopped';
    end

    function delete(this)
        structfun(@delete, this.states);
        delete(this.audioObjectGenerator);
        delete(this.audioPlayer);
        delete(this.ioDevice);
    end
    
    function set.maxReactionTime(this, value)
        % Set the maximum reaction time that will be rewarded.
        if value < 0
            error('Impossible argument: maxReaction time lower than 0.')
        end
        this.maxReactionTime = value;
        this.states.timeout.setTimeoutSpan(value); %#ok<*MCSUP>
        this.states.trial.maxReactionTime = value;
    end
    
    function setReinsertTrials(this, value)
        % Set if early jump trials should be appended to the
        % AudioObjectGenerator (if supported).
        % Early jumps are trials at which a stimulus has been sent to the
        % sound device already, but the subject left the platform before
        % the stimulus reached the loudspeaker.
        this.states.trial.reinsert = value;
    end
    
    function start(this)
        % Start the experiment
        if ~strcmp(this.currentState, 'stopped')
            warning('Already running.');
            return
        end
        if ~this.audioObjectGenerator.hasNext()
            warning('AudioObjectGenerator is empty.');
            return
        end
        this.setState('readyDebounce');
        if isvalid(this.ioDevice)
            this.ioListener = addlistener(this.ioDevice, 'DataReceived', ...
                @this.dataReceivedCb);
        else
            warning(sprintf( ...
                ['InputOutputDevice was deleted.\n', ...
                 'Control of the experiment will not be possible!'])); %#ok<SPWRN>
        end
        this.audioPlayer.start();
        this.notify('Running');
    end

    function stop(this)
        if strcmp(this.currentState, 'stopped')
            warning('Already stopped.');
            return
        end
        % Stop the experiment
        delete(this.ioListener);
        this.audioPlayer.stop();
        this.currentState = 'stopped';
        this.notify('Stopped');
    end

    function giveReward(this)
        % Operate the feeder to release a reward.
        this.ioDevice.send(this.pins.feeder, 1);
        pause(.01);
        this.ioDevice.send(this.pins.feeder, 0);
        this.notify('Reward');
    end

    function skipTrial(this)
        % Skip the current (buffered) stimulus
        this.states.trial.skipStimulus();
    end

    function setState(this, newState)
        % Change the state of the setting.
        % (This is a kind of state pattern.)
        switch newState
            % Subject is not on platform or approaching the platform
            case 'readyDebounce'
                this.currentState = this.states.readyDebounce;
            % Subject is on the platform, trials will be played
            case 'trial'
                this.currentState = this.states.trial;
            % Subject received a reward
            case 'timeout'
                this.currentState = this.states.timeout;
            otherwise
                error(['No state ', newState, ' defined.']);
        end
        this.currentState.init();
    end

    function signalEvent(this, eventName, evtData)
        % signalEvent(eventName, [evtData])
        % ExperimentStates use this function to trigger Events.
        if nargin > 2
            this.notify(eventName, evtData)
        else
            this.notify(eventName);
        end
    end

    function playAudioObject(this, audioObject)
        % Let the audioPlayer play an AudioObject. That is,
        % send the AudioObject to the audioPlayer.
        this.audioPlayer.playAudioObject(audioObject);
    end
    
    function lastAOTime = getLastAOTime(this)
        % Get the time when the last AudioObject has been played.
        lastAOTime = this.audioPlayer.lastAOTime;
    end

end

methods (Access = private)
    
    function stopExperiment(this)
        % Stop the experiment
        this.audioPlayer.stop();
        this.notify('Stopped');
        delete(this.ioListener);
    end

    function dataReceivedCb(this, ~, eventData)
        % This function is called when the I/O device registered 
        % a change at a pin. Actually, that will be a change
        % at the photo sensor.
        pin = eventData.pin;
        val = eventData.value;
        switch(pin)
            case(this.pins.sensor)
                switch(val)
                    case(0) % Subject descends the platform
                        this.sensorPinValue = 0;
                        this.currentState.descend();
                    case(1) % Subject ascends the platform
                        % (Event will be notified by ReadyDebounceState)
                        this.sensorPinValue = 1;
                        this.currentState.ascend();
                end
        end
    end

end

end
