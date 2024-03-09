
function [obj]=fitness(proOScode,machin_Op,particleLong,machineNum,OMProcessTime,OMAdjuctTime,OMTransTime)
% OScode=[22 21 22 22 21 11 11 21 31 31];
% MScode=[4 5 1 3 4 2 4 2 2 1];
% OMProcessTime=[3 3 2 3 2 2 2 2 2 1];
% machin_Op={[2,3,9] [6,10] [1,8] 5 [4,7]};
% OMAdjuctTime=[0 0 0 0 0 0 1 1.5 2 0];
proIndex=proOScode(2,:);
MScode=proOScode(4,:);
BeginSchedule=zeros(1,particleLong);
EndSchedule=zeros(1,particleLong);
%%%%%------------找到当前机器上的 工序的起始时间 时刻表---------------%%%%%%
for i=1:particleLong %仅仅遍历数字1-10
    mk=MScode(i);%找到对应的机器
    mkIndex=find(i==machin_Op{mk});%从机器加工-工序索引集合 找到对应的工序的位置
    if proIndex(i)>1
       pre_i_val=proOScode(3,i)-1;%从原始序列 中找到上一道工序
       pre_i=find(proOScode(3,:)==pre_i_val); %找到当前工序的上一道工序对应索引
    end
    if mkIndex>1
        %找到当前加工工序在机器OP中上一道工序对应的下标
        Mop_pre_i=machin_Op{mk}(mkIndex-1);
    end
    Logical_v1=(mkIndex==1); %判断当前加工的工序 是否为机器加工第一道工序
    Logical_v2=(proIndex(i)==1);%判断当前加工的工序 是否为工件首道工序
    if Logical_v1
       if Logical_v2 %工件、机器首道工序开始加工时间为0
          BeginSchedule(i)=0; 
       else        %机器首道工序 不是工件首道工序 开始加工时间为工件上一道工序的结束时间
           BeginSchedule(i)=EndSchedule(pre_i)+OMTransTime(i);  
       end
    else
        if Logical_v2 %工件首道工序 不是机器首道序 开始加工时间为机器工序排列中的上一道结束时间
           BeginSchedule(i)=EndSchedule(Mop_pre_i)+OMAdjuctTime(i); 
        else
            %不是工件首道工序  不是机器首道序 开始加工时间为上述两者较大的
            BeginSchedule(i)=max(EndSchedule(pre_i)+OMTransTime(i),EndSchedule(Mop_pre_i)+OMAdjuctTime(i));
        end
    end
    EndSchedule(i)=BeginSchedule(i)+OMProcessTime(i);
end

%找到最后一个工序的完工时刻即粒子中最大的结束时刻
makespan=max(EndSchedule);
%搬运工件的总次数
NOC=sum(OMTransTime~=0);
%机器的总停机次数
NOM=zeros(1,machineNum);%记录每个机器的停机次数
for i=1:machineNum
    L=length(machin_Op{i});
    if L==0
        NOM(i)=0;
    else
        if L==1
           NOM(i)=1;
        else
            k=0;
            for j=2:L
                OpqIndex=machin_Op{i}(j);
                if OMAdjuctTime(OpqIndex)>0
                    k=k+1;
                end
            end
            NOM(i)=k+1;
        end 
    end
end
TJ_Num=sum(NOM);
%加工机器的总负荷即加工时间求和
MachineLoad=sum(OMProcessTime);
obj(:,1)=1/makespan;
obj(:,2)=1/TJ_Num;
obj(:,3)=1/NOC;
obj(:,4)=1/MachineLoad;



    
