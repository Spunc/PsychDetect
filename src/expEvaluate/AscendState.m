classdef AscendState < LogbookState
%ASCENDSTATE is the state that happens when a subject initialized a trial.
    
% Author: Lasse Osterhagen
    
methods

    function this = AscendState(evaluator)
        this@LogbookState(evaluator)
    end

    function evaluate(this, ~)
        nextEvent = this.evaluator.getNextEvent();
        if ~any(strcmp(nextEvent, ...
                {'NewTrial', 'Descend', 'Stopped'}))
            throwIncorrectEventError('AscendState:evaluate', ...
                ['Ascend->', nextEvent]);
        end
    end

end
    
end