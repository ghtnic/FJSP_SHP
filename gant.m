function gant(MM,gbest_particle,particleLong,workpieceNum,machineNum,ProcessTime,AdjustmentTime,HandlingTime)
OScode=gbest_particle(1,:);
proIndex=gbest_particle(2,:);
IndexNum=gbest_particle(3,:);
MScode=gbest_particle(4,:);
[proOScode,machin_Op,OMProcessTime,OMAdjuctTime,OMTransTime]=getOM_ATtime(MM,OScode,proIndex,IndexNum,particleLong,MScode,workpieceNum,machineNum,ProcessTime,AdjustmentTime,HandlingTime);

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
%找到最后一个工序的完工时刻即粒子中最大的结束时
makespan=max(EndSchedule)
axis([0,16.5,0,6.5]);%x轴 y轴的范围
set(gca,'xtick',0:1:16) ;%x轴的增长幅度
set(gca,'ytick',0:1:6) ;%y轴的增长幅度
yticks([1, 2, 3, 4, 5,6]);
yticklabels({'WC_{11}', 'WC_{21}', 'WC_{22}', 'WC_{31}', 'WC_{32}', 'WC_{41}'});
xlabel('time/min','FontName','微软雅黑','Color','b','FontSize',14)
ylabel('Work-center machine number','FontName','微软雅黑','Color','b','FontSize',14,'Rotation',90)
title('Optimal scheduling Gantt chart','fontname','微软雅黑','Color','b','FontSize',14);%图形的标题
grid on
rec1=[0,0,0,0];
rec2=rec1;
rec3=rec1;
color=[0.75 0.98039 0.94118;0.66 0.8549 0.72549;0.7541 0.7541 0.7451;0.39216 0.58431 0.92941;0.11765 0.26471 1;0 1 1;0.49804 1 0.83137;0 1 0.49804;0 1 0;0.9333 0.9098 0.6667;0.73725 0.56078 0.56078;0.89 0.27 0.20;0.87 0 1;0.78 0.231 0.23137;0.5058 0.721568 0.874509;0.996 0.50588 0.49;0.035 0.662 0.3529;0 1 0.989;0.88 0.44 0.11;0.88 0.44 0.22;0.88 0.55 0.11; 0.88 0.55 0.33;0.88 0.11 0.12;0.77 0.22 0.11];
for i=1:particleLong
    if OMAdjuctTime(i)~=0
        mk=MScode(i);%找到对应的机器
        mkIndex=find(i==machin_Op{mk});
        if mkIndex>1
        %找到当前加工工序在机器OP中上一道工序对应的下标
           Mop_pre_i=machin_Op{mk}(mkIndex-1);
        end
    end
end
for i =1:particleLong
    %加工时间矩形
    rec1(1)=BeginSchedule(i);  %矩形的横坐标-工序开始时间
    rec1(2)=MScode(i)-0.125;     %矩形的纵坐标-机器号
    rec1(3)=OMProcessTime(i);  %矩形的x轴方向的长度
    rec1(4)=0.25;
    txt1=sprintf('O(%d,%d,%.f)',OScode(i),proIndex(i),OMProcessTime(i));%将机器号，工序号，加工时间连字符串
    ck=(MM(1,:)==OScode(i));
    rectangle('Position',rec1,'LineWidth',0.5,'LineStyle','-','FaceColor',color(ck,:));%draw every rectangle
    text(rec1(1),rec1(2)+0.125,txt1,'FontWeight','Normal','FontSize',10);%字体的坐标和其它特性
    hold on
    %调整时间矩形
    if OMAdjuctTime(i)~=0
        mk=MScode(i);%找到对应的机器
        mkIndex=find(i==machin_Op{mk});
        if mkIndex>1
        %找到当前加工工序在机器OP中上一道工序对应的下标
           Mop_pre_i=machin_Op{mk}(mkIndex-1);
        end
        rec2(1)=EndSchedule(Mop_pre_i);  %矩形的横坐标-调整开始时间
        rec2(2)=rec1(2);                  %矩形的纵坐标-机器号
        rec2(3)=OMAdjuctTime(i);          %矩形的x轴方向的长度
        rec2(4)=0.25;
        txt2=sprintf('A(%d,%d,%.1f)',OScode(i),proIndex(i),OMAdjuctTime(i));%将机器号，工序号，调整时间连字符串
        rectangle('Position',rec2,'LineWidth',0.5,'LineStyle','-','FaceColor',[1 0.15 0]);%draw every rectangle
        text(rec2(1),rec2(2)+0.125,txt2,'FontWeight','Normal','FontSize',10);%字体的坐标和其它特性
    end 
    hold on
    %运输时间矩形
    if OMTransTime(i)~=0
        if proIndex(i)>1
            pre_i_val=proOScode(3,i)-1;%从原始序列 中找到上一道工序
            pre_i=find(proOScode(3,:)==pre_i_val); %找到当前工序的上一道工序对应索引
        end
        rec3(1)=EndSchedule(pre_i);  %矩形的横坐标-运输开始时间
        rec3(2)=MScode(pre_i)-0.375; %矩形的纵坐标-机器号
        rec3(3)=OMTransTime(i);      %矩形的x轴方向的长度
        rec3(4)=0.25;
        txt3=sprintf('T(%d,%d,%.1f)',OScode(i),proIndex(i),OMTransTime(i));%将机器号，工序号，调整时间连字符串
        rectangle('Position',rec3,'LineWidth',0.5,'LineStyle','-','FaceColor',[1 0.6 0]);%draw every rectangle
        text(rec3(1),rec3(2)+0.125,txt3,'FontWeight','Normal','FontSize',10);%字体的坐标和其它特性
    end
end  