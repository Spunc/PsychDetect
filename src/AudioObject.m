classdef (Abstract) AudioObject < matlab.mixin.Heterogeneous
%AUDIOOBJECT can be played by an AudioPlayer.
%   This class is the base class for all classes that can be read
%   by an AudioPlayer for sending data to the sound interface.
%   It implements the matlab.mixin.Heterogeneous interface to allow the
%   creation of arrays of mixed subtypes of AudioObject. Hence it is
%   possible to create an experimentArray with for example ToneStimulus
%   intermixed with LaserCtrl objects.

% Author: Lasse Osterhagen

properties
    % ID of AudioObject (can be evaluated by BinCodeGenerator)
    id
    % Start (onset) delay in s [default=0]
    startDelay = 0;
    % Duration of the AudioObject in s
    duration
end

methods
    
    function expEventData = getEvent(this)
        % Return the ExperimentEventData object that characterizes the
        % event that will be triggered by sendig this AudioObject to the
        % AudioPlayer.
        % The default behavior is that the first two row of
        % ExperimentEventData display {'Type', class(this); 'ID', this.id}
        % Typically, you do not want to override this function to provide
        % event information for inherited classes, but you want to override
        % getEvenData().
        evtData = [{'Type', class(this); 'ID', this.id}; getEventData(this)];
        expEventData = ExperimentEventData(evtData);
    end
    
end

methods (Abstract, Access = protected)

    eventData = getEventData(this);
    % Get event data that characterizes the stimulus.
    % eventData is a m-by-2 cell matrix containing m attributes
    % (string) - value (any data type) pairs.
    %
    % Override this function in subclasses to display additional
    % attributes.
        
end

methods (Static, Sealed, Access = protected)
    % The following method must be implemented in order to fullfill the
    % requirements of the matlab.mixin.Heterogeneous interface.
   function default_object = getDefaultScalarElement
       default_object = NullStimulus();
   end
end
    
end

