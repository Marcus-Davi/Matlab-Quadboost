clear;
close all;
clc;
addpath(genpath('.')) % adiciona bibliotecas à path
%% Caracteristicas do conversor
% Quadratic Boost Data Structure
BoostQ.L1 = 1.48e-3;
BoostQ.L2 = 1.7e-3;
BoostQ.C1 = 100e-6;
BoostQ.C2 = 100e-6;
BoostQ.R = 175; %175
BoostQ.f = 20e3;
BoostQ.Vin = 30;
BoostQ.Ts = 1/(BoostQ.f);
% Parasitics
BoostQ.rL1 = 0.4;
BoostQ.rL2 = 0.8;
BoostQ.rC1 = 0.318;
BoostQ.rC2 = 0.318;
BoostQ.Rmos = 0.1;
BoostQ.Dn = 0.5; % AJUSTE DO DUTY CYCLE NOMINAL
BoostQ.Vout = BoostQ.Vin/(1-BoostQ.Dn)^2;
save('Boost_Data','BoostQ');

%% Configura��o PRBS
%TbN>/ Tassentamento
%1/(2^N-1)Tb < fprbs < 0.44/Tb
%Assentamento = 0.01
% PRBS
PRBS_N = 10;
Tb = 0.002; % 0.002
Lmax = 0.44/Tb;
Lmin = 1/((2^PRBS_N-1)*Tb);
PRBS_Ts = Tb;
% PRBS_Ts = 5;
PRBS_Amp = .05;
Tsim_min = (2^PRBS_N-1)*Tb;
Tsim = 1*Tsim_min;
Ramp_Max = 0.75;
sim 'SimuQBoostPLMS'

%% Identifica��o LPV (PLMS)

ymin = Voutmin.Data;
ymed = Vout.Data;
ymax = Voutmax.Data;

%Normaliza saida
y_norm = max(Voutmax.Data);
ymin = ymin/y_norm;
ymed = ymed/y_norm;
ymax = ymax/y_norm;
Gains.Ynorm = y_norm;

% Constru��o dos vetores
uplms = [Dinmin.Data Din.Data Dinmax.Data];
yplms = [ymin ymed ymax];
% pplms = [Dinmin.Data Din.Data Dinmax.Data];
pplms = [Pinmin.Data Pinmed.Data Pinmax.Data];
Ts = BoostQ.Ts;

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