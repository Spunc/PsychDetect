classdef loadSingleVarFromFileTest < matlab.unittest.TestCase

% Author: Lasse Osterhagen
    
properties (Constant)
    varContent = 'testContent';
end
    
properties
    config
end

methods (TestMethodSetup)
    
    function initConfig(this)
        this.config.method = 'loadSingleVarFromFile';
        this.config.fileName = 'testLoadVarFromFile.mat';
        this.config.varName = 'test';
    end
    
end

methods (Test)
    
    function testCurrentDirectory(this)
        var = loadSingleVarFromFile(this.config);
        this.verifyEqual(var, this.varContent);
    end
    
    function testOtherDirectory(this)
        this.config.evalPath = '[pwd(), filesep()]';
        var = loadSingleVarFromFile(this.config);
        this.verifyEqual(var, this.varContent);
    end
end

end