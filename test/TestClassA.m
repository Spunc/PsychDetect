classdef TestClassA < handle
    %TESTCLASSA Class for testing createObjFromTree()
    %   This class is used on the first layer of a tree struct. It
    %   containts a simple property and an object of TestClassB, which will
    %   represent a second layer.
    
    % Author: Lasse Osterhagen
    
    properties
        simpleProp1
        testClassB
    end
    
    methods
        function this = TestClassA(config)
            this.simpleProp1 = config.simpleProp1;
            this.testClassB = config.testClassB;
        end
    end
    
end

