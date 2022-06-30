function [prediction,test_error,n1] = TrainTestStackedESN(data,StackedESN,eLag,eDim,param2)
initLen = 0;
o_data=data;
n=length(data);
n1=param2;
n1=round(n1);
n1=n*n1*0.1;
trainLen=n1;
testLen =n-n1;
X=[];
XX=[];
eDim=eDim-1;
eLag=[eLag;2*eLag;3*eLag;4*eLag];
for t=1:trainLen
    for i=1:eDim
        if i==1
            StackedESN{i}.in = data(t);
            totalin= StackedESN{i}.Win*[1;StackedESN{i}.in]+...
                StackedESN{i}.Wres* StackedESN{i}.InternalState(:,max(t-1,1));
        else
            StackedESN{i}.in=StackedESN{i-1}.InternalState(:,max(t-eLag(i-1,1),1));
            totalin= StackedESN{i}.Win*[1;1*StackedESN{i}.in]+...
                StackedESN{i}.Wres* StackedESN{i}.InternalState(:,max(t-1,1));
        end
        x=(1-StackedESN{i}.a)*StackedESN{i}.InternalState(:,max(t-1,1))+StackedESN{i}.a*tanh(totalin);
        StackedESN{i}.InternalState(:,t)=x;
        if t > initLen
            %StackedESN{i}.X(:,t-initLen) = [1;StackedESN{i}.in;x];
            StackedESN{i}.X(:,t-initLen) = x;
        end   
    end
    C=StackedESN{1}.X;
    for j=2:eDim
        C=[C;StackedESN{j}.X];
    end
    X(:,t-initLen)=[1;data(t);C(:,t)]; 
end
Yt = data(initLen+2:trainLen+1)';
inSize=1;
outSize=1;
resSize=0;
for i=1:eDim
    resSize=resSize+StackedESN{i}.resSize;
end
reg = 1e-8;  
Wout = ((X*X' + reg*eye(1+inSize+resSize)) \ (X*Yt'))'; 


for t=1:testLen-1 
     for i=1:eDim
         if i==1
             StackedESN{i}.in = data(trainLen+t);
             totalin= StackedESN{i}.Win*[1;StackedESN{i}.in]+...
                StackedESN{i}.Wres* StackedESN{i}.InternalState(:,trainLen+t-1);
         else
             StackedESN{i}.in=StackedESN{i-1}.InternalState(:,max(trainLen+t-eLag(i-1,1),n1));
             totalin= StackedESN{i}.Win*[1;1*StackedESN{i}.in]+...
                StackedESN{i}.Wres* StackedESN{i}.InternalState(:,max(trainLen+t-1,n1));
         end
         x=(1-StackedESN{i}.a)*StackedESN{i}.InternalState(:,max(trainLen+t-1,n1))+StackedESN{i}.a*tanh(totalin);
         StackedESN{i}.InternalState(:,trainLen+t)=x;
         StackedESN{i}.XX(:,t-initLen) = x;
     end
     C1=StackedESN{1}.XX;
     for j=2:eDim
        C1=[C1;StackedESN{j}.XX];
     end
     XX(:,t-initLen)=[1;data(trainLen+t);C1(:,t)];
end
Y = zeros(outSize,testLen);
Y=Wout*XX;
prediction=Y';
errorLen = testLen;
B1 = o_data(trainLen+2:trainLen+errorLen);
test_error=B1-prediction;
end