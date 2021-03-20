function out = buildcnn(LMST, simplexList, nodeX, nodeY)
    convLayer = SimplexConvLayer(LMST, simplexList, nodeX, nodeY);
    features = convLayer.forward();
    nodesMap = convLayer.getNodesMap();
 
    poolLayer = SimplexPoolLayer(simplexList, nodesMap, nodeX, nodeY);
    featuresAfterPool = poolLayer.forward(features);
end