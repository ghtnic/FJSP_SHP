function [OScode,MScode]=f3_update(gbest_particle,OScode,MScode,operationCode,MM,machine,c2,workpieceNum,machineNum,ProcessTime,AdjustmentTime,HandlingTime,particleLong)
if rand()<c2
    gb_j=cell(4,1);
    for i=1:4
        gb_j{i,:}=gbest_particle(i,:);
    end
    c0=2;
    [OScode,MScode]=f2_update(gb_j,OScode,MScode,operationCode,MM,c0,workpieceNum,machineNum,ProcessTime,AdjustmentTime,HandlingTime);
    proIndex=zeros(1,particleLong);
    IndexNum=zeros(1,particleLong);
    for j=1:particleLong
       %得到工件对应工序的下标即出现次数proIndex
       proIndex(1,j)=numel(find(OScode(1,j)==OScode(1,1:j)));
       %得到工件对应工序和出现次数 对应初始OS中的序号IndexNum
       OS_Num=find(OScode(1,j)==operationCode);
       IndexNum(1,j)=OS_Num(proIndex(1,j));
    end
    pos=randperm(particleLong,1);
    selectMchLong=length(machine{IndexNum(pos)});
    MScode(pos)=machine{IndexNum(pos),1}(randperm(selectMchLong,1));
end
