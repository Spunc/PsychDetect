classdef StoppedState < LogbookState

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
                {'Running', 'LaserEvent'})))
            throwIncorrectEventError('StoppedState:evaluate', nextEvent);
        end
    end

end
    
end

