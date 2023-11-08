function [H,f,b,a]=my_ellip_filt(Fc,Wp,Ws,Rp,Rs,type)

% Parameters conversion
Wp=Wp/(Fc/2);
Ws=Ws/(Fc/2);
Rp=-20*log10(Rp);
Rs=-20*log10(Rs);
%  Filter determination
[n,Wn]=ellipord(Wp,Ws,Rp,Rs);
[b,a]=ellip(n,Rp,Rs,Wn,type); 
[H,f]=freqz(b,a,512,Fc);


end
