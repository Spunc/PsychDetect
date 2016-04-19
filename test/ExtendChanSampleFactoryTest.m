% Test ExtendChanSampleFactory.m

% Author: Lasse Osterhagen

% Create mock AudioObjectSampleFactories
mockFactory1Row.makeAudioObjectSamples = @(a,b) b; % return rawSamples
mockFactory1Row.calcRequiredSamples = 0;
mockFactory2Rows.makeAudioObjectSamples = @(a,b) [b; b+1];
        % return [rawSamples; rawSamples+1]
mockFactory2Rows.calcRequiredSamples = 0;

%% Test 1: One row -> one row
e = ExtendChanSampleFactory(mockFactory1Row, 1);
out = e.makeAudioObjectSamples(0, 1:10);
assert(isequal(out, 1:10));

%% Test 2: One row -> two rows
e = ExtendChanSampleFactory(mockFactory1Row, 2);
out = e.makeAudioObjectSamples(0, 1:10);
expectedOut = [1:10; zeros(1,10)];
assert(isequal(out, expectedOut));

%% Test 3: One row -> four rows
e = ExtendChanSampleFactory(mockFactory1Row, 4);
out = e.makeAudioObjectSamples(0, 1:10);
expectedOut = [1:10; zeros(3,10)];
assert(isequal(out, expectedOut));

%% Test 4: Two rows -> one row
e = ExtendChanSampleFactory(mockFactory2Rows, 1);
out = e.makeAudioObjectSamples(0, 1:10);
assert(isequal(out, 1:10));

%% Test 5: Two rows -> two rows
e = ExtendChanSampleFactory(mockFactory2Rows, 2);
out = e.makeAudioObjectSamples(0, 1:10);
expectedOut = [1:10; (1:10)+1];
assert(isequal(out, expectedOut));

%% Test 6; Two rows -> three rows
e = ExtendChanSampleFactory(mockFactory2Rows, 3);
out = e.makeAudioObjectSamples(0, 1:10);
expectedOut = [1:10; (1:10)+1; zeros(1,10)];
assert(isequal(out, expectedOut));

