function [prediction2] = Error_TrainTestStackedESN(Errordata,StackedESN,eDim,n1)
initLen = 0;
trainLen=1000-n1-400-1;
testLen =400;
for t=1:trainLen
    StackedESN{eDim}.in = Errordata(t);
    totalin= StackedESN{eDim}.Win*[1;StackedESN{eDim}.in]+StackedESN{eDim}.Wres* StackedESN{eDim}.InternalState(:,max(t-1,1));
    x=(1-StackedESN{eDim}.a)*StackedESN{eDim}.InternalState(:,max(t-1,1))+StackedESN{eDim}.a*tanh(totalin);
    if t > initLen
        X(:,t-initLen)=[1;Errordata(t);x];     
    end
end
Yt = Errordata(initLen+2:trainLen+1)';
inSize=1;
outSize=1;
reg = 1e-8;  
Wout = ((X*X' + reg*eye(1+inSize+StackedESN{eDim}.resSize)) \ (X*Yt'))'; 
for t=1:testLen-1
    StackedESN{eDim}.in = Errordata(trainLen+t);
    totalin= StackedESN{eDim}.Win*[1;StackedESN{eDim}.in]+StackedESN{eDim}.Wres* StackedESN{eDim}.InternalState(:,trainLen+t-1);
    x=(1-StackedESN{eDim}.a)*StackedESN{eDim}.InternalState(:,trainLen+t-1)+StackedESN{eDim}.a*tanh(totalin);
    y = Wout*[1;Errordata(trainLen+t);x];
    Y(:,t) = y;
end
prediction2=Y';
end
