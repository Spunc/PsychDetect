classdef NewTrialState < LogbookState
    
% Author: Lasse Osterhagen
    
properties (SetAccess = private)
    trials = cell.empty;
    shamTrials = cell.empty;
    ignoredTrials = cell.empty;
    ignoredShamTrials = cell.empty;
end

methods

    function this = NewTrialState(evaluator)
        this@LogbookState(evaluator)
    end

    function evaluate(this, event)
        
        % Check if a field of class Target exists
        targetIdx = find(strcmp(event(:,1), 'Target'), 1);
        if ~isempty(targetIdx)
            target = event{targetIdx,2};
            switch target
                case Target.No
                    nEvent = [event; {'FalseAlarm', 0}];
                    this.shamTrials{end+1} = nEvent;
                case Target.Yes_Reward
                    nEvent = [event; {'Hit', 0}];
                    this.trials{end+1} = nEvent;
                otherwise
                    throw(MException('NewTrialState:evaluate', ...
                        ['No rule for Target: ' char(target)]));
            end
        else
            % Handle non-Stimulus AudioObjects here
        end
        
        % Go to next event
        nextEvent = this.evaluator.getNextEvent();
        if ~any(strcmp(nextEvent, ...
                {'NewTrial', 'Descend', 'Stopped'}))
            throwIncorrectEventError('RunningState:evaluate', nextEvent);
        end
    end
    
    function reClassifyTrial(this)
        % Call this function if a descend after a trial was a hit
        this.trials{end}{end} = 1;
    end
    
    function reClassifiyShamTrial(this)
        % Call this function if a descend after a sham trial was a false
        % alarm
        this.shamTrials{end}{end} = 1;
    end
    
    function shiftTrial2Ignored(this)
        % Call this function if a descend after a trial had a negative
        % reaction time
        this.ignoredTrials(end+1) = this.trials(end);
        this.trials(end) = [];
    end
    
    function shiftShamTrial2Ignored(this)
        % Call this function if a descend after a sham trial had a negative
        % reaction time
        this.ignoredShamTrials(end+1) = this.shamTrials(end);
        this.shamTrials(end) = [];
    end
        
end
    
end
