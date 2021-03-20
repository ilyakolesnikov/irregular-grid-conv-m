classdef SimplexConvLayer < handle
    properties
        LMST
        simplexList
        kernel
        kernelSize = 4
        inputFeatures
        outputFeatures
        nodesMap
        nodeX
        nodeY
        deltaErrors
    end
    methods
        out = simplexAngles(obj, simplexIndex);
        out = getSideSimplexesIds(obj, simplexIndex);

        function obj = SimplexConvLayer(inKernel)
            obj.nodesMap = containers.Map('KeyType', 'double', 'ValueType', 'any');
            obj.kernel = inKernel;
            
        end
        
        function out = prepareInputFeatures(obj, inNodeX, inNodeY, inSimplexList, inLMST)
            obj.simplexList = inSimplexList;
            obj.nodeX = inNodeX;
            obj.nodeY = inNodeY;
            obj.LMST = inLMST;
            features = zeros(length(inSimplexList), 4);
            %maxDiv = 
 
            for i = 1:length(inSimplexList)
                angles = obj.simplexAngles(i);
                simplexDiv = sum(obj.LMST(:, i));
                
                features(i, :) = [simplexDiv angles.'];
            end
            
            maxDiv = max(features(:, 1));
            
            for i = 1:length(inSimplexList)
                features(i, 1) = features(i, 1) / maxDiv;
            end
            
            out = features;
        end

        function out = forward(obj, inNodeX, inNodeY, inSimplexList, inFeatures)
            obj.simplexList = inSimplexList;
            obj.nodeX = inNodeX;
            obj.nodeY = inNodeY;
            obj.inputFeatures = inFeatures;
            obj.outputFeatures = zeros(length(inFeatures), 4);
            
            obj.initNodesMap();

            for i = 1:size(obj.simplexList, 1)
                obj.forwardBySimplex(i);
            end
            
            out = obj.outputFeatures;
            % - перед пулом сделать poslin - это ReLU активаци€
        end

        function forwardBySimplex(obj, simplexIndex)
            sideSimplexes = obj.getSideSimplexesIds(simplexIndex);
            simplexIds = [simplexIndex sideSimplexes];
            inputFeaturesList = zeros(4, 4);
            reduced = zeros(1, 4);
            
            for i = 1:length(simplexIds)
                simplexId = simplexIds(i);
                inputFeaturesList(i, :) = obj.getFeaturesToSimplex(simplexId);
            end

            for i = 1:size(inputFeaturesList, 1)
                reduced(i) = obj.simplexConvLocal(inputFeaturesList(:, i).', false);
            end
                            
            obj.outputFeatures(simplexIndex, :) = reduced;
        end
        
        function out = backward(obj, inDeltaErrors, learnRate)
            newDeltaErrors = zeros(size(inDeltaErrors));
            obj.deltaErrors = inDeltaErrors;
            meanError = 0;
            
            for i = 1:length(obj.simplexList)
                newDeltaErrors(i, :) = obj.backwardBySimplex(i);
            end
            
            for i = 1:size(obj.inDeltaErrors, 1)
                meanError = meanError + mean(obj.inDeltaErrors(i, :));
            end
            
            meanError = meanError / size(obj.inDeltaErrors, 1);
            sideSimplexes = obj.getSideSimplexesIds(1);
            simplexIds = [1 sideSimplexes];
            inputFeaturesList = zeros(4, 4);
            
            for i = 1:simplexIds(sideSimplexes)
                features = obj.getFeaturesToSimplex(i);
                featureVal = features(1);
                weightDelta = meanError * featureVal * learnRate;
                kernel(i) = kernel(i) + weightDelta;
            end
            
            out = newDeltaErrors;
            % - Ќадо обновить deltaMap
        end
        
        function out = backwardBySimplex(obj, simplexIndex)
            sideSimplexes = obj.getSideSimplexesIds(simplexIndex);
            simplexIds = [simplexIndex sideSimplexes];
            deltaFeaturesList = zeros(4, 4);
            reduced = zeros(1, 4);
            
            for i = 1:length(simplexIds)
                simplexId = simplexIds(i);
                deltaFeaturesList(i, :) = obj.deltaErrors(simplexId, :);
            end

            for i = 1:size(deltaFeaturesList, 1)
                reduced(i) = obj.simplexConvLocal(deltaFeaturesList(:, i).', true);
            end
            
            out = reduced;
        end
        
        function out = getFeaturesToSimplex(obj, simplexIndex)
            availableFeatures = obj.inputFeatures(simplexIndex, :);
            allFeatures = zeros(1, 4);
            
            for i = 1:length(allFeatures)
                allFeatures(i) = availableFeatures(i);
            end

            out = allFeatures;
            %out = [simplexDiv angles.'];
        end

        % inputFeatures - one-parameter features list for each side-simplex
        function out = simplexConvLocal(obj, inputFeatures, isInverted)
            convSum = 0;
            kernel = obj.kernel;
            
            if (isInverted)
                kernel = flip(kernel);
            end
            
            convSum = sum(inputFeatures.*kernel);
            out = convSum;
        end

        function initKernel(obj)
            obj.kernel = [1 2 3 4];
        end

        % create map with link "nodeIndex -> [simplexIndex1, ...]"
        function initNodesMap(obj)
            obj.nodesMap = [];
            obj.nodesMap = containers.Map('KeyType', 'double', 'ValueType', 'any');
            
            for i = 1:length(obj.simplexList)
                simplexNodes = obj.simplexList(i, :);

                for j = 1:length(simplexNodes)
                    currentNodeIdx = simplexNodes(j);
                    hasSimplex = obj.nodesMap.isKey(currentNodeIdx);
        
                    if (hasSimplex)
                        currentNodeSimplexes = obj.nodesMap(currentNodeIdx);
                        obj.nodesMap(currentNodeIdx) = [currentNodeSimplexes i];
                    else
                        obj.nodesMap(currentNodeIdx) = [i];
                    end
                end
            end
            
        end

        function out = getDuplicateIds(obj, ids)
            [ii, jj, kk] = unique(ids);
            out = ii(histc(kk, 1:numel(ii)) > 1);
        end
        
        function out = getNodesMap(obj)
            out = obj.nodesMap;
        end
   end
end