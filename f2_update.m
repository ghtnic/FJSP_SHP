function [OScode,MScode]=f2_update(pb_j,OScode,MScode,operationCode,MM,c1,workpieceNum,machineNum,ProcessTime,AdjustmentTime,HandlingTime)
% OScode=[21 22 31 22	21 31 11 11 21 22];
% proIndex=[1 1 1 2 2 2 1	2 3 3];
% IndexNum=[3 6 9 7 4 10 1 2 5 8];
% MScode=[3 3 2 1	5 1	1 5	3 1];
% pb_j{1,1}=[11 21 22 31 11 22 31 21 22 21];
% pb_j{4,1}=[2 5 3 5 5 1 3 4 1 1];
% c1=0.8;
L=numel(OScode);
particleLong=L;
%% f2算子交叉 得到O1、O2
if rand()<c1
    point=randi(numel(MM(1,:))-1);  %随机划分工件切割点
    s11=MM(1,1:point);             %s11划分的工件
    s12=MM(1,point+1:end);         %s12划分的工件
    a_s11_index=[];  %P中需要待备份的索引
    b_s11_index=[];  %P中需要待插入的索引
    for i=1:numel(s11)      %s11划分的工件分别在P、Pb中的位置索引
        a=find(s11(i)==OScode);
        b=find(s11(i)==pb_j{1,1});
        a_s11_index=[a_s11_index a];
        b_s11_index=[b_s11_index b];
    end
    a_s12_index=[]; %Pb中需要待备份的索引
    b_s12_index=[]; %Pb中需要待插入的索引
    for i=1:numel(s12)    %s12划分的工件分别在P、Pb中的位置索引
        a=find(s12(i)==OScode);
        b=find(s12(i)==pb_j{1,1});
        a_s12_index=[a_s12_index a];
        b_s12_index=[b_s12_index b];
    end
    %排序处理
    a_s11_index=sort(a_s11_index);
    a_s12_index=sort(a_s12_index);
    b_s11_index=sort(b_s11_index);
    b_s12_index=sort(b_s12_index);
    OScode1=zeros(1,L);
    OScode2=zeros(1,L);
    MScode1=zeros(1,L);
    MScode2=zeros(1,L);
    %根据a_s11_index索引  备份到O1
    for i=1:numel(a_s11_index) 
        OScode1(a_s11_index(i))=OScode(a_s11_index(i));
        MScode1(a_s11_index(i))=MScode(a_s11_index(i));
    end
        %根据a_s12_index索引  将b_s12_index内容插入到O1中
    for i=1:numel(a_s12_index) 
        OScode1(a_s12_index(i))=pb_j{1,1}(b_s12_index(i));
        MScode1(a_s12_index(i))=pb_j{4,1}(b_s12_index(i));
    end

    %根据b_s12_index索引  备份到O1
    for i=1:numel(b_s12_index) 
        OScode2(b_s12_index(i))=pb_j{1,1}(b_s12_index(i));
        MScode2(b_s12_index(i))=pb_j{4,1}(b_s12_index(i));
    end
        %根据b_s11_index索引  将a_s11_index内容插入到O1中
    for i=1:numel(b_s11_index) 
        OScode2(b_s11_index(i))=OScode(a_s11_index(i));
        MScode2(b_s11_index(i))=MScode(a_s11_index(i));
    end

    %% 得到O1粒子的OMProcessTime,OMAdjuctTime,OMTransTime 机器加工工序集合
    for j=1:particleLong
        %得到工件对应工序的下标即出现次数proIndex
        proIndex1(1,j)=numel(find(OScode1(1,j)==OScode1(1,1:j)));
        %得到工件对应工序和出现次数 对应初始OS中的序号IndexNum
        OS_Num=find(OScode1(1,j)==operationCode);
        IndexNum1(1,j)=OS_Num(proIndex1(1,j));
    end
    [proOScode1,machin_Op1,OMProcessTime1,OMAdjuctTime1,OMTransTime1]=getOM_ATtime(MM,OScode1,proIndex1,IndexNum1,particleLong,MScode1,workpieceNum,machineNum,ProcessTime,AdjustmentTime,HandlingTime);
    [obj1]=fitness(proOScode1,machin_Op1,particleLong,machineNum,OMProcessTime1,OMAdjuctTime1,OMTransTime1);
    %得到O2粒子的OMProcessTime,OMAdjuctTime,OMTransTime 机器加工工序集合
    for j=1:particleLong
        %得到工件对应工序的下标即出现次数proIndex
        proIndex2(1,j)=numel(find(OScode2(1,j)==OScode2(1,1:j)));
        %得到工件对应工序和出现次数 对应初始OS中的序号IndexNum
        OS_Num=find(OScode2(1,j)==operationCode);
        IndexNum2(1,j)=OS_Num(proIndex2(1,j));
    end
    [proOScode2,machin_Op2,OMProcessTime2,OMAdjuctTime2,OMTransTime2]=getOM_ATtime(MM,OScode2,proIndex2,IndexNum2,particleLong,MScode2,workpieceNum,machineNum,ProcessTime,AdjustmentTime,HandlingTime);
    [obj2]=fitness(proOScode2,machin_Op2,particleLong,machineNum,OMProcessTime2,OMAdjuctTime2,OMTransTime2);
    %% 比较O1和O2适应度函数值
    if obj1(1)>obj2(1) %优先完工时间适应度大的
        L=0;
    elseif obj1(1)==obj2(1) %完工时间适应度一样
        if obj1(2)>obj2(2) %优先调整次数适应度大的
            L=0;
        elseif obj1(2)==obj2(2) %优先调整次数适应度大的
            if obj1(3)>obj2(3) %优先搬运次数适应度大的
                L=0;
            elseif obj1(3)==obj2(3)
                if obj1(4)>obj2(4) %优先加工负荷适应度大的
                    L=0;
                else
                    L=1;
                end
            else
                L=1;
            end
        else
            L=1;
        end
    else
        L=1;
    end
    if L==0
        OScode=OScode1;
        proIndex=proIndex1;
        IndexNum=IndexNum1;
        MScode=MScode1;
    else
        OScode=OScode2;
        proIndex=proIndex2;
        IndexNum=IndexNum2;
        MScode=MScode2;
    end
end
