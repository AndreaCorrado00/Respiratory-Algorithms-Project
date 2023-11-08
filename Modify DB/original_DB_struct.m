function database=original_DB_struct()
sets=["AER","BAS","CRO","FIT","JOG","MID","RUN","SOC","TEN","ZUM"];
base="D:\Desktop\progetto\SportDB\";
database=struct;
for i=1:length(sets)
    set=sets(i);
    sub=base + set;
    num_dir=count_dir(sub); % number of sub dir of the set

    for j=1:num_dir
        S_j=['S'  num2str(j)];
        subsub=sub+'\'+S_j; % access to the j-st sub dir of the set
        num_subdir=count_dir(subsub);
        for k=1:num_subdir
            % now we can load the data
            CRD_k=['CRD' num2str(k)];
            full_name=subsub+'\'+CRD_k+'\Data.mat';
            load(full_name);
            %CRD_name=
            % data are now only copied
            database.(set).(S_j).(CRD_k).HR=Data.HR;
            database.(set).(S_j).(CRD_k).BR=Data.BR;
            database.(set).(S_j).(CRD_k).RR=Data.RR;
            database.(set).(S_j).(CRD_k).ECG=Data.ECG;
        end
    end
end
end
