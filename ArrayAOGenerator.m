classdef ArrayAOGenerator < AudioObjectGenerator
%ARRAYAOGENERATOR generates AudioObjects out of an array of AudioObjects.
%   This is not much more than a container class implementing the
%   AudioObjectGenerator iterator interface.

% Author: Lasse Osterhagen

properties (SetAccess = private)
    % Container for all AudioObjects
    aoArray
end

properties (Access = private)
    % Index of the current position within aoArray
    % (points one before the next element)
    position = 0;
end

methods

    function this = ArrayAOGenerator(aoArray_config)
        % ArrayAOGenerator(aoArray)
        % Arguments:
        % aoArray - row vector of AudioObjects
        %
        % ArrayAOGenerator(config)
        % Arguments:
        % config - struct with the field 'aoArray' which contains a
        %   row vector of AudioObjects
        if isstruct(aoArray_config)
            this.aoArray = aoArray_config.aoArray;
        else
            this.aoArray = aoArray_config;
        end
    end

    function bool = hasNext(this)
        % Check if there is one more AudioObject available
        bool = this.position < length(this.aoArray);
    end

    function audioObject = next(this)
        % Get the following Stimulus
        if this.hasNext
            this.position = this.position + 1;
            audioObject = this.aoArray(this.position);
        else
            error('ArrayTrialGenerator: no more elements!');
        end
    end

    function append(this, aoObject)
        % Append an AudioObject to end of aoArray
        this.aoObject(end+1) = aoObject;
    end

end
    
end
