classdef LogBook < handle
    % Class to register (listen to) a number of events and save them to a
    % cell array with a time stamp. Event can optionally have an
    % ExperimentEventData object as event.EventData.
    
    % Author: Lasse Osterhagen
    
    properties
        displaying = true;
    end
    
    properties (Access = private)
        % observables is a cell array (better performance for growing
        % arrays in comparison to standard arrays) that holds all handles
        % to objects that are listened to.
        observables = cell.empty;
    end
    
    properties (SetAccess = private)
        % eventLog is a cell array that logs all event data.
        eventLog = cell.empty;
    end
    
    methods
        
        function delete(this)
            for i = 1:length(this.observables)
                delete(this.observables{i});
            end
        end
        
        function addObservable(this, hObservable, eventName)
            % addObservable(hObservable, eventName): Use this function to
            % listen to an event that is generated by an object that
            % defines this event.
            this.observables{end+1} = ...
                addlistener(hObservable, eventName, @this.eventCb);
        end
        
    end
    
    methods (Access = private)
        
        function eventCb(this, ~, evt)
            if isprop(evt, 'datacell')
                evtdata = evt.datacell;
                evtdataSize = size(evtdata);
                data = cell(evtdataSize(1)+1, 2);
                data(2:end, 1:2) = evtdata;
            else
                data = cell(1, 2);
            end
            data{1,1} = evt.EventName;
            data{1,2} = GetSecs;
            if this.displaying
                display(data);
            end
            this.eventLog{end+1} = data;
        end
        
    end
    
end

