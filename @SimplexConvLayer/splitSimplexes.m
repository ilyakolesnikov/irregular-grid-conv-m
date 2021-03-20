function out = splitSimplexes(obj)
    % - разделить все симплексы по две пары
    % - как именно?
    simplexesCount = size(obj.simplexList, 1);
    processedSimplexes = [];
    firstPair = [];
    secondPair = [];
    pairTuples = [];
 
    for i = 1:simplexesCount
        if (any(ismember(processedSimplexes, i)))
            continue;
        end
                
        processedSimplexes = [processedSimplexes i];
        sideSimplexes = setdiff(obj.getSideSimplexesIds(i), processedSimplexes);
        
        if (isempty(sideSimplexes))
            continue;
        end
        
        firstSideSimplex = sideSimplexes(1);        
        firstPair = [i firstSideSimplex];
        processedSimplexes = [processedSimplexes firstSideSimplex];        
        nextSideSimpexes = setdiff(obj.getSideSimplexesIds(firstSideSimplex), processedSimplexes);
        
        if (isempty(nextSideSimpexes))
            continue;
        end
        
        nextSideSimplex = nextSideSimpexes(1);
        processedSimplexes = [processedSimplexes nextSideSimplex];
        lastSideSimplexes = setdiff(obj.getSideSimplexesIds(nextSideSimplex), processedSimplexes);
        
        if (isempty(lastSideSimplexes))
            continue;
        end
        
        lastSideSimplex = lastSideSimplexes(1);
        secondPair = [nextSideSimplex lastSideSimplex];
        processedSimplexes = [processedSimplexes lastSideSimplex];
        
        pairTuples = [pairTuples; [firstPair secondPair]];
        firstPair = [];
        secondPair = [];
    end

    out = pairTuples;
end