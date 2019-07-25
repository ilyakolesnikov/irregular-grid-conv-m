% @param triangles - [ [node_index1, node_index2, node_index3], ... ]
% @param index - number(int)
% @return [node_index1, node_index2, ... ]
function res = edgenodes(triangles, index)
    adjacentTriangles = sidetriangles(triangles, index);
    nodes = [];

    for i = 1:length(adjacentTriangles)
        triangleIndex = adjacentTriangles(i);
        nodes = horzcat(nodes, triangles(triangleIndex, :));
    end

    uniquedNodes = unique(nodes);
    res = uniquedNodes(uniquedNodes ~= index);
end