c = xlsread('ssq.xlsx','sheet1','c3:I496')
red_3 = c(:,1) 
% high = 1.high;      % 最高价
% low = 2.low;       % 最低价
% Close = 3.close;     % 收盘价
% open = 4.open;      % 开盘价
% average = 5.average;   % 平均价
% volume = 6.Volume;    % 成交量
% positions = 1.Positions; % 持仓量
x1=[1 33]

[y1,PS] = mapminmax(x1)
train = mapminmax('apply',c,PS)
% date = datenum(luowen.date1); % 交易日期
% % 归一化处理
%  提取标量数值以及特征维度，训练样本归一化。
%  通过运用mapminmax函数将不同量纲的训练样本数据归一到[-1，1]上，便于对模型的训练。
%  关于归一化的问题前面章节有具体介绍，这里不再赘述。
% Train = c';
% [Train,Train_ps] = mapminmax(Train); %归一化
% train = Train';
Train1 = train(1:end-1,:);

% 以交易信号作为标量，1代表涨；-1代表跌。
Label = sign(red_3(2:end,:) - red_3(1:end-1,:));

Label( Label == 0 ) = 1;
%% C-SVM算法静态仿真
%  这里用当日的价格信息来对当日的买卖信号作训练，通过运用SVMcgForClass函数来验证在
%  假设已知当日全部价格信息的前提下，模型对买卖信号的判断精准度。

%  参数寻优
[bestmse1,bestc1,bestg1] = SVMcgForClass(Label,Train1,-8,8,-8,8,5,0.5,0.5,1);
cmd1 = ['-c ', num2str(bestc1), ' -g ', num2str(bestg1) ' -b ', num2str(1)];
%  cmd1
% 模型建立，训练SVM网络
model = svmtrain(Label,Train1,cmd1);
% 模型预测
[predict_label1, accuracy1, dec_values1] = svmpredict(Label,Train1,model,'-b 1');
roc_label1(Label>=0) = 1;

% %% SVM算法动态仿真
% %  寻找模型中最优的滑窗wiondow的大小
% Train = cell(1,2);
% 
% Train{1} = train(1:end-1,:);
% Train{2} = Train2(1:end-1,:);
% 
% bestc = cell(1,2);
% bestc{1} = bestc1;
% bestc{2} = bestc2;
% bestg = cell(1,2);
% bestg{1} = bestg1;
% bestg{2} = bestg2;
% window = cell(1,2);
% bestaccurate = cell(1,2);
% 
% strtemp = {'[以价量信息为样本属性集合]','[以技术指标为样本属性集合]'};
% % 窗口设定的范围为: x~y 天
% for i = 1:2
% %     [bestaccurate{i},window{i},Accurate,xlab] = Bestwindow(Label,Train{i},bestc1,bestg1,15,65);
%     
%     [bestaccurate{i},window{i},Accurate,xlab] = ...
%                        Bestwindow(Label,Train{i},bestc{i},bestg{i},15,65);
%     
%     scrsz = get(0,'ScreenSize');
%     figure('Position',[scrsz(3)*1/4 scrsz(4)*1/6 scrsz(3)*4/5 scrsz(4)]*3/4);
%     plot(xlab,Accurate,'-*');
%     xlabel('滑窗的长度');
%     ylabel('准确度');
%     
%     title(['最优的滑窗长度=',num2str(window{i}),',最佳准确率=',num2str(bestaccurate{i}), ...
%         strtemp{i}], 'FontWeight', 'Bold');
%     
%     grid on
%     hold on
%     scatter(window{i},bestaccurate{i},'MarkerFaceColor',[1 0 0],'Marker','square');
%     hold off
% end
% %% C-SVM动态仿真的回测检验
% %  对两种模型进行回测检验
% P_S = cell(1,2);
% R_S = cell(1,2);
% r = cell(1,2);
% cumr = cell(1,2);
% benchmark = cell(1,2);
% x = cell(1,2);
% ret = cell(1,2);
% Maxdrawdown = cell(1,2);
% dd = cell(1,2);
% for i = 1:2
%     % 交易信号确认
%     [P_S{i},decvalues] = SVMforecast(Label,Train{i},bestc{i},bestg{i},window{i}); % P_S为算法预测信号
%     R_S{i} = Label(1+window{i}:end-1,:); % R_S为真实交易信号
%     
%     % 预测信号与实际信号对比
%     Signal = [P_S{i} R_S{i}];
%     Signalforcast(P_S{i},R_S{i})
%     
%     % 每笔盈利及累计收益计算
%     r{i}  = [0; P_S{i}.*(Close(window{i}+2:end-1,1)-Close(window{i}+1:end-2,1));]; % 每笔收益
% end
% %% 各项指标的测试结果
% % 模型准确率
% Accuratcy = cell(1,2);
% EED = cell(1,2);
% SharpeRadio = cell(1,2);
% Inforatio = cell(1,2);
% for i = 1:2
%     R_S{i} = Label(window{i}+1:end-1,:); %实际交易信号
%     k = ones(length(P_S{i}),1);
%     z = sum(k(P_S{i}==R_S{i}));
%     Accuratcy{i} = z/length(k);
%     % 预期最大回测
%     rm = price2ret(ret{i});
%     Return = tick2ret(ret{i});
%     [mean,std] = normfit(Return);
%     EED{i} = emaxdrawdown(mean,std,5);
%     % 年化夏普比率
%     SharpeRadio{i} = sqrt(250)*sharpe(rm,0);
%     % 信息比率
%     Inforatio{i} = inforatio(rm,price2ret(benchmark{i}));
% end
%% 打印结果
% 
% %% 移动平均线生成和展示
% lead = cell(1,5);
% lag = cell(1,5);
% scrsz = get(0,'ScreenSize');
% figure('Position',[scrsz(3)*1/4 scrsz(4)*1/6 scrsz(3)*4/5 scrsz(4)]*3/4);
% MT_candle(high,low,Close,open,'r',date);
% xlim([1 length(date)]);
% hold on;
% for i = 1:5
%     [lead{i},lag{i}]=movavg(Close,i*3-2,i*9-6,'e');
%     plot(lead{i}, 'Color', [i/5, 0, 0]);
%     
%     plot(lag{i}, 'Color', [0, 0, i/5]);
%     grid on   
% end
% title('5组不同时间长度的移动平均线展示','FontWeight','Bold');
% %% 基于移动平均技术指标预测的C-SVM算法静态仿真
% %  对由移动平均技术指标形成的模型训练样本进行静态仿真，这里的训练样本集Train2为一个
% %  200 X 5的double型矩阵。x ? Train2 ∈{-1,1}，其中 -1代表下穿（死叉），1代表上穿（金叉）。
% 
% Train_Signal = cell(1,5);
% for i = 1:5
%     Train_Signal{i}(lead{i}>=lag{i}) = 1;                         % 买  (多头)
%     Train_Signal{i}(lead{i}<lag{i}) = -1;                         % 卖  (空头)
% end
% 
% Train2 = cell2mat(Train_Signal);
% Train2 = reshape(Train2,200,5);
% %  g,c参数寻优
% [bestmse2,bestc2,bestg2] = SVMcgForClass(Label,Train2(2:end,:),-10,10,-10,10,5,0.5,0.5,0.5);
% cmd2 = ['-c ', num2str(bestc2), ' -g ', num2str(bestg2) ' -b ', num2str(1)];
% cmd2
% % 模型建立，训练SVM网络
% model = svmtrain(Label,Train2(2:end,:),cmd2);
% % 模型预测
% [predict_label2, accuracy2, dec_values2] = svmpredict(Label,Train2(2:end,:),model,'-b 1');
% roc_label2(Label>=0) = 1;
% 
% %% ROC曲线对比
% 
% roc_label = [roc_label1;roc_label2];
% dec_values = [dec_values1(:,1)';dec_values2(:,1)'];
% 
% scrsz = get(0,'ScreenSize');
% figure('Position',[scrsz(3)*1/4 scrsz(4)*1/6 scrsz(3)*4/5 scrsz(4)]*3/4);
% 
% plotroc(roc_label,dec_values);
%% SVM算法动态仿真
%  寻找模型中最优的滑窗wiondow的大小
Train = cell(1);

Train{1} = train(1:end-1,:);


bestc = cell(1);
bestc{1} = bestc1;

bestg = cell(1);
bestg{1} = bestg1;

window = cell(1);
bestaccurate = cell(1);

strtemp = {'[以价量信息为样本属性集合]','[以技术指标为样本属性集合]'};
% 窗口设定的范围为: x~y 天
for i = 1
%     [bestaccurate{i},window{i},Accurate,xlab] = Bestwindow(Label,Train{i},bestc1,bestg1,15,65);
    
    [bestaccurate{i},window{i},Accurate,xlab] = ...
                       Bestwindow(Label,Train{i},bestc{i},bestg{i},50,110);
    
    scrsz = get(0,'ScreenSize');
    figure('Position',[scrsz(3)*1/4 scrsz(4)*1/6 scrsz(3)*4/5 scrsz(4)]*3/4);
    plot(xlab,Accurate,'-*');
    xlabel('滑窗的长度');
    ylabel('准确度');
    
    title(['最优的滑窗长度=',num2str(window{i}),',最佳准确率=',num2str(bestaccurate{i}), ...
        strtemp{i}], 'FontWeight', 'Bold');
    
    grid on
    hold on
    scatter(window{i},bestaccurate{i},'MarkerFaceColor',[1 0 0],'Marker','square');
    hold off
end
%% C-SVM动态仿真的回测检验
Train_T = train(end,:);
svmpredict
redfor=svmpredict(Train_T)
libsvmread
SVMforecast
sss=sim(model,Train_T)
 i=1
 [P_S{i},decvalues] = SVMforecast(Label,Train{i},bestc{i},bestg{i},60)
 [P_S{i},decvalues] = SVMforecast(Label,c,bestc{i},bestg{i},60)

% 
% 
% 
% %  对两种模型进行回测检验
% P_S = cell(1,2);
% R_S = cell(1,2);
% r = cell(1,2);
% cumr = cell(1,2);
% benchmark = cell(1,2);
% x = cell(1,2);
% ret = cell(1,2);
% Maxdrawdown = cell(1,2);
% dd = cell(1,2);
% for i = 1
%     % 交易信号确认
%     [P_S{i},decvalues] = SVMforecast(Label,Train{i},bestc{i},bestg{i},window{i}); % P_S为算法预测信号
%     R_S{i} = Label(1+window{i}:end-1,:); % R_S为真实交易信号
%     
%     % 预测信号与实际信号对比
%     Signal = [P_S{i} R_S{i}];
%     Signalforcast(P_S{i},R_S{i})
%     
%     % 每笔盈利及累计收益计算
%     r{i}  = [0; P_S{i}.*(Close(window{i}+2:end-1,1)-Close(window{i}+1:end-2,1));]; % 每笔收益
% end
% 
