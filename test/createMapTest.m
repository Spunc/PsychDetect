classdef createMapTest < matlab.unittest.TestCase
    
% Author: Lasse Osterhagen

properties
    % Test stuct
    s
end

methods (TestMethodSetup)
    
    function initS(this)
        this.s.method = 'mapCreator';
        this.s.keys = {'a', 'b', 'c'};
    end
    
end

methods (Test)
    
    function testSimpleMap(this)
        % Test map creation with only double values
        this.s.values = {1, 2, 3};
        m = createMap(this.s);
        this.verifyEqual(m('a'), 1);
        this.verifyEqual(m('b'), 2);
    end
    
    function testSimpleMapDifferentValueTypes(this)
        % Test map creation with different (non-object) values
        this.s.values = {1, 'abcd', [1 2 3]};
        m = createMap(this.s);
        this.verifyEqual(m('a'), 1);
        this.verifyEqual(m('b'), 'abcd');
        this.verifyEqual(m('c'), [1 2 3]);
    end
    
    function testComplexMap(this)
        % Test creation of map containing objects
        objStruct.method = 'TestClassB';
        objStruct.simpleProp1 = 'prop1';
        objStruct.simpleProp2 = 'prop2';
        this.s.values = cell(1, 3);
        this.s.values{1} = objStruct;
        this.s.values(2:3) = {1, 2};
        m = createMap(this.s);
        this.verifyClass(m('a'), 'TestClassB');
        this.verifyEqual(m('a').simpleProp1, 'prop1');
    end
    
end

end

