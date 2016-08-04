classdef ControlState < LogbookState
%CONTROLSTATE corresponds to an AudioObject played, that is not a Stimulus.
    
% Author: Lasse Osterhagen
    
properties (SetAccess = private)
    % Array of all control events
    controls = cell.empty;
end

methods

    function this = ControlState(evaluator)
        this@LogbookState(evaluator)
    end

    function evaluate(this, event)
        % Append control event to cell array of control events
        this.controls{end+1} = event;
        nextEvent = this.evaluator.getNextEvent();
        if ~any(strcmp(nextEvent, ...
                {'NewTrial', 'Descend', 'Stopped', 'Control'}))
            throwIncorrectEventError('RunningState:evaluate', ...
                ['NewTrial->', nextEvent]);
        end
    end

end
    
end
