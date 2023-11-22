clc
clear
close
%% NEW VERSION OF THE DB
% The idea behind this code is creating a new DB and, why not, other
% possible versions of it. 

%% Structural DB 
% Here i build a struct with the db inside as it is in origin

database=original_DB_struct();

%% Simpler DB
% Here i build a DB simpler and more easier to work on. In particular the
% DB will have:
    % 1. mean of the signals equal to zero
    % 2. shorter signals, under sampled ECG at 1Hz (take 1 sample every
    %       250)
    % 3. Take the ecg as reference and find a window of signal enough
    %       regular to be analyzed (!!!!)
    % 4. Consider as limit the shorter signal in the db and start from such
    %       dimension

% Temp db without mean
temp_db=remove_mean();
    % Verify
    figure
    plot(temp_db.AER.S1.CRD1.RR)
    title(['Example of data without mean, mean = ',num2str(round(mean(temp_db.AER.S1.CRD1.RR)))])
    
% Undersampled ecg
% temp_db=undersampling(temp_db);
%     % Verify
%     figure
%     subplot(211)
%     plot(temp_db.AER.S1.CRD1.ECG)
%     title(['Undersampled, length of ',num2str(length(temp_db.AER.S1.CRD1.ECG))])
%     subplot(212)
%     plot(database.AER.S1.CRD1.ECG)
%     title(['Original sampling, length of ',num2str(length(database.AER.S1.CRD1.ECG))])
%     xlabel(['Reduction of: ', num2str((length(temp_db.AER.S1.CRD1.ECG)/length(database.AER.S1.CRD1.ECG)*100)),'%'])

% Undersampling the ecg not seems to be a good idea, becouse of one could
% lost too much information. I don't want to explude completely this idea,
% but i have to face with such fact. So I'll transform the code into a
% funcion and, if necessary, I'll use it.


% cutting unphysiological values
trial=temp_db.AER.S1.CRD1.ECG;
sets=["AER","BAS","CRO","FIT","JOG","MID","RUN","SOC","TEN","ZUM"];
for i=1:length(sets)
    set=sets(i);
    for j=1:length(fieldnames(temp_db.(set)))
        s=['S',num2str(j)];
        for k=1:length(fieldnames(temp_db.(set).(s)))
            crd=['CRD',num2str(k)];
            ECG=temp_db.(set).(s).(crd).ECG;
            mask=ECG<-0.1 | ECG > 0.1;
            ECG(mask)=0;

            temp_db.(set).(s).(crd).ECG=ECG;
        end
    end
end
    % Verify
    figure
    subplot(211)
    plot(trial)
    title('Original ECG')
    subplot(212)
    plot(temp_db.AER.S1.CRD1.ECG)
    title('New ECG corrected' )
    ylim([-0.5,0.5])

%% Data selection 
%     % model of data
% model=temp_db.AER.S1.CRD1.ECG(993468:993573);
% ref=model;
% mask=zeros(1,length(model));
% plot(model,Marker='o',LineStyle='none')
% 
% mask(1)=1;
% mask(12)=1;
% mask(29)=1;
% mask(40)=1;
% mask(45)=1;
% mask(50)=1;
% mask(54)=1;
% mask(58)=1;
% mask(76)=1;
% %mask(95)=1;
% mask(end)=1;
% 
% model=model(mask==1);
% %I would like to extract a "smoothed" model
% ts=1:1:length(model);
% B=diag(ones(1,length(model)));
% m=3;
% sd2=0.01;
% tv=0.02:0.02:ts(end);
% [uhat,~ ,~ ,~ ,~ ,~ ]=smoothdiscrepancy(ts,model,B,sd2,tv,m);
% 
% 
% plot(ts,model,'bo',tv, uhat,'r-')
% %%
% % Finally the model of data.
% reference=uhat(round(ts/0.02));
% reference=repmat(reference,50,1);
% % Now with such model I'll pass all the dataset to find if and where there
% % are possible candidates to our analysis
% window=2000;
% step=length(reference);
% 
% sets=["AER","BAS","CRO","FIT","JOG","MID","RUN","SOC","TEN","ZUM"];
% 
% for i=1:1 %length(sets)
%     set=sets(i);
%     for j=2:2 %length(fieldnames(temp_db.(set)))
%         s=['S',num2str(j)];
%         for k=1:1 %length(fieldnames(temp_db.(set).(s)))
%             crd=['CRD',num2str(k)];
%             ECG=temp_db.(set).(s).(crd).ECG;
%             candidate=[];
%             for h=1:step:length(ECG)-step
%                 R=corr(reference, ECG(h:h+step-1));
%                 if R>0
%                     candidate=[candidate;ECG(h:h+step-1)];
%                     disp(['Candidate has length = ',num2str(length(candidate))])
% 
%                 elseif R<0 || isnan(R)
%                     disp(R)
%                     candidate=[candidate;zeros(step,1)];
%                 else
%                     disp('aooo')
%                     break
%                 end
%             end
%         end
%     end
% end
% %%
% plot(candidate)
% ylim([-0.2,0.2])
% window=2000;
% step=length(reference);
% 
% sets=["AER","BAS","CRO","FIT","JOG","MID","RUN","SOC","TEN","ZUM"];
% 
% for i=1:1 %length(sets)
%     set=sets(i);
%     for j=2:2 %length(fieldnames(temp_db.(set)))
%         s=['S',num2str(j)];
%         for k=1:1 %length(fieldnames(temp_db.(set).(s)))
%             crd=['CRD',num2str(k)];
%             ECG=temp_db.(set).(s).(crd).ECG;
%             candidate=[];
%             for h=1:step:length(ECG)-step
%                 R=corr(reference, ECG(h:h+step-1));
%                 if R>0
%                     candidate=[candidate;ECG(h:h+step-1)];
%                     disp(['Candidate has length = ',num2str(length(candidate))])
% 
%                 elseif R<0 || isnan(R)
%                     disp(R)
%                     candidate=[candidate;zeros(step,1)];
%                 else
%                     disp('aooo')
%                     break
%                 end
%             end
%         end
%     end
% end
% %%
% plot(candidate)
% ylim([-0.2,0.2])
% Il metodo della correlazione non è un buon metodo si a alivello
% computazionale che a livello uqalitativo. In sostanza si perde troppo
% tempo.
% Potrei usare un'altra idea: i run "validi" per la mia analisi sono quelli
% che, in un certo itervallo abbastanza lungo, non presentano zeri (proprio
% zero non è mai l'ecg.) Quindi potrei fissare un intervallo abbastanza
% lungo e dire che considero come porzione utile del segnale quel medesimo
% intervallo.


% Here I use an other way to extrapolate the ecg track form the original db
% with zeros inside. First, with a mask, i have evaluated the size of the
% pre and post processing ecg. Based on such evaluation i fixed a window of
% interest, where i can assume that there is an ecg track enought regular. 
% Then i will operate data augmentation on the extrapolated dataset to have
% the correct number of samples.

% The first step allow us to find out that there are some track equal to
% zero, so we can exclude them. So the pipeline now is:
    % 1 cleaning data from traks equal to zero (made by the function
        % database cleaning with flag of extraction = 0
    % 2 extraction of the ecg track and data augmentation of the other
        % traks, building the final dataset, made by the same function with
        % flag =1 

[temp_db,ecg_length_sets]=database_cleaning(temp_db,0); % Note that this function does not change the structure of the db

disp(min(ecg_length_sets(:,2))) % 43228
disp(max(ecg_length_sets(:,2))) % 1645537
%% ECG run extraction 
temp_temp_db=temp_db;
[temp_temp_db,ecg_length_sets]=database_cleaning(temp_temp_db,1); % > 30 min of work!!

%% Inspecting results
figure(3)
subplot(411)
plot(temp_temp_db.AER.S1.CRD1.ECG)
title('ECG')
subplot(412)
plot(temp_temp_db.AER.S1.CRD1.RR)
title('RR interval')
subplot(413)
plot(temp_temp_db.AER.S1.CRD1.HR)
title('Heart Rate')
subplot(414)
plot(temp_temp_db.AER.S1.CRD1.BR)
title('Breathing Rate')



