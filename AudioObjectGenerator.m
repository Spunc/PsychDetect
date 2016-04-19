classdef (Abstract) AudioObjectGenerator < handle
%AUDIOOBJECTGENERATOR - interface for the generation of AudioObjects.
%   This is an iterator interface that must be implemeted by classes that
%   provide new AudioObjects.

% Author: Lasse Osterhagen

methods

    function append(~)
        % Append an AudioObject to the AudioObjectGenerator.
        % Useful if early jumps shall be reinserted.
        % Default behavior: not implemented.
    end

end

methods (Abstract)
    % Are there more AudioObjects in the queue?
    bool = hasNext(this)
    % Get the next AudioObject
    aoObject = next(this)
end
    
end

