function [new_RR,new_BR,new_HR,new_ECG]=remove_mean(RR,BR,HR,ECG)
% removes the mean from signals
new_RR=RR-mean(RR);
new_HR=HR-mean(HR);
new_BR=HR-mean(BR);
new_ECG=ECG-mean(ECG);