classdef (Abstract) DetectionGUI < handle
%DETECTIONGUI is the base class for stimulus detection GUIs.

% Author: Lasse Osterhagen

properties
    % Current subject id
    subjectID
    % Path and file name prefix, where the LogBook will be saved
    filePathPrefix
end

properties (Access = protected)
    % ExperimentController
    ec
    % GUI components
    window
    % Training session saved?
    saved = 1;
end

properties (Access = private)
    % Logbook
    logBook  
end

methods

    function this = DetectionGUI(ec, subjectID, filePathPrefix, logBook)
        this.ec = ec;
        this.subjectID = subjectID;
        this.filePathPrefix = filePathPrefix;
        this.logBook = logBook;
        this.initGUI();
        set(this.window, 'Visible','on');
        movegui(this.window, [200, -200]);
    end

end

methods (Abstract, Access = protected)
    
    % Override this function to initialize GUI window and its components
    initGUI(~);
    
end

methods (Access = protected)
    
    function cbCloseGUI(this, ~, ~)
        % This function is called after pushing the 'x' button
        if ~this.saved
            choice = questdlg('Exit without save?', 'Exit', ...
                'Save and exit', ...
                'Exit without save', ...
                'Cancel', ...
                'Save and exit');
            switch choice
                case 'Save and exit'
                    this.saveData();
                    this.finish();
                case 'Exit without save'
                    this.finish();
                case 'Cancel'
                    return
            end
        else
            this.finish();
        end
    end
    
    function saveData(this)
        % Save cell array of the LogBook
        el = this.logBook.eventLog; %#ok<NASGU>
        save([this.filePathPrefix, datestr(now, 30)], 'el');
        disp('Data saved.');
        this.saved = 1;            
    end
    
end
    
methods (Access = private)

    function finish(this)
        % Delete all handle objects and close window
        delete(this.logBook);
        delete(this.ec);
        delete(this.window);
    end
    
end
    
end

