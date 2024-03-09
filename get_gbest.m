function [gbest,gbest_particle]= get_gbest(pregbest,pregbest_particle,i_gbest,i_gbest_particle)

if pregbest{1,2}>i_gbest{1,2} %优先完工时间适应度大的
    L=0;
elseif pregbest{1,2}==i_gbest{1,2} %完工时间适应度一样
    if pregbest{1,4}>i_gbest{1,4} %优先调整次数适应度大的
        L=0;
    elseif pregbest{1,4}==i_gbest{1,4} %优先调整次数适应度大的
        if pregbest{1,3}>i_gbest{1,3} %优先搬运次数适应度大的
            L=0;
        elseif pregbest{1,3}==i_gbest{1,3}
            if pregbest{1,5}>i_gbest{1,5} %优先加工负荷适应度大的
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
    gbest=pregbest;
    gbest_particle=pregbest_particle;
else
    gbest=i_gbest;
    gbest_particle=i_gbest_particle;
end

