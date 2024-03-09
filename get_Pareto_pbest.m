function L= get_Pareto_pbest(p_obj,j,p1_obj,obj_Num)

less = 0;         %判断i是否可以支配j
equal= 0;         %判断i是否等于j，序号相同时相等
more = 0;         %判断i是否被j支配
for k = 1:obj_Num  %在每一个目标函数中判断支配关系
    if p_obj(j,1+k) <p1_obj(1,1+k)
        less = less+1;
    elseif p_obj(j,1+k)==p1_obj(1,1+k)
        equal = equal+1;
    else
        more = more + 1;
    end
end
if less == 0 && equal ~= obj_Num            %全是大于等于，至少有一个大于
    L=1;                                    %p_obj比p1_obj好
elseif more == 0 && equal ~= obj_Num        %全是小于等于，至少有一个小于
    L=0;                                    %p_obj比p1_obj差
else
    if p_obj(j,2)>p_obj(1,2) %优先完工时间适应度大的
        L=1;
    elseif p_obj(j,2)==p_obj(1,2) %完工时间适应度一样
        if p_obj(j,4)>p_obj(1,4) %优先调整次数适应度大的
            L=1;
        elseif p_obj(j,4)==p_obj(1,4) %优先调整次数适应度大的
             if p_obj(j,3)>p_obj(1,3) %优先搬运次数适应度大的
                 L=1;
             else
                 L=0;
             end
        else
             L=0;
        end
    else
        L=0;
    end    
end
