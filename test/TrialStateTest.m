classdef TrialStateTest < matlab.unittest.TestCase
% Tests TrialState

% Author: Lasse Osterhagen

properties(Constant)
    firstTimerCall = 0.05;
    timerPeriod = 0.25 % 2nd timer call at 0.05+0.25 = 0.3 s
    maxReactionTime = 0.1;
end

properties
    % ExperimentController mock object
    experimentController
    % Struct of MemFunctors that memorize function calls
    mem
    % Timer object to test time-dependent behavior.
    % timerObj will execute its callback function at 0.1 and 0.3 s from
    % start.
    timerObj = timer.empty;
    % A logbook that saves the content of MemFunctor.arguments at
    % timerObj callback calls
    functionCallLog
end

properties (Access = private)
    lastAOTime = -100; % mutable last audio object time
end

methods(TestMethodSetup)

    function setup(this)
        this.mem.setState = MemFunctor(@nothing);
        this.mem.giveReward = MemFunctor(@nothing);
        this.mem.signalEvent = MemFunctor(@nothing);
        this.mem.play = MemFunctor(@this.playFunc);
        this.mem.stop = MemFunctor(@nothing);
        this.experimentController = struct( ...
            'setState', @(x)this.mem.setState.func(x), ...
            'giveReward', @() this.mem.giveReward.func, ...
            'signalEvent', @(x,y)this.mem.signalEvent.func(x,y), ...
            'playAudioObject', @(x)this.mem.play.func(x), ...
            'stop', @()this.mem.stop.func, ...
            'getLastAOTime', @this.getLastAOTime);
        % Init timer calls @ 0.1 and 0.3 s
        this.timerObj = timer( ...
            'ExecutionMode', 'fixedRate', ...
            'StartDelay', this.firstTimerCall, ...
            'TasksToExecute', 2, ...
            'Period', this.timerPeriod, ...
            'TimerFcn', @this.timerCb);
        this.functionCallLog.setState = cell.empty;
        this.functionCallLog.giveReward = cell.empty;
        this.functionCallLog.signalEvent = cell.empty;
        this.functionCallLog.play = cell.empty;
        this.functionCallLog.stop = cell.empty;
    end  
end

methods(TestMethodTeardown)
    function deleteTimer(this)
        delete(this.timerObj)
    end
end

methods (Test)

    function testEnd(this)
        % Check that an empty TrialGenerator will result into a call to
        % ExperimentController.stop() only after maxReactionTime has
        % passed.

        % Create a TrialGenerator with a single Stimulus
        trialGenerator = ArrayAOGenerator(NullStimulus());
        trialState = TrialState(this.experimentController, ...
            trialGenerator, this.maxReactionTime);
        trialState.init();
        start(this.timerObj);
        wait(this.timerObj); 

        % Two calls to timerCb have been made:
        this.verifyLength(this.functionCallLog.setState, 2);

        % At 1st call of timerCb, setState has not been called yet
        this.verifyEmpty(this.functionCallLog.stop{1});
        % At 2nd call, setState('end') must have been called
        this.verifyNotEmpty(this.functionCallLog.stop{2});

        % Delete ressources
        delete(trialGenerator);
        delete(trialState);
    end

    function testPlay(this)
        % Verify that play will be called only after
        % Stimulus.startDelay
        startDelay = 0.1; % a bit longer than the first timer callback (.05)
        trialGenerator = ArrayAOGenerator(GapStimulus(0, startDelay));
        trialState = TrialState(this.experimentController, ...
            trialGenerator, this.maxReactionTime);
        trialState.init();
        start(this.timerObj);
        wait(this.timerObj);

        % At 1st call of timerCb, play has not been called yet
        this.verifyEmpty(this.functionCallLog.play{1});
        % At 2nd call, play must have been called
        this.verifyNotEmpty(this.functionCallLog.play{2});

        % Delete ressources
        delete(trialGenerator);
        delete(trialState);
    end

    function testReward(this)
        % Verify that a descend within maxReactionTime after Stimulus
        % presentation results into a reward
        trialGenerator = ArrayAOGenerator(GapStimulus(0, 0, Target.Yes_Reward));
        trialState = TrialState(this.experimentController, ...
            trialGenerator, this.maxReactionTime);            
        trialState.init();
        start(this.timerObj);
        pause(this.maxReactionTime*.5);
        trialState.descend();
        wait(this.timerObj);

        % At 1st call of timerCb, giveReward has not been called yet
        this.verifyEmpty(this.functionCallLog.giveReward{1});
        % At 2nd call, giveReward must have been called
        this.verifyNotEmpty(this.functionCallLog.giveReward{2});

        % Delete ressources
        delete(trialGenerator);
        delete(trialState);
    end

    function testNoReward(this)
        % Verify that a descend after maxReactionTime after Stimulus
        % offset results in no reward
        trialGenerator = ArrayAOGenerator(GapStimulus(0, 0, Target.Yes_Reward));
        trialState = TrialState(this.experimentController, ...
            trialGenerator, this.maxReactionTime);            
        trialState.init();
        start(this.timerObj);
        pause(this.maxReactionTime+.05); % allow 50 ms delay
        trialState.descend();
        wait(this.timerObj);

        % At 2nd call of timerCb, giveReward must not have been called
        this.verifyEmpty(this.functionCallLog.giveReward{2});

        % Delete ressources
        delete(trialGenerator);
        delete(trialState);
    end

end

methods(Access = private)

    function timerCb(this, ~, ~)
        this.functionCallLog.setState{end+1} = this.mem.setState.arguments;
        this.functionCallLog.giveReward{end+1} = this.mem.giveReward.arguments;
        this.functionCallLog.signalEvent{end+1} = this.mem.signalEvent.arguments;
        this.functionCallLog.play{end+1} = this.mem.play.arguments;
        this.functionCallLog.stop{end+1} = this.mem.stop.arguments;
    end

    function playFunc(this, ~)
        this.lastAOTime = GetSecs();
    end
    
    function time = getLastAOTime(this)
        time = this.lastAOTime;
    end
    
end
    
end
