clear;close all;clc
%% Identifica��o LPV (LMS-Global)
load('BoostQParameters'); % Apenas pra usarmos o Ts da simulação
load('BoostSimData'); % Dados de simulação

DinRange %correspondencia entre coluan de vetores de dados e duty cycle usado.
%Ex Dinrange = [0.3 0.5] -> Din(:,2) corresponde ao dados do ensaio para 0.5
Selecionador = 2; % seleciona os dados correspondentes à coluna do DinRagne


 ninit = 1000; %Ignorar dinâmica de
 u = DinTotal(ninit:end,Selecionador);
 y = VoutTotal(ninit:end,Selecionador);
 p = u;

Ts = BoostQParam.Ts;

%Normaliza saida
y_norm = max(y);
y = y/y_norm;
Gains.Ynorm = y_norm;
% return
%Configura��es do modelo
Na = 6;
N = 2;
Iterations = 70;
alpha_0 = 0.006; %inicial
alpha_1 = 0.002; %final
% alpha_0 = 6; %inicial
% alpha_1 = 2; %final


Modelo_MA_LPV_LMS = ident_lpv_lms_sb0_loop(y,u,p,Ts,Na,N,alpha_0,alpha_1,'plota1',Iterations);
% m_printa_modelo_LPV (Modelo_MA_LPV_LMS,Na,Na,N);
m_salva_planta_lpv_struct('Modelo_MA_LPV_LMS',Modelo_MA_LPV_LMS,Ts,Na,N);
valida_mod_LPV(y,u,p,Modelo_MA_LPV_LMS,Ts,Na,N,'plota1');
disp('Nome = MODELO_MA_LPV');
save('Gains','Gains');

%% Plot
close all
valida_ARX_LPV(y,u,p,Modelo_MA_LPV_LMS,Ts,Na,N,'plota1');


% Carrega Modelo LPV Salvo
sdpvar teta
% [B_LPV,A_LPV] = carrega_planta_lpv('Modelo_MA_LPV_LMS.txt',teta);
 [B_LPV,A_LPV] = m_carrega_planta_lpv('Modelo_MA_LPV_LMS',teta);
% m_printa_modelo_LPV(Modelo_MA_LPV_LMS,Na,Na,N)
% Gr�fico com o p�los do modelo LPV estimado 
maximo = 0.65;
minimo = 0.35;
precisao = 0.01;
% plota_polos(A_LPV,teta,maximo,minimo,precisao,'Xm');
figure
% Gr�fico com a resposta ao degrau do modelo LPV estimado
 plota_degrau(B_LPV,A_LPV,0,teta,maximo,minimo,0.1,Ts)  
  