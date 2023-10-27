clc
clear
close
%% Evaluation of the drift from the data
% The scope of this section is building an implementable filter capable of
% evaluating the movement of the ecg becouse of the drift. Now i made a
% strong HP: becouse of the data are acquired using a chest band, the drift
% is "only" a function of the chest movement and, in conclusion, of the
% respiration.

load("D:\Desktop\progetto\database.mat")
%% Evaluation of the spectrum of the signals
% Here i compare different spectrums of different signals of the DB

sets=["AER","BAS","CRO","FIT","JOG","MID","RUN","SOC","TEN","ZUM"];

%% Periodogram
% First attemp with periodogram: I choose to use this tecnique to investigate the specturm of the signals.
% I choose to use a lower number of points in order to find a more "clean"
% track. Moreover, this will simplify a lot the computational weight of the
% code. However, this tecnique result to be too much semplicistic and the
% conclusions that can be made are not satisfactory. So I choose to try
% with the ar technique.

% Second attemp with ar model:
Fs=250;
for i=1:10
    if i==5
        ECG=database.(sets(i)).S1.C3.data(:,3);
    elseif i==8
        ECG=database.(sets(i)).S1.C9.data(:,3);
    else
        ECG=database.(sets(i)).S1.C1.data(:,3);
    end
if sum(isnan(ECG))>0
    ECG(isnan(ECG))=0;
end


% PERIODOGRAM
% N=length(ECG(1:1000));
% FT_x=fft(ECG(1:1000),N);
% subplot(5,2,i)
% S=abs(FT_x).^2/N;
% f_S=0:Fs/N:Fs-Fs/N;%vettore delle frequenza

% AR MODEL
N=length(ECG(1:10000));
p=30;
th=ar(ECG(1:10000),p,'yw');
[H,f]=freqz(1,th.a,N,Fs); 
f_S=f;
S=(abs(H).^2)*th.NoiseVariance;

subplot(5,2,i)
plot(f_S,S,'b')
title(['sdf signal ',num2str(i)])
xlim([0,10])
end

% to do:
% 1. Verify the quality of the spectrum (change the order)
% 2. Understand where the ecg should be in frequency 
