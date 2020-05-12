clear;
close all;
clc;

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
sim 'BoostQuadSimu'
%% Identifica��o LPV (LMS-Global)

u = Din.Data;
y = Vout.Data;
p = Din.Data;
Ts = BoostQ.Ts;

%Normaliza saida
y_norm = max(y);
y = y/y_norm;
Gains.Ynorm = y_norm;

%Configura��es do modelo
Na = 6;
N = 2;
Iterations = 70;
alpha_0 = 0.006; %inicial
alpha_1 = 0.002; %final
% alpha_0 = 6; %inicial
% alpha_1 = 2; %final

Modelo_MA_LPV_LMS = ident_lpv_lms_sb0_loop(y,u,p,Ts,Na,N,alpha_0,alpha_1,'plota1',Iterations)
% m_printa_modelo_LPV (Modelo_MA_LPV_LMS,Na,Na,N);
m_salva_planta_lpv_struct('Modelo_MA_LPV_LMS',Modelo_MA_LPV_LMS,Ts,Na,N);
valida_mod_LPV(y,u,p,Modelo_MA_LPV_LMS,Ts,Na,N,'plota1');
disp('Nome = MODELO_MA_LPV');
save('Gains','Gains');

%% Plot
valida_ARX_LPV(y,u,p,Modelo_MA_LPV_LMS,Ts,Na,N,'plota1');


% Carrega Modelo LPV Salvo
sdpvar teta
% [B_LPV,A_LPV] = carrega_planta_lpv('Modelo_MA_LPV_LMS.txt',teta);
 [B_LPV,A_LPV] = m_carrega_planta_lpv('Modelo_MA_LPV_LMS',teta);

% Gr�fico com o p�los do modelo LPV estimado 
maximo = 0.7;
minimo = 0.3;
precisao = 0.01;
plota_polos(A_LPV,teta,maximo,minimo,precisao,'Xm');

% Gr�fico com a resposta ao degrau do modelo LPV estimado
plota_degrau(B_LPV,A_LPV,teta,maximo,minimo,0.1,Ts)  
  