classdef PunishState < ExperimentState
%PUNISHSTATE : not used at the moment.
    
    % Author: Lasse Osterhagen
    
    properties
        
        % Time out as punishment when the subject descends on no-target
        % trials
        punishTimeOut = 12;
        
    end
    
    properties (Access = protected)
        
        % time-out timer
        timeOutTimer
        
    end
    
    methods
        
        function this = PunishState(experimentCbBehavior)
            this = this@ExperimentState(experimentCbBehavior);
            this.timeOutTimer = timer('ExecutionMode', 'singleShot', ...
                'TimerFcn', @this.timerCb);
        end
        
        function delete(this)
            stop(this.timeOutTimer);
            delete(this.timeOutTimer);
        end
        
        function init(this)
            this.cbBehavior.signalEvent('PlatformLight', LEDEventData(0));            
            this.timeOutTimer.StartDelay = this.punishTimeOut;
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
            this.cbBehavior.setState('readyDebounce');
        end
        
    end
    
    
end
