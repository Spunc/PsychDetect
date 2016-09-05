classdef (Abstract) LogbookState < handle
%LOGBOOKSTATE is the base class of all experimental states.
%   An experiment traverses different states. Those states are reflected in
%   the Logbook, which keeps track of them.

% Author: Lasse Osterhagen
    
properties (Access = protected)
    % Reference to LogbookEvaluator
    evaluator
end

methods

    function this = LogbookState(evaluator)
        this.evaluator = evaluator;
    end

end

methods (Abstract)
    
    evaluate(this, event)

end
    
end
