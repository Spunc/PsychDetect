classdef ToneStimulusSampleFactoryTest < matlab.unittest.TestCase
%TONESTIMULUSSAMPLEFACTORYTEST tests ToneStimulusSampleFactory
%   It only tests one fixed factory object.

% Author: Lasse Osterhagen
    
properties(Constant)
    sF = 192e3;
    gateDuration = .0005;
    dur_freq_set = [.5, 10000; .1, 15000; .1, 20000];
    refdB = 50;
end

properties
    toneStimuli = ToneStimulus.empty
    calib
    factory
end

methods (Access = private)
    
    function out = createSamples(this, toneStimulus)
        reqSamples = this.factory.calcRequiredSamples(toneStimulus);
        out = this.factory.makeAudioObjectSamples(toneStimulus, ...
            zeros(1, reqSamples));
    end
    
end

methods(TestClassSetup)
    
    function init(this)
        this.toneStimuli(3) = ToneStimulus('duration', .1, ...
            'frequency', 20000, 'level', this.refdB);
        this.toneStimuli(2) = ToneStimulus('duration', .1, ...
            'frequency', 15000, 'level', this.refdB);
        this.toneStimuli(1) = ToneStimulus('duration', .5, ...
            'frequency', 10000, 'level', this.refdB);
        this.calib.freq = [2000, 9000, 15000];
        this.calib.voltage = [1, .1, .3];
        this.calib.refdB = this.refdB;
        this.factory = ToneStimulusSampleFactory(this.sF, this.gateDuration, ...
            this.dur_freq_set, this.calib);
    end
    
end

methods(Test)
    
    function testStimulusSamples(this)
        % Tests created samples frequency content
        for index=1:length(this.toneStimuli)
            stim = this.toneStimuli(index);
            out = this.createSamples(stim);
            % compute fft
            L = length(out);
            y = fft(out);
            p2 = abs(y/L);
            p1 = p2(1:L/2+1);
            p1(2:end-1) = 2*p1(2:end-1);
            f = this.sF*(0:(L/2))/L;
            % the amplitude max should be near the expected frequency
            [~, maxIdx] = max(p1);
            maxFreq = f(maxIdx);
            this.verifyEqual(maxFreq, stim.frequency, 'RelTol', .01);
            % high frequency content should be around the expected
            % frequency
            f_idx = p1 > (mean(p1)+5*std(p1));
            fHigh = f(f_idx);
            deltaF = fHigh-stim.frequency;
            this.verifyTrue(all(deltaF < stim.frequency*.05));
        end
    end

    function testRequiredSamples(this)
        % The number of samples needed to fit in a ToneStimulus should
        % be approximately equal to
        % (toneStimulus.duration+2*0.5*gateDuration)*sF
        for index=1:length(this.toneStimuli)
            stim = this.toneStimuli(index);
            expectedReqSamples = (stim.duration+2*.5*this.gateDuration)*this.sF;
            actualReqSamples = this.factory.calcRequiredSamples(stim);
            this.verifyEqual(actualReqSamples, round(expectedReqSamples), ...
                'AbsTol', 2) % allow two samples tolerance
        end
    end

    function testNumberOutputSamples(this)
        % Test if the number of output samples is equal to the number
        % of raw input samples
        numInputSamples = this.sF;
        toneStim = ToneStimulus('frequency', 10000, 'duration', .5);
        outSamples = this.factory.makeAudioObjectSamples(toneStim, ...
            zeros(1, numInputSamples));
        this.verifyLength(outSamples, numInputSamples);
    end
    
    function testNoWaveTable4Stimulus(this)
        % A stimulus duration/frequency configuration, that is unexpected,
        % should throw an error.
        toneStim = ToneStimulus('frequency', 100);
        this.verifyError(@()this.createSamples(toneStim), ...
            'ToneStimulusSampleFactory:ValueError');
    end

end

end
