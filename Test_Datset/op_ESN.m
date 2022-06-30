function [mae] = op_ESN(param,data,eLag,eDim)
inSize   = 1;
outSize  = 1;
l1=length(data);
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
    StackedESN{i}=op_BuildSingleReservoir(StackedESN{i});
end
[Prediction_Y1,Errordata,n1]=op_TrainTestStackedESN(data,StackedESN,eLag,eDim,param2);
Prediction_Y2=op_Error_TrainTestStackedESN(Errordata,StackedESN,eDim,n1);
predicationY1=Prediction_Y1((1000-n1-400):end-1);
PREDICTION=predicationY1+Prediction_Y2;
B3=PREDICTION;
B1=data(601:end-1);
X1 = B1(1:200);
X2 = B3(1:200);
Y1 = B1(201:end);
Y2 = B3(201:end);
RMSE_test = sqrt(mean((X1-X2).^2));
RMSE_prediction = sqrt(mean((Y1-Y2).^2));
x = X1;
y = X2;
mae=sum(abs(x-y))/size(x,1);
RMSE = sqrt(mean((x-y).^2));
disp( ['RMSE_test = ', num2str( RMSE_test )] );
disp( ['RMSE_prediction ', num2str(RMSE_prediction )] );
disp( ['mae = ', num2str( mae )] );
end