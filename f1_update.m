function [OScode,MScode]=f1_update(OScode,MScode,operationCode,w,machine,particleLong)
% OScode=[21 22 31 22 21 31 11 11 21 22];
% proIndex=[1 1 1 2 2 2 1 2 3 3];
% IndexNum=[3 6 9 7 4 10 1 2 5 8];
% MScode=[3 3 2 1 5 1	1 5	3 1];
% pb_j{1,1}=[11 21 22 31 11 22 31 21 22 21];
% w=0.65;
% c1=0.8;
% c2=0.3;
L=numel(OScode);
%% f1算子生产随机数与W比较，确定是否变异
if rand()<w
   location=randperm(L,2);
   t=OScode(location(1));
   OScode(location(1))=OScode(location(2));
   OScode(location(2))=t;
   proIndex=zeros(1,particleLong);
   IndexNum=zeros(1,particleLong);
   for j=1:L
       %得到工件对应工序的下标即出现次数proIndex
       proIndex(1,j)=numel(find(OScode(1,j)==OScode(1,1:j)));
       %得到工件对应工序和出现次数 对应初始OS中的序号IndexNum
       OS_Num=find(OScode(1,j)==operationCode);
       IndexNum(1,j)=OS_Num(proIndex(1,j));
   end
   for i=1:2
       selectMchLong=length(machine{IndexNum(location(i)),1});
       MScode(location(i))=machine{IndexNum(location(i)),1}(randperm(selectMchLong,1));
   end
end



