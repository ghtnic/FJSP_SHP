clc
clear
%=========数据录入，参数调整=================
MM=[11 21 22 31 32 33 41 42 43 51 52 53;2 3 3 2 2 2 3 3 3 3 3 3];%工件、工序数量矩阵，MM第一行表示工件，第二行表示每个工件的工序数；
workpieceNum=size(MM,2);   %工件数；
operationCode=[11 11 21 21 21 22 22 22 31 31 32 32 33 33 41 41 41 42 42 42 43 43 43 51 51 51 52 52 52 53 53 53];%批量工件工序集；
machineNum=6;   %加工机器数；
T=300;        %迭代次数
particleNum=100; %初始生成的粒子数；
particleLong=sum(MM(2,:));  %所有工序数即粒子长度； 
obj_Num=4;
w_max=0.9;
w_min=0.4;
c1=0.5;
c2=0.7;

machine=xlsread("AT01.xlsx","加工机器","D4:I57");%工序加工-机器约束矩阵；

ProcessTime=xlsread("AT01.xlsx","加工时间","D4:I57");%工序加工时间约束矩阵；

AdjustmentTime=xlsread("AT01.xlsx","调整时间","D4:I57");%工序调整时间约束矩阵；

HandlingTime=xlsread("AT01.xlsx","搬运时间","D4:I57");%工序搬运时间约束矩阵；
            
%%%%%%%=================算法模型===============================%%%%%%%

%%%%%%--------------初始化种群个体-------------------------%%%%%%%%
%% 粒子初始化 生成300x10矩阵，OScode\MScode相关信息
[particle,particle_proIndex,particle_IndexNum,particle_MS]=initialization(operationCode,particleNum,particleLong,machine,ProcessTime);
p=cell(4,particleNum); %保存粒子个体信息
for j=1:particleNum
    p{1,j}=particle(j,:);
    p{2,j}=particle_proIndex(j,:);
    p{3,j}=particle_IndexNum(j,:);
    p{4,j}=particle_MS(j,:);
end
%%%%%%--------------初始化个体最优位置和最优值---------------------%%%%%%%%
%% 遍历第i个粒子的工序方案，机器方案，时间安排，适应度等，得到所有的粒子 方案
machineTime=cell(machineNum,particleNum);
p_obj=zeros(particleNum,obj_Num+1);%添加1列 对应粒子的序号
for i=1:particleNum
    OScode=particle(i,:);
    MScode=particle_MS(i,:);
    IndexNum=particle_IndexNum(i,:);
    proIndex=particle_proIndex(i,:);
    %得到一个粒子的OMProcessTime,OMAdjuctTime,OMTransTime 机器加工工序集合
    [proOScode,machin_Op,OMProcessTime,OMAdjuctTime,OMTransTime]=getOM_ATtime(MM,OScode,proIndex,IndexNum,particleLong,MScode,workpieceNum,machineNum,ProcessTime,AdjustmentTime,HandlingTime);
    [obj]=fitness(proOScode,machin_Op,particleLong,machineNum,OMProcessTime,OMAdjuctTime,OMTransTime);
    p_obj(i,1)=i;
    p_obj(i,2:end)=obj;%种群的粒子目标适应度
end
[pbest_obj]= sort_Pareto(p_obj,obj_Num,particleNum);
%提取帕累托前沿集合S:pbest_obj第6列为1的集合
[S]= S_Pareto(pbest_obj,p);
%%%%%%--------------初始化全局最优位置和最优值---------------------%%%%%%%%
%% 从种群中得到(S集合) 全局最优的粒子及方案
%从种群中得到 最优粒子以及适应度
[pregbest,pregbest_particle]= get_Pareto_gbest(S,operationCode,particleLong);

%% 按照公式依次迭代，记录最优质%%
gb=zeros(T,obj_Num);
gbestParticle=zeros(4*T,particleLong);
tic
for i=1:T
    i
    w=w_max-(w_max-w_min)*i/T;
    for j=1:particleNum
        pb_j=p(:,j);%迭代之前第j粒子
        % 更新后粒子位置OS、MS、proIndex、IndexNum
        OScode=p{1,j};
        MScode=p{4,j};
        [OScode,MScode]=f1_update(OScode,MScode,operationCode,w,machine,particleLong);
        [OScode,MScode]=f2_update(pb_j,OScode,MScode,operationCode,MM,c1,workpieceNum,machineNum,ProcessTime,AdjustmentTime,HandlingTime);
        [OScode,MScode]=f3_update(pregbest_particle,OScode,MScode,operationCode,MM,machine,c2,workpieceNum,machineNum,ProcessTime,AdjustmentTime,HandlingTime,particleLong);
        proIndex=zeros(1,particleLong);
        IndexNum=zeros(1,particleLong);
        for j1=1:particleLong
            %得到工件对应工序的下标即出现次数proIndex
            proIndex(1,j1)=numel(find(OScode(1,j1)==OScode(1,1:j1)));
            %得到工件对应工序和出现次数 对应初始OS中的序号IndexNum
            OS_Num=find(OScode(1,j1)==operationCode);
            IndexNum(1,j1)=OS_Num(proIndex(1,j1));
        end
        %边界条件处理
        %判断机器码是否正确
         for j2=1:particleLong
             mindex=IndexNum(1,j2);
             %该位置的机器码不在对应的机器集合里
             if ~ismember(MScode(1,j2),machine{mindex,1})
                 selectMchLong=length(machine{mindex,1});
                 MScode(1,j2)=machine{mindex,1}(randperm(selectMchLong,1));
             end
         end
        % 更新后的个体最优位置和最优值
        [proOScode,machin_Op,OMProcessTime,OMAdjuctTime,OMTransTime]=getOM_ATtime(MM,OScode,proIndex,IndexNum,particleLong,MScode,workpieceNum,machineNum,ProcessTime,AdjustmentTime,HandlingTime);
        [obj]=fitness(proOScode,machin_Op,particleLong,machineNum,OMProcessTime,OMAdjuctTime,OMTransTime);
        %粒子更新后的目标适应度
        p1_obj=zeros(1,1+obj_Num);%粒子更新 每次初始化赋值
        p1_obj(1,1)=j;
        p1_obj(1,2:end)=obj;
        L= get_Pareto_pbest(p_obj,j,p1_obj,obj_Num);
        %更新后的粒子 比之前的粒子更优的话，就替换原粒子
        if L==0
            p{1,j}=OScode;
            p{2,j}=proIndex;
            p{3,j}=IndexNum;
            p{4,j}=MScode;
            p_obj(j,:)=p1_obj;
        end
    end
    %更新后 获取当代的帕累托排序
    [pbest_obj]= sort_Pareto(p_obj,obj_Num,particleNum);
    %更新后 获取当代的帕累托解集
    [nowS]=S_Pareto(pbest_obj,p);
    %更新后 获取当代的帕累托最优的解
    [i_gbest,i_gbest_particle]= get_Pareto_gbest(nowS,operationCode,particleLong);
    %更新全局最优位置和最优值 if 第i代粒子比上一代更优则保留，反之，保留上一代粒子
    [gbest,gbest_particle]=get_gbest(pregbest,pregbest_particle,i_gbest,i_gbest_particle);
    pregbest=gbest;
    pregbest_particle=gbest_particle;
    %记录全局最优粒子及目标适应度
     for j=1:4
         gbestParticle((i-1)*4+j,:)=gbest_particle(j,:);
     end
     gb(i,:)=cell2mat(gbest(1,2:5));
end
figure
subplot(2,2,1)
plot(gb(:,1))
title('Evolution curve of minimum completion time');
xlabel('Number of iterations','FontName','微软雅黑','Color','k','FontSize',10)
ylabel('Fitness value','FontName','微软雅黑','Color','k','FontSize',10,'Rotation',90)
subplot(2,2,2)
plot(gb(:,2))
title('Evolution curve of machine shutdown times');
xlabel('Number of iterations','FontName','微软雅黑','Color','k','FontSize',10)
ylabel('Fitness value','FontName','微软雅黑','Color','k','FontSize',10,'Rotation',90)
subplot(2,2,3)
plot(gb(:,3))
title('Evolution curve of job handling times');
xlabel('Number of iterations','FontName','微软雅黑','Color','k','FontSize',10)
ylabel('Fitness value','FontName','微软雅黑','Color','k','FontSize',10,'Rotation',90)
subplot(2,2,4)
plot(gb(:,4))
title('Evolution curve of total machining load');
xlabel('Number of iterations','FontName','微软雅黑','Color','k','FontSize',10)
ylabel('Fitness value','FontName','微软雅黑','Color','k','FontSize',10,'Rotation',90)
%toc
figure
gant(MM,gbest_particle,particleLong,workpieceNum,machineNum,ProcessTime,AdjustmentTime,HandlingTime);