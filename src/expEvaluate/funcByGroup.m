function [out, groups] = funcByGroup(values, grouping, func)
%FUNCBYGROUP apply a function to every group of values.
%   Arguments:
%   values - an array of all values
%   grouping - an array of the same size as values that specifies to which
%       group the value belongs
%   func - the function that should be applied to groups of values,
%       specified as function handle
%
% Author: Lasse Osterhagen

assert(length(values) == length(grouping), ...
    'The length of values and grouping must match.');
assert(isa(func, 'function_handle'), ...
    'func must be a function handle.');

groups = unique(grouping);
numGroups = length(groups);
out = zeros(numGroups, 1);

for index = 1:numGroups
    group = groups(index);
    if iscell(grouping)
        selectIdx = cellfun(@(x) isequal(group{:}, x), grouping);
    else
        selectIdx = grouping == group;
    end
    selectVals = values(selectIdx);
    out(index) = func(selectVals);
end
