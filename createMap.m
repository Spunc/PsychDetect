function map = createMap(config)
%CREATEMAP Create a containers.Map from a config file.
%   Use this class in the dependency injection framework
%   (createObjFromTree()). For the method field, write 'createMap'. The
%   struct config must have a field 'keys' with a cell array containing all
%   keys and another field 'values' with a cell array containing all
%   values. Those values will again be evaluated by createObjFromTree().
%
%   Example of a root struct for a map:
%   config.method = 'mapCreator'
%   config.keys = {'key1', 'key2'}
%   config.values = {ojb1
%                       .method = 'Obj1'
%                       .parameter1 = 123   ,
%                    obj2
%                       .method = 'Obj2'
%                   }

% Author: Lasse Osterhagen

assert(isstruct(config), 'mapCreator:InvalidFormat', ...
    'Map object template must be a struct.');
assert(isfield(config, 'keys'), 'mapCreator:InvalidFormat', ...
    'Map object template must have a field named keys.')
assert(iscell(config.keys), 'mapCreator:InvalidFormat', ...
    'keys must be a cell array.');
assert(all(cellfun(@ischar, config.keys)), 'mapCreator:InvalidFormat', ...
    'keys must be a cell array of strings.');
assert(length(config.keys) == length(unique(config.keys)), ...
    'mapCreator:InvalidFormat', 'Non unique key set.');
assert(isfield(config, 'values'), 'mapCreator:InvalidFormat', ...
    'Map object template must have a field named values.');
assert(iscell(config.values), 'mapCreator:InvalidFormat', ...
    'values must be a cell array.');

map = containers.Map;

keys = config.keys;
vals = config.values;
for index=1:length(keys)
    val = vals{index};
    if isstruct(val) && isfield(val, 'method')
        valObj = createObjFromTree(val);
    else
        valObj = val;
    end
    map(keys{index}) = valObj;
end

end
