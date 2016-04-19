function outStruct = publicProperties2Struct(obj)
%PUBLICPROPERTIES2STRUCT converts public properties of an Object to a struct.

% Author: Lasse Osterhagen

props = properties(obj);
outStruct = cell2struct(cellfun(@(p) obj.(p), props, ...
    'UniformOutput', false), props, 1);
end
