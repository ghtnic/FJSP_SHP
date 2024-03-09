
function [proOScode,machin_Op,OMProcessTime,OMAdjuctTime,OMTransTime]=getOM_ATtime(MM,OScode,proIndex,IndexNum,particleLong,MScode,workpieceNum,machineNum,ProcessTime,AdjustmentTime,HandlingTime)
%%%     每个工件的 由OScode和MScode 生产加工时间矩阵    %%%%
OMProcessTime=zeros(1,particleLong);
for j=1:particleLong %遍历OS、MS向量
    OMProcessTime(1,j)=ProcessTime(IndexNum(1,j),MScode(1,j));
end

%%%%%%%&&&=========每个工件的工序的搬运时间========%%%%%%%%%%%%
transformOS=cell(workpieceNum,1);  %每个工件对应工序集合 初始化
OMTransTime=zeros(1,particleLong);
for i=1:workpieceNum
    transformOS{i}(1,:)=find(MM(1,i)==OScode); %找出每个工件对应工序索引集合
    linT=transformOS{i}(1,:);%找出每个工件对应工序顺序 排列
    for j=1:MM(2,i)   %遍历工件的顺序
        k=linT(j);  %找出每个工件顺序加工工序的下标
        if j==1
            OMTransTime(k)=0;
        else
            OMTransTime(k)=HandlingTime(MScode(linT(j-1)),MScode(k));
        end
    end
end
%%%%%%%&&&=========每个工件的工序的调整时间========%%%%%%%%%%%%
machin_Op=cell(machineNum,1);       %每个机器存放对应要加工的工序工序-下标
for j=1:machineNum
    machin_Op{j}(1,:)=find(j==MScode); %每个机器 存放对应要加工的工序-序号也是
end
OMAdjuctTime=zeros(1,particleLong);
AdjustIndex=machin_Op;  %每个机器存放对应要加工的工序下标
for i=1:machineNum
    L=length(machin_Op{i});
    if L>0
       for j=1:L
           Aindex=AdjustIndex{i}; %Aindex是工序对应在OScode中的索引
           if j==1
              OMAdjuctTime(Aindex(j))=0;
           else
              previous_workpiece=OScode(Aindex(j-1));%上一道加工工序的对应的工件类型
              now_workpiece=OScode(Aindex(j));%本道加工工序的对应的工件类型
              previous_OSindex=proIndex(Aindex(j-1));%上一道加工工序的对应的工件顺序标号
              now_OSindex=proIndex(Aindex(j));%本道加工工序的对应的工件顺序标号
               %提前判断If 条件的逻辑值
              logical_V1=(fix(previous_workpiece/10)==fix(now_workpiece/10));  %真时，本道工序与上一道工序属于同一类型 
              logical_V2=(previous_workpiece==now_workpiece);       %真时，本道工序与上一道工序属于同一类型同一工件
              logical_V3=~ logical_V2;                              %真时，本道工序与上一道工序属于同一类型不同工件
              logical_V4=(previous_OSindex+1==now_OSindex);         %真时，本道工序与上一道工序属于同一工件的相邻工序
              logical_V5=(previous_OSindex==now_OSindex);            %真时，本道工序与上一道工序属于同一类型不同工件的相同工序
              if (logical_V1&&logical_V2&&logical_V4)||(logical_V1&&logical_V3&&logical_V5)
                  OMAdjuctTime(Aindex(j))=0;
              else
                   OMAdjuctTime(Aindex(j))=AdjustmentTime(IndexNum(1,Aindex(j)),i);
              end
          end
      end
    end
end
proOScode(1,:)=OScode;
proOScode(2,:)=proIndex;
proOScode(3,:)=IndexNum;
proOScode(4,:)=MScode;                



