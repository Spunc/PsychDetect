classdef GapStimulus < Stimulus
%GAPSTIMULUS is a Stimulus that represents a gap.
%   Input arguments:
%       id=0,
%       startDelay=0,               % sec
%       target=Target.Yes_Reward,
%       'duration', 0.016           % sec

% Author: Lasse Osterhagen

methods

    function this = GapStimulus(varargin)
        p = inputParser;
        addOptional(p, 'id', 0, @isnumeric); % ids typically inidicate trial no
        checkPositiveNumber = @(x) isnumeric(x) && x>=0;
        addOptional(p, 'startDelay', 0, checkPositiveNumber);
        addOptional(p, 'target', Target.Yes_Reward, @(x) isa(x, 'Target'));
        addParameter(p, 'duration', .016, checkPositiveNumber);
        parse(p, varargin{:});
        this = this@Stimulus(p.Results.id, p.Results.startDelay, ...
            p.Results.duration, p.Results.target);
        this.duration = p.Results.duration;
    end

end

end
