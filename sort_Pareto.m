function [pbest_obj]= sort_Pareto(p_obj,obj_Num,particleNum)
N=particleNum;
target=obj_Num;      %目标值暂时排除（不包含完工时间）
pop_eva=p_obj;
dimension=1;           %目标值之前粒子长度值（不包含完工时间）
front = 1;             %初始化帕累托等级
F(front).f = [];       %帕累托等级front的个体序号集合
individual = [];
%%  1、先确定等级为1的个体以及被支配的集合
for i = 1:N
    %inividual 定义一个结构体n、p
    individual(i).n=0;  %支配i的个体个数
    individual(i).p=[]; %被粒子i支配的个体集合
    for j = 1:N
        less = 0;         %判断i是否可以支配j
        equal= 0;         %判断i是否等于j，序号相同时相等
        more = 0;         %判断i是否被j支配
        for k = 1:target  %在每一个目标函数中判断支配关系
            if (pop_eva(i,dimension+k))< (pop_eva(j,dimension+k))
                less = less+1;
            elseif (pop_eva(i,dimension+k)) == (pop_eva(j,dimension+k))
                equal = equal+1;
            else 
                more = more + 1;
            end
        end
        if less == 0 && equal ~= target            %全是大于等于，至少有一个大于
              individual(i).p = [individual(i).p j]; %i比j好，i支配j，将j加入i支配集合
        elseif more == 0 && equal ~= target        %全是小于等于，至少有一个小于
              individual(i).n = individual(i).n + 1; %i比j差，i被j支配，数目加1
        end
    end
    if individual(i).n == 0               %i粒子被支配数目为0
        pop_eva(i,target+dimension+1) = 1;%i粒子的帕累托等级最优
        F(front).f = [F(front).f i];      %将帕累托等级为1的个体序号加进来。
    end
end
 
%%  2、对种群其他个体进行帕累托等级（剔除了帕累托等级1个体）划分
while ~isempty(F(front).f)  %利用剔除方法去一次性判断所有粒子帕累托等级
    Q = [];
    %遍历帕累托等级为front集合的粒子
    for i = 1:length(F(front).f)     
        %查找等级为front集合中第i个粒子所支配的个体
        if ~isempty(individual(F(front).f(i)).p)  
            %遍历 当前个体等级为front第i个粒子所支配的个体
            for j = 1:length((individual(F(front).f(i)).p)) %括号内为数量
                %被支配粒子数目减1
                individual(individual(F(front).f(i)).p(j)).n = ...
                    individual(individual(F(front).f(i)).p(j)).n - 1;
                %如果被支配粒子数目变为0了，那么将其帕累托等级判定为下一等级
        	   	 if individual(individual(F(front).f(i)).p(j)).n == 0
                    pop_eva(individual(F(front).f(i)).p(j),target + dimension + 1) = front + 1;
                    %记录下一等级的支配粒子的集合
                    Q = [Q individual(F(front).f(i)).p(j)]; 
                 end                 
            end
        end
    end
    front =  front + 1;
    F(front).f = Q;   %Q是帕累托等级为front的集合
end
 
%排序
[~, index_front] = sort(pop_eva(:,target + dimension +1));%根据帕累托等级对个体进行升序
sort_front = zeros(size(pop_eva));
for i = 1 : length(index_front)
    sort_front(i,:) = pop_eva(index_front(i),:);  %排序后的结果
end
 
current_index = 0; %当前下标。
 
%% 只有同一个Pareto等级下，去计算拥挤距离才有意义
%使种群向帕累托等级为1的粒子进化，可以加强智能优化算法的边界搜索能力
for  front = 1 : (length(F)-1)
    distance = 0;  %初始化拥挤距离为0
    y =[];         %中间变量，存储的是该帕累托等级下按拥挤度排序的粒子
    previous_index = current_index + 1;
    for i = 1 : length(F(front).f)   %该帕累托等级下的数量
        y(i,:) = sort_front(current_index + i,:);%将该帕累托的所有粒子赋值给中间变量y
    end
    current_index = current_index + i;
    sorted_based_on_objective = [];
    %函数值排序
    for i = 1 : target  %分目标对该帕累托等级粒子进行升序排列
        %y函数值排序
        [sorted_based_on_objective, index_of_objectives] = sort(y(:,dimension + i));
        sorted_based_on_objective = [];
        for j = 1 : length(index_of_objectives)
            sorted_based_on_objective(j,:) = y(index_of_objectives(j),:);
        end
         %该帕累托等级下边界值，Inf为无穷大
        f_max = ...
            sorted_based_on_objective(length(index_of_objectives), dimension + i);
        f_min = sorted_based_on_objective(1, dimension + i);
        y(index_of_objectives(length(index_of_objectives)),target + dimension + 1 + i)...
            = Inf;
        y(index_of_objectives(1),target + dimension + 1 + i) = Inf;
        for j = 2 : length(index_of_objectives) - 1
           next_obj  = sorted_based_on_objective(j + 1,dimension + i);
           previous_obj  = sorted_based_on_objective(j - 1,dimension + i);
           if (f_max - f_min == 0)  %该帕累托等级下只有一个粒子或者粒子刚好重合了
               y(index_of_objectives(j),target + dimension + 1 + i) = Inf;
           else
               y(index_of_objectives(j),target + dimension + 1 + i) = ...
                    (next_obj - previous_obj)/(f_max - f_min);%拥挤度计算公式
           end
        end
    end
    %将多个目标函数的拥挤度整合为一个拥挤度
    distance = [];
    distance(:,1) = zeros(length(F(front).f),1);
    for i = 1 : target
        distance(:,1) = distance(:,1) + y(:,target + dimension + 1 + i);
    end
    y(:,target + dimension + 2) = distance;
    y = y(:,1 : target + dimension + 2);
    z(previous_index:current_index,:) = y;
end
pbest_obj= z(); %按照帕累托等级+拥挤度排序好的粒子
