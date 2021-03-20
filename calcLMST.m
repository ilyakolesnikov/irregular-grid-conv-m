function LMST = calcLMST(nodeX, nodeY, T, imageData)
    pic_in = imageData; %imread(imageSrc);
    size_in = size(pic_in);
    height_in = size_in(1);
    width_in = size_in(2);

    % general suggession - add 0.5 to each nodal coordinate except 1, ones are
    % to be replaced by 0.5

    %LMS coeffs

    %linear approx
    ttt=size(T);
    tri=ttt(1);

    CRC = zeros(3,1);
    CRC(3,1) = 1;
    TRT = zeros(3,3);
    TRT(3,1) = 1;
    TRT(3,2) = 1;
    TRT(3,3) = 1;
    pix_in = zeros(1,tri,'uint16');
    LMST = zeros(3,tri);
    for k=1:tri
        LMSM=zeros(3,3);
        LMSC=zeros(3,1);
        LMS=zeros(3,1);
        xA=nodeX(T(k,1));
        yA=nodeY(T(k,1));
        xB=nodeX(T(k,2));
        yB=nodeY(T(k,2));
        xC=nodeX(T(k,3));
        yC=nodeY(T(k,3));
        Xmin=min([xA xB xC]);
        Ymin=min([yA yB yC]);
        Xmax=max([xA xB xC]);
        Ymax=max([yA yB yC]);
        xA=nodeX(T(k,1))+0.5;
        yA=nodeY(T(k,1))+0.5;
        xB=nodeX(T(k,2))+0.5;
        yB=nodeY(T(k,2))+0.5;
        xC=nodeX(T(k,3))+0.5;
        yC=nodeY(T(k,3))+0.5;

        if xA==1.5
            xA=xA-1;
        end
        if yA==1.5
            yA=yA-1;
        end
        if xB==1.5
            xB=xB-1;
        end
        if yB==1.5
            yB=yB-1;
        end
        if xC==1.5
            xC=xC-1;
        end
        if yC==1.5
            yC=yC-1;
        end

        TRT(1,1)=xA;
        TRT(1,2)=xB;
        TRT(1,3)=xC;
        TRT(2,1)=yA;
        TRT(2,2)=yB;
        TRT(2,3)=yC;
        for x=Xmin:Xmax
            for y=Ymin:Ymax
                CRC(1,1)=x;
                CRC(2,1)=y;
                volC=TRT\CRC;
                if (min(volC)>=-0.001)&&(max(volC)<=1.001) 
                    %inside of triangle
                    LMSM=LMSM+volC*volC';
                    LMSC=LMSC+volC*double(pic_in(x,y));
                    pix_in(k)=pix_in(k)+1;
                end
            end
        end
        if pix_in(k)>3
            LMS=LMSM\LMSC;
            if det(LMSM)<1e-9
                display(strcat('poor LMS for #',num2str(k)));
                LMS=[0; 0; 0];
            end
        end
        if pix_in(k)<4
            xA=nodeX(T(k,1));
            yA=nodeY(T(k,1));
            xB=nodeX(T(k,2));
            yB=nodeY(T(k,2));
            xC=nodeX(T(k,3));
            yC=nodeY(T(k,3));
            LMS(1,1)=double(pic_in(xA,yA));
            LMS(2,1)=double(pic_in(xB,yB));
            LMS(3,1)=double(pic_in(xC,yC));

        end
        LMST(:,k)=LMS;
    end
end

