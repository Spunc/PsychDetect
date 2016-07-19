classdef RunningState < LogbookState
    
% Author: Lasse Osterhagen
    
properties (SetAccess = private)
    % Array of all start times
    startTimes
end

methods

    function this = RunningState(evaluator)
        this@LogbookState(evaluator)
    end

    function evaluate(this, event)
        this.startTimes(end+1) = event{2};
        nextEvent = this.evaluator.getNextEvent();
        if ~any(strcmp(nextEvent, ...
                {'Ascend', 'Stopped'}))
            throwIncorrectEventError('RunningState:evaluate', ...
                ['Running->', nextEvent]);
        end
    end

end
    
end

