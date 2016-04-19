classdef GapStimulusSampleFactoryTest < matlab.unittest.TestCase
    
% Author: Lasse Osterhagen
    
properties(Constant)
    gaps = [1, .1, .01, .001];
    sFs = [44100, 192e3];
    gates = [.001, .0005];
end

methods(Static, Access = private)

    function [outSamples, requiredSamples] = applySampleFac(gapDuration, ...
            sF, gateDuration, numInputSamples)
        gapStimulus = GapStimulus('duration', gapDuration);
        sampleFactory = GapStimulusSampleFactory(sF, gateDuration);
        requiredSamples = sampleFactory.calcRequiredSamples(gapStimulus);
        if isempty(numInputSamples)
            numInputSamples = requiredSamples;
        end
        outSamples = sampleFactory.makeAudioObjectSamples(gapStimulus, ...
            ones(1, numInputSamples));
    end

    function str = strDiag(gap, sF, gate)
        str = sprintf('Gap: %.3f; sF: %0.4g; gate: %.4f', gap, sF, gate);
    end

end

methods(Test)

    function testCorrectGap(this)
        % Test if there are enough samples below .5 times the inputs
        % signal.
        for sF=1:length(this.sFs)
            for gate=1:length(this.gates)
                for gap=1:length(this.gaps)
                    outSamples = this.applySampleFac(this.gaps(gap), ...
                        this.sFs(sF), this.gates(gate), []);
                    actualBelow_5 = sum(outSamples < .5);
                    expectedBelow_5 = this.gaps(gap)*this.sFs(sF);
                    this.verifyEqual(actualBelow_5, expectedBelow_5, ...
                        'AbsTol', 1, ... % allow one sample tolerance
                        this.strDiag( ...
                        this.gaps(gap), this.sFs(sF), this.gates(gate)));
                end
            end
        end
    end

    function testRequiredSamples(this)
        % The number of samples needed to fit in a gapStimulus should
        % be approximately equal to
        % (gapStimulus.duration+2*0.5*gateDuration)*sF            
        for sF=1:length(this.sFs)
            for gate=1:length(this.gates)
                for gap=1:length(this.gaps)
                    [~, requiredSamples] = this.applySampleFac(this.gaps(gap), ...
                        this.sFs(sF), this.gates(gate), []);
                    expectedReqSamples = (this.gaps(gap)+this.gates(gate))* ...
                        this.sFs(sF);
                    this.verifyEqual(requiredSamples, round(expectedReqSamples), ...
                        'AbsTol', 2, ... % allow two samples tolerance
                        this.strDiag( ...
                        this.gaps(gap), this.sFs(sF), this.gates(gate)));
                end
            end
        end 
    end

    function testNumberOutputSamples(this)
        % Test if the number of output samples is equal to the number
        % of raw input samples
        numInputSamples = 123456;
        outSamples = this.applySampleFac(.01, 44100, .005, numInputSamples);
        this.verifyLength(outSamples, numInputSamples);
    end

end

end
