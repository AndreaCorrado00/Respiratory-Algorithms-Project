function [new_temp_db,ecg_length_sets]=database_cleaning(temp_db,extraction)
sets=["AER","BAS","CRO","FIT","JOG","MID","RUN","SOC","TEN","ZUM"];
ecg_length_sets=[]; % length ecg, length new ecg, size reduction


%####################################################################
% This is a quite complex function used to extract, or at least evluate the
% possibility of extraction, a raw signal as regular as possible. 

%%%%%%%%%
% As input:
    % temp_db: struct db to be evaluated
    % extraction: logical flag to extract or not the signal
% As output:
    % new_temp_db: new db evaluated (at least identical to the origial one)
    % ecg_length_sets: (Possible) table containg the initial length of the
    % ECG, the length of the ecg signals which respect the condition of not
    % being zero and the compression factor

% ####################################################################
% Description of the function
% The function inspect all the database (so the cycle structure is build
% usign the information about the logic of the db) and:
% IF extraction is false:
    % Build a candidate which is basically the ecg signal not equal to zero
    % Return the original db and the ecg_length_sets variable completed of
    % the indìformations about compression

% IF extraction is true:
    % Build a logical mask and find if there is into the mask a run of ones long as required (fixed value)

    % If there is, proceed by extracting the ECG run and by extracting the
    % counter part of BR,HR,RR signals (once augmented)

    % If the isn't such run, the field in the db is eliminated and the code
    % continue

% #####################################################################

%% Body
%% DB reading
for h=1: length(sets)
    set=sets(h);

    for j=1:length(fieldnames(temp_db.(set)))
        s=['S',num2str(j)];

        for k=1:length(fieldnames(temp_db.(set).(s)))
            crd=['CRD',num2str(k)];
            
            % Extraction of the signal
            ECG=temp_db.(set).(s).(crd).ECG;
            RR=temp_db.(set).(s).(crd).RR;
            HR=temp_db.(set).(s).(crd).HR;
            BR=temp_db.(set).(s).(crd).BR;
            
            %% Ectraction of the candidate: double usage of the function
            candidate=[];
            mask= ECG ~= 0;
            candidate=ECG(mask==1);

%% First usage
            if extraction
                % Initialize variables to store the starting index and length of the sub-vector
                startIndex = 0;
                subVectorLength = 20000;
                oneIndices = find(mask == 1);
                % Initialize a flag to check if a valid sub-vector is found
                subVectorFound = false;

                % Iterate through the oneIndices to find the sub-vector
                for i = 1:length(oneIndices)-subVectorLength+1
                    if all(diff(oneIndices(i:i+subVectorLength-1)) == 1)
                        startIndex = oneIndices(i);
                        subVectorFound = true;
                        break;
                    end
                end

                % Check if a valid sub-vector is found
                if subVectorFound
                    disp(['Candidate found! in ', set,s,crd])

                    %% Frequency augmentation factor
                    augmentationFactor = 250;
                    % Augment data
                    % Original vector recorded at 1Hz
                    originalVector = RR;

                    % Augment data
                    augmentedVector = zeros(1, length(RR) * augmentationFactor);
                    for i = 1:augmentationFactor
                        augmentedVector(i:augmentationFactor:end) = RR;
                    end
                    RR=augmentedVector;

                    augmentedVector = zeros(1, length(BR) * augmentationFactor);
                    for i = 1:augmentationFactor
                        augmentedVector(i:augmentationFactor:end) = BR;
                    end
                    BR=augmentedVector;

                    augmentedVector = zeros(1, length(HR) * augmentationFactor);
                    for i = 1:augmentationFactor
                        augmentedVector(i:augmentationFactor:end) = HR;
                    end
                    HR=augmentedVector;
                  

                    % RR = reshape(repmat(RR, augmentationFactor, 1), 1, [])';
                    % HR = reshape(repmat(HR, augmentationFactor, 1), 1, [])';
                    % BR = reshape(repmat(BR, augmentationFactor, 1), 1, [])';
                   
                    %% New dataset
                    % Extract the sub-vector for ECG
                    
                    new_temp_db.(set).(s).(crd).ECG=ECG(startIndex : startIndex + subVectorLength - 1);
                    new_temp_db.(set).(s).(crd).RR=RR(startIndex : startIndex + subVectorLength - 1)';
                    new_temp_db.(set).(s).(crd).HR=HR(startIndex : startIndex + subVectorLength - 1)';
                    new_temp_db.(set).(s).(crd).BR=BR(startIndex : startIndex + subVectorLength - 1)';

                else
                    disp(['cadidate not found, eliminated', set,s,crd])
                end
                ecg_length_sets=NaN;
%% Second usage of the function
            else
                if sum(candidate)==0
                    disp(['eliminated', set,s,crd])
                else
                    new_temp_db=temp_db;
                    ecg_length_sets=[ecg_length_sets;length(ECG),length(candidate),((length(ECG)-length(candidate))/length(ECG))*100];

                end
            end
            
        end
    end
end