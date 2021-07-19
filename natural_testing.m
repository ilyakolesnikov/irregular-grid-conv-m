warning('off', 'all');
networkManager = NetworkManager();
networkManager.initConvToPoolBlockSets();

epochsCount = 3;
countPerBatch = 50;
imgClasses = ["fruit",  "person", "car"];
basePath = 'datasets/natural_dataset/data/natural_images/';

logFile = 'dashboard/test-natural.xlsx';
File = [];
ClassId = [];
Accuracy = [];
Lost = [];
PassTimestamp = [];
dataTable = table(File, ClassId, Accuracy, Lost, PassTimestamp);
variablesNamesDict = {'File', 'ClassId', 'Accuracy', 'Lost', 'PassTimestamp'};
writeTablePos = 1;

fprintf(' >>> Timestamp natural testing START - %s  <<<\n', datestr(now,'HH:MM:SS.FFF'));

for epochIdx = 1:epochsCount
    for i = 1:length(imgClasses)
        for j = 0:countPerBatch
            className = imgClasses(i);
            imageIdx = (epochIdx - 1) * countPerBatch + j;
            fileName = strcat(className, '_', num2str(imageIdx, '%04i'), '.jpg');
            imgSrc = convertStringsToChars(strcat(basePath, className, '/', fileName));
            imgFile = rgb2gray(imread(imgSrc));

            [accuracy, lost, deltas] = networkManager.checkImage(imgFile, i);
            networkManager.backwardByImage(deltas);
            fprintf('Lost for img - %s = %s\n', fileName, num2str(lost, '%4f'));
            fprintf('Accuracy for img - %s = %s\n', fileName, num2str(accuracy, '%4f'));
            fprintf('--- --- --- --- \n');
            
            dataTable = [dataTable; table(...
                fileName, i, accuracy, lost, datestr(now,'HH:MM:SS.FFF'),...
                'VariableNames', variablesNamesDict...
            )];
        end
        
        writetable(dataTable, logFile, 'WriteVariableNames', false, 'Range',...
            sprintf('A%d:E%d', writeTablePos, writeTablePos + countPerBatch - 1)...
        );
        dataTable(:, :) = [];
        writeTablePos = writeTablePos + countPerBatch;
    end
end

fprintf(' >>> Timestamp natural testing STOP - %s  <<<\n', datestr(now,'HH:MM:SS.FFF'));