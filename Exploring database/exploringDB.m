
%% Sport Database 
% includes 126 cardiorespiratory datasets (CRD) from 81 subjects while performing 10 different sports: 
% aerial silks, basketball, CrossFit, fitness, jogging, middle-distance running, running, soccer, tennis and Zumba (Table 1). 
% Data are organized in a tree structure (Fig. 1). The main directory (SportDB) includes a folder for each sport 
% (AER, BAS, CRO, FIT, JOG, MID, RUN, SOC, TEN and ZUM, respectively). Each sport folder contains a subfolder 
% for each subject performing that sport (Sn, with n = 1,2 …). Eventually, each subject subfolder contains a 
% sub-subfolder for each acquisition performed by that subject (CRDm, with m = 1,2 …). 
% Each CRDm includes a demographic data file (Dem.txt), a cardiorespiratory data MATLAB structure (Data.mat)
% and a training note file (TrNote.txt). The demographic data file includes information about gender (male: 0; female: 1), 
% age (years), weight (kg), height (cm), smoking habit (no: 0; yes: 1), alcohol consumption (no: 0; sometimes: 1) 
% and weekly training rate (integer from 1 to 7); missing data are indicated with ‘NA’. 
% The cardiorespiratory data structure contains the recorded cardiorespiratory signals during the acquisition and includes four fields: 
% Data.ECG, containing the raw electrocardiogram (ECG); 
% Data.HR, containing the raw heart-rate (HR) series; 
% Data.RR, containing the RR-interval series; and 
% Data.BR containing the raw breathing-rate (BR) series. 
% Characteristics of the cardiorespiratory signals (sampling frequency, amplitude range and data-loss index) are reported in Table 2. 
% The training-notes file contains information about duration of the training phases during the acquisition and details about the 
% sport-related acquisition protocol; acquisition phases annotated as ‘none’ indicate training phases not practiced by the subject.
% 
% Signal	Sampling Frequency	AmplitudeRange	DataLoss
% ECG	      250 Hz	        0.25–15 mV	       0 mV
% HR	        1 Hz	        25-240 bpm	       0 bpm
% RR	        1 Hz	        250–2400 ms	        Inf
% BR	        1 Hz	        3–70 cpm	    6553.5 cpm
% ECG = electrocardiogram; HR = heart-rate series; RR = RR-interval series; BR = breathing-rate series.

% As my intention is making a ML alghoritm, I'll consider the differente
% acquisition of each subject for each sport as a "new" subject. In fact,
% the aim will be finding the BR signal from the other.

%% First observations on the dataset:
% 1. Data are collected in a way not very usefull for ML training.
% 2. Data vector haven't the same length between subject (but we have so
% much information for each subject...
% 3. Ecg data analysis should be done carefully
% 4. RR and HR are DIRECTLY RELATED! (Inverse proportionality)
% 5. the different sample frequency used for ECG and
% other measures imply the huge difference into the length of the
% vectors. BUT the ECG is sampled 250 times when other are sampled 1! HP:
% considering a point every 250 measures? (Not a good idea i think)
% 6. raw data, specially of ecg, are very noisy. How to deal with this
% fact?

% Point 5 is critic. I cannot remove some data (It will have no sense).
% Could I augment the data? (RR is constant during 250-length intervals)

% Point 6 is critic too. Tecnically different time series of ECG correspont
% to different times of the experimental protocol. So Tecnically i cannot
% remove them. BUT my hope is this: i want a model able to predict RR and
% other respiratory factor directly from ECG, so i could assume that the
% noisy data can be neglected because what chainged from a certain phase of
% the excerse is the frequency of the rithm not the amplitude!
% So potentially i could cut the data if they ar over a certain
% physiological threshold.


%% Proof of what said in 4
% plot(60*1000./Data.HR)
% hold on
% plot(Data.RR)

%% Proof of what said in 5: the resoult isn't very clear.
% ecg=Data.ECG;
% ecg_mask=zeros(length(ecg),1);
% ecg_mask(1:250:end)=1;
% 
% ecg=ecg.*ecg_mask;
% ecg=nonzeros(ecg);
% plot(ecg)

%% Proof of what said in the note after point 5
% new_RR=zeros(length(Data.ECG),1);
% RR_indices=1:length(Data.RR);
% j=1;
% for i=1:250:length(Data.ECG)
% 
%     new_RR(i:i+250)=Data.RR(RR_indices(j));
%     j=j+1;
% end
% 
% plot(new_RR)
% hold on
% plot(Data.ECG*500) % scale factor for rapresentation
% 
% % What does it mean? I proceed with a data augmentation using the fact that
% % i can suppose constant the RR in a transient of 1/250 sec. Same for other
% % derivates measures.


%% Possible pypeline so far
% 1. Cleaning and building the best dataset from these data. Even CSV
% format
% 2. Evaluating the drift from the ecg signal with traditional tecniques
% (Ideally, implementable)
% 3. correlate the drift witht the RR signal (In this analysis you cannot
% use the HR signal because of the direct correlation with RR signal)
% Find out if is possibile to compute other respiratory desciptors from
% ecg.

%% BUILDING THE DATASET
% Operations are made step by step, then I'll make a cycle to upload each
% subfolder and so on

%% FIND OUT THE BEST VECTOR SIZE

% Now i would like to identify the best length of the vector of data. So,
% I'll eliminate part of the points and I'll re-make the dataset with same
% dimensions of the columns
% Initial HP, a possibility is counting i.e 2000 sec of acticity centered
% into the center of the vector

[new_RR,new_BR,new_HR,new_ECG]=resize_around_center(2000,Data);

%% Data Augmentation for HR,BB,BR
[new_RR,new_BR,new_HR]=data_augmentation(new_ECG,new_RR,new_HR,new_BR);

%% Data Cleaning for non-physiological values 
% Now data cleaning. First of all i will work with data with zero mean. I
% don't know if it could be usefull normalize them to have zero variance
% too. Then I will make NaN all the values over the physiological
% threshold. Up to now,I don't know if this is a good idea.

[new_RR,new_BR,new_HR,new_ECG]=remove_mean(new_RR,new_BR,new_HR,new_ECG);

new_ECG=remove_nonphysio_val(new_ECG);
% % % Just to visualize the result
% figure(1)
% subplot(221)
% plot(new_RR)
% title('RR')
% subplot(222)
% plot(new_HR) 
% title('HR')
% subplot(223)
% plot(new_BR) 
% title('BR')
% subplot(224)
% plot(new_ECG) 
% title('ECG')
% xlim([0,0.5*10'^4])

% NOW all the procedure must be automatized. By looking into each folder
% and by looking into each dataset, you should build a big dataset with the
% ecg and the other variables...BUT I THINK YOU SHOULD THINK CAREFULLY
% ABOUT THE STRUCTURE OF THE DATASET!


























