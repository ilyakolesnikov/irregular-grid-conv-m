###Example

```
filteredPoints = pool(LMST, T, nodes);

newX = arrayfun(@(i) nodeX(i), filteredPoints);
newY = arrayfun(@(i) nodeY(i), filteredPoints); 
newT=delaunay(newX,newY);
figure;
hold on;
triplot(newT,newX,newY);
```