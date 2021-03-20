function out = splitSimplexes(obj)
    % - разделить все симплексы по две пары
    % - как именно?
    simplexesCount = size(obj.simplexList, 1);
    obj.processedSimplexes = [];
    firstPair = [];
    secondPair = [];
    pairTuples = [];
    
    for i = 1:simplexesCount
        firstPair = [];
        secondPair = [];
        isProcessed = any(ismember(obj.processedSimplexes, i));
 
        if (isProcessed || ~obj.isCenterSimplex(i))
            continue;
        end

        obj.processedSimplexes = [obj.processedSimplexes i];
        firstSideSimplex = obj.getPairSimplex(i);
        
        if (~firstSideSimplex)
            obj.processedSimplexes(obj.processedSimplexes == i) = [];
            continue;
        end
           
        firstPair = [i firstSideSimplex];
        obj.processedSimplexes = [obj.processedSimplexes firstSideSimplex];
        nextSideSimplex = obj.getPairSimplex(firstSideSimplex);
        
        if (~nextSideSimplex)
            obj.processedSimplexes(obj.processedSimplexes == i) = [];
            obj.processedSimplexes(obj.processedSimplexes == firstSideSimplex) = [];
            continue;
        end

        obj.processedSimplexes = [obj.processedSimplexes nextSideSimplex];
        lastSideSimplex = obj.getPairSimplex(nextSideSimplex);

        if (~lastSideSimplex)
            obj.processedSimplexes(obj.processedSimplexes == i) = [];
            obj.processedSimplexes(obj.processedSimplexes == firstSideSimplex) = [];
            obj.processedSimplexes(obj.processedSimplexes == nextSideSimplex) = [];
            continue;
        end

        secondPair = [nextSideSimplex lastSideSimplex];
        obj.processedSimplexes = [obj.processedSimplexes lastSideSimplex];
        
        pairTuples = [pairTuples; [firstPair secondPair]]; 
    end

    out = pairTuples;
end