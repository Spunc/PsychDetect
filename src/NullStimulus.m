classdef NullStimulus < Stimulus
%NULLSTIMULUS is the absence of a Stimulus.
% Can be used as catch/sham trial.
% Input arguments:
%   id=0,
%   startDelay=0,               % sec
%   target=Target.Yes_Reward,
%   'duration', 0.016           % sec

% Author: Lasse Osterhagen

methods

    function this = NullStimulus(varargin)
        p = inputParser;
        addOptional(p, 'id', 0, @isnumeric); % ids typically indicate trial no
        checkPositiveNumber = @(x) isnumeric(x) && x>=0;
        addOptional(p, 'startDelay', 0, checkPositiveNumber);
        addOptional(p, 'target', Target.No, @(x) isa(x, 'Target'));
        addParameter(p, 'duration', 0, checkPositiveNumber);
        parse(p, varargin{:});
        this = this@Stimulus(p.Results.id, p.Results.startDelay, ...
            p.Results.duration, p.Results.target);
        this.duration = p.Results.duration;
    end

end

end

