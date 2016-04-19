classdef InputOutputDevice < handle
%INPUTOUTPUTDEVICE is a class for a generic i/o device.
%   It is an observable class that signals 'DataReceived' events if it got
%   input. 'DataReceived' events have an 'InputDeviceData' object with the
%   properties 'pin' and 'value'. In that manner, it maps directly to
%   devices like the Arduino, which can receive data at their pins.
%   To send a value to a specific pin, use the function send(pin, value).

% Author: Lasse Osterhagen

properties
end

events
    % The input device received data
    DataReceived
end

methods

    function signalEvent(this, pin, value)
        % signalEvent(pin, value) will trigger a 'DataReceived' event.
        this.notify('DataReceived', InputDeviceData(pin, value));
    end
    
    function send(~, ~, ~)
        % send(pin, value) - send data to a pin
        % Default implementation: do nothing.
        % Override this function to have different behavior.
    end

end
    
end
