function [uhat,res,wres,nres,gamma,itergamma]=smoothdiscrepancy(ts,ys,B,sd2,tv,m)
% Inizializzazione
n=length(ts);

% Matrice di covarianza Ev=sigma^2*B con B diagonale.
Ev=(sd2)*B;
Tv=tv(2)-tv(1);
% mashera per eliminare i valori da Gv e creare quindi G
mask=zeros(length(tv),1);
mask(round(ts./Tv))=1;

Gv=eye(length(mask));
G=Gv(mask==1,:);

%% calcolo della matice F
if m==0
    F=eye(length(mask));
else
 %Inizializzazione matrice di Toepliz
    r=[1;zeros(length(tv)-1,1)]';
    c=[1;-1;zeros(length(tv)-2,1)];
    D=toeplitz(c,r);
 % Calcolo di F
    F=D^m;
end

%% Metodo di bisezione per il gamma di discrepanza
itergamma=0;
L=0.00001;
R=1000000;
toll=0.001;
while (R - L)>2*toll && itergamma<800
    % Gamma medio per l'iterazione
    C=10^((log10(L)+log10(R))/2);
    sig_u=inv(F' * F); % due passaggi per  semplicità
    u_hat=sig_u * G' * inv(G * sig_u *G' +C * B) * ys;

    abs_res=ys-u_hat(mask==1);
    pes_res=abs_res./sqrt(diag(B));
    wrss=pes_res'*pes_res;
    % iterazione e centro del segmento all'iterazione corrente
    itergamma=itergamma+1;
    

    % criteri di verifica
    if wrss>=toll+n*sd2
        R=C;
    else
        L=C;
    end %if

end %while

gamma=(L+R)/2;




%% calcolo della curva interpolante
sig_u=inv(F' * F); % due passaggi per  semplicità

uhat=sig_u * G' * inv(G * sig_u *G' +gamma * B) * ys;


%% Calcolo dei residui
res=ys-u_hat(mask==1);
wres=res./sqrt(diag(B));
nres=res./sqrt(diag(Ev));
% 
% wrss=pes_res'*pes_res;
% nrss=norm_res'*norm_res;