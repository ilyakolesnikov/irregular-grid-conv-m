classdef FullConnectionLayer < handle  
    properties
        inputsCount
        neuronsCount
        weights
        cachedInputs
    end
    
    methods
        function obj = FullConnectionLayer(inInputsCount, inNeuronsCount, testWeights)
            obj.inputsCount = inInputsCount;
            obj.neuronsCount = inNeuronsCount;
            obj.weights = testWeights;
           
        end
        
        function out = forward(obj, inputFeatures)
            obj.cachedInputs = inputFeatures;
            outputFeatures = zeros(1, obj.neuronsCount);
            
            for i = 1:obj.neuronsCount
                rawOut = sum(inputFeatures .* obj.weights(i, :));
                outputFeatures(i) = obj.activation(rawOut);
            end
            
            out = outputFeatures;
        end
        
        function out = backward(obj, deltaErrors, learnRate)
            newDeltaErrors = zeros(1, obj.inputsCount);
            newWeights = zeros(size(obj.weights));
            
            for i = 1:obj.inputsCount
                localWeights = obj.weights(:, i).';
                newDeltaErrors(i) = sum(deltaErrors .* localWeights);
                
                for j = 1:size(obj.weights, 1)
                    newWeights(j, i) = newWeights(j, i) + deltaErrors(j) * learnRate * obj.cachedInputs(i);
                end
            end
            
            obj.weights = newWeights;            
            out = newDeltaErrors;
        end
        
        function out = activation(obj, val)
            out = val;
        end
    end
end

