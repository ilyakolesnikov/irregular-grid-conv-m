classdef NetworkManager < handle
    properties
        convToPoolBlockSets
        globalPoolLayers
        fcLayer
        kernels
        learnRate
    end
    
    methods
        function obj = NetworkManager()
            %obj.LMST = inLMST;
            %obj.simplexList = inSimplexList;
            %obj.nodeX = inNodeX;
            %obj.nodeY = inNodeY;
            obj.learnRate = 0.2;
            fcTestKernels = [
                1.0 1.1 0.9 1.2 1.0 1.1 0.9 1.2 1.0 1.1 0.9 1.2;
                0.8 0.9 1.0 1.1 0.8 0.9 1.0 1.1 0.8 0.9 1.0 1.1;
                0.9 1.2 1.0 0.8 0.9 1.2 1.0 0.8 0.9 1.2 1.0 0.8;
                1.1 0.9 1.2 1.0 1.1 0.9 1.2 1.0 1.1 0.9 1.2 1.0;
                0.9 1.0 1.1 0.8 0.9 1.0 1.1 0.8 0.9 1.0 1.1 0.8;
                1.1 0.8 0.9 1.0 1.1 0.8 0.9 1.0 1.1 0.8 0.9 1.0;
                0.8 0.9 1.0 0.8 0.9 1.0 0.8 0.9 1.0 0.8 0.9 1.0;
                1.0 1.1 0.9 1.0 1.1 0.9 1.0 1.1 0.9 1.0 1.1 0.9;
                1.2 1.0 0.8 1.2 1.0 0.8 1.2 1.0 0.8 1.2 1.0 0.8;
                1.0 0.8 1.0 0.8 1.0 0.8 1.0 0.8 1.0 0.8 1.0 0.8;
            ];
            obj.fcLayer = FullConnectionLayer(12, 10, fcTestKernels); 
            obj.initKernels(2);

        end
        
        function out = passByAllConvToPoolBlockSets(obj, imageData)
            blockSetsCount = size(obj.convToPoolBlockSets, 1);
            
            fprintf('Timestamp start - %s\n', datestr(now,'HH:MM:SS.FFF'));
            % prepare
            [LMST, simplexList, nodeX, nodeY] = processimg(imageData);
            
            fprintf('Timestamp processing done - %s\n', datestr(now,'HH:MM:SS.FFF'));
            dataMap = containers.Map;
            dataMap('LMST') = LMST;
            dataMap('simplexList') = simplexList;
            dataMap('nodeX') = nodeX;
            dataMap('nodeY') = nodeY;
            
            dataMapsList = containers.Map('KeyType', 'double', 'ValueType', 'any');
            dataMapsList(1) = dataMap;
            
            for i = 1:blockSetsCount
                dataMapsList = obj.passByConvToPoolBlockSet(i, dataMapsList, imageData);
            end
   
            fprintf('Timestamp propagation done - %s\n', datestr(now,'HH:MM:SS.FFF'));
            out = dataMapsList;   
        end
        
        function out = passByConvToPoolBlockSet(obj, setId, inputMapList, imageData)
            blocksCount = size(obj.convToPoolBlockSets(setId), 1);
            outputMapList = containers.Map('KeyType', 'double', 'ValueType', 'any');
            
            for i = 1:blocksCount
                inputMap = inputMapList(1);
                outputMapList(i) = obj.passByConvToPoolBlock(...
                    setId,...
                    i,...
                    inputMap('nodeX'),...
                    inputMap('nodeY'),...
                    inputMap('simplexList'),...
                    inputMap('LMST'),...
                    imageData...
                );
            end
            
            out = outputMapList;
        end
        
        %function [newLMST, newNodeX, newNodeY, newSimplexList] = passByConvToPoolBlock(...
        function out = passByConvToPoolBlock(...
            obj,...
            setId,...
            blockId,...
            nodeX,...
            nodeY,...
            simplexList,...
            LMST,...
            imageData...
        )
            blockSet = obj.convToPoolBlockSets(setId);
            block = blockSet(blockId);
            convLayer = block(1);
            poolLayer = block(2);
            resultMap = containers.Map;
            
            inputFeatures = convLayer.prepareInputFeatures(...
                nodeX, nodeY, simplexList, LMST...
            );
            featuresAfterConv = convLayer.forward(...
                nodeX, nodeY, simplexList, inputFeatures...
            );
            [newNodeX, newNodeY, newSimplexList] = poolLayer.forward(...
                nodeX, nodeY, simplexList, featuresAfterConv...
            );
        
            newLMST = calcLMST(newNodeX, newNodeY, newSimplexList, imageData);
            
            resultMap('LMST') = newLMST;
            resultMap('nodeX') = newNodeX;
            resultMap('nodeY') = newNodeY;
            resultMap('simplexList') = newSimplexList;
            
            out = resultMap;
        end
        
        function [accuracy, lost, deltas] = checkImage(obj, imageData, classId)
            outFeatures = obj.passByImage(imageData);
            classResult = max(1, outFeatures(classId));
            deltas = zeros(1, 10);
            
            for i = 1:10
                if (classId == i)
                    deltas(i) = (1 - classResult) ^ 2;
                else
                	 deltas(i) = classResult ^ 2;
                end
            end

            lost = sum(deltas) / 10;
            accuracy = 1 - lost;
        end
        
        function out = backwardByImage(obj, deltas)
            newDeltas = obj.fcLayer.backward(deltas, obj.learnRate);
            deltasAfterGlobalPool = [];
            
            for i = 1:size(obj.globalPoolLayers, 1)
                startPos = (i - 1) * 4 + 1;
                stopPos = startPos + 3;
                localDeltas = newDeltas(startPos:stopPos);
                deltasAfterGlobalPool(:, :, i) = obj.globalPoolLayers(i).backward(localDeltas);
            end
            
            blockSet = obj.convToPoolBlockSets(2);
            nextDeltas = [];
                
            for i = 1:size(blockSet, 1)
                block = blockSet(i);
                poolLayer = block(2);
                convLayer = block(1);
                deltasSlice = deltasAfterGlobalPool(:, :, i);
                poolDeltas = poolLayer.backward(deltasSlice);
                convDeltas = convLayer.backward(poolDeltas, obj.learnRate);
                
                if (i == 1)
                    nextDeltas = convDeltas;
                else
                    nextDeltas = nextDeltas + convDeltas;
                end
            end
            
            nextDeltas = nextDeltas / size(blockSet, 1);
            
            firstBlockSet = obj.convToPoolBlockSets(1);
            firstBlock = firstBlockSet(1);
            firstPoolLayer = firstBlock(2);
            firstConvLayer = firstBlock(1);
            
            lastPoolDeltas = firstPoolLayer.backward(nextDeltas);
            lastConvDeltas = firstConvLayer.backward(lastPoolDeltas, obj.learnRate);
        end
        
        function out = passByImage(obj, imageData)
            blocksSetOut = obj.passByAllConvToPoolBlockSets(imageData);
            obj.globalPoolLayers = containers.Map('KeyType', 'double', 'ValueType', 'any');
            flattenFeatures = [];
            
            for i = 1:size(blocksSetOut, 1)
                utilConvLayer = SimplexConvLayer([1 1 1 1]);
                obj.globalPoolLayers(i) = GlobalPoolLayer();
                blockDataMap = blocksSetOut(i);
                blockFeatures = utilConvLayer.prepareInputFeatures(...
                    blockDataMap('nodeX'),...
                    blockDataMap('nodeY'),...
                    blockDataMap('simplexList'),...
                    blockDataMap('LMST')...
                );
            
                globalBlockFeatures = obj.globalPoolLayers(i).forward(blockFeatures);
            
                flattenFeatures = [flattenFeatures globalBlockFeatures];  
            end
            
            fcOutRaw = obj.fcLayer.forward(flattenFeatures);
            maxVal = max(fcOutRaw);
            fcOut = fcOutRaw ./ maxVal;           
            
            out = fcOut;       
            
            
            %{
               % prepare
            [LMST, simplexList, nodeX, nodeY] = processimg(imageSrc);
            
            % first pass
            inputFeatures = obj.firstConvLayer.prepareInputFeatures(...
                nodeX, nodeY, simplexList, LMST...
            );
            featuresAfterConv = obj.firstConvLayer.forward(...
                nodeX, nodeY, simplexList, inputFeatures...
            );
            [newNodeX, newNodeY, newSimplexList] = obj.firstPoolLayer.forward(...
                nodeX, nodeY, simplexList, featuresAfterConv...
            );
        
            % get new LMST
            newLMST = calcLMST(newNodeX, newNodeY, newSimplexList, imageSrc);
        
            % second pass
            newInputFeatures = obj.firstConvLayer.prepareInputFeatures(...
                newNodeX, newNodeY, newSimplexList, newLMST...
            );
            newFeaturesAfterConv = obj.secondConvLayer.forward(...
                newNodeX, newNodeY, newSimplexList, newInputFeatures...
            );
            [newNodeX, newNodeY, newSimplexList] = obj.secondPoolLayer.forward(...
                newNodeX, newNodeY, newSimplexList, newFeaturesAfterConv...
            );
            %}
        end

        function initLayers(obj)           
            obj.globalPoolLayer = GlobalPoolLayer();
        end
                
        function initKernels(obj, kernelsCount)
            obj.kernels = ones(kernelsCount, 4);
        end
        
        function out = createConvToPoolBlock(obj, kernel)
            convLayer = SimplexConvLayer(kernel);
            poolLayer = SimplexPoolLayer();
            
            poolBlock = containers.Map('KeyType', 'double', 'ValueType', 'any');
            poolBlock(1) = convLayer;
            poolBlock(2) = poolLayer;
                        
            out = poolBlock;
        end
        
        function out = createConvToPoolBlockSet(obj, kernels)
            blockSet = containers.Map('KeyType', 'double', 'ValueType', 'any');
            
            for i = 1:size(kernels, 1)
                convToPoolBlock = obj.createConvToPoolBlock(kernels(i, :));
                blockSet(i) = convToPoolBlock;
            end
            
           out = blockSet;
        end
        
        % --- common configuration
        function initConvToPoolBlockSets(obj)
            obj.convToPoolBlockSets = containers.Map('KeyType', 'double', 'ValueType', 'any');
            
            obj.convToPoolBlockSets(1) = obj.createConvToPoolBlockSet([1 1 1 1]);
            obj.convToPoolBlockSets(2) = obj.createConvToPoolBlockSet(...
                [1.0 0.9 1.0 1.1; 0.5 0.6 1.2 1.3; 1.0 1.8 0.4 0.9]...
            );
        end
        
    end
end

