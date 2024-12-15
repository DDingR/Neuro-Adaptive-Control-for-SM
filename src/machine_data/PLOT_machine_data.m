%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Filename    :   PLOT_machine_data.m
%
%   Author(en)  :   Labor für Mechatronische und Regenerative Energiesysteme (LMRES)
%                   Hochschule München (HM)
%                   Leitung: Prof. Dr.-Ing. habil. Christoph M. Hackl
%
%   web         :   https://lmres.ee.hm.edu
%   date        :   © 2022
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% prepare workspace
clc;
clear all;
close all;

load('./machine_pmsm_mtpx.mat')

%% extract data from machine struct

kappa = machine.kappa;
nP = machine.nP;
% current vectors / grids
isd = machine.psi.s.arg.isd;
isq = machine.psi.s.arg.isq;
[ISD, ISQ] = ndgrid(isd, isq);
% flux linkages
PSISD = machine.psi.s.d;
PSISQ = machine.psi.s.q;

% differential inductances
LSDD = machine.L.s.dd;
LSDQ = machine.L.s.dq;
LSQD = machine.L.s.qd;
LSQQ = machine.L.s.qq;

% torque
if length(size(machine.mM.mM)) == 3
    MM = machine.mM.mM(:,:,1);  
elseif length(size(machine.mM.mM)) == 2
    MM = machine.mM.mM;
else
    error('torque map dimension not supported!')
end
    
%% plot flux linakges and differential inductances
figure('Name','flux linakges and differential inductances')
% psisd
subplot(3,2,1)
surf(ISD',ISQ',PSISD') %explain transpose!!!
xlabel('$i_{\rm s}^d$ / A','interpreter','latex')
ylabel('$i_{\rm s}^q$ / A','interpreter','latex')
zlabel('$\psi_{\rm s}^d$ / Vs','interpreter','latex')

% psisq
subplot(3,2,2)
surf(ISD',ISQ',PSISQ')
xlabel('$i_{\rm s}^d$ / A','interpreter','latex')
ylabel('$i_{\rm s}^q$ / A','interpreter','latex')
zlabel('$\psi_{\rm s}^q$ / Vs','interpreter','latex')

% Lsdd
subplot(3,2,3)
surf(ISD',ISQ',LSDD')
xlabel('$i_{\rm s}^d$ / A','interpreter','latex')
ylabel('$i_{\rm s}^q$ / A','interpreter','latex')
zlabel('$L_{\rm s}^{dd}$ / Vs','interpreter','latex')

% Lsdq
subplot(3,2,4)
surf(ISD',ISQ',LSDQ')
xlabel('$i_{\rm s}^d$ / A','interpreter','latex')
ylabel('$i_{\rm s}^q$ / A','interpreter','latex')
zlabel('$L_{\rm s}^{dq}$ / Vs','interpreter','latex')

% Lsqd
subplot(3,2,5)
surf(ISD',ISQ',LSDQ')
xlabel('$i_{\rm s}^d$ / A','interpreter','latex')
ylabel('$i_{\rm s}^q$ / A','interpreter','latex')
zlabel('$L_{\rm s}^{qd}$ / Vs','interpreter','latex')

% Lsqq
subplot(3,2,6)
surf(ISD',ISQ',LSQQ')
xlabel('$i_{\rm s}^d$ / A','interpreter','latex')
ylabel('$i_{\rm s}^q$ / A','interpreter','latex')
zlabel('$L_{\rm s}^{qq}$ / Vs','interpreter','latex')


%% machine torque
figure('Name','machine torque')
surf(ISD',ISQ',MM')
xlabel('$i_{\rm s}^d$ / A','interpreter','latex')
ylabel('$i_{\rm s}^q$ / A','interpreter','latex')
zlabel('$m_{\rm m}$ / Nm (@ $0 \cdot \omega_{\rm p,R}$)','interpreter','latex')

