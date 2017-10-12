c = xlsread('ssq.xlsx','sheet1','c3:I496')
red_3 = c(:,1) 
% high = 1.high;      % ��߼�
% low = 2.low;       % ��ͼ�
% Close = 3.close;     % ���̼�
% open = 4.open;      % ���̼�
% average = 5.average;   % ƽ����
% volume = 6.Volume;    % �ɽ���
% positions = 1.Positions; % �ֲ���
x1=[1 33]

[y1,PS] = mapminmax(x1)
train = mapminmax('apply',c,PS)
% date = datenum(luowen.date1); % ��������
% % ��һ������
%  ��ȡ������ֵ�Լ�����ά�ȣ�ѵ��������һ����
%  ͨ������mapminmax��������ͬ���ٵ�ѵ���������ݹ�һ��[-1��1]�ϣ����ڶ�ģ�͵�ѵ����
%  ���ڹ�һ��������ǰ���½��о�����ܣ����ﲻ��׸����
% Train = c';
% [Train,Train_ps] = mapminmax(Train); %��һ��
% train = Train';
Train1 = train(1:end-1,:);

% �Խ����ź���Ϊ������1�����ǣ�-1�������
Label = sign(red_3(2:end,:) - red_3(1:end-1,:));

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

% %% SVM�㷨��̬����
% %  Ѱ��ģ�������ŵĻ���wiondow�Ĵ�С
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
% strtemp = {'[�Լ�����ϢΪ�������Լ���]','[�Լ���ָ��Ϊ�������Լ���]'};
% % �����趨�ķ�ΧΪ: x~y ��
% for i = 1:2
% %     [bestaccurate{i},window{i},Accurate,xlab] = Bestwindow(Label,Train{i},bestc1,bestg1,15,65);
%     
%     [bestaccurate{i},window{i},Accurate,xlab] = ...
%                        Bestwindow(Label,Train{i},bestc{i},bestg{i},15,65);
%     
%     scrsz = get(0,'ScreenSize');
%     figure('Position',[scrsz(3)*1/4 scrsz(4)*1/6 scrsz(3)*4/5 scrsz(4)]*3/4);
%     plot(xlab,Accurate,'-*');
%     xlabel('�����ĳ���');
%     ylabel('׼ȷ��');
%     
%     title(['���ŵĻ�������=',num2str(window{i}),',���׼ȷ��=',num2str(bestaccurate{i}), ...
%         strtemp{i}], 'FontWeight', 'Bold');
%     
%     grid on
%     hold on
%     scatter(window{i},bestaccurate{i},'MarkerFaceColor',[1 0 0],'Marker','square');
%     hold off
% end
% %% C-SVM��̬����Ļز����
% %  ������ģ�ͽ��лز����
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
%     % �����ź�ȷ��
%     [P_S{i},decvalues] = SVMforecast(Label,Train{i},bestc{i},bestg{i},window{i}); % P_SΪ�㷨Ԥ���ź�
%     R_S{i} = Label(1+window{i}:end-1,:); % R_SΪ��ʵ�����ź�
%     
%     % Ԥ���ź���ʵ���źŶԱ�
%     Signal = [P_S{i} R_S{i}];
%     Signalforcast(P_S{i},R_S{i})
%     
%     % ÿ��ӯ�����ۼ��������
%     r{i}  = [0; P_S{i}.*(Close(window{i}+2:end-1,1)-Close(window{i}+1:end-2,1));]; % ÿ������
% end
% %% ����ָ��Ĳ��Խ��
% % ģ��׼ȷ��
% Accuratcy = cell(1,2);
% EED = cell(1,2);
% SharpeRadio = cell(1,2);
% Inforatio = cell(1,2);
% for i = 1:2
%     R_S{i} = Label(window{i}+1:end-1,:); %ʵ�ʽ����ź�
%     k = ones(length(P_S{i}),1);
%     z = sum(k(P_S{i}==R_S{i}));
%     Accuratcy{i} = z/length(k);
%     % Ԥ�����ز�
%     rm = price2ret(ret{i});
%     Return = tick2ret(ret{i});
%     [mean,std] = normfit(Return);
%     EED{i} = emaxdrawdown(mean,std,5);
%     % �껯���ձ���
%     SharpeRadio{i} = sqrt(250)*sharpe(rm,0);
%     % ��Ϣ����
%     Inforatio{i} = inforatio(rm,price2ret(benchmark{i}));
% end
%% ��ӡ���
% 
% %% �ƶ�ƽ�������ɺ�չʾ
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
% title('5�鲻ͬʱ�䳤�ȵ��ƶ�ƽ����չʾ','FontWeight','Bold');
% %% �����ƶ�ƽ������ָ��Ԥ���C-SVM�㷨��̬����
% %  �����ƶ�ƽ������ָ���γɵ�ģ��ѵ���������о�̬���棬�����ѵ��������Train2Ϊһ��
% %  200 X 5��double�;���x ? Train2 ��{-1,1}������ -1�����´������棩��1�����ϴ�����棩��
% 
% Train_Signal = cell(1,5);
% for i = 1:5
%     Train_Signal{i}(lead{i}>=lag{i}) = 1;                         % ��  (��ͷ)
%     Train_Signal{i}(lead{i}<lag{i}) = -1;                         % ��  (��ͷ)
% end
% 
% Train2 = cell2mat(Train_Signal);
% Train2 = reshape(Train2,200,5);
% %  g,c����Ѱ��
% [bestmse2,bestc2,bestg2] = SVMcgForClass(Label,Train2(2:end,:),-10,10,-10,10,5,0.5,0.5,0.5);
% cmd2 = ['-c ', num2str(bestc2), ' -g ', num2str(bestg2) ' -b ', num2str(1)];
% cmd2
% % ģ�ͽ�����ѵ��SVM����
% model = svmtrain(Label,Train2(2:end,:),cmd2);
% % ģ��Ԥ��
% [predict_label2, accuracy2, dec_values2] = svmpredict(Label,Train2(2:end,:),model,'-b 1');
% roc_label2(Label>=0) = 1;
% 
% %% ROC���߶Ա�
% 
% roc_label = [roc_label1;roc_label2];
% dec_values = [dec_values1(:,1)';dec_values2(:,1)'];
% 
% scrsz = get(0,'ScreenSize');
% figure('Position',[scrsz(3)*1/4 scrsz(4)*1/6 scrsz(3)*4/5 scrsz(4)]*3/4);
% 
% plotroc(roc_label,dec_values);
%% SVM�㷨��̬����
%  Ѱ��ģ�������ŵĻ���wiondow�Ĵ�С
Train = cell(1);

Train{1} = train(1:end-1,:);


bestc = cell(1);
bestc{1} = bestc1;

bestg = cell(1);
bestg{1} = bestg1;

window = cell(1);
bestaccurate = cell(1);

strtemp = {'[�Լ�����ϢΪ�������Լ���]','[�Լ���ָ��Ϊ�������Լ���]'};
% �����趨�ķ�ΧΪ: x~y ��
for i = 1
%     [bestaccurate{i},window{i},Accurate,xlab] = Bestwindow(Label,Train{i},bestc1,bestg1,15,65);
    
    [bestaccurate{i},window{i},Accurate,xlab] = ...
                       Bestwindow(Label,Train{i},bestc{i},bestg{i},50,110);
    
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
% %  ������ģ�ͽ��лز����
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
%     % �����ź�ȷ��
%     [P_S{i},decvalues] = SVMforecast(Label,Train{i},bestc{i},bestg{i},window{i}); % P_SΪ�㷨Ԥ���ź�
%     R_S{i} = Label(1+window{i}:end-1,:); % R_SΪ��ʵ�����ź�
%     
%     % Ԥ���ź���ʵ���źŶԱ�
%     Signal = [P_S{i} R_S{i}];
%     Signalforcast(P_S{i},R_S{i})
%     
%     % ÿ��ӯ�����ۼ��������
%     r{i}  = [0; P_S{i}.*(Close(window{i}+2:end-1,1)-Close(window{i}+1:end-2,1));]; % ÿ������
% end
% 
