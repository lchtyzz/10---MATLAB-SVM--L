function [ MaxAccurate,window,Accurate,xlab] = Bestwindow( Label,Train,bestc,bestg,x,y )
%BESTWINDOW Summary of this function goes here
%   Detailed explanation goes here
Accurate = zeros(y-x,1);
xlab = zeros(y-x,1);
for i = x:y

    P_S = SVMforecast(Label,Train,bestc,bestg,i);
    R_S = Label(i+1:end-1,:);
    
    k = ones(length(P_S),1);
    z = sum(k(P_S==R_S));
    Accurate(i-x+1,1) = z/length(k);
    xlab(i-x+1,1) = i;
end
[MaxAccurate,ind] = max(Accurate);
window = ind + x-1;
end

