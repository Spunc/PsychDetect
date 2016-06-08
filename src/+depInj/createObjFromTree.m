function obj = createObjFromTree(s)
%CREATEOBJFROMTREE creates an object from a tree-shaped struct
%   This function creates an object (called root object) by dependency
%   injection from a struct that has a tree-shaped from.
%
%   The struct must have the following form:
%   An object is represented by a struct. The construction method for this
%   object is specified in the field 'method'.
%   Additional fields with non struct values represent parameters of that
%   object.
%   Additonal fields with structs as values, with one of its fields
%   again named 'method' represent more objects that are one level higher
%   in the hierarchy and that the object at the lower level depends on.
%   Those objects can be further nested.
%   Construction methods must take exactly one struct argument.
%   Construction methods may be class-object constructors (with one single
%   struct parameter).
%
%   Example of a tree-shaped struct:
%   root.method = 'ClassA'
%   root.param = 'someSimpleParameterOfClassA'
%   root.param2.method = 'ClassB'
%   root.param2.param = 'someSimpleParamOfClassB'

% Author: Lasse Osterhagen

config = struct();

fns = fieldnames(s);
for index=1:length(fns)
    fn = fns{index};
    if strcmp(fn, 'method')  % field to determine the construction method
        method = s.method;
        continue;
    end
    if isstruct(s.(fn)) && isfield(s.(fn), 'method') % another object in hierarchy
        config.(fn) = depInj.createObjFromTree(s.(fn));
        continue;
    end
    config.(fn) = s.(fn);
end

obj = eval([method, '(config)']);

end
