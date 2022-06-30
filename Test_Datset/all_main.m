clc
clear all
close all
tic;
Originaldata=xlsread('Dataset.xlsx');
X=xlsread('ICEEMDAN-Dataset.xlsx');
L1=length(X(1,:));
    for bb=1:L1
        [XR,eLag,eDim] = phaseSpaceReconstruction(X(:,bb));
        globalparams=op_CCOA(X(:,bb),eLag,eDim);
        inSize   = 1;
        outSize  = 1;
        l1=length(X(:,bb));
        param=globalparams;
        param1=param(1:5*eDim);
        param1=reshape(param1,5,[]);
        param2=param(5*eDim+1);
        for i=1:eDim
            StackedESN{i}.ID=i;
            if i==1||i==eDim
                StackedESN{i}.inSize=inSize;
                StackedESN{i}.outSize=outSize;
                StackedESN{i}.IS = param1(1,i);     
                StackedESN{i}.radius = param1(2,i);  
                StackedESN{i}.a = param1(3,i);      
                StackedESN{i}.resSize = param1(4,i); 
                StackedESN{i}.degree = param1(5,i);  
                StackedESN{i}.resSize = round(StackedESN{i}.resSize);
                StackedESN{i}.InternalState= zeros(StackedESN{i}.resSize,l1);
            else
                StackedESN{i}.inSize=StackedESN{i-1}.resSize;
                StackedESN{i}.outSize=outSize;
                StackedESN{i}.IS = param1(1,i);     
                StackedESN{i}.radius = param1(2,i);  
                StackedESN{i}.a = param1(3,i);       
                StackedESN{i}.resSize = param1(4,i); 
                StackedESN{i}.degree = param1(5,i);  
                StackedESN{i}.resSize = round(StackedESN{i}.resSize);
                StackedESN{i}.InternalState= zeros(StackedESN{i}.resSize,l1);
            end
            StackedESN{i}=BuildSingleReservoir(StackedESN{i});
        end
        [Prediction_Y1,Errordata,n1]=TrainTestStackedESN(X(:,bb),StackedESN,eLag,eDim,param2);
        Prediction_Y2=Error_TrainTestStackedESN(Errordata,StackedESN,eDim,n1);
        predicationY1=Prediction_Y1((1000-n1-400):end-1);
        PREDICTION=predicationY1+Prediction_Y2;
        B3=PREDICTION;
        B1=X(601:end-1,bb);
        X1 = B1(1:200);
        X2 = B3(1:200);
        Y1 = B1(201:end);
        Y2 = B3(201:end);
        subprediction(:,bb)=Y2;
        RMSE_test = sqrt(mean((X1-X2).^2));
        RMSE_prediction = sqrt(mean((Y1-Y2).^2));
        x = Y1;
        y = Y2;
        RMSE = sqrt(mean((y-x).^2));
        mae=sum(abs(x-y))/size(x,1);
        mape=sum(abs((x-y)./x))/size(x,1);
        p = polyfit(x,y,1);
        f = polyval(p,x);
        [r2, rmse] = rsquare(y,f);
        biaoge(1,bb)=mae;
        biaoge(2,bb)=mape;
        biaoge(3,bb)=RMSE;
        biaoge(4,bb)=r2;
        PP(:,bb)=y;
    end
    PPP=sum(PP,2);
    x1=Originaldata(601:end-1);
    x1=x1(201:end);
    y1=PPP;
    RMSE1 = sqrt(mean((y1-x1).^2));
    mae1=sum(abs(x1-y1))/size(x1,1);
    mape1=100*sum(abs((x1-y1)./x1))/size(x1,1);
    p1 = polyfit(x1,y1,1);
    f1 = polyval(p1,x1);
    [r21, rmse1] = rsquare(y1,f1);
    disp( ['mae = ', num2str( mae1 )] );
    disp( ['mape = ', num2str( mape1 )]);
    disp( ['RMSE = ', num2str( RMSE1 )] );
    disp( ['r2 = ', num2str( r21 )] );
    toc;