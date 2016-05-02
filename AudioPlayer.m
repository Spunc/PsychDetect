classdef (Abstract) AudioPlayer < handle
%AUDIOPLAYER is an abstract base class for audio players.
%   Implement this interface to create audio players that can be used by
%   ExperimentController.

% Author: Lasse Osterhagen

properties (SetAccess = protected)
    % Time when last AudioObject was played
    lastAOTime = -1000;
end

methods (Abstract)

    start(this)
    stop(this)
    playAudioObject(this, audioObject)

end

end
