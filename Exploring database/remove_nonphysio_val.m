function new_ECG=remove_nonphysio_val(ECG)
% This funtion remove the values of ecg over the physiological value
mask_up=ECG>1.2;
mask_down=ECG<-0.5;
ECG(mask_up)=NaN;
ECG(mask_down)=NaN;
new_ECG=ECG;