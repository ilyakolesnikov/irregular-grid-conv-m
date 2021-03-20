% layers testing

% --- prepare initial data ---
nodeX = [0 10 10 0 1 2 4 5 6 7];
nodeY = [10 10 0 0 2 6 2 6 2 7];
simplexList = [
    5 6 7;
    6 7 8;
    7 8 9;
    8 9 10;
    9 10 3;
    10 2 3;
    10 1 2;
    8 10 1;
    6 8 1;
    6 1 4;
    6 5 4;
    5 7 4;
    4 7 3;
    7 9 3;
];
simplexFeatures = [
    20 12 10 5;
    30 10 12 10;
    2 8 7 0;
    0 2 5 2;
    1 1 1 1;
    3 3 3 3;
    2 2 2 2;
    0 0 0 0;
    1 1 1 1;
    3 3 3 3;
    2 2 2 2;
    0 0 0 0;
    0 0 0 0;
    0 0 0 0;
];

% -------------------------------------------
% --- >>> SimplexConvLayer test cases <<< ---
testKernel = [1 2 1 1];
simplexConvLayer = SimplexConvLayer(testKernel);

disp('--- [TEST] SimplexConvLayer.prepareInputFeatures ---');
testLMST = [
    1 1 1 1 1 1 1 1 1 1 1 1 1 1 1;
    0 0 0 0 0 0 0 0 0 0 0 0 0 0 0;
    0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
];
expectedPreparedFeatures = [
    1 0.2425 0.7593 0.4472
    1 0.4472 0.7593 0.2425
    1 0.2425 0.8824 0.2425
    1 -0.2169 0.9037 0.6139
    1 -0.2631 0.8240 0.7634
    1 -0.3714 0.7071 0.9191
    1 -0.3714 0.9191 0.7071
    1 -0.4191 0.6459 0.9638
    1 -0.4472 0.7809 0.9080
	1 -0.7071 0.8944 0.9487
	1 0.9971 -0.9762 0.9899
    1 -0.4472 0.8944 0.8000
    1 0.8944 -0.7071 0.9487
    1 0.9487 -0.8944 0.9899
];
resultPreparedFeatures = simplexConvLayer.prepareInputFeatures(...
    nodeX, nodeY, simplexList, testLMST...
);
testCase = matlab.unittest.TestCase.forInteractiveUse;
assertEqual(testCase, expectedPreparedFeatures, resultPreparedFeatures, 'AbsTol', 0.01);
fprintf('\n');

expectedFeatures = zeros(14, 4);
expectedFeatures(:, 1) = [
    sum([20 30 0 2].*testKernel)
    sum([30 20 2 1].*testKernel)
    sum([2 30 0 0].*testKernel)
    sum([0 2 1 0].*testKernel)
    sum([1 0 3 0].*testKernel)
    sum([3 1 2 0].*testKernel)
    sum([2 3 0 0].*testKernel)
    sum([0 0 2 1].*testKernel)
    sum([1 30 0 3].*testKernel)
    sum([3 1 2 0].*testKernel)
    sum([2 20 3 0].*testKernel)
    sum([0 20 2 0].*testKernel)
    sum([0 0 0 0].*testKernel)
    sum([0 2 1 0].*testKernel)
];

disp('--- [TEST] SimplexConvLayer.forward ---');
resultFeatures = simplexConvLayer.forward(nodeX, nodeY, simplexList, simplexFeatures);
testCase = matlab.unittest.TestCase.forInteractiveUse;
assertEqual(testCase, resultFeatures(:, 1), expectedFeatures(:, 1));
fprintf('\n');

invertedKernel = flip(testKernel);
convDeltaErrors = [
    0.01 0.02 0.03 0.01
    0.01 0.12 0.01 0.20 % - 2
    0.02 0.18 0.11 0.17
    0.02 0.12 0.20 0.09 % - 4
    0.03 0.20 0.09 0.17 
    0.03 0.01 0.11 0.21 % - 6
    0.04 0.12 0.03 0.18 
    0.04 0.11 0.17 0.21 % - 8
    0.05 0.20 0.11 0.17 
    0.05 0.09 0.17 0.21 % - 10
    0.06 0.12 0.01 0.20 
    0.06 0.11 0.17 0.21 % - 12
    0.07 0.18 0.09 0.11
    0.07 0.12 0.03 0.18 % - 14
];
convErrorsExpected = zeros(14, 4);
convErrorsExpected(:, 1) = [
    sum([0.01 0.01 0.06 0.06].*invertedKernel)
    sum([0.01 0.01 0.02 0.05].*invertedKernel)
    sum([0.02 0.01 0.02 0.07].*invertedKernel)
    sum([0.02 0.02 0.03 0.04].*invertedKernel)
    sum([0.03 0.02 0.03 0.07].*invertedKernel)
    sum([0.03 0.03 0.04 0.00].*invertedKernel)
    sum([0.04 0.03 0.04 0.00].*invertedKernel)
    sum([0.04 0.02 0.04 0.05].*invertedKernel)
    sum([0.05 0.01 0.04 0.05].*invertedKernel)
    sum([0.05 0.05 0.06 0.00].*invertedKernel)
    sum([0.06 0.01 0.05 0.06].*invertedKernel)
    sum([0.06 0.01 0.06 0.07].*invertedKernel)
    sum([0.07 0.06 0.07 0.00].*invertedKernel)
    sum([0.07 0.02 0.03 0.07].*invertedKernel)
];
disp('--- [TEST] SimplexConvLayer.backward ---');
resultConvErrors = simplexConvLayer.backward(convDeltaErrors);
testCase = matlab.unittest.TestCase.forInteractiveUse;
assertEqual(testCase, resultConvErrors(:, 1), convErrorsExpected(:, 1));
fprintf('\n');

% -------------------------------------------
% --- >>> SimplexPoolLayer test cases <<< ---
simplexPoolLayer = SimplexPoolLayer();
    
expectedNodeX = [nodeX 5];
expectedNodeY = [nodeY 4];
expectedSimplexList = [
    5 6 7;
    6 7 11;
    11 10 3;
    10 2 3;
    10 1 2;
    11 10 1;
    6 11 1;
    6 1 4;
    6 5 4;
    5 7 4;
    4 7 3;
    7 11 3;
];

disp('--- [TEST] SimplexPoolLayer.forward ---');
[newNodeX, newNodeY, newSimplexList] = simplexPoolLayer.forward(...
    nodeX,...
    nodeY,...
    simplexList,...
    simplexFeatures...
);
testCase = matlab.unittest.TestCase.forInteractiveUse;
assertEqual(testCase, newNodeX, expectedNodeX);
assertEqual(testCase, newNodeY, expectedNodeY);
assertEqual(testCase, newSimplexList, expectedSimplexList);
fprintf('\n');

disp('--- [TEST] SimplexPoolLayer.backward ---');
deltaErrors = [
    0.07 0.01 0.12 0.06;
    0.10 0.11 0.12 0.06;
	0.06 0.06 0.15 0.03;
	0.23 0.15 0.11 0.24;
	0.16 0.00 0.22 0.22;
	0.19 0.10 0.00 0.17;
	0.01 0.23 0.24 0.06;
	0.05 0.02 0.15 0.16;
	0.14 0.15 0.23 0.03;
	0.25 0.21 0.06 0.05;
	0.00 0.21 0.24 0.01;
	0.07 0.03 0.24 0.22;
];
expected = [
    0.07 0.01 0.12 0.06;
    0.10 0.11 0.12 0.06;
    0.00 0.00 0.00 0.00;
    0.00 0.00 0.00 0.00;
	0.06 0.06 0.15 0.03;
	0.23 0.15 0.11 0.24;
	0.16 0.00 0.22 0.22;
	0.19 0.10 0.00 0.17;
	0.01 0.23 0.24 0.06;
	0.05 0.02 0.15 0.16;
	0.14 0.15 0.23 0.03;
	0.25 0.21 0.06 0.05;
	0.00 0.21 0.24 0.01;
	0.07 0.03 0.24 0.22;
];

result = simplexPoolLayer.backward(deltaErrors);
testCase = matlab.unittest.TestCase.forInteractiveUse;
assertEqual(testCase, result, expected);
fprintf('\n');

% -------------------------------------------
% --- >>> GlopalPoolLayer test cases <<< ---
globalPoolLayer = GlobalPoolLayer();

disp('--- [TEST] GlobalPoolLayer.forward ---');
inputFeatures = [
    0 0 0 12 0 9;
    3 0 1 78 3 2;
    34 1 1 1 0 2;
    0.1 4 4 4 4 4.3;
];
expected = [12 78 34 4.3];
result = globalPoolLayer.forward(inputFeatures);
testCase = matlab.unittest.TestCase.forInteractiveUse;
assertEqual(testCase, result, expected);
fprintf('\n');

disp('--- [TEST] GlobalPoolLayer.backward ---');
deltaErrors = [0.12 0.07 0.29 0.10];
expected = [
    0 0 0 0.12 0 0;
    0 0 0 0.07 0 0;
    0.29 0 0 0 0 0;
    0 0 0 0 0 0.10;
];
result = globalPoolLayer.backward(deltaErrors);
testCase = matlab.unittest.TestCase.forInteractiveUse;
assertEqual(testCase, result, expected);
fprintf('\n');

% -------------------------------------------
% --- >>> FullConnectionLayer test cases <<< ---
inputsCount = 3;
neuronsCount = 2;
testWeights = [1 1 1; 1.2 1 1.2];

fcLayer = FullConnectionLayer(inputsCount, neuronsCount, testWeights);

disp('--- [TEST] FullConnectionLayer.forward ---');
fcInputFeatures = [1 2 3];
fcOutputExpected = [6 6.8];
fcOutputResult = fcLayer.forward(fcInputFeatures);
testCase = matlab.unittest.TestCase.forInteractiveUse;
assertEqual(testCase, fcOutputResult, fcOutputExpected, 'AbsTol', 0.001);
fprintf('\n');

disp('--- [TEST] FullConnectionLayer.backward ---');
fcDeltaErrors = [0.1 0.2];
fcNewDeltasExpected = [0.34 0.30 0.34];
fcNewDeltasResult = fcLayer.backward(fcDeltaErrors);
testCase = matlab.unittest.TestCase.forInteractiveUse;
assertEqual(testCase, fcNewDeltasResult, fcNewDeltasExpected, 'AbsTol', 0.001);
fprintf('\n');

