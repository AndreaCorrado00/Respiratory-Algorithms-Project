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

% Ok everything good... but how to clean the data AUTOMATICALLY !?
