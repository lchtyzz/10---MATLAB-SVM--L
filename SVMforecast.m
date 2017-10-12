function [ Yt,decvalues] = SVMforecast( Label,Train,bestc,bestg,w )
%SVMFORECAST Summary of th1s funct1on goes here
%   Deta1led explanat1on goes here
[m,n] = size(Train);

%�涨���ݲ��ԵĻ�����С
Xt=zeros(m-w-1,n); %����Xt����󣬹�m-w-1�У�n��
Yt=zeros(m-w-1,1); %����Yt����󣬹�m-w-1�У�1��

decvalues = zeros(m-w-1,2);
%%
for i=1:m-w-1
  
    labeltemp=Label(i:i+w-1,1); %���̼�ת��Ϊ��������
    traintemp=Train(i:i+w-1,:); %�����ռ�ת��Ϊѵ���ռ�
    %SVM����Ѱ��
    % [~,bestc,bestg] = SVMcgForClass1(labeltemp,traintemp,-10,10,-10,10,3,1,1,0.4);
    
    Xt(i,:)= Train(i+w,:);
    
    % ѵ��SVM
    %cmd = [ '-c 4 -g 4 -b 1'];
    cmd = ['-c ', num2str(bestc), ' -g ', num2str(bestg) ' -b ', num2str(1)];
    model = svmtrain(labeltemp,traintemp,cmd);
    
    % Ԥ��
    [Ytt,~,decvaluess] = svmpredict(1,Xt(i,:),model,'-b 1');
    Yt(i) = Ytt;
    decvalues(i,1) = decvaluess(1,1);
end
end

