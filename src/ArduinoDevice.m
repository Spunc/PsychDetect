classdef ArduinoDevice < InputOutputDevice
%ARDUINODEVICE establishes a serial connection to an Arduino (Uno).
%   Data transmission is realized by 2-byte arrays with the first byte
%   specifying the pin involved and the second byte specifying the
%   associated value.
%   If the class receives data from the Arduino, a DataReceived event will
%   be generated. The event.EventData will then contain a field 'pin' and a
%   field 'value' to signal at which pin a state change occured and the new
%   value of the pin.
%   To change pin states, use send(pin, value), to let the Arduino change
%   the pin value.

% Author: Lasse Osterhagen

properties (Access = protected, Hidden)
    % Handle to serial device
    ser   
end

methods

    function this = ArduinoDevice(portNo_config)
        % ArduinoDevice(portNo)
        % Arguments:
        % portNo - COM-port number as string (e. g. 'COM3')
        %
        % ArduinoDevice()
        % Windows only: find a COM-port that is used by tha Arduino
        %
        % ArduinoDevice(config)
        % Arguments:
        % config - a configuration struct with portNo as field
        
        if nargin < 1 || ...
                (isstruct(portNo_config) && ...
                (~isfield(portNo_config, 'portNo') || isempty(portNo_config.portNo)))
            % No COM-port specified; use findArduinoDevice() to find the
            % COM-ports of available Arduino devices and use the first one
            % found.
            arduinoPorts = findArduinoPorts();
                if isempty(arduinoPorts)
                    error('Could not find an Arduino COM-port.');
                end
            port = arduinoPorts(1);
        else
            if isstruct(portNo_config)  % configuration struct argument
                port = portNo_config.portNo;
            else
                port = portNo_config; % portNo as string argument
            end
        end
        % Open the serial device (Arduino settings)
        this.ser = serial(port, 'BaudRate', 9600, 'DataBits', 8, ...
            'StopBits', 1);
        % Attach the callback function.
        this.ser.BytesAvailableFcnMode = 'byte';
        this.ser.BytesAvailableFcnCount = 2;
        this.ser.BytesAvailableFcn = @this.serialCallback;
        % Open the connection.
        fopen(this.ser);
    end

    function delete(this)
        % Delete the SerialDevice object; free ressources.
        fclose(this.ser);
        delete(this.ser);
        disp('Arduino disconnected.');
    end

    function send(this, pin, value)
        % send(pin, value) sends value to the specified pin.
        fwrite(this.ser, [pin value], 'uint8');
    end

end

methods (Access = protected)

    function serialCallback(this, obj, ~)
        % This callback function is called, when the serial device
        % provides new bytes.
        data = fread(obj, 2, 'uint8');
        this.signalEvent(data(1), data(2));
    end

end
    
end

