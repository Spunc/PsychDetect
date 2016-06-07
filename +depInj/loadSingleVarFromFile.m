function var = loadSingleVarFromFile(config)
%LOADVARFROMFILE loads a variable from a .mat file
%   This function is part of the dependency injection framework
%   (depInj.createObjFromTree()). For the method field, write
%   'depInj.loadVarFromFile'.
%   The struct config must have a field 'fileName' with
%   a string that specifies the full path to the file that should be
%   loaded.
%   An additional field 'varName' specifies the variable name within the
%   .mat file which should be returned.
%   An optional field 'evalPath' may contain an expression as a
%   string, that evaluates to the path of the file.
%   
%   Example of a root struct that loads testfile.mat from current dirctory:
%   config.method = 'depInj.loadVarFromFile'
%   config.fileName = 'testfile'
%   config.varName = 'test'
%
%   Example of a root struct that loads testfile.mat from the home
%   directory:
%   config.method = 'depInj.loadVarFromFile'
%   config.fileName = 'testfile'
%   config.varName = 'test'
%   config.evalPath = 'depInj.getHomePath'

% Author: Lasse Osterhagen

assert(isstruct(config), 'loadSingleVarFromFile:InvalidFormat', ...
    'config for file load must be a struct.');
assert(isfield(config, 'fileName'), 'loadSingleVarFromFile:InvalidFormat', ...
    'config for file load must have a field named fileName.')
assert(isfield(config, 'varName'), 'loadSingleVarFromFile:InvalidFormat', ...
    'config for file load must have a field named varName.')

path = char.empty;

if isfield(config, 'evalPath')
    path = eval(config.evalPath);
end
load([path, config.fileName]);
var = eval(config.varName);

end
