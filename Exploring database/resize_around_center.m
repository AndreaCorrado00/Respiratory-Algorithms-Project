
function [new_RR,new_BR,new_HR,new_ECG]=resize_around_center(duration,Data)


% This function resize the vectors taking the central -duration- points of
% the vector given as input

%% Importat HP:
% 1. Data is a struct
% 2. ecg is sampled at 250Hz, other signals at 1Hz

%% Building the output
time_ex=length(Data.RR); % Exploiting that RR is recorded with a frequency of 1Hz
% center of the workout
half_duration=round(duration/2);
center=round(time_ex/2);

% Mask for 1Hz data
mask=zeros(time_ex,1);
mask(center-half_duration:center+half_duration-1)=1;

%Mask for ecg (250Hz)
center_ecg=round(time_ex*250/2);
mask_ecg=zeros(time_ex*250,1);
mask_ecg(center_ecg-half_duration*250:center_ecg+half_duration*250-1)=1;

% masking and resizing
new_RR=Data.RR(mask==1);
new_BR=Data.BR(mask==1);
new_HR=Data.HR(mask==1);
new_ECG=Data.ECG(mask_ecg==1);

