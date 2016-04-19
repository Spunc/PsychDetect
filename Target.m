classdef Target
%TARGET is a type-safe enumeration for stimulus reward categories.
%   Stimuli can be targets that are rewarded: 'Yes_Reward', targets that
%   are not rewarded: 'Yes_NoReward', or non-targets that likewise are
%   not rewarded: 'No'.

% Author: Lasse Osterhagen
    
    enumeration
        Yes_Reward, Yes_NoReward, No
    end
    
end
