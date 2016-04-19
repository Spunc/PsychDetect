classdef EventGenerator < handle
    
% Author: Lasse Osterhagen    
    
    events
        Event1
        Event2
    end
    
    methods
        function sendEvent(this, evtName, evtData)
            if isempty(evtData)
                this.notify(evtName);
            else
                this.notify(evtName, evtData);
            end
        end
    end
    
end

