function [ Yt,decvalues] = SVMforecast( Label,Train,bestc,bestg,w )
%SVMFORECAST Summary of th1s funct1on goes here
%   Deta1led explanat1on goes here
[m,n] = size(Train);

%规定数据测试的滑窗大小
Xt=zeros(m-w-1,n); %创造Xt零矩阵，共m-w-1行，n列
Yt=zeros(m-w-1,1); %创造Yt零矩阵，共m-w-1行，1列

decvalues = zeros(m-w-1,2);
%%
for i=1:m-w-1
  
    labeltemp=Label(i:i+w-1,1); %收盘价转换为样本标量
    traintemp=Train(i:i+w-1,:); %样本空间转化为训练空间
    %SVM参数寻优
    % [~,bestc,bestg] = SVMcgForClass1(labeltemp,traintemp,-10,10,-10,10,3,1,1,0.4);
    
    Xt(i,:)= Train(i+w,:);
    
    % 训练SVM
    %cmd = [ '-c 4 -g 4 -b 1'];
    cmd = ['-c ', num2str(bestc), ' -g ', num2str(bestg) ' -b ', num2str(1)];
    model = svmtrain(labeltemp,traintemp,cmd);
    
    % 预测
    [Ytt,~,decvaluess] = svmpredict(1,Xt(i,:),model,'-b 1');
    Yt(i) = Ytt;
    decvalues(i,1) = decvaluess(1,1);
end
end

