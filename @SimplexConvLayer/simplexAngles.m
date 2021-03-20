function out = simplexAngles(obj, simplexIndex)
    nodes = obj.simplexList(simplexIndex, :);
    angles = zeros(3, 1);
    
    for i = 1:length(nodes)
        sideNodeAId = i + 1;
        sideNodeBId = i + 2;

        if (i == length(nodes) - 1)
            sideNodeBId = 1;
        elseif (i == length(nodes))
            sideNodeAId = 1;
            sideNodeBId = 2;
        end
        
        currentNode = nodes(i);
        sideNodeA = nodes(sideNodeAId);
        sideNodeB = nodes(sideNodeBId);
        edgeAVector = [
            obj.nodeX(sideNodeA) - obj.nodeX(currentNode)
            obj.nodeY(sideNodeA) - obj.nodeY(currentNode)
        ];
        edgeBVector = [
            obj.nodeX(sideNodeB) - obj.nodeX(currentNode)
            obj.nodeY(sideNodeB) - obj.nodeY(currentNode)
        ];
      
        dotProduct = edgeAVector(1) * edgeBVector(1) + edgeAVector(2) * edgeBVector(2);
        absProduct = hypot(edgeAVector(1), edgeAVector(2)) * hypot(edgeBVector(1), edgeBVector(2));

        angles(i) = dotProduct / absProduct;
    end
             
    out = angles;
end