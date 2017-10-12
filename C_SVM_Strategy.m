%% 基于C-SVM算法的螺纹钢主力合约交易模型(R)   作者：张宇霖
% Modified by 李洋faruto 2014.06.01
%  支持向量机( Support Vector Machines, SVM)是近几年来应用于建模的一种新的学习方法
%  与传统经网络相比,支持向量机算法最终将转化为一个二次型寻优问题,从理论上讲得到的将是全局最优点,
%  解决了在神经网络中无法避免的局部极小值问题。
%
%  本篇报告旨在运用SVM模型系统对以螺纹钢期货主力合约进行动态的回测检验，目的是为了检测
%  SVM算法在商品期货中进行价格推演和预测的可行性。
%
%  本报告所涉及的SVM算法来自于台湾大学林智仁先生的libsvm工具箱；SVMcgForClass函数接口来自于
%  李洋先生的LIBSVM-farutoUltimateVersion工具箱；其余均来自于本作者。
%% 数据的选取及预处理
%  测试数据：螺纹钢主力合约（10/23/2012 ~ 08/20/2013）
%  整体样本数据存储在luowen.mat,数据为200X8的dataset数据。包含了BR主力合约的：
%  开盘价、收盘价、最高价、最低价、平均价、成交量、持仓量等7个计量指标，以
%  及一个时间轴信息。
%  数据来源：wind数据库

% 载入数据
load luowen.mat

% 获取样本数据
data = [luowen.close, luowen.open, luowen.high, luowen.low, luowen.average, luowen.Volume, luowen.Positions];

% 获取样本数据
high = luowen.high;      % 最高价
low = luowen.low;       % 最低价
Close = luowen.close;     % 收盘价
open = luowen.open;      % 开盘价
average = luowen.average;   % 平均价
volume = luowen.Volume;    % 成交量
positions = luowen.Positions; % 持仓量

date = datenum(luowen.date1); % 交易日期

%% K线图及价格信息

%  画出测试数据的K线图以及其对于的成交量和持仓量
scrsz = get(0,'ScreenSize');
figure('Position',[scrsz(3)*1/4 scrsz(4)*1/6 scrsz(3)*4/5 scrsz(4)]*3/4);

ax(1) = subplot(3,1,[1,2]);
MT_candle(high,low,Close,open,'r',date);

xlim([1,length(date)]);
XTick = [1:floor(length(date)/7):length(date)];
XTickLabel = datestr(date(XTick,1));
set(gca,'XTick', XTick);
set(gca,'XTickLabel', XTickLabel);

hold on
plot(average,'r*')
title('RB主力合约日K线图', 'FontWeight','Bold');
grid on

ax(2) = subplot(3,1,3);
bar(volume,'FaceColor',[1 0 0],'EdgeColor',[1 1 1],'BarWidth',1);
hold on
plot(positions,'LineWidth',2,'Color',[0 0 1]);
legend('成交量','持仓量');
title('成交量和持仓量走势图','FontWeight','Bold');
XTick = [1:floor(length(date)/7):length(date)];
XTickLabel = datestr(date(XTick,1));
set(gca,'XTick', XTick);
set(gca,'XTickLabel', XTickLabel);
grid on
linkaxes(ax,'x')
hold off
%% 归一化处理
%  提取标量数值以及特征维度，训练样本归一化。
%  通过运用mapminmax函数将不同量纲的训练样本数据归一到[-1，1]上，便于对模型的训练。
%  关于归一化的问题前面章节有具体介绍，这里不再赘述。
Train = data';
[Train,Train_ps] = mapminmax(Train); %归一化
train = Train';
Train1 = train(2:end,:);


% 以交易信号作为标量，1代表涨；-1代表跌。
Label = sign(Close(2:end,:) - Close(1:end-1,:));

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

%% 移动平均线生成和展示
lead = cell(1,5);
lag = cell(1,5);
scrsz = get(0,'ScreenSize');
figure('Position',[scrsz(3)*1/4 scrsz(4)*1/6 scrsz(3)*4/5 scrsz(4)]*3/4);
MT_candle(high,low,Close,open,'r',date);
xlim([1 length(date)]);
hold on;
for i = 1:5
    [lead{i},lag{i}]=movavg(Close,i*3-2,i*9-6,'e');
    plot(lead{i}, 'Color', [i/5, 0, 0]);
    
    plot(lag{i}, 'Color', [0, 0, i/5]);
    grid on   
end
title('5组不同时间长度的移动平均线展示','FontWeight','Bold');
%% 基于移动平均技术指标预测的C-SVM算法静态仿真
%  对由移动平均技术指标形成的模型训练样本进行静态仿真，这里的训练样本集Train2为一个
%  200 X 5的double型矩阵。x ? Train2 ∈{-1,1}，其中 -1代表下穿（死叉），1代表上穿（金叉）。

Train_Signal = cell(1,5);
for i = 1:5
    Train_Signal{i}(lead{i}>=lag{i}) = 1;                         % 买  (多头)
    Train_Signal{i}(lead{i}<lag{i}) = -1;                         % 卖  (空头)
end

Train2 = cell2mat(Train_Signal);
Train2 = reshape(Train2,200,5);
%  g,c参数寻优
[bestmse2,bestc2,bestg2] = SVMcgForClass(Label,Train2(2:end,:),-10,10,-10,10,5,0.5,0.5,0.5);
cmd2 = ['-c ', num2str(bestc2), ' -g ', num2str(bestg2) ' -b ', num2str(1)];
cmd2
% 模型建立，训练SVM网络
model = svmtrain(Label,Train2(2:end,:),cmd2);
% 模型预测
[predict_label2, accuracy2, dec_values2] = svmpredict(Label,Train2(2:end,:),model,'-b 1');
roc_label2(Label>=0) = 1;

%% ROC曲线对比

roc_label = [roc_label1;roc_label2];
dec_values = [dec_values1(:,1)';dec_values2(:,1)'];

scrsz = get(0,'ScreenSize');
figure('Position',[scrsz(3)*1/4 scrsz(4)*1/6 scrsz(3)*4/5 scrsz(4)]*3/4);

plotroc(roc_label,dec_values);
%% SVM算法动态仿真
%  寻找模型中最优的滑窗wiondow的大小
Train = cell(1,2);

Train{1} = train(1:end-1,:);
Train{2} = Train2(1:end-1,:);

bestc = cell(1,2);
bestc{1} = bestc1;
bestc{2} = bestc2;
bestg = cell(1,2);
bestg{1} = bestg1;
bestg{2} = bestg2;
window = cell(1,2);
bestaccurate = cell(1,2);

strtemp = {'[以价量信息为样本属性集合]','[以技术指标为样本属性集合]'};
% 窗口设定的范围为: x~y 天
for i = 1:2
%     [bestaccurate{i},window{i},Accurate,xlab] = Bestwindow(Label,Train{i},bestc1,bestg1,15,65);
    
    [bestaccurate{i},window{i},Accurate,xlab] = ...
                       Bestwindow(Label,Train{i},bestc{i},bestg{i},15,65);
    
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
%  对两种模型进行回测检验
P_S = cell(1,2);
R_S = cell(1,2);
r = cell(1,2);
cumr = cell(1,2);
benchmark = cell(1,2);
x = cell(1,2);
ret = cell(1,2);
Maxdrawdown = cell(1,2);
dd = cell(1,2);
for i = 1:2
    % 交易信号确认
    [P_S{i},decvalues] = SVMforecast(Label,Train{i},bestc{i},bestg{i},window{i}); % P_S为算法预测信号
    R_S{i} = Label(1+window{i}:end-1,:); % R_S为真实交易信号
    
    % 预测信号与实际信号对比
    Signal = [P_S{i} R_S{i}];
    Signalforcast(P_S{i},R_S{i})
    
    % 每笔盈利及累计收益计算
    r{i}  = [0; P_S{i}.*(Close(window{i}+2:end-1,1)-Close(window{i}+1:end-2,1));]; % 每笔收益
end
%% 止损策略
% 设stop为止损点，达到时进行止损策略
for i = 1:2
    stop = 30;
    for j = 1:length(r{i})
        if r{i}(j)<-stop
            r{i}(j) = -stop;
        end
    end
    
    cumr{i} = cumsum(r{i}); % 累计受获利点数
    benchmark{i} = Close(window{i}+2:end,1); % 价格的基准走势
    x{i} = 1:length(Close(window{i}+2:end,1));
    % 模型的最大回测
    ret{i} = cumr{i}+1000*ones(length(cumr{i}),1);
    [Maxdrawdown{i},dd{i}] = maxdrawdown(ret{i},'return');
end
%% 每笔交易盈亏图
for i = 1:2
    r1 = r{i};
    r2 = r{i};
    for j = 1:length(r{i})
        if r1(j) < 0
            r1(j) = 0;
        end
    end
    for j = 1:length(r{i})
        if r2(j) > 0
            r2(j) = 0;
        end
    end
%     figure
%     bar(r1,'FaceColor',[1 0 0],'EdgeColor',[1 1 1])
%     hold on
%     bar(r2,'FaceColor',[0 0 1],'EdgeColor',[1 1 1])
%     dateaxis('x', 3, date(1+window{i},1))
%     xlabel('交易次数')
%     ylabel('浮盈浮亏')
%     title('交易信号图')
%     grid on
%     hold off
end
%% 模型可视化结果

% 螺纹钢指数收益率分布于交易策略收益率分布
for i = 1:2

%     scrsz = get(0,'ScreenSize');
%     figure('Position',[scrsz(3)*1/4 scrsz(4)*1/6 scrsz(3)*4/5 scrsz(4)]*3/4);    
%     subplot(2,1,1)
%     hist(price2ret(data(:,1:5)))
%     legend('开盘价收益率','收盘价收益率','最高价收益率','最低价收益率','结算价收益率')
%     title('收益率分布图')
%     grid on
%     subplot(2,1,2)
%     cumrdistr = price2ret(ret{i});
%     hist(price2ret(ret{i}))
%     legend('策略交易收益率')
%     grid on
    
    % 螺纹钢走势及累计收益率曲线图
    createfigure(x{i}, cumr{i}, benchmark{i},dd{i})
    hold off
end
%% 各项指标的测试结果
% 模型准确率
Accuratcy = cell(1,2);
EED = cell(1,2);
SharpeRadio = cell(1,2);
Inforatio = cell(1,2);
for i = 1:2
    R_S{i} = Label(window{i}+1:end-1,:); %实际交易信号
    k = ones(length(P_S{i}),1);
    z = sum(k(P_S{i}==R_S{i}));
    Accuratcy{i} = z/length(k);
    % 预期最大回测
    rm = price2ret(ret{i});
    Return = tick2ret(ret{i});
    [mean,std] = normfit(Return);
    EED{i} = emaxdrawdown(mean,std,5);
    % 年化夏普比率
    SharpeRadio{i} = sqrt(250)*sharpe(rm,0);
    % 信息比率
    Inforatio{i} = inforatio(rm,price2ret(benchmark{i}));
end
%% 打印结果
strtemp = {'[以价量信息为样本属性集合]','[以技术指标为样本属性集合]'};
for i = 1:2
    fprintf(1,'------------------------------\n');
    fprintf(1,'各项指标的测试结果\n');
    fprintf(1,strtemp{i});
    fprintf(1,'\n');
    fprintf(1,['最佳滑窗敞口 =', num2str(window{i})]);
    fprintf(1,'\n');
    fprintf(1,['最优准确度 =', num2str(bestaccurate{i})]);
    fprintf(1,'\n');
    fprintf(1,['夏普比率 =', num2str(SharpeRadio{i})]);
    fprintf(1,'\n');
    fprintf(1,['信息比率 =', num2str(Inforatio{i})]);
    fprintf(1,'\n');
    fprintf(1,['最终获利点数 =', num2str(cumr{i}(end,1))]);
    fprintf(1,'\n');
    fprintf(1,['最大回撤 =', num2str(Maxdrawdown{i}),'   回撤时间为第',num2str(dd{i}(1,1)),'到',num2str(dd{i}(2,1)),'个交易日']);
    fprintf(1,'\n');
    fprintf(1,['预期未来10日内最大回撤 =', num2str(EED{i})]);
    fprintf(1,'\n');
end