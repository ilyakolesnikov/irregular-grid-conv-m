function out = splitSimplexes(obj)
    % - разделить все симплексы по две пары
    % - как именно?
    simplexesCount = size(obj.simplexList, 1);
    obj.processedSimplexes = [];
    currentPair = [];
    pairs = [];
    
%     firstPair = [];
%     secondPair = [];
%     pairTuples = [];
    
    for i = 1:simplexesCount
        currentPair = [];
        isProcessed = any(ismember(obj.processedSimplexes, i));
 
        if (isProcessed || ~obj.isCenterSimplex(i))
            continue;
        end

        obj.processedSimplexes = [obj.processedSimplexes i];
        firstSideSimplexId = obj.getPairSimplex(i);
        
        if (~firstSideSimplexId)
            obj.processedSimplexes(obj.processedSimplexes == i) = [];
            continue;
        end
           
        currentPair = [i firstSideSimplexId];
        obj.processedSimplexes = [obj.processedSimplexes firstSideSimplexId];

        pairs = [pairs; currentPair]; 
    end

    out = pairs;
end