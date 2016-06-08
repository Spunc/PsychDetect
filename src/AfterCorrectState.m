classdef AfterCorrectState < ExperimentState
% ExperimentalState that happens after a reward has been given.

% Author: Lasse Osterhagen

    properties (Constant)
        % How long should the experiment be interrupted after a reward has
        % been released
        afterRewardTimeOut = 4;  
    end
    
    properties (Access = protected)
        % time-out timer
        timeOutTimer = timer.empty;
    end
    
    methods
        
        function this = AfterCorrectState(experimentController)
            this = this@ExperimentState(experimentController);
            this.timeOutTimer = timer('ExecutionMode', 'singleShot', ...
                'TimerFcn', @this.timerCb);
        end
        
        function delete(this)
            stop(this.timeOutTimer);
            delete(this.timeOutTimer);
        end
        
        function init(this)
            this.timeOutTimer.StartDelay = this.afterRewardTimeOut;
            start(this.timeOutTimer);
        end
        
        function ascend(~)
            % The subject ascends the platform. Do nothing.
        end
        
        function descend(~)
            % The subject descends the platform. Do nothing.           
        end
        
    end
    
    methods (Access = private)
       
        function timerCb(this, ~, ~)
            if strcmp(this.experimentController.currentState, 'stopped')
                % State has been switched to stopped in the meantime
                return;
            end
            this.experimentController.setState('readyDebounce');
        end
        
    end
    
end

