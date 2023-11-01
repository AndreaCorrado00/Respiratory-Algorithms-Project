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
% ORDER OF THE VARIABLES:
% 1: RR
% 2: BR
% 3: ECG

%% Periodogram
% First attemp with periodogram: I choose to use this tecnique to investigate the specturm of the signals.
% I choose to use a lower number of points in order to find a more "clean"
% track. Moreover, this will simplify a lot the computational weight of the
% code. However, this tecnique result to be too much semplicistic and the
% conclusions that can be made are not satisfactory. So I choose to try
% with the ar technique. 
% AR MODEL performs better and helps to find out where the ecg bandwidth
% should be. Now i can proceed with te implementation ot the filter

% Second attemp with ar model:
Fs=250;
check=false;
if check
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
        % AR MODEL
        N=length(ECG(1:10000));
        p=100;
        th=ar(ECG(1:10000),p,'yw');
        [H,f]=freqz(1,th.a,N,Fs);
        f_S=f;
        S=(abs(H).^2)*th.NoiseVariance;

        figure(2)
        subplot(5,2,i)
        plot(f_S,S,'b')
        title(['sdf signal ',num2str(i)])
        xlim([0,Fs/2])
    end
end

%% ECG FILTERING
% 2. Understand where the ecg should be in frequency: 0.05-150 Hz
%% filter parametrs in Hz
Fc=250; %Hz
Wp=0.5;%Hz
Ws=(Wp-Wp/2);
                     
Rp=0.90; % percentage
Rs=0.1;


%% Parameters conversion
Wp=Wp/(Fc/2);
Ws=Ws/(Fc/2);
Rp=-20*log10(Rp);
Rs=-20*log10(Rs);

%% Filter determination
[n,Wn]=ellipord(Wp,Ws,Rp,Rs);
[b,a]=ellip(n,Rp,Rs,Wn,"low"); 

%% Freq response
[H,f]=freqz(b,a,512,Fc);
figure(1)
plot(f,abs(H))
xlim([0 15])
ylim([0 1.2])
grid on
title('Modulo del filtro')

%% Filtering 
% Perfomances of the filter
for i=1:10
    if i==5
        ECG=database.(sets(i)).S2.C2.data(:,3);
    elseif i==8
        ECG=database.(sets(i)).S2.C5.data(:,3);
    else
        ECG=database.(sets(i)).S2.C1.data(:,3);
    end
    if sum(isnan(ECG))>0
        ECG(isnan(ECG))=0;
    end
    ecg_filt=filter(b,a,ECG);

    figure(2)
    subplot(5,2,i)
    plot(ecg_filt,'b',LineWidth=2)
    hold on
    plot(ECG,'k--')
    title(['ECG drift signal ',num2str(i)])
    xlim([0,5000])
end
% Overall, the filter looks good for all the ecg traks. Technically, the
% drift is almost good for each track. So the signal can be easily detected
% without hp on the breath signal. 

% Now there are two main problems: 
    % 1. There are ecg signals equal to 0 
    % 2. Are there some correlation between the drift and the respiratory rithm??

% I have to think about the structure of the data. First of all: I have the
% RR signal (bpm) and the BR (cpm, counts per minute). Moreover I have the
% ecg signal and the drift avaluated simply filtering the raw ecg. How to
% evaluate the BR rithm from the drift?

%% Deep into the problem
% Between each maximum of the signal drift there is a time: the BR can be
% computed as: 1:peak_time=x_br:time_min -> time_min/peak_time=x_br
% But now what do you want? You have the BP signal -> there is yet a way
% to compute it. So which are the next steps? Where is the novelty?
% Why not validate a model capable of represent the respiratory signal? 

% Instead of finding the maximum could i use some geometry? If I build an
% orizontal line parametrized on the values of the ecg drift, every 2
% interceptions with the drift signal there will be a max and a min (it's a
% strong hp on the regularity of the signal). Moreover, the drift should be
% centered into zero. 
% The problem is that we don't have a signal enought regoular to ensure
% this hp. So? A possibility is make a strong smoothing...but this will
% make an other strong convolutional operation so not so good. So how?

% Moreover the huge amount of data caould compromize the overall result...

% The line idea is too easy. An other possibility is regolize the signal by
% using some smoothing algorithms or by identifing a good ar/ma model, why
% not. If the model describes correctly the signal variation, it could be
% possible to use the line idea with a good approximation. 

% There is an other little problem: you must be sure that the ecg filtered
% signal IS the respiratory signal. A good way could be do some experiments
% by computing manually the BR signal..


figure(3)
ECG=database.AER.S1.C1.data(:,3);
if sum(isnan(ECG))>0
        ECG(isnan(ECG))=0;
end
ecg_filt=filter(b,a,ECG);
plot(ecg_filt,'b',LineWidth=2)
hold on
plot(ECG,'k:')
title(['ECG drift signal ',num2str(i)])
xlim([0,15000])
% line idea
line=zeros(length(ecg_filt),1);
plot(line,'r')  

%% NEXT STEPS
% 1. asset is the filtered signal is a good approximation of the
% respiratory signal
% 2. find out a way to automathize the BR extraction.



