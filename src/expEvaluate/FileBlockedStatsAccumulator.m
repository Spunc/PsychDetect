classdef FileBlockedStatsAccumulator < handle
%FILESTATSACCUMULATOR accumulates session stats from saved experimental
%data.
%   Similar to FileStatsAccumulator, but for experiments with multiple
%   blocked trials.

% Author: Lasse Osterhagen

properties (SetAccess = private)
    % Higher false alarm rates will let the session to be excluded
    falseAlarmRejectionRate = 0.2;
    % Session will be excluded if value not reached within any category
    minimalDPrime = 1;
    % Files
    files
    % Number of files
    numberOfFiles
    % Rejected session and its cause
    rejections
    % False alarm rates of sessions
    falseAlarmRates
    % Conditions
    condition = struct();
end

methods

    function this = FileBlockedStatsAccumulator(headerStr, trialFilter, ...
            falseAlarmRejectionRate, minimalDPrime)
        % FileStatsAccumulator(headerStr, trialFilter,
        % falseAlarmRejectionRate, minimalDPrime)
        % Arguments:
        % headerStr - field of the trial struct by which the trials will
        %   be partitioned to calculate separate statistics for each unique
        %   value of that field (e. g. 'Duration' for GapStimuli).
        % trialFilter - a function handle that takes a trial struct and
        %   returns logical true or false depending on whether the trial
        %   should be included or not (e. g. '@(x) x.ID > 0'). Default:
        %   include all trials
        % falseAlarmRejectionRate - maximum allowed false alarm rate for
        %   the inclusion of the session. Default = 0.2
        % minimalDPrime - minium dPrime that must have been reached in any
        %   category for the inclusion of the session.
        if nargin > 3
            this.minimalDPrime = minimalDPrime;
        end
        if nargin > 2
            this.falseAlarmRejectionRate = falseAlarmRejectionRate;
        end
        if nargin < 2
            trialFilter = [];
        end
        [fileNames, this.files.path] = uigetfile( ...
            '*.mat', 'Select experiment logbooks', 'Multiselect', 'on');
        if ~iscell(fileNames)
            fileNames = {fileNames};
        end
        this.files.name = fileNames;
        this.numberOfFiles = length(this.files.name);
        calcStats(this, headerStr, trialFilter);
    end
    
end

methods (Access = private)

    function calcStats(this, headerStr, trialFilter)
        % Init objects
        this.rejections = cell(1, this.numberOfFiles);
        this.falseAlarmRates = zeros(1, this.numberOfFiles);

        % Iterate over files
        for fileIndex=1:this.numberOfFiles
            currentFileName = this.files.name{fileIndex};
            % Load file (should make variable 'el' accessible in work
            % space)
            load(strcat(this.files.path, currentFileName));
            % Compute stats for logbook within file
            try
                lbe = LogbookEvaluator(el);
            catch exception
                match = strfind(exception.identifier, ...
                    'ExperimentState:IncorrectEvent');
                if ~isempty(match)
                    % change to error
                    msg = sprintf('%s %s in:\n%s', char(exception.identifier), ...
                        char(exception.message), char(this.files.name(fileIndex)));
                    disp(msg);
                    continue;
                else
                    rethrow(exception);
                end
            end
            trials = lbe.getTrials();
            if ~isempty(trialFilter)
                trials = trials(arrayfun(trialFilter, trials));
            end
            % Compute statistics over whole experiment
            shamTrials = lbe.getShamTrials();
            faStats = getFalseAlarmStats(shamTrials);
            wholeStats = getSessionStats(trials, headerStr, faStats.adjustedFalseAlarmRate);
            
            % Save false alarm rate
            this.falseAlarmRates(fileIndex) = faStats.falseAlarmRate;

            % Collect information about rejections
            if faStats.falseAlarmRate > this.falseAlarmRejectionRate
                this.rejections{fileIndex} = 'rejected:falseAlarm';
            elseif ~any(wholeStats.dPrime >= this.minimalDPrime)
                this.rejections{fileIndex} = 'rejected:dPrime';
            else
                this.rejections{fileIndex} = 'included';
                
                % Compute statistics for individual conditions and
                % accumulate
                [classifiedTrials, classNames] = classifyBlockedTrials(trials, lbe.getAudioObjects());
                for condIdx = 1:length(classNames)
                    if isempty(classifiedTrials{condIdx})
                        continue;
                    end
                    condName = classNames{condIdx};
                    condStats = getSessionStats(classifiedTrials{condIdx}, ...
                        headerStr, faStats.adjustedFalseAlarmRate);
                    if ~isfield(this.condition, condName)
                        this.condition.(condName) = ...
                            cell2struct(cell(1,6), ...
                            {'header', 'num', 'hits', 'missings', 'hitRate', 'dPrime'}, 2);
                    end
                    this.condition.(condName).header = [this.condition.(condName).header; condStats.header];
                    this.condition.(condName).num = [this.condition.(condName).num; condStats.num];
                    this.condition.(condName).hits = [this.condition.(condName).hits; condStats.hits];
                    this.condition.(condName).missings = [this.condition.(condName).missings; condStats.missings];
                    this.condition.(condName).hitRate = [this.condition.(condName).hitRate; condStats.hitRate];
                    this.condition.(condName).dPrime = [this.condition.(condName).dPrime; condStats.dPrime];              
                end
            end
        end            
    end

end
    
end
