
function [OScode,proIndex,IndexNum,MScode]=initialization(operationCode,particleNum,particleLong,machine,ProcessTime)
% operationCode=[11 11 21 21 21 22 22 22 31 31];
% particle=[1 2 3 4 5 6 7 8 9 10];

%%         工序码随机选择生产            %%%%
%%    工序OScode、工序出现次数proIndex、对应初始OS中的序号IndexNum是一一对应的
%粒子OScode初始0矩阵
OScode=zeros(particleNum,particleLong);

for i=1:particleNum
    OScode(i,:)=operationCode(randperm(particleLong)); %粒子OScode随机初始化矩阵50x10；
end

%粒子OScode对应初始OS中的序号IndexNum是一一对应的
IndexNum=zeros(particleNum,particleLong); 
%粒子OScode工序出现次数proIndex
proIndex=zeros(particleNum,particleLong); 
for i=1:particleNum
    for j=1:particleLong
        %得到工件对应工序的下标即出现次数proIndex
        proIndex(i,j)=numel(find(OScode(i,j)==OScode(i,1:j)));
        %得到工件对应工序和出现次数 对应初始OS中的序号IndexNum
        OS_Num=find(OScode(i,j)==operationCode);
        IndexNum(i,j)=OS_Num(proIndex(i,j));
    end
end

%%   机器码混合初始化  60%随机选择 40%选择加工时间最小的机器     %%%%
selectNum1=0.3;
MScode=zeros(particleNum,particleLong);

%%%  粒子MScode随机初始化矩阵30x10；%%%
for i=1:particleNum*selectNum1
    for j=1:particleLong %遍历OS向量
        Opq=IndexNum(i,j); %获取当前工序对应初始OS中的序号IndexNum
        selectMchLong=length(machine{Opq});
        MScode(i,j)=machine{Opq}(randperm(selectMchLong,1));
    end
end               
%%%  粒子MScode选择加工时间最小的机器初始化矩阵20x10；%%%
for i=particleNum*selectNum1+1:particleNum
    for j=1:particleLong %遍历OS向量
        Opq=IndexNum(i,j); %获取当前工序的编码
        shortestTime=min(ProcessTime(Opq,:));
        shortTimeIndex=find(ProcessTime(Opq,:)==shortestTime);
        MScode(i,j)=shortTimeIndex(randperm(length(shortTimeIndex),1));
    end
end
