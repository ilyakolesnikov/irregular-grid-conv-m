classdef GlobalPoolLayer < handle
    properties
        simplexFeatures
        maxValuesIndexes
    end
    
    methods
        function obj = GlobalPoolLayer()
        end
        
        function out = forward(obj, inputSimplexFeatures)
            obj.simplexFeatures = inputSimplexFeatures;
            featuresCount = size(obj.simplexFeatures, 2);
            maxValues = zeros(1, featuresCount);
            maxIndexes = zeros(1, featuresCount);
            
            for i = 1:featuresCount
                [maxValue, valueIndex] = max(obj.simplexFeatures(:, i));
                maxValues(i) = maxValue;
                maxIndexes(i) = valueIndex;
            end
            
            obj.maxValuesIndexes = maxIndexes;
            
            out = maxValues;
        end
        
        function out = backward(obj, deltaErrors)         
            featuresShape = size(obj.simplexFeatures);
            errorsOut = zeros(featuresShape);
            
            for i = 1:featuresShape(2)
                error = deltaErrors(i);
                errorIdx = obj.maxValuesIndexes(i);
                errorsOut(i, errorIdx) = error;
            end
            
            out = errorsOut;
        end
        
    end
end