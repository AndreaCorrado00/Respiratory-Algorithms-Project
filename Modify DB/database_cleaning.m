function [new_temp_db,ecg_length_sets]=database_cleaning(temp_db,extraction)
sets=["AER","BAS","CRO","FIT","JOG","MID","RUN","SOC","TEN","ZUM"];
ecg_length_sets=[]; % length ecg, length new ecg, size reduction

for i=1:length(sets)
    set=sets(i);
    for j=1:length(fieldnames(temp_db.(set)))
        s=['S',num2str(j)];
        for k=1:length(fieldnames(temp_db.(set).(s)))
            crd=['CRD',num2str(k)];
            
            % Extraction of the signal
            ECG=temp_db.(set).(s).(crd).ECG;
            %start=round(length(ECG)*randn());
            % Ectraction of the candidate (cleaned ECG)
            candidate=[];
            mask= ECG ~= 0;
            candidate=ECG(mask==1);
            if extraction
                % COMPLETARE CON DATA AUGEMENTATION E CICLO DI ESTRAZIONE
                % DEL TRACCIATO ECG
            else
                if sum(candidate)==0
                    disp(['eliminated', set,s,crd])
                else
                    new_temp_db.(set).(s).(crd).ECG=ECG;
                    new_temp_db.(set).(s).(crd).RR=temp_db.(set).(s).(crd).RR;
                    new_temp_db.(set).(s).(crd).HR=temp_db.(set).(s).(crd).HR;
                    new_temp_db.(set).(s).(crd).BR=temp_db.(set).(s).(crd).BR;

                    ecg_length_sets=[ecg_length_sets;length(ECG),length(candidate),((length(ECG)-length(candidate))/length(ECG))*100];

                end
            end
            
        end
    end
end