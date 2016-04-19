classdef (Abstract) Stimulus < AudioObject
%STIMULUS is the base class for stimuli.

% Author: Lasse Osterhagen

properties
    % Reward Target (Target.Yes_Reward, Target.Yes_NoReward, Target.No)
    target
end

methods

    function this = Stimulus(id, startDelay, duration, target)
        this.id = id;
        this.startDelay = startDelay;
        this.duration = duration;
        this.target = target;
    end

end

methods (Access = protected)

    function eventData = getEventData(this)
        % Provides stimulus specification as attribute - value pairs.
        % Default (in addition to AudioObject, which provides
        %   {'Type', class(this); 'ID', this.id}:
        % {
        % 'StartDelay', startDelay;
        % 'Duration', duration
        % 'Target', target
        % }
        eventData = {'StartDelay', this.startDelay;
                    'Duration', this.duration;
                    'Target', this.target};
    end

end

end

