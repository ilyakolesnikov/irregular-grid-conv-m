classdef SimplexPoolLayer < handle
    properties
        nodeX
        nodeY
        simplexFeatures
        simplexList
        nodesMap
        collapsedSimplexes
        simplexesCollapseMap
        processedSimplexes
    end
    methods
        out = splitSimplexes(obj);
        
        function obj = SimplexPoolLayer()
            obj.nodesMap = containers.Map('KeyType', 'double', 'ValueType', 'any');
        end
        
        function [newNodeX, newNodeY, newSimplexList] = forward(obj, inNodeX, inNodeY, inSimplexList, inSimplexFeatures)
            obj.nodeX = inNodeX;
            obj.nodeY = inNodeY;
            obj.simplexList = inSimplexList;
            obj.simplexFeatures = inSimplexFeatures;
            obj.initNodesMap();
            
            simplexTuples = obj.splitSimplexes();
            
            for i = 1:size(simplexTuples, 1)
                firstPair = simplexTuples(i, 1:2);
                secondPair = simplexTuples(i, 3:4);
                compareResult = obj.comparePairs(firstPair, secondPair);
                
                if (compareResult)
                    obj.collapseSideEdge(secondPair(1), secondPair(2));
                else
                    obj.collapseSideEdge(firstPair(1), firstPair(2));
                end
            end
            
            obj.clearNullSimplexes();
            
            newNodeX = obj.nodeX;
            newNodeY = obj.nodeY;
            newSimplexList = obj.simplexList;
        end
        
        function out = forwardd(obj, inputSimplexFeatures)
            obj.simplexFeatures = inputSimplexFeatures;
        end
        
        function out = backward(obj, simplexDeltaErrors)
            newDeltaErrors = [];
            
            if (~size(obj.simplexesCollapseMap, 1))
                out = simplexDeltaErrors;
            else
                for i = 1:size(simplexDeltaErrors, 1)
                    restoredIndex = obj.simplexesCollapseMap(i);
                    newDeltaErrors(restoredIndex, :) = simplexDeltaErrors(i, :);
                end

                out = newDeltaErrors;
            end
        end
        
        function out = getSideSimplexesIds(obj, simplexIndex)
            nodes = obj.simplexList(simplexIndex, :);
            simplexesByNodes = [];

            for i = 1:length(nodes)
                nodeSimplexes = obj.nodesMap(nodes(i));
                simplexesByNodes = [simplexesByNodes nodeSimplexes];        
            end

            duplicates = obj.getDuplicateIds(simplexesByNodes);
            out = duplicates(duplicates ~= simplexIndex);
        end
        
        % create map with link "nodeIndex -> [simplexIndex1, ...]"
        function initNodesMap(obj)       
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
        
        % returns TRUE if firstPair >= secondPair by features sum
        function out = comparePairs(obj, firstPair, secondPair)
            firstPairFeaturesSum = obj.sumFeaturesForSimplex(firstPair(1)) + obj.sumFeaturesForSimplex(firstPair(2));
            secondPairFeaturesSum = obj.sumFeaturesForSimplex(secondPair(1)) + obj.sumFeaturesForSimplex(secondPair(2));
            
            out = firstPairFeaturesSum >= secondPairFeaturesSum;
        end
        
        function out = sumFeaturesForSimplex(obj, simplexId)
            features = obj.simplexFeatures(simplexId);
            
            out = sum(features);
        end
        
        function collapseSideEdge(obj, simplexA, simplexB)
            simplexANodes = obj.simplexList(simplexA, :);
            simplexBNodes = obj.simplexList(simplexB, :);
            sharedNodes = intersect(simplexANodes, simplexBNodes);
            
            newNodeId = length(obj.nodeX) + 1;
            firstNodePos = [obj.nodeX(sharedNodes(1)) obj.nodeY(sharedNodes(1))];
            secondNodePos = [obj.nodeX(sharedNodes(2)) obj.nodeY(sharedNodes(2))];
            newNodePos = floor(mean([firstNodePos; secondNodePos]));
            obj.nodeX(newNodeId) = newNodePos(1);
            obj.nodeY(newNodeId) = newNodePos(2);
            
            newSimplexList = obj.simplexList;
            obj.simplexesCollapseMap = [];
            
            newSimplexList(newSimplexList == sharedNodes(1)) = newNodeId;
            newSimplexList(newSimplexList == sharedNodes(2)) = newNodeId;
            
            obj.collapsedSimplexes(simplexA) = true;
            obj.collapsedSimplexes(simplexB) = true;
            prevSimplexesCount = size(obj.simplexList, 1);

            % optimize
            for i = 1:prevSimplexesCount
                if (i ~= simplexA && i ~= simplexB)
                    obj.simplexesCollapseMap = [obj.simplexesCollapseMap i];
                    obj.simplexList = obj.simplexList;
                end
            end
          
            newSimplexList(simplexA, :) = [0 0 0];
            newSimplexList(simplexB, :) = [0 0 0];
            
            %if (simplexA > simplexB)
                %newSimplexList(simplexB, :) = [0 0 0];
            %else
                %newSimplexList(simplexB - 1, :) = [0 0 0];
            %end
            
            obj.simplexList = newSimplexList;
        end
        
        function clearNullSimplexes(obj)
            newSimplexList = [];
            
            for i = 1:length(obj.simplexList)
                simplexValue = obj.simplexList(i, :);
                
                if (~isequal(simplexValue, [0 0 0]))
                    newSimplexList = cat(1, newSimplexList, simplexValue);
                end    
            end
            
            obj.simplexList = newSimplexList;
        end
        
        function out = getDuplicateIds(obj, ids)
            [ii, jj, kk] = unique(ids);
            out = ii(histc(kk, 1:numel(ii)) > 1);
        end
        
        function out = isCenterSimplex(obj, simplexId)
            sideSimplexes = obj.getSideSimplexesIds(simplexId);
            sideSimplexesCount = length(sideSimplexes);
            
            out = (sideSimplexesCount == 3);
        end
        
        function out = getCenterSideSimplexesIds(obj, simplexId)
            sideSimplexes = obj.getSideSimplexesIds(simplexId);
            centeredSideSimplexes = [];
            
            for i = 1:length(sideSimplexes)
                simplexId = sideSimplexes(i);
                if (obj.isCenterSimplex(simplexId))
                    centeredSideSimplexes = [centeredSideSimplexes simplexId];
                end
            end
            
            out = centeredSideSimplexes;
        end
        
        function out = getPairSimplex(obj, simplexId)
            centerSideSimplexes = obj.getCenterSideSimplexesIds(simplexId);
            unusedSimplexes = setdiff(centerSideSimplexes, obj.processedSimplexes);
            
            if (isempty(unusedSimplexes))
                out = 0;
            else
                out = unusedSimplexes(1);
            end
        end
    end
end