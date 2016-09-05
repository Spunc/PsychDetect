classdef LogbookEvaluator < handle
%LOGBOOKEVALUATOR extracts data from a LogBook of a behavioral experiment.
%   Arguments:
%   logbook - event log of a LogBook instance.
%
%   Evaluation of data from a behavioral experiment starts in this class.
%   It extracts trials and sham trials from a LogBook.
%
% Author: Lasse Osterhagen

properties (SetAccess = private)
    runningState
    ascendState
    descendState
    stoppedState
    newTrialState
    controlState
end

properties (Access = private)
    logbook
    index
    currentState
end

methods

    function this = LogbookEvaluator(logbook)
        this.logbook = logbook;
        this.init();
        this.evaluate();
    end
    
    function trials = getTrials(this)
        cellTrials = this.newTrialState.trials;
        trials = cellfun(@(x) cell2struct(x(:,2), x(:,1), 1), cellTrials);
    end
    
    function shamTrials = getShamTrials(this)
        cellShamTrials = this.newTrialState.shamTrials;
        shamTrials = cellfun(@(x) cell2struct(x(:,2), x(:,1), 1), ...
            cellShamTrials);
    end
    
    function ignoredTrials = getIgnoredTrials(this)
        cellIgnoredTrials = this.newTrialState.ignoredTrials;
        ignoredTrials = cellfun(@(x) cell2struct(x(:,2), x(:,1), 1), ...
            cellIgnoredTrials);
    end
    
    function ignoredShamTrials = getIgnoredShamTrials(this)
        cellIgnoredShamTrials = this.newTrialState.ignoredShamTrials;
        ignoredShamTrials = cellfun(@(x) cell2struct(x(:,2), x(:,1), 1), ...
            cellIgnoredShamTrials);
    end
    
    function audioObjects = getAudioObjects(this)
        cellAudioObjects = this.newTrialState.audioObjects;
        % Maybe leave the audio objects in cells if their content
        % diverges.
        audioObjects = cellfun(@(x) cell2struct(x(:,2), x(:,1), 1), ...
            cellAudioObjects);
    end

    function strState = getNextEvent(this)
        % Returns the name of the next logbook event, or empty if at
        % the end of logbook.
        elementNum = this.index+1;
        if elementNum <= length(this.logbook)
            strState = this.logbook{elementNum}{1};
        else
            strState = [];
        end
    end

end

methods (Access = private)

    function evaluate(this)
        this.index = 1;
        if ~strcmp('Running', this.logbook{this.index}{1})
            % The first entry must be 'Running'
            throwIncorrectEventError('LogbookEvaluator:evaluate', ...
                [this.logbook{this.index}{1}, ' @index=', ...
                num2str(this.index)]);
        end

        while this.index <= length(this.logbook)
            this.setCurrentState(this.logbook{this.index}{1});
            try
                this.currentState.evaluate(this.logbook{this.index});
            catch exception
                match = strfind(exception.identifier, ...
                    'ExperimentState:IncorrectEvent');
                if ~isempty(match)
                    newMessage = [exception.message, ' @index=', ...
                        num2str(this.index)];
                    throw(MException(exception.identifier, newMessage));
                else
                    rethrow(exception);
                end

            end
            this.index = this.index+1;
        end 
    end
    
    function init(this)
        this.runningState = RunningState(this);
        this.ascendState = AscendState(this);
        this.descendState = DescendState(this);
        this.stoppedState = StoppedState(this);
        this.newTrialState = NewTrialState(this);
        this.controlState = ControlState(this);
    end

    function setCurrentState(this, newState)
        switch newState
            case 'Running'
                this.currentState = this.runningState;
            case 'Ascend'
                this.currentState = this.ascendState;
            case 'Descend'
                this.currentState = this.descendState;
            case 'NewTrial'
                this.currentState = this.newTrialState;
            case 'Stopped'
                this.currentState = this.stoppedState;
            case 'Control'
                this.currentState = this.controlState;
            otherwise
                error(['Unknown event in logbook: ', ...
                    newState]);
        end
    end
    
end
    
end
