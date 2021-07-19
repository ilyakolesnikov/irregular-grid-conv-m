warning('off', 'all');
networkManager = NetworkManager();
networkManager.initConvToPoolBlockSets();

%networkManager.initLayers(); 
%networkManager.passByImage('freud.jpg');
%{ 
csvSamples = readtable('datasets/MNIST/mnist_sample_20.csv');
images = zeros(28, 28, 20);
for imgIdx = 1:20
    for x = 1:28
        for y = 1:28
            pointIdx = 1 + 28*(x - 1) + y;
            images(x, y, imgIdx) = csvSamples{imgIdx, pointIdx};
        end
    end
end
%} 

%save(fullfile('C:\dev\irregular-grid-conv-m', 'mnist_samples.mat'), 'images');
load('mnist_samples.mat');
%load('datasets/CIFAR-10/data_batch_1.mat');
%{
images = zeros(3, 32, 32, 10);
for imgIdx = 1:20
    for x = 1:32
        for y = 1:32
            pointRed = 32*(y - 1) + x;
            pointGreen = 1024 + 32*(y - 1) + x;
            pointBlue = 2048 + 32*(y - 1) + x;
            value = [
                data(imgIdx, pointRed)
                data(imgIdx, pointGreen)
                data(imgIdx, pointBlue)
            ];
            images(:, x, y, imgIdx) = value;
        end
    end
end
%}
%[accuracy, lost, deltas] = networkManager.checkImage(img, 10);
%disp(10);
%disp(lost);
%networkManager.backwardByImage(deltas);

%img = images(:, :, :, 3);
%img = images(:, :, 1);

lenaImg = imread('lena.jpg');
freudImg = rgb2gray(imread('freud.jpg'));
[accuracy, lost, deltas] = networkManager.checkImage(freudImg, 2);
networkManager.backwardByImage(deltas);
%disp(1);
disp(lost);

% --- Продумать по обучению


%[LMST, T, nodeX, nodeY] = processimg(img);
