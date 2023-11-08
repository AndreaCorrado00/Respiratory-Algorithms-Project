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

%% ECG FILTERING: Traditional way
% 2. Understand where the ecg should be in frequency: 0.05-150 Hz

%% LP Filter
[H,f,b,a]=my_ellip_filt(250,0.5,0.6,0.9,0.005,'low');
%  Freq response
figure(1)
plot(f,abs(H))
xlim([0 15])
ylim([0 1.2])
grid on
title('Magnitude Low Pass')

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
% drift is almost good for each track. So the signal seem to be detectable
% without hp on the breath signal. 

% Now there are two main problems: 
    % 1. There are ecg signals equal to 0 
    % 2. Are there some correlation between the drift and the respiratory rithm??

% I have to think about the structure of the data. First of all: I have the
% RR signal (bpm) and the BR (cpm, counts per minute). Moreover I have the
% ecg signal and the drift avaluated simply filtering the raw ecg. How to
% evaluate the BR rithm from the drift?

% There is an other problem: how to deal with the fact that, surely, once
% you have filterde the signal you have lost even a part of the information
% on the respiratory signal? 

%% Deep into the problem
figure(3)
ECG=database.JOG.S1.C3.data(:,3);
if sum(isnan(ECG))>0
        ECG(isnan(ECG))=0;
end
ecg_filt=filter(b,a,ECG);
plot(ecg_filt,'b',LineWidth=2)
hold on
plot(ECG,'k:')
title('ECG drift signal')
xlim([30000,50000])
% line idea
line=zeros(length(ecg_filt),1);
plot(line,'r')  

%% Coclusion for the filtering
% There are so many things that compromize the overall result. First of
% all, not all the signals are enough "pure" to ensure a good filtration.
% Thus, in many of them there could be a lot or artifacts. So we need
% something that can, in some way, regolarize the signal (at least the
% respiratory one). 
% Moreover, the tecnique is still too semplicistic, in fact surely exlude
% some informative contenents becouse of the sovrapposition between the
% useful signal and the "noise".
% To conclude, no one ensure that the filtered signal IS the respiratory
% signal. It's a real problem!

% So I need some time to stop and think. Some questions are:
    % 1. Is the db really build well? do you really need millions of
    % values? 
    % 2. Can you build a way to construct a dataset of really usefull
    % signals?
    % 3. Once you have the new dataset, can you build the curve of the
    % respiratory signal? Think about the hp 
    % 4. If you think you are able to do it, which is the best way to
    % extract the signal?
    % 5. How to deal with the data not excluded from the db? Can you handle
    % the problem of recostruction of the signal?

 % These questions are trivial. You must define the breakpoints of the
 % project: where you want to go? A description of all the time of
 % acquisition? 

 % Moreover, are there some algorithms that are the state of art into this
 % field. Find them and figure out how to use them. 

