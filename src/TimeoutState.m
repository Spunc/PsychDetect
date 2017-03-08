classdef TimeoutState < ExperimentState
%TIMEOUTSTATE - ExperimentState that interrupts the experiment for a
%certain amount of time.
% This ExperimentState is used to avoid that rewards are given after a
% negative reaction time and to avoid that multiple rewards are given after
% a correct response.

% Author: Lasse Osterhagen


properties (Access = protected)
    % time-out timer
    timeoutTimer = timer.empty;
end

methods

    function this = TimeoutState(experimentController, timeoutSpan)
        this = this@ExperimentState(experimentController);
        this.timeoutTimer = timer('ExecutionMode', 'singleShot', ...
            'TimerFcn', @this.timerCb);
        this.setTimeoutSpan(timeoutSpan);
    end

    function delete(this)
        stop(this.timeoutTimer);
        delete(this.timeoutTimer);
    end
    
    function setTimeoutSpan(this, value)
        % Set the span of the timeout timer in s
        this.timeoutTimer.StartDelay = value;
    end
        
    function init(this)
        start(this.timeoutTimer);
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

