% Test createObjFromTreeTest.m

% Author: Lasse Osterhagen

% Set up
classBConf.method = 'TestClassB';
classBConf.simpleProp1 = 'B_simpleProp1';
classBConf.simpleProp2 = 'B_simpleProp2';

treeConf.method = 'TestClassA';
treeConf.simpleProp1 = 'A_simpleProp1';
treeConf.testClassB = classBConf;

testClassA = createObjFromTree(treeConf);

%% Test 1: Layer 1 simple properties
assert(strcmp(testClassA.simpleProp1, treeConf.simpleProp1));

%% Test 2: Layer 2 class properties
assert(isa(testClassA.testClassB, 'TestClassB'));

%% Test 3: Layer 2 simple properties
assert(strcmp(testClassA.testClassB.simpleProp1, classBConf.simpleProp1));
assert(strcmp(testClassA.testClassB.simpleProp2, classBConf.simpleProp2));
