classdef ReadyDebounceState < ExperimentState
    % Ready to start trials, but debounce photo sensor first.
    
    % Author: Lasse Osterhagen
    
    properties (Constant)
        % How long does the photo sensor value has to be stable to go on to
        % the next state?
        debounceTime = 0.1;   
    end
    
    properties (Access = private)
        % Timer for debouncing
        debounceTimer = timer.empty
        
    end
    
    methods
        
        function this = ReadyDebounceState(experimentController)
            this = this@ExperimentState(experimentController);
            this.debounceTimer = timer('ExecutionMode', 'singleShot', ...
                'StartDelay', this.debounceTime, 'TimerFcn', @this.timerCb);
        end
        
        function delete(this)
            stop(this.debounceTimer);
            delete(this.debounceTimer);
        end
        
        function init(this)
            if this.experimentController.sensorPinValue == 1
                % The subject is already on the platform.
                this.ascend();
            end
        end
        
        function ascend(this)
            start(this.debounceTimer);
        end
        
        function descend(this)
            stop(this.debounceTimer);
        end
        
    end
    
    methods (Access = private)
       
        function timerCb(this, ~, ~)
            this.experimentController.signalEvent('Ascend', ...
                ExperimentEventData({'State', 'StartTrial'}));            
            this.experimentController.setState('trial');
        end
        
    end
    
end

