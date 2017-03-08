classdef TrialState < ExperimentState
%TRIALSTATE ExperimentState when the subject is on the platform.
%   This is the only state during which trials will be played and advanced.

% Author: Lasse Osterhagen

properties
    % Reinsert an 'early jump' stimulus at the end of the
    % trialGenerator
    reinsert = false;
end

properties (Access = private)
    % Maximum time in s in which the subject needs to react upon a target
    maxReactionTime
    % A TrialGenerator that provides trials
    trialGenerator
    % Timer that handle sound stimuli. Two timers are needed to allow
    % scheduling the next stimulus within the other timer execution.
    stimulusTimerPing = timer.empty
    stimulusTimerPong = timer.empty
    % Timer that retains TrialState for maxReactionTimer and then changes
    % the state to end
    endTimer = timer.empty
    % Audio object that was played last.
    audioObject 
    % The scheduled Stimulus that will be played next
    nextAudioObject
    % Aborted stimulus that should be played next
    abortedStimulus = []
end

methods

    function this = TrialState(experimentController, ...
            trialGenerator, maxReactionTime)
        this = this@ExperimentState(experimentController);
        this.trialGenerator = trialGenerator;
        this.stimulusTimerPing = timer('ExecutionMode', 'singleShot', ...
            'TimerFcn', @this.stimTimerCb);
        this.stimulusTimerPong = timer('ExecutionMode', 'singleShot', ...
            'TimerFcn', @this.stimTimerCb);
        this.endTimer = timer('ExecutionMode', 'singleShot', ...
            'TimerFcn', @this.endTimerCb); % StartDelay will be set by
                % set.maxReactionTime()
        this.audioObject = NullStimulus();
        this.maxReactionTime = maxReactionTime;
    end

    function delete(this)
        stop(this.stimulusTimerPing);
        stop(this.stimulusTimerPong);
        stop(this.endTimer);
        delete(this.stimulusTimerPing);
        delete(this.stimulusTimerPong);
        delete(this.endTimer);
    end

    function setMaxReactionTime(this, value)
        this.maxReactionTime = value;
        this.endTimer.StartDelay = value+.1;
    end

    function init(this)
        % The subject should be on the platform already.
        if ~isempty(this.abortedStimulus)
            % This state only happens at the first call of init() or after
            % a call to skipStimulus().
            this.nextAudioObject = this.abortedStimulus;
        else
            if ~this.trialGenerator.hasNext()
                % End of experiment
                this.experimentController.stop();
                return
            else 
                this.nextAudioObject = this.trialGenerator.next();
            end
        end
        % Schedule the next stimulus
        this.stimulusTimerPing.StartDelay = round2Milli( ...
            this.nextAudioObject.startDelay);
        start(this.stimulusTimerPing);
    end

    function ascend(this)
        this.init()
    end

    function descend(this)
        % The subject descends the platform.
        descendTime = GetSecs();
        stop(this.stimulusTimerPing);
        stop(this.stimulusTimerPong);

        if ~isa(this.audioObject, 'Stimulus')
            % Last stimulus actually was not a Stimulus but some other
            % kind of AudioObject.
            this.abortedStimulus = this.nextAudioObject;
            return
        end
        
        % Reaction time
        descendDiffTime = ...
            descendTime - this.experimentController.getLastAOTime();
        
        % Classify responses
        if descendDiffTime > this.maxReactionTime
            % Jump too late: ignore
            responseClass = 'Ignore';
            responseSpecifier = 0;
            this.experimentController.setState('readyDebounce');
        elseif descendDiffTime < 0
            % Negative reaction time
            if this.reinsert
                % Append trials to end of TrialGenerator, if desired
                this.trialGenerator.append(this.audioObject);
            end
            if this.audioObject.target == Target.Yes_Reward
                % Trial
                responseClass = 'Trial';
            else
                % Sham trial
                responseClass = 'ShamTrial';
            end
            responseSpecifier = 'Ignore';
            this.experimentController.setState('timeout');
        else
            if this.audioObject.target == Target.Yes_Reward
                % Trial
                responseClass = 'Trial';
                responseSpecifier = 'Correct';
                this.experimentController.giveReward();
                this.experimentController.setState('timeout');
            else
                % Sham trial
                responseClass = 'ShamTrial';
                responseSpecifier = 'FalseAlarm';
                this.experimentController.setState('readyDebounce');
            end
        end
        
        this.experimentController.signalEvent('Descend', ExperimentEventData( ...
            {'TrialNo', this.audioObject.id; ...
            'StopTime', descendDiffTime; ...
            responseClass, responseSpecifier}));
        this.abortedStimulus = this.nextAudioObject;
    end

    function skipStimulus(this)
        % Skip the current stimulus, go on with the next one.
        % First, stop timers that might be on
        stop(this.stimulusTimerPing);
        stop(this.stimulusTimerPong);
        if ~isempty(this.abortedStimulus)
            % The typical case
            % Clear abortedStimuls so that a new stimulus will be
            % generated on the next call of init().
            stimId = this.abortedStimulus.id;
            this.abortedStimulus = [];
        else
            % The subject has never been on the platform yet
            % Just advance the trialGenerator
            if ~this.trialGenerator.hasNext()
                % If the TrialGenerator is empty, we cannot provide a
                % new trial. Therefore, we stop the experiment.
                this.experimentController.stop();
                return;
            end
            skipStim = this.trialGenerator.next();
            stimId = skipStim.id;
        end
        this.experimentController.signalEvent('ManuallySkipped', ...
            ExperimentEventData({'TrialNo', stimId}));
    end

end

methods (Access = private)

    function stimTimerCb(this, timerObj, ~)
        % Callback of stimulusTimer for playing stimuli at the
        % specified time

        % Play stimulus
        this.experimentController.playAudioObject(this.nextAudioObject);
        this.audioObject = this.nextAudioObject;
        this.experimentController.signalEvent( ...
            'NewTrial', this.audioObject.getEvent());

        % Get the next trial
        if ~this.trialGenerator.hasNext()
            % End of trialGenerator: end the experiment
            start(this.endTimer);
            return
        end
        this.nextAudioObject = this.trialGenerator.next();
        offsetTime = max(this.audioObject.duration, this.maxReactionTime);
        % offsetTime is minimal time between the beginning of two sound
        % stimuli
        nextCbTime = offsetTime + this.nextAudioObject.startDelay;
        % Start the timer that is not currently executing this callback
        if timerObj == this.stimulusTimerPing
            this.stimulusTimerPong.StartDelay = round2Milli(nextCbTime);
            start(this.stimulusTimerPong);
        else
            this.stimulusTimerPing.StartDelay = round2Milli(nextCbTime);
            start(this.stimulusTimerPing);
        end
    end

    function endTimerCb(this, ~, ~)
        % Will be called by endTimer
        this.experimentController.stop();
    end

end
    
end
