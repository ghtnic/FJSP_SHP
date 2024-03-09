function [gbest,gbest_particle]= get_Pareto_gbest(S,operationCode,particleLong)
%从S里得到目标1的完工时间适应度（第2列）转换成数组
D=cell2mat(S(:,2));
D_index=find(max(D)==D);%选完工时间目标适应度大的
if numel(D_index)>1
    %从D中提取完工时间目标适应度大的的数组
    f1(:,1)=D_index;
    f1(:,2:7)=cell2mat(S(D_index(1:end),2:7));
    %选调整次数目标适应度大的
    k1=find(max(f1(:,3))==f1(:,3));  
    if numel(k1)>1
        %从f1中取f2调整次数目标适应度大的数组
        f2(:,1)=k1;
        f2(:,2:7)=f1(k1(1:end),2:7);
        k2=find(max(f2(:,4))==f2(:,4)); %选搬运次数目标适应度大的
        if numel(k2)>1
            k3=k2(randperm(numel(k2),1),1);
            g=f1(k3,1);
        else
            g=f1(k2,1);
        end
    else
        g=f1(k1,1);
    end
    gbest=S(g,:);
else
    gbest=S(D_index,:);
end
OScode=gbest{1,1}(1,:);
MScode=gbest{1,1}(2,:);
for j=1:particleLong
    %得到工件对应工序的下标即出现次数proIndex
    proIndex(1,j)=numel(find(OScode(1,j)==OScode(1,1:j)));
    %得到工件对应工序和出现次数 对应初始OS中的序号IndexNum
    OS_Num=find(OScode(1,j)==operationCode);
    IndexNum(1,j)=OS_Num(proIndex(1,j));
end
% for j2=1:particleLong
%     mindex=IndexNum(1,j2);
%     %该位置的机器码不在对应的机器集合里
%     if ~ismember(MScode(1,j2),machine{mindex,1})
%         selectMchLong=length(machine{mindex,1});
%         MScode(1,j2)=machine{mindex,1}(randperm(selectMchLong,1));
%     end
% end%判断机器码是否正确
gbest_particle(1,:)=OScode;
gbest_particle(2,:)=proIndex;
gbest_particle(3,:)=IndexNum;
gbest_particle(4,:)=MScode;
% gbest{1,1}(1,:)=OScode;
% gbest{1,1}(2,:)=MScode;


