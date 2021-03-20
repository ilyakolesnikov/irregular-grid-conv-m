function [nodeX, nodeY, T] = createmesh(imageData)
    pic_in=imageData;
    %imshow(pic_in);
    size_in=size(pic_in);
    height_in=size_in(1);
    width_in=size_in(2);
    diff=zeros(height_in,width_in,'int8');
    % differential signal
    for i=2:height_in-1
        for j=2:width_in-1
            diff(i,j) = pic_in(i,j)-pic_in(i+1,j)/4-pic_in(i,j+1)/4-pic_in(i-1,j)/4-pic_in(i,j-1)/4;
        end
    end
    % figure;
    % hold on;
    % colormap('gray');
    % imshow(diff);

    % crossmark points
    crossmarksHH=zeros(height_in,width_in,'int8');
    crossmarksVV=crossmarksHH;
    crossmarksVH=crossmarksHH;
    crossmarksHV=crossmarksHH;

    for i=3:height_in-2
        for j=3:width_in-2
            if abs(diff(i,j))>1
                crossmarksHH(i,j)=(diff(i-2,j)+diff(i-1,j)+diff(i-2,j-1)+diff(i-2,j+1))-(diff(i+2,j)+diff(i+1,j)+diff(i+2,j-1)+diff(i+2,j+1));
                crossmarksVV(i,j)=(diff(i,j-2)+diff(i,j-1)+diff(i-1,j-2)+diff(i+1,j-2))-(diff(i,j+2)+diff(i,j+1)+diff(i-1,j+2)+diff(i+1,j+2));
                crossmarksHV(i,j)=(diff(i-2,j-2)+diff(i-1,j-1)+diff(i-2,j-1)+diff(i-1,j-2))-(diff(i+2,j+2)+diff(i+1,j+1)+diff(i+2,j+1)+diff(i+1,j+2));
                crossmarksVH(i,j)=(diff(i+2,j-2)+diff(i+1,j-1)+diff(i+2,j-1)+diff(i+1,j-2))-(diff(i-2,j+2)+diff(i+1,j+1)+diff(i-2,j+1)+diff(i-1,j+2));

            end;
        end;
    end;

    %saturated_crossmarks=zeros(height_in,width_in);
    crossmarks=zeros(height_in,width_in);
    average_crossmarks=zeros(height_in,width_in);
    %average_crossmark=(sum(sum(abs(crossmarksHH)))+sum(sum(abs(crossmarksHV)))+sum(sum(abs(crossmarksVH)))+sum(sum(abs(crossmarksVV))))/width_in/height_in;
    % for i=3:height_in-2
    %     for j=3:width_in-2
    %        if (abs(crossmarksHH(i,j))+abs(crossmarksHH(i,j))+abs(crossmarksHH(i,j))+abs(crossmarksHH(i,j)))>3*average_crossmark
    %             saturated_crossmarks(i,j)=127;
    %        end;
    %     end;
    % end;
    crossmarks=double((abs(crossmarksHH)+abs(crossmarksVH)+abs(crossmarksHV)+abs(crossmarksVV))/4);
    %figure;
    %hold on;
    %colormap('gray');
    %imshow(uint8(crossmarks));

    filter=[0 0 0 1 0 0 0; 0 0 1 1 1 0 0; 0 1 1 1 1 1 0; 1 1 1 1 1 1 1; 0 1 1 1 1 1 0; 0 0 1 1 1 0 0; 0 0 0 1 0 0 0];
    filter=filter/49;
    average_crossmarks=conv2(crossmarks,filter,'same');

    %figure;
    %hold on;
    %colormap('gray');
    %imshow(uint8(average_crossmarks));
    average_crossmark=mean(mean(average_crossmarks));
    nodes=0;
    for i=3:height_in-2
        for j=3:width_in-2
           if average_crossmarks(i,j)>4*average_crossmark
               % check if it is maximum
               Axy=average_crossmarks(i,j);
               if (Axy>average_crossmarks(i+1,j))&&(Axy>average_crossmarks(i,j+1))&&(Axy>average_crossmarks(i-1,j))&&(Axy>average_crossmarks(i,j-1))&&(Axy>average_crossmarks(i+1,j+1))&&(Axy>average_crossmarks(i-1,j+1))&&(Axy>average_crossmarks(i-1,j-1))&&(Axy>average_crossmarks(i+1,j-1))
                   nodes=nodes+1;
                   nodeX(nodes) = i;
                   nodeY(nodes) = j;
               end;
           end;
        end;
    end;
    %add boundary nodes
    for i=31:32:width_in-32
        nodes=nodes+1;
        nodeX(nodes)=1;
        nodeY(nodes)=i;
        nodes=nodes+1;
        nodeX(nodes)=height_in;
        nodeY(nodes)=i;
    end;
    for j=31:32:height_in-32
        nodes=nodes+1;
        nodeX(nodes)=j;
        nodeY(nodes)=1;
        nodes=nodes+1;
        nodeX(nodes)=j;
        nodeY(nodes)=width_in;
    end;
    nodes=nodes+1;
    nodeX(nodes)=height_in;
    nodeY(nodes)=width_in;
    nodes=nodes+1;
    nodeX(nodes)=1;
    nodeY(nodes)=width_in;
    nodes=nodes+1;
    nodeX(nodes)=height_in;
    nodeY(nodes)=1;
    nodes=nodes+1;
    nodeX(nodes)=1;
    nodeY(nodes)=1;

    % = unique(A)

    %plot nodes
    %figure;
    %hold on;
    %plot(nodeX,nodeY,'bx');

    %form triangles
    T=delaunay(nodeX,nodeY);
    %display(size(T));
    %figure;
    %hold on;
    %triplot(T,nodeX,nodeY);
    %refine mesh
    ttt=size(T);
    tri=ttt(1);
    add_nodes=0;
    for k=1:tri
        xA=nodeX(T(k,1));
        yA=nodeY(T(k,1));
        xB=nodeX(T(k,2));
        yB=nodeY(T(k,2));
        xC=nodeX(T(k,3));
        yC=nodeY(T(k,3));
        AB=(xA-xB)*(xA-xB)+(yA-yB)*(yA-yB);
        AC=(xA-xC)*(xA-xC)+(yA-yC)*(yA-yC);    
        BC=(xC-xB)*(xC-xB)+(yC-yB)*(yC-yB);    
        a=AB/AC;
        b=AB/BC;
        c=AC/BC;
        if ((a>5)||(a<0.2)||(b>5)||(b<0.2)||(c>5)||(c<0.2))&&(AB>25)&&(BC>25)&&(AC>25)
            nodes=nodes+1;
            add_nodes=add_nodes+1;
            nodeX(nodes)=round((xA+xB+xC)/3);
            nodeY(nodes)=round((yA+yB+yC)/3);
        end;
    end;
    %display(add_nodes);

    %plot nodes

    %figure;
    %hold on;
    %plot(nodeX,nodeY,'bx');

    %form triangles
    T=delaunay(nodeX,nodeY);
end

