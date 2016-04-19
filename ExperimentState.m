classdef ExperimentState < handle
% Base class for all experiment states.

% Author: Lasse Osterhagen
    
    properties (Access = protected)
        % experimentController functions as context
        experimentController
    end
    
    methods
       
        function this = ExperimentState(experimentController)
            this.experimentController = experimentController;
        end
        
    end
    
    methods (Abstract)
        % Called when the experiment switches to this state
        init(this)
        % Subject decends the platform
        descend(this)
        % Subject ascends the platform
        ascend(this)
    end
    
end
