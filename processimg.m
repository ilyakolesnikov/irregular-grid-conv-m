function [LMST, T, nodeX, nodeY] = processimg(imageData)
    [nodeX, nodeY, T] = createmesh(imageData);
    LMST = calcLMST(nodeX, nodeY, T, imageData);
end

