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







% IDEA: eseguo un primo undersampling dell'ecg riportandolo a 1hz. Proseguo
% poi eseguendo una prima pulizia: taglio tutto ciò che è al di fuori dei
% valori fisiologici (attenzione, sarà necessario togliere la media). Poi
% estraggo una forma d'onda accettabile e decido a priori la lunghezza del
% vettore. Estraggo un numero casuale dal quale partire (meglio pensare bene a come strarlo). Da lì eseguo un
% ciclo che correla la forma d'onda di riferimento con il segnale. Se R è
% maggiore di una certa soglia (posso fare più prove, ma direi attorno al
% 75%) allora tengo la porzione e proseguo. Se R è inferiore, interrompo e
% ricomincio dal valore successivo. Interrompo quando raggiungo la
% lunghezza prestabilita. Inoltre devo tenere traccia dell'indice di
% partenza per poter estrarre correttamente gli altri segnali.

% Rigurado questa procedura, essendo comunque ancora relativa alla pulizia
% dei dati, sono abbastanza libero. Potrei addirittura valutare di
% escludere due tipologie di dataset:
    % 1. dataset undersampled comunque troppo corti
    % 2. dataset che non permettono l'estrazione di alcun segnale utile
    % (tutti zeri o nan)

% poi potrei usare questo nuovo dataset per le analisi in frequenza e
% magari per valutare qualche semplice modello


