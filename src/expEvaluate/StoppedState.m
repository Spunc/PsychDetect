classdef StoppedState < LogbookState
%STOPPEDSTATED happens when an experiment has been stopped.

% Author: Lasse Osterhagen
    
properties (SetAccess = private)
    stopTimes
end

methods

    function this = StoppedState(evaluator)
        this@LogbookState(evaluator)
    end

    function evaluate(this, event)
        this.stopTimes(end+1) = event{2};
        nextEvent = this.evaluator.getNextEvent();
        if ~(isempty(nextEvent)) && ~(any(strcmp(nextEvent, ...
                {'Running'})))
            throwIncorrectEventError('StoppedState:evaluate', ...
                ['Stopped->', nextEvent]);
        end
    end

end
    
end

