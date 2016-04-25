classdef KeyGUI < InputOutputDevice
% KEYGUI is a class for the substitution of an Arduino device for i/o.

% Author: Lasse Osterhagen
    
properties
   pins 
end

properties (Constant)
    grey = [.8, .8, .8];
end

properties (SetAccess = private)
    keys2React
    states
end

properties (Access = private)
    window
    keysUI
    receivedUI
    receivedTimer
end
    
methods
    
    function this = KeyGUI(keys2React_config, pins)
        % KeyGUI(keys2React, pinValue)
        % Arguments:
        % keys2React - a cell array of keys on which the program should
        %   react.
        % pins - an array that maps every key of keys2React to a pin number.
        %
        % KeyGUI(conf)
        % Arguments:
        % config - a configuration struct with all parameters as
        % fieldnames.
        if nargin == 1
            keys2React = keys2React_config.keys2React;
            pins = keys2React_config.pins;
        else
            keys2React = keys2React_config;
        end
        numPins = length(pins);
        assert(numPins == length(keys2React), 'KeyGUI:ValueError', ...
            'Length of keys2React and pins must be the same.');
        this.window = figure('Position', [0,0,numPins*65+20,150], ...
            'MenuBar', 'none', 'name', 'Key press interface', ...
            'KeyPressFcn', @this.keyPressFcn, ...
            'KeyReleaseFc', @this.keyReleaseFcn, ...
            'CloseRequestFcn', @this.cbCloseGUI);
        movegui(this.window, [600, -200]);
        this.receivedUI = uicontrol('Style', 'text', 'String', 'Reward', ...
            'FontSize', 14, 'Position', [20, 120, 70, 20], ...
            'ForegroundColor', this.grey);
        for index=1:numPins  
            this.keysUI(index) = uicontrol('Style', 'text', ...
                'String', keys2React(index), ...
                'FontSize', 14, ...
                'Position', [10+(index-1)*65, 40, 60, 30]);
        end
        this.keys2React = keys2React;
        this.pins = pins;
        this.states = zeros(1, numPins);
        this.receivedTimer = timer('ExecutionMode', 'singleShot', ...
            'StartDelay', 1, 'TimerFcn', @this.timerCb);
    end
    
    function send(this, ~, val)
        % Displays 'Reward' after any pin is set to on
        if val % pin must be set to on
            set(this.receivedUI, 'ForegroundColor', 'green');
            if ~strcmp(this.receivedTimer.Running, 'on')
                % don't start a running timer
                start(this.receivedTimer);
            end
        end
    end
    
end

methods (Access = private)

    function keyPressFcn(this, ~, evt)
        index = find(strcmp(this.keys2React, evt.Key), 1);
        if ~isempty(index) && ~this.states(index)
            this.states(index) = true;
            this.signalEvent(this.pins(index), 1);
            set(this.keysUI(index), 'ForegroundColor', 'red');
            
        end
    end

    function keyReleaseFcn(this, ~, evt)
        index = find(strcmp(this.keys2React, evt.Key), 1);
        if ~isempty(index)
            this.states(index) = false;
            this.signalEvent(this.pins(index), 0);
            set(this.keysUI(index), 'ForegroundColor', 'black');
        end
    end
       
    function timerCb(this, ~, ~)
        set(this.receivedUI, 'ForegroundColor', this.grey);
    end
    
    function cbCloseGUI(this, ~, ~)
        stop(this.receivedTimer);
        delete(this.receivedTimer);
        delete(this.window);
        delete(this);
    end
    
end

end
