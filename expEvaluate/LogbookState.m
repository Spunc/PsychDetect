classdef (Abstract) LogbookState < handle
%LOGBOOKSTATE is the base class of all experimental states.

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
