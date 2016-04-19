classdef TestClassB < handle
    %TESTCLASSB Class for testing createObjFromTree()
    %   This class is used on the second layer of a tree struct. It
    %   containts a two simple properties.
    
    % Author: Lasse Osterhagen
    
    properties
        simpleProp1
        simpleProp2
    end
    
    methods
        function this = TestClassB(config)
            this.simpleProp1 = config.simpleProp1;
            this.simpleProp2 = config.simpleProp2;
        end
    end
    
end

