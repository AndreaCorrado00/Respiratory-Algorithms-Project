function temp_db=undersampling(temp_db)
sets=["AER","BAS","CRO","FIT","JOG","MID","RUN","SOC","TEN","ZUM"];
fc=5;
for i=1:length(sets)
    set=sets(i);
    for j=1:length(fieldnames(temp_db.(set)))
        s=['S',num2str(j)];
        for k=1:length(fieldnames(temp_db.(set).(s)))
            crd=['CRD',num2str(k)];
            ECG=temp_db.(set).(s).(crd).ECG;
            mask=zeros(length(ECG),1);
            mask(1:fc:length(mask))=1;
            ECG=ECG(mask==1);
            temp_db.(set).(s).(crd).ECG=ECG;
        end
    end
end