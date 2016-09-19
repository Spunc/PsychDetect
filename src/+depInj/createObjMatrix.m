function objMatrix = createObjMatrix(s)
%CREATEOBJMATRIX creates a matrix of objects of a single class.
%   Use this class in the dependency injection framework
%   (depInj.createObjFromTree()).
%   For the method field, write 'depInj.createObjMatrix'. Another field
%   named 'constructor' contains the constructor method for all objects. A
%   third field named 'param' contains a struct with field names
%   corresponding to the parameters needed for object creation. The values
%   of the struct are matrices of the same size as the target (output)
%   matrix, containing the values for the objects.
%
%   Examples of a root struct for a matrix of objects:
%   config.method = 'depInj.createObjMatrix';
%   config.constructor = 'SomeClassConstructor';
%   config.param.param1 = [1 2; 3 4];
%   config.param.param2 = {'val1', 'val2'; 'val3', 'val4'};

% Author: Lasse Osterhagen

% Validate arguments
assert(isstruct(s), 'createObjMatrix:InvalidFormat', ...
    'Matrix of objects template must be a struct.');
assert(isfield(s, 'constructor'), 'createObjMatrix:InvalidFormat', ...
    'Matrix of objects template must have a field named constructor.');
assert(isfield(s, 'param'), 'createObjMatrix:InvalidFormat', ...
    'Matrix of objects template must have a field named param.');
assert(isstruct(s.param), 'createObjMatrix:InvalidFormat', ...
    'The field param must be a struct');
param = s.param;
paramCell = struct2cell(param);
if ~length(paramCell) == 1
    cellSizes = cellfun(@size, paramCell, 'UniformOutput', false);
    assert(isequal(cellSizes{:}), 'createObjMatrix:InvalidFormat', ...
        'Sizes of all param matrices must be the same.');
end

% Save global properties
globals = rmfield(s, {'constructor', 'param'});

outSize = size(paramCell{1});
outSize = num2cell(outSize);
objMatrix(outSize{:}) = eval(s.constructor);
fns = fieldnames(param);
for objIdx = 1:numel(objMatrix)
    config = struct('method', s.constructor);
    for fieldIdx=1:length(fns)
        fn = fns{fieldIdx};
        config.(fn) = param.(fn)(objIdx);
    end
    objMatrix(objIdx) = depInj.createObjFromTree(config, globals);
end
