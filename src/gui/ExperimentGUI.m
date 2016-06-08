classdef ExperimentGUI < DetectionGUI
%EXPERIMENTGUI is a GUI to control a stimulus detection experiment.

% Author: Lasse Osterhagen

properties (Access = private)
    
    % GUI components
    txtCurrentTrial
    txtNumRewards
    
    % Number of received rewards
    numRewards = 0;
    
end

methods

    function this = ExperimentGUI(ec, subjectID, filePathPrefix, logBook)
        this@DetectionGUI(ec, subjectID, filePathPrefix, logBook);
    end

end

methods (Access = protected)

    function initGUI(this)
        % Init GUI window and components
        this.window = figure('Visible', 'off', 'Position', [0,0,380,200], ...
            'MenuBar', 'none', 'name', 'Detection experiment GUI', ...
            'CloseRequestFcn', @this.cbCloseGUI); 

        % Components
        hctop = uigridcontainer('v0', 'Units','norm', ...
            'Position',[.05,.05,.85,.85]);
        set(hctop, 'GridSize', [2,1]);
        set(hctop, 'VerticalWeight',[0.75 0.25])
        hcDisplay = uigridcontainer('v0', 'Units', 'norm', ...
            'Position', [.05,.05,.85,.85], 'Parent', hctop);
        set(hcDisplay, 'GridSize',[3,2]);
        % Display panels
        uicontrol('Style', 'Text', 'String', 'Subject ID', ...
            'Parent', hcDisplay);
        uicontrol('Style', 'Text', 'String', this.subjectID, ...
            'Parent', hcDisplay);
        uicontrol('Style', 'Text', 'String', 'Current trial no.', ...
            'Parent', hcDisplay);
        this.txtCurrentTrial = uicontrol('Style', 'Text', 'String', ...
            '0', 'Parent', hcDisplay);
        uicontrol('Style', 'Text', 'String', 'Number of rewards', ...
            'Parent', hcDisplay);
        this.txtNumRewards = uicontrol('Style', 'Text', 'String', ...
            this.numRewards, 'Parent', hcDisplay);
        % Button panel
        hcButtons = uiflowcontainer('v0', 'Units','norm', ...
            'Position',[.1,.1,.8,.8], 'Parent', hctop);
        uicontrol('Style', 'Pushbutton', 'String', 'Start', ...
            'Parent', hcButtons, 'Callback', @this.cbButtons);            
        uicontrol('Style', 'Pushbutton', 'String', 'Stop', ...
            'Parent', hcButtons, 'Callback', @this.cbButtons);
        uicontrol('Style', 'Pushbutton', 'String', 'Save', ...
            'Parent', hcButtons, 'Callback', @this.cbButtons);
        uicontrol('Style', 'Pushbutton', 'String', 'Give reward', ...
            'Parent', hcButtons, 'Callback', @this.cbButtons);            

        % Listen to events and actualize display
        this.ec.addlistener('NewTrial', ...
            @this.actualizeComponents);
        this.ec.addlistener('Reward', ...
            @this.actualizeComponents);
    end

    function actualizeComponents(this, ~, evt)
        % General callback function to acutalize displays as a response
        % to targeting events.
        switch evt.EventName
            case 'NewTrial'
                set(this.txtCurrentTrial, 'string', evt.datacell{2,2});
            case 'Reward'
                this.numRewards = this.numRewards+1;
                set(this.txtNumRewards, 'string', this.numRewards);
        end
    end

    function cbButtons(this, hButton, ~)
        % General callback function for push buttons
        buttonName = get(hButton, 'string');
        switch buttonName
            case 'Start'
                this.saved = 0;
                this.ec.start();
            case 'Stop'
                this.ec.stop();
            case 'Save'
                this.saveData();
            case 'Give reward'
                this.ec.giveReward();
                disp('Manual reward given.')
        end
    end

end

end
