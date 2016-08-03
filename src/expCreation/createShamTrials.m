function shamTrials = createShamTrials(delays, repFactor)
%CREATESHAMTRIALS creates an array of sham trials.
%   Arguments:
%   delays - an array of delays [default: 1.25:5.25]
%    repFactor - replication factor
%
%   Creates a sham trial (trial with a NullStimulus) for every delay in
%   delays. Creates in total length(delays)*repFactor sham trials.
%   Attention: the output sham trials will be sorted. It is recommended to
%   use randperm() on the output array. Furthermore, the id of the stimuli
%   is set to 0.

% Author: Lasse Osterhagen

if nargin < 2
    repFactor = 1;
end
if nargin < 1
    delays = 1.25:5.25;
end

shamTrialDelays = repmat(delays, 1, repFactor);
packedShamTrials = arrayfun(@(x) NullStimulus(0, x), ...
    shamTrialDelays, 'UniformOutput', false);
shamTrials = [packedShamTrials{:}];
