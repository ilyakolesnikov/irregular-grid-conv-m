% @param triangles - [ [node_index1, node_index2, node_index3], ... ]
% @param index - number(int)
% @return [triangle_index1, triangle_index2, ... ]
function res = sidetriangles(triangles, index)
    res = [];

    for i = 1:size(triangles, 1)
        triangleNodes = find(triangles(i, :) == index);
        
        if (~isempty(triangleNodes))
            res = horzcat(res, i);
        end
    end
end