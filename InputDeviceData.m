classdef InputDeviceData < event.EventData
% Holds data of an InputDevice

% Author: Lasse Osterhagen

properties
    % Pin no
    pin
    % Value of pin
    value
end

methods
    
    function this = InputDeviceData(pin, value)
        this.pin = pin;
        this.value = value;
    end
    
end
    
end
