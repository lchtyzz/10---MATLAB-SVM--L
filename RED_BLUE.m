
 r = cell(1,7);
cmdd = cell(1,7);
accuracy_all = cell(1,7);
   % c = xlsread('ssq.xlsx','sheet1','J2:P495')
   %c = xlsread('ssq.xlsx','sheet2','J2:P495') 
 %  c = xlsread('ssq.xlsx','sheet2','q2:w495')



for n=1:1:7
   %%n=1
   
    %c = xlsread('ssq.xlsx','sheet1','c3:I496')
    
    %red_3 = c(:,n) 
    %x1=[1 33]
    c = xlsread('ssq.xlsx','sheet2','J2:p497');
   d = xlsread('ssq.xlsx','sheet1','q2:w497');
    red_3 = c(:,n) ;
    x1=[0 10];

    [y1,PS] = mapminmax(x1);
    train = mapminmax('apply',c,PS);
    Train1 = train(1:end-1,:);
    Train2 = train(1:end,:);

% �Խ����ź���Ϊ������1�����ǣ�-1�������
  Label = sign(red_3(2:end,:) - red_3(1:end-1,:));
   
  % label
  Label( Label == 0 ) = 1;
 %label = red_3(2:end,:);
 %label( label == 0 ) = -1;
 %Label = label;
   % Label=(red_3(2:end,:));
   label_add=-1;
   Label1=Label;
    Label2 = [Label;label_add];
%% C-SVM�㷨��̬����
%  �����õ��յļ۸���Ϣ���Ե��յ������ź���ѵ����ͨ������SVMcgForClass��������֤��
%  ������֪����ȫ���۸���Ϣ��ǰ���£�ģ�Ͷ������źŵ��жϾ�׼�ȡ�

%  ����Ѱ��
   % [bestmse1,bestc1,bestg1] = SVMcgForClass(Label1,Train1,-8,8,-8,8,5,0.5,0.5,1);
   [bestmse1,bestc1,bestg1] = SVMcgForClass(Label1,Train1,-8,8,-8,8,5,1,1,2);
    cmd1 = ['-c ', num2str(bestc1), ' -g ', num2str(bestg1) ' -b ', num2str(1)];
%  cmd1
% ģ�ͽ�����ѵ��SVM����
    model = svmtrain(Label,Train1,cmd1);
% ģ��Ԥ��
    [predict_labeln, accuracy1, dec_values1] = svmpredict(Label2,Train2,model,'-b 1');
%%   %






Train = cell(1,2);

Train{1} = train(1:end-1,:);
Train{2} = Train2(1:end-1,:);

bestc = cell(1,2);
bestc{1} = bestc1;
bestc{2} = bestc1;
bestg = cell(1,2);
bestg{1} = bestg1;
bestg{2} = bestg1;
window = cell(1,2);
% bestaccurate = cell(1,2);
% 
% strtemp = {'[�Լ�����ϢΪ�������Լ���]','[�Լ���ָ��Ϊ�������Լ���]'};
% for i = 1
% %        [bestaccurate{i},window{i},Accurate,xlab] = Bestwindow(Label,Train{i},bestc1,bestg1,15,65);
%     
%          [bestaccurate{i},window{i},Accurate,xlab] = ...
%                            Bestwindow(Label,Train{i},bestc{i},bestg{i},15,65);
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
% 
%     
%     [predict_labeln_2,decvalues] = SVMforecast(Label,Train{i},bestc{i},bestg{i},window{i}); % P_SΪ�㷨Ԥ���ź�
% end
%     %
    
     accuracy_all{n}=accuracy1;
     r{n}=predict_labeln(end,:);
     cmdd{n}=cmd1;
end

