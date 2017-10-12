%% ����C-SVM�㷨�����Ƹ�������Լ����ģ��(R)   ���ߣ�������
% Modified by ����faruto 2014.06.01
%  ֧��������( Support Vector Machines, SVM)�ǽ�������Ӧ���ڽ�ģ��һ���µ�ѧϰ����
%  �봫ͳ���������,֧���������㷨���ս�ת��Ϊһ��������Ѱ������,�������Ͻ��õ��Ľ���ȫ�����ŵ�,
%  ����������������޷�����ľֲ���Сֵ���⡣
%
%  ��ƪ����ּ������SVMģ��ϵͳ�������Ƹ��ڻ�������Լ���ж�̬�Ļز���飬Ŀ����Ϊ�˼��
%  SVM�㷨����Ʒ�ڻ��н��м۸����ݺ�Ԥ��Ŀ����ԡ�
%
%  ���������漰��SVM�㷨������̨���ѧ������������libsvm�����䣻SVMcgForClass�����ӿ�������
%  ����������LIBSVM-farutoUltimateVersion�����䣻����������ڱ����ߡ�
%% ���ݵ�ѡȡ��Ԥ����
%  �������ݣ����Ƹ�������Լ��10/23/2012 ~ 08/20/2013��
%  �����������ݴ洢��luowen.mat,����Ϊ200X8��dataset���ݡ�������BR������Լ�ģ�
%  ���̼ۡ����̼ۡ���߼ۡ���ͼۡ�ƽ���ۡ��ɽ������ֲ�����7������ָ�꣬��
%  ��һ��ʱ������Ϣ��
%  ������Դ��wind���ݿ�

% ��������
load luowen.mat

% ��ȡ��������
data = [luowen.close, luowen.open, luowen.high, luowen.low, luowen.average, luowen.Volume, luowen.Positions];

% ��ȡ��������
high = luowen.high;      % ��߼�
low = luowen.low;       % ��ͼ�
Close = luowen.close;     % ���̼�
open = luowen.open;      % ���̼�
average = luowen.average;   % ƽ����
volume = luowen.Volume;    % �ɽ���
positions = luowen.Positions; % �ֲ���

date = datenum(luowen.date1); % ��������

%% K��ͼ���۸���Ϣ

%  �����������ݵ�K��ͼ�Լ�����ڵĳɽ����ͳֲ���
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
title('RB������Լ��K��ͼ', 'FontWeight','Bold');
grid on

ax(2) = subplot(3,1,3);
bar(volume,'FaceColor',[1 0 0],'EdgeColor',[1 1 1],'BarWidth',1);
hold on
plot(positions,'LineWidth',2,'Color',[0 0 1]);
legend('�ɽ���','�ֲ���');
title('�ɽ����ͳֲ�������ͼ','FontWeight','Bold');
XTick = [1:floor(length(date)/7):length(date)];
XTickLabel = datestr(date(XTick,1));
set(gca,'XTick', XTick);
set(gca,'XTickLabel', XTickLabel);
grid on
linkaxes(ax,'x')
hold off
%% ��һ������
%  ��ȡ������ֵ�Լ�����ά�ȣ�ѵ��������һ����
%  ͨ������mapminmax��������ͬ���ٵ�ѵ���������ݹ�һ��[-1��1]�ϣ����ڶ�ģ�͵�ѵ����
%  ���ڹ�һ��������ǰ���½��о�����ܣ����ﲻ��׸����
Train = data';
[Train,Train_ps] = mapminmax(Train); %��һ��
train = Train';
Train1 = train(2:end,:);


% �Խ����ź���Ϊ������1�����ǣ�-1�������
Label = sign(Close(2:end,:) - Close(1:end-1,:));

Label( Label == 0 ) = 1;
%% C-SVM�㷨��̬����
%  �����õ��յļ۸���Ϣ���Ե��յ������ź���ѵ����ͨ������SVMcgForClass��������֤��
%  ������֪����ȫ���۸���Ϣ��ǰ���£�ģ�Ͷ������źŵ��жϾ�׼�ȡ�

%  ����Ѱ��
[bestmse1,bestc1,bestg1] = SVMcgForClass(Label,Train1,-8,8,-8,8,5,0.5,0.5,1);
cmd1 = ['-c ', num2str(bestc1), ' -g ', num2str(bestg1) ' -b ', num2str(1)];
%  cmd1
% ģ�ͽ�����ѵ��SVM����
model = svmtrain(Label,Train1,cmd1);
% ģ��Ԥ��
[predict_label1, accuracy1, dec_values1] = svmpredict(Label,Train1,model,'-b 1');
roc_label1(Label>=0) = 1;

%% �ƶ�ƽ�������ɺ�չʾ
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
title('5�鲻ͬʱ�䳤�ȵ��ƶ�ƽ����չʾ','FontWeight','Bold');
%% �����ƶ�ƽ������ָ��Ԥ���C-SVM�㷨��̬����
%  �����ƶ�ƽ������ָ���γɵ�ģ��ѵ���������о�̬���棬�����ѵ��������Train2Ϊһ��
%  200 X 5��double�;���x ? Train2 ��{-1,1}������ -1�����´������棩��1�����ϴ�����棩��

Train_Signal = cell(1,5);
for i = 1:5
    Train_Signal{i}(lead{i}>=lag{i}) = 1;                         % ��  (��ͷ)
    Train_Signal{i}(lead{i}<lag{i}) = -1;                         % ��  (��ͷ)
end

Train2 = cell2mat(Train_Signal);
Train2 = reshape(Train2,200,5);
%  g,c����Ѱ��
[bestmse2,bestc2,bestg2] = SVMcgForClass(Label,Train2(2:end,:),-10,10,-10,10,5,0.5,0.5,0.5);
cmd2 = ['-c ', num2str(bestc2), ' -g ', num2str(bestg2) ' -b ', num2str(1)];
cmd2
% ģ�ͽ�����ѵ��SVM����
model = svmtrain(Label,Train2(2:end,:),cmd2);
% ģ��Ԥ��
[predict_label2, accuracy2, dec_values2] = svmpredict(Label,Train2(2:end,:),model,'-b 1');
roc_label2(Label>=0) = 1;

%% ROC���߶Ա�

roc_label = [roc_label1;roc_label2];
dec_values = [dec_values1(:,1)';dec_values2(:,1)'];

scrsz = get(0,'ScreenSize');
figure('Position',[scrsz(3)*1/4 scrsz(4)*1/6 scrsz(3)*4/5 scrsz(4)]*3/4);

plotroc(roc_label,dec_values);
%% SVM�㷨��̬����
%  Ѱ��ģ�������ŵĻ���wiondow�Ĵ�С
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

strtemp = {'[�Լ�����ϢΪ�������Լ���]','[�Լ���ָ��Ϊ�������Լ���]'};
% �����趨�ķ�ΧΪ: x~y ��
for i = 1:2
%     [bestaccurate{i},window{i},Accurate,xlab] = Bestwindow(Label,Train{i},bestc1,bestg1,15,65);
    
    [bestaccurate{i},window{i},Accurate,xlab] = ...
                       Bestwindow(Label,Train{i},bestc{i},bestg{i},15,65);
    
    scrsz = get(0,'ScreenSize');
    figure('Position',[scrsz(3)*1/4 scrsz(4)*1/6 scrsz(3)*4/5 scrsz(4)]*3/4);
    plot(xlab,Accurate,'-*');
    xlabel('�����ĳ���');
    ylabel('׼ȷ��');
    
    title(['���ŵĻ�������=',num2str(window{i}),',���׼ȷ��=',num2str(bestaccurate{i}), ...
        strtemp{i}], 'FontWeight', 'Bold');
    
    grid on
    hold on
    scatter(window{i},bestaccurate{i},'MarkerFaceColor',[1 0 0],'Marker','square');
    hold off
end
%% C-SVM��̬����Ļز����
%  ������ģ�ͽ��лز����
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
    % �����ź�ȷ��
    [P_S{i},decvalues] = SVMforecast(Label,Train{i},bestc{i},bestg{i},window{i}); % P_SΪ�㷨Ԥ���ź�
    R_S{i} = Label(1+window{i}:end-1,:); % R_SΪ��ʵ�����ź�
    
    % Ԥ���ź���ʵ���źŶԱ�
    Signal = [P_S{i} R_S{i}];
    Signalforcast(P_S{i},R_S{i})
    
    % ÿ��ӯ�����ۼ��������
    r{i}  = [0; P_S{i}.*(Close(window{i}+2:end-1,1)-Close(window{i}+1:end-2,1));]; % ÿ������
end
%% ֹ�����
% ��stopΪֹ��㣬�ﵽʱ����ֹ�����
for i = 1:2
    stop = 30;
    for j = 1:length(r{i})
        if r{i}(j)<-stop
            r{i}(j) = -stop;
        end
    end
    
    cumr{i} = cumsum(r{i}); % �ۼ��ܻ�������
    benchmark{i} = Close(window{i}+2:end,1); % �۸�Ļ�׼����
    x{i} = 1:length(Close(window{i}+2:end,1));
    % ģ�͵����ز�
    ret{i} = cumr{i}+1000*ones(length(cumr{i}),1);
    [Maxdrawdown{i},dd{i}] = maxdrawdown(ret{i},'return');
end
%% ÿ�ʽ���ӯ��ͼ
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
%     xlabel('���״���')
%     ylabel('��ӯ����')
%     title('�����ź�ͼ')
%     grid on
%     hold off
end
%% ģ�Ϳ��ӻ����

% ���Ƹ�ָ�������ʷֲ��ڽ��ײ��������ʷֲ�
for i = 1:2

%     scrsz = get(0,'ScreenSize');
%     figure('Position',[scrsz(3)*1/4 scrsz(4)*1/6 scrsz(3)*4/5 scrsz(4)]*3/4);    
%     subplot(2,1,1)
%     hist(price2ret(data(:,1:5)))
%     legend('���̼�������','���̼�������','��߼�������','��ͼ�������','�����������')
%     title('�����ʷֲ�ͼ')
%     grid on
%     subplot(2,1,2)
%     cumrdistr = price2ret(ret{i});
%     hist(price2ret(ret{i}))
%     legend('���Խ���������')
%     grid on
    
    % ���Ƹ����Ƽ��ۼ�����������ͼ
    createfigure(x{i}, cumr{i}, benchmark{i},dd{i})
    hold off
end
%% ����ָ��Ĳ��Խ��
% ģ��׼ȷ��
Accuratcy = cell(1,2);
EED = cell(1,2);
SharpeRadio = cell(1,2);
Inforatio = cell(1,2);
for i = 1:2
    R_S{i} = Label(window{i}+1:end-1,:); %ʵ�ʽ����ź�
    k = ones(length(P_S{i}),1);
    z = sum(k(P_S{i}==R_S{i}));
    Accuratcy{i} = z/length(k);
    % Ԥ�����ز�
    rm = price2ret(ret{i});
    Return = tick2ret(ret{i});
    [mean,std] = normfit(Return);
    EED{i} = emaxdrawdown(mean,std,5);
    % �껯���ձ���
    SharpeRadio{i} = sqrt(250)*sharpe(rm,0);
    % ��Ϣ����
    Inforatio{i} = inforatio(rm,price2ret(benchmark{i}));
end
%% ��ӡ���
strtemp = {'[�Լ�����ϢΪ�������Լ���]','[�Լ���ָ��Ϊ�������Լ���]'};
for i = 1:2
    fprintf(1,'------------------------------\n');
    fprintf(1,'����ָ��Ĳ��Խ��\n');
    fprintf(1,strtemp{i});
    fprintf(1,'\n');
    fprintf(1,['��ѻ������� =', num2str(window{i})]);
    fprintf(1,'\n');
    fprintf(1,['����׼ȷ�� =', num2str(bestaccurate{i})]);
    fprintf(1,'\n');
    fprintf(1,['���ձ��� =', num2str(SharpeRadio{i})]);
    fprintf(1,'\n');
    fprintf(1,['��Ϣ���� =', num2str(Inforatio{i})]);
    fprintf(1,'\n');
    fprintf(1,['���ջ������� =', num2str(cumr{i}(end,1))]);
    fprintf(1,'\n');
    fprintf(1,['���س� =', num2str(Maxdrawdown{i}),'   �س�ʱ��Ϊ��',num2str(dd{i}(1,1)),'��',num2str(dd{i}(2,1)),'��������']);
    fprintf(1,'\n');
    fprintf(1,['Ԥ��δ��10�������س� =', num2str(EED{i})]);
    fprintf(1,'\n');
end