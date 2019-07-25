% param index - int
% param LMST - [ [Q1, Q2, ... ], [P1, ... ], [R1, ... ] ]
% param triangles - [ [node1, node2, node3], ... ]
% return divergention - double
function res = pointdiv(index, LMST, triangles)
    sideTriangles = sidetriangles(triangles, index);
    coeffs = arrayfun(@(i) sum(LMST(:, i)), sideTriangles);

    res = sum(coeffs);
end