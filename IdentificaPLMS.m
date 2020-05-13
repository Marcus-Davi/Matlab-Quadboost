clear;close all;clc
%% Identifica��o LPV (PLMS)
load('BoostQParameters'); %for Ts
load('BoostSimData');

ymin = VoutTotal(:,1);
ymed = VoutTotal(:,2);
ymax = VoutTotal(:,3);

%Normaliza saida
y_norm = max(Voutmax.Data);
ymin = ymin/y_norm;
ymed = ymed/y_norm;
ymax = ymax/y_norm;
Gains.Ynorm = y_norm;

% Constru��o dos vetores
uplms = [DinTotal(:,1)  DinTotal(:,2)  DinTotal(:,3)];
yplms = [ymin ymed ymax];
% pplms = [PinTotal(:,1) PinTotal(:,2) PinTotal(:,3)];
pplms = [DinTotal(:,1) DinTotal(:,2) DinTotal(:,3)];
Ts = BoostQParam.Ts;
return
%% Identifica��o

%Configura��es do modelo
Na = 6;
N = 2;
Iterations = 50;
alpha_0 = 0.0000006; %inicial
alpha_1 = 0.0000002; %final

Modelo_MA_LPV = ident_lpv_plms_sb0_loop(yplms,uplms,pplms,Ts,Na,N,alpha_0,alpha_1,'plota0',Iterations);

% Valida��o do modelo LPV identificado (pode ser usado outro conjunto de dados)
valida_mod_LPV(yplms(:,1),uplms,pplms,Modelo_MA_LPV,Ts,Na,N,'plota1');

% Salva modelo LPV em um arquivo txt
salva_modelo_lpv('Modelo_LPV.txt',Modelo_MA_LPV,Ts,Na,N);

maximo = max(max(pplms));
minimo = min(min(pplms));

% Carrega Modelo LPV Salvo
sdpvar teta
[B_LPVplms,A_LPVplms] = carrega_planta_lpv('Modelo_LPV.txt',teta);

% Gr�fico com o p�los do modelo LPV estimado
precisao = 0.01;
figure
plota_polos(A_LPVplms,teta,maximo,minimo,precisao,'Xm');

% Gr�fico com a resposta ao degrau do modelo LPV estimado
figure
plota_degrau(B_LPVplms,A_LPVplms,0,teta,maximo,minimo,0.1,Ts)   