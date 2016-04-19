classdef GapTrainingStimuliGeneratorTest < matlab.unittest.TestCase
    
% Author: Lasse Osterhagen
    
properties (Constant)
    defaultGapDurMean = .01;
    defaultGapDurStd = .002;
    defaultStartDelayBounds = [1, 5];
end
    
properties
    % default config
    config
    defaultGapDurBounds % (constant property that depends on other properties)
end
    
methods (TestMethodSetup)
    
    function createConfigForInit(this)
        this.defaultGapDurBounds = [this.defaultGapDurMean-2*this.defaultGapDurStd, ...
            this.defaultGapDurMean+2*this.defaultGapDurStd];
        this.config.gapDuration = [this.defaultGapDurMean, ...
            this.defaultGapDurStd];
        this.config.gapDurationBounds = this.defaultGapDurBounds;
        this.config.startDelayBounds = this.defaultStartDelayBounds;
    end
    
end
    
methods (Test)
    
    function testGapDurationBounds(this)
        % Test that gap durations does not exceed gapDurationBounds
        this.config.gapDurationBounds = [this.defaultGapDurMean, ...
            this.defaultGapDurMean];
        g = GapTrainingStimuliGenerator(this.config);
        arraySize = 100;
        array = this.createGapStimulusArray(g, arraySize);
        this.verifyEqual(sum([array.duration] == this.defaultGapDurMean), ...
            arraySize);
    end
    
    function testGapDurationMean(this)
        % Test correct gap duration according to normal distribution
        g = GapTrainingStimuliGenerator(this.config);
        arraySize = 100;
        array = this.createGapStimulusArray(g, arraySize);
        durations = [array.duration];
        SE = this.defaultGapDurStd/sqrt(arraySize);
        this.verifyEqual(mean(durations), this.defaultGapDurMean, ...
            'AbsTol', 2*SE);
    end
    
    function testGapDurationStd(this)
        g = GapTrainingStimuliGenerator(this.config);
        arraySize = 100;
        array = this.createGapStimulusArray(g, arraySize);
        durations = [array.duration];
        % Calculate percentage of elements that exceed one std
        p = 2*normcdf(-1);
        numBelow = sum(durations < this.defaultGapDurMean- ...
            this.defaultGapDurStd);
        numAbove = sum(durations > this.defaultGapDurMean+ ...
            this.defaultGapDurStd);
        percentage = (numBelow+numAbove)/arraySize;
        this.verifyEqual(percentage, p, 'AbsTol', .1);
    end
    
    function testStartDelayBounds(this)
        g = GapTrainingStimuliGenerator(this.config);
        array = this.createGapStimulusArray(g, 100);
        delay = [array.startDelay];
        this.verifyFalse(any(delay < this.defaultStartDelayBounds(1)));
        this.verifyFalse(any(delay > this.defaultStartDelayBounds(2)));
    end
    
end

methods (Static)
    
    function outArray = createGapStimulusArray(gfac, len)
        outArray(len) = GapStimulus();
        for index=1:len
            outArray(index) = gfac.next();
        end
    end
    
end

end