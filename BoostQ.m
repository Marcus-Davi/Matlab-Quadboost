clear;
close all;
clc;
addpath(genpath('.')) % adiciona bibliotecas à path
%% Caracteristicas do conversor
% Quadratic Boost Data Structure
BoostQParam.L1 = 1.48e-3;
BoostQParam.L2 = 1.7e-3;
BoostQParam.C1 = 100e-6;
BoostQParam.C2 = 100e-6;
BoostQParam.R = 175; %175
BoostQParam.f = 20e3;
BoostQParam.Vin = 30;
BoostQParam.Ts = 1/(BoostQParam.f);
% Parasitics
BoostQParam.rL1 = 0.4;
BoostQParam.rL2 = 0.8;
BoostQParam.rC1 = 0.318;
BoostQParam.rC2 = 0.318;
BoostQParam.Rmos = 0.1;
BoostQParam.Dn = 0.5; % AJUSTE DO DUTY CYCLE NOMINAL
BoostQParam.Vout = BoostQParam.Vin/(1-BoostQParam.Dn)^2;
save('BoostQParameters','BoostQParam');
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
PRBS_Amp = .1;
Tsim_min = (2^PRBS_N-1)*Tb;
Tsim = 1*Tsim_min;
Ramp_Max = 0.75;

%% Simula 
DinRange = [0.3 0.5 0.7];
DinTotal = [];
VoutTotal = [];
IinTotal = [];
PinTotal = [];

for DutyConst = DinRange
sim('BoostQSim')
DinTotal = [DinTotal Din.Data]; 
VoutTotal = [VoutTotal Vout.Data];
IinTotal = [IinTotal Iin.Data];
PinTotal = [PinTotal Pin.Data];
end


save('BoostSimData','DinTotal','VoutTotal','IinTotal','PinTotal','DinRange'); %Só duty e corrente

