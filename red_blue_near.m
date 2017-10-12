ff = xlsread('ssq.xlsx','sheet1','J2:P497');
int=ff';

b=495
a=b-53
binput_train=int(1:7,a:b);
boutput_train=int(:,a+1:b+1);
binput_test=int(1:7,b:b+1);
boutput_test=int(:,b+1:b+1);
test_out=0

for a=1:1:10
    
   
THRESHOLD=[0 1;0 1;0 1;0 1;0 1;0 1;0 1];

net=newff(THRESHOLD,[30 7],{'tansig','purelin'},'trainlm');
%网络训练 threshoul 可进行调整 789，ctrl+ent，排除倒数3正数4个共计8个一次
net.trainParam.epochs=10;
net.trainParam.lr=0.05;
net.trainParam.goal=0.01;
net.trainParam.max_fail = 20

% 
% 
%  网络训练
%  net.IW{1,1};              输入层到隐层的权值
%  net.b{1,1};                输入层到隐层的阈值
%  net.IW{2,1};              隐层到输出层的权值
% net.b{2,1};                隐层到输出层的阈值
%   
% 
   net=train(net,binput_train,boutput_train);

    out=sim(net,binput_train);
    testout=sim(net,binput_test);
    test_out= test_out+testout
    c =sum(sum(testout>0.5))
    cc=sum(sum(testout<-0.3))
    if c<2&&cc<2
         test_out= test_out+testout   
     end
           
end 
eee=test_out/10
