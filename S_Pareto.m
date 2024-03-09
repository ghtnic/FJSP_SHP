function [S]= S_Pareto(pbest_obj,p)
index=find(pbest_obj(:,6)==1);
S={};
for i=1:numel(index)
    S{i,1}(1,:)=p{1,pbest_obj(i,1)};
    S{i,1}(2,:)=p{4,pbest_obj(i,1)};
    S{i,2}=pbest_obj(i,2);
    S{i,3}=pbest_obj(i,3);
    S{i,4}=pbest_obj(i,4);
    S{i,5}=pbest_obj(i,5);
    S{i,6}=pbest_obj(i,6);
    S{i,7}=pbest_obj(i,7);
end

