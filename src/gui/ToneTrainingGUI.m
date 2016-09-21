classdef ToneTrainingGUI < DetectionGUI
%TONETRAININGGUI is a GUI for tone in noise detection training.
%   Allows to change properties of a ToneTrainingStimuliGenerator to change
%   tone properties. Furthermore, allows to change the maximum reaction time
%   after stimulus offset, that will lead to a reward.

% Author: Lasse Osterhagen

properties (Access = private)
    % Additional control objects
    audioPlayer

    % UI components
    txtCurrentTrial
    txtNumRewards

    % Number of received rewards
    numRewards = 0;
    
end

methods

    function this = ToneTrainingGUI(ec, audioPlayer, subjectID, filePathPrefix, logBook)
        this@DetectionGUI(ec, subjectID, filePathPrefix, logBook);
        this.audioPlayer = audioPlayer;
    end

end

methods (Access = protected)

    function initGUI(this)
        % Init GUI window and components
        this.window = figure('Visible', 'off', 'Position', [0,0,350,440], ...
            'MenuBar', 'none', 'name', 'Tone detection trainer', ...
            'CloseRequestFcn', @this.cbCloseGUI);

        % Top layout container that contains the edit and the button
        % panels.
        hctop = uigridcontainer('v0', 'Units','norm', ...   %'v0' suppresses undocumented feature warning
            'Position',[.05,.05,.85,.85]);
        set(hctop, 'GridSize', [4,1]);
        set(hctop, 'VerticalWeight',[0.1 0.5, 0.3, 0.1])

        % Save button panel
        hcTopButtons = uiflowcontainer('v0', 'Units','norm', ...
            'Position',[.1,.1,.8,.8], 'Parent', hctop);
        uicontrol('Style', 'Pushbutton', 'String', 'Save params', ...
            'Parent', hcTopButtons, 'Callback', @this.cbButtons);
        uicontrol('Style', 'Pushbutton', 'String', 'Save training data', ...
            'Parent', hcTopButtons, 'Callback', @this.cbButtons);

        % Edit and display panel (two columns)
        hc1 = uigridcontainer('v0', 'Units','norm', ...
            'Position',[.05,.05,.85,.85], 'Parent', hctop);
        set(hc1, 'GridSize',[6,2]);
        uicontrol('Style', 'Text', 'String', 'Subject ID', ...
            'Parent', hc1);
        uicontrol('Style', 'Text', 'String', this.subjectID, ...
            'Parent', hc1);
        uicontrol('Style', 'Text', 'String', 'Current trial no.', ...
            'Parent', hc1);
        this.txtCurrentTrial = uicontrol('Style', 'Text', 'String', ...
            '0', 'Parent', hc1);
        uicontrol('Style', 'Text', 'String', 'Number of rewards', ...
            'Parent', hc1);
        this.txtNumRewards = uicontrol('Style', 'Text', 'String', ...
            this.numRewards, 'Parent', hc1);
        uicontrol('Style', 'Text', 'String', 'Maximum reaction time', ...
            'Parent', hc1);
        uicontrol('Style', 'Edit', 'String', ...
            this.ec.maxReactionTime, ...
            'Tag', 'ec.maxReactionTime', ...
            'Callback', @this.cbEdit, ...
            'Parent', hc1);
        
        uicontrol('Style', 'Text', 'String', 'Tone duration', ...
            'Parent', hc1);
        uicontrol('Style', 'Edit', 'String', ...
            num2str(this.ec.audioObjectGenerator.durations), ...
            'Tag', 'ec.audioObjectGenerator.durations', ...
            'Callback', @this.cbEditArray, ...
            'Parent', hc1);
        uicontrol('Style', 'Text', 'String', 'Tone frequencies', ...
            'Parent', hc1);
        uicontrol('Style', 'Edit', 'String', ...
            num2str(this.ec.audioObjectGenerator.frequencies), ...
            'Tag', 'ec.audioObjectGenerator.frequencies', ...
            'Callback', @this.cbEditArray, ...
            'Parent', hc1);
        
        % Edit panel (three columns)
        hc2 = uigridcontainer('v0', 'Units','norm', ...
            'Position',[.05,.05,.85,.85], 'Parent', hctop);
        set(hc2, 'GridSize',[3,3]);
        uicontrol('Style', 'Text', 'String', 'Level', ...
            'Parent', hc2);
        uicontrol('Style', 'Edit', 'String', ...
            this.ec.audioObjectGenerator.level(1), ...
            'TooltipString', 'Mean level', ...
            'Tag', 'ec.audioObjectGenerator.level(1)', ...
            'Callback',@this.cbEdit, ...
            'Parent', hc2);
        uicontrol('Style', 'Edit', 'String', ...
            this.ec.audioObjectGenerator.level(2), ...
            'TooltipString', 'Std level', ...
            'Tag', 'ec.audioObjectGenerator.level(2)', ...
            'Callback',@this.cbEdit, ...
            'Parent', hc2);
        uicontrol('Style', 'Text', 'String', 'Level bounds', ...
            'Parent', hc2);
        uicontrol('Style', 'Edit', 'String', ...
            this.ec.audioObjectGenerator.levelBounds(1), ...
            'TooltipString', 'Minimum level', ...
            'Tag', 'ec.audioObjectGenerator.levelBounds(1)', ...
            'Callback',@this.cbEdit, ...
            'Parent', hc2);
        uicontrol('Style', 'Edit', 'String', ...
            this.ec.audioObjectGenerator.levelBounds(2), ...
            'TooltipString', 'Maximum level', ...
            'Tag', 'ec.audioObjectGenerator.levelBounds(2)', ...
            'Callback',@this.cbEdit, ...
            'Parent', hc2);
        uicontrol('Style', 'Text', 'String', 'Start delay bounds', ...
            'Parent', hc2);
        uicontrol('Style', 'Edit', 'String', ...
            this.ec.audioObjectGenerator.startDelayBounds(1), ...
            'TooltipString', 'Minimun duration', ...
            'Tag', 'ec.audioObjectGenerator.startDelayBounds(1)', ...
            'Callback',@this.cbEdit, ...
            'Parent', hc2);
        uicontrol('Style', 'Edit', 'String', ...
            this.ec.audioObjectGenerator.startDelayBounds(2), ...
            'TooltipString', 'Maximum duration', ...
            'Tag', 'ec.audioObjectGenerator.startDelayBounds(2)', ...
            'Callback',@this.cbEdit, ...
            'Parent', hc2);

        % Start/Stop/Skip/Reward button panel
        hcBottomButtons = uiflowcontainer('v0', 'Units','norm', ...
            'Position',[.1,.1,.8,.8], 'Parent', hctop);
        uicontrol('Style', 'Pushbutton', 'String', 'Start', ...
            'Parent', hcBottomButtons, 'Callback', @this.cbButtons);
        uicontrol('Style', 'Pushbutton', 'String', 'Stop', ...
            'Parent', hcBottomButtons, 'Callback', @this.cbButtons);
        uicontrol('Style', 'Pushbutton', 'String', 'Skip trial', ...
            'Parent', hcBottomButtons, 'Callback', @this.cbButtons);
        uicontrol('Style', 'Pushbutton', 'String', 'Give reward', ...
            'Parent', hcBottomButtons, 'Callback', @this.cbButtons);

        % Listen to events and actualize display
        this.ec.addlistener('NewTrial', @this.actualizeComponents);
        this.ec.addlistener('Reward', @this.actualizeComponents);
    end
    
end

methods (Access = private)

    function cbEdit(this, hUIEdit, ~) %#ok<INUSL>
        % General callback function for most text fields.
        % Input validity should be checked at the level of the property
        % set-methods of the objects.
        tag = get(hUIEdit, 'Tag');
        oldVal = eval(['this.', tag]);
        stringVal = get(hUIEdit, 'string');
        try
            eval(['this.', tag, '=', stringVal, ';']);
        catch err
            errordlg(err.message);
            set(hUIEdit, 'string', oldVal);
        end
    end

    function cbEditArray(this, hUIEdit, ~)
        % Callback for text fields that contain arrays
        tag = get(hUIEdit, 'Tag');
        oldVal = eval(['this.', tag]);
        stringVal = get(hUIEdit, 'string');
        try
            % Update ToneTrainingStimuliGenerator
            eval(['this.', tag, '=[', stringVal, '];']);
            % Create the set of all duration/frequency combinations and
            % pass them to ToneStimulusSampleFactory
            durFreqSet = combvec(this.ec.audioObjectGenerator.durations, ...
                 this.ec.audioObjectGenerator.frequencies)';
            toneStimSamFac = this.audioPlayer.audioObjSamFacMap('ToneStimulus');
            toneStimSamFac.setDurFreqSet(durFreqSet);
            % Skip the buffered trial, because there might be no
            % wavetable in the newly specified
            % ToneStimulusSampleFactory
            this.ec.skipTrial();
        catch err
            errordlg(err.message);
            set(hUIEdit, 'string', num2str(oldVal));
        end
    end
    
    function param = getParameterStruct(this)
        % Create a param struct with all editable parameters
        param.maxReactionTime = this.ec.maxReactionTime;
        param.level = this.ec.audioObjectGenerator.level;
        param.levelBounds = this.ec.audioObjectGenerator.levelBounds;
        param.startDelayBounds = this.ec.audioObjectGenerator.startDelayBounds;
        param.durations = this.ec.audioObjectGenerator.durations;
        param.frequencies = this.ec.audioObjectGenerator.frequencies;
    end

    function cbButtons(this, hButton, ~)
        % General callback function for push buttons
        buttonName = get(hButton, 'string');
        switch buttonName
            case 'Save params'
                this.saveParameters();
            case 'Save training data'
                this.saveData();
            case 'Start'
                this.saved = 0;
                this.ec.start();
            case 'Stop'
                this.ec.stop();
            case 'Skip trial'
                this.ec.skipTrial();
            case 'Give reward'
                this.ec.giveReward();
                disp('Manual reward given.')
        end
    end

    function actualizeComponents(this, ~, evt)
        % General callback function to acutalize displays as a response
        % to targeting events.
        switch evt.EventName
            case 'NewTrial'
                set(this.txtCurrentTrial, 'string', evt.datacell{1,2});
            case 'Reward'
                this.numRewards = this.numRewards+1;
                set(this.txtNumRewards, 'string', this.numRewards);
        end
    end

    function saveParameters(this)       
        % Save editable parameters for tone training (maxReactionTime,
        % stimTrainerConfig)
        trainingConfig.maxReactionTime = this.ec.maxReactionTime;
        trainingConfig.stimTrainerConfig = ...
            publicProperties2Struct(this.ec.audioObjectGenerator);
        trainingConfig.stimTrainerConfig.method = class( ...
            this.ec.audioObjectGenerator);
        save([this.filePathPrefix, 'param.mat'], 'trainingConfig');
        disp('Parameters saved.');        
    end

end
    
end

