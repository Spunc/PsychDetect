classdef LogBookTest < matlab.unittest.TestCase

% Author: Lasse Osterhagen
    
    properties(Constant)
        eventGenerator = EventGenerator();
    end
    
    properties
        logbook
    end
    
    methods(TestMethodSetup)
        function setUp(this)
            this.logbook = LogBook();
            this.logbook.addObservable(this.eventGenerator, 'Event1');
            this.logbook.addObservable(this.eventGenerator, 'Event2');
            this.logbook.displaying = false;
        end
    end
    
    methods(TestMethodTeardown)
        function removeListeners(this)
            delete(this.logbook)
        end
    end
    
    methods(Test)
       
        function testrecord(this)
            this.eventGenerator.sendEvent('Event1', []);
            this.verifyEqual(this.logbook.eventLog{1}{1}, 'Event1');
        end
        
        function testTiming(this)
            this.eventGenerator.sendEvent('Event1', []);
            time = GetSecs();
            this.verifyEqual(this.logbook.eventLog{1}{2}, time, ...
                'AbsTol', 0.005); % 5 ms tolerance
        end
        
        function testData(this)
            this.eventGenerator.sendEvent('Event1', ExperimentEventData({ ...
                'row1', 1; ...
                'row2', 2}));
            this.verifyEqual(this.logbook.eventLog{1}{2,1}, 'row1');
            this.verifyEqual(this.logbook.eventLog{1}{3,2}, 2);
        end
        
        function testMultipleRecored(this)
            this.eventGenerator.sendEvent('Event1', []);
            this.eventGenerator.sendEvent('Event2', []);
            this.verifyEqual(this.logbook.eventLog{1}{1}, 'Event1');
            this.verifyEqual(this.logbook.eventLog{2}{1}, 'Event2');
        end
    end
    
end

