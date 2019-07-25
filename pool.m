% param LMST - [ [Q1, Q2, ... ], [P1, ... ], [R1, ... ] ]
% param triangles - [ [node1, node2, node3], ... ]
% param nodes - [ [x1, y1], ... ]
% return [ node1, node2, ... ]
function res = pool(LMST, triangles, nodes)
    Xmax = max(nodes(:, 1));
    Xmin = min(nodes(:, 1));
    Ymax = max(nodes(:, 2));
    Ymin = min(nodes(:, 2));
    
    function isBorder = isBorderPoint(node)
        isBorderX = (node(1) == Xmax | node(1) == Xmin);
        isBorderY = (node(2) == Ymax | node(2) == Ymin);
        
        isBorder = isBorderX | isBorderY;
    end

    PASS_RATE = 0.58;

    len = length(nodes);
    div = zeros(len, 1);
    
    for i = 1:len
        div(i) = pointdiv(i, LMST, triangles);
    end
    
    res = [];
    divMin = min(div);
    divMax = max(div);
    diff = divMax - divMin;
    treshold = divMax - diff * PASS_RATE;
 
    for i = 1:len
        node = nodes(i, :);
        
        if (isBorderPoint(node) || div(i) > treshold)
            res = [res i];
        end
    end
end