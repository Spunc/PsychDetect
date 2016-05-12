classdef DescendState < LogbookState
    
% Author: Lasse Osterhagen
    
properties (SetAccess = private)
    ignores = 0
end

methods

    function this = DescendState(evaluator)
        this@LogbookState(evaluator)
    end

    function evaluate(this, event)
        kind = event{4,1};

        % Simple ignored
        if strcmp(kind, 'Ignore')
            this.ignores = this.ignores+1;
            return
        end

        % Response to a trial
        stopTime = event{3,2};

        switch kind
            case 'FalseAlarm'
                if stopTime < 0
                    this.evaluator.newTrialState.shiftShamTrial2Ignored();
                    this.ignores = this.ignores+1;
                else
                    this.evaluator.newTrialState.reClassifiyShamTrial();
                end
            case 'Correct'
                if stopTime < 0
                    this.evaluator.newTrialState.shiftTrial2Ignored();
                    this.ignores = this.ignores+1;
                else
                    this.evaluator.newTrialState.reClassifyTrial();
                end
        end

        if ~any(strcmp(this.evaluator.getNextEvent(), ...
                {'Ascend', 'Stopped'}))
            throwIncorrectEventError('DescemdState:evaluate', nextEvent);
        end
    end

end
    
end