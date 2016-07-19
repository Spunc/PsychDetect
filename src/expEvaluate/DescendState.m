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
        specifier = event{4,2};

        % Simple ignored
        if strcmp(kind, 'Ignore')
            this.ignores = this.ignores+1;
            return
        end

        % Response to a trial
        stopTime = event{3,2};

        switch kind
            case 'ShamTrial'
                switch specifier
                    case 'Ignore'
                        this.evaluator.newTrialState.shiftShamTrial2Ignored();
                        this.ignores = this.ignores+1;
                    case 'FalseAlarm'
                        this.evaluator.newTrialState.reClassifiyShamTrial(stopTime);
                end
            case 'Trial'
                switch specifier
                    case 'Ignore'
                        this.evaluator.newTrialState.shiftTrial2Ignored();
                        this.ignores = this.ignores+1;
                    case 'Correct'
                        this.evaluator.newTrialState.reClassifyTrial(stopTime);
                end
        end

        if ~any(strcmp(this.evaluator.getNextEvent(), ...
                {'Ascend', 'Stopped'}))
            throwIncorrectEventError('DescemdState:evaluate', ...
                ['Descend->', nextEvent]);
        end
    end

end
    
end