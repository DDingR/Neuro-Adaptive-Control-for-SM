% IPMSM Speed-Current controller (Casecade loop)
clc;
clear;

% 매개변수 초기화
J = 0.1; % 관성 [kg*m^2]
B = 0.001; % 점성 계수 [N*m/(rad/s)]
Kt = 0.1; % 토크 상수 [N*m/A]
Rs = 25e-3; % 저항 [Ohm]
Lds = 0.45e-3; % d축 인덕턴스 [H]
Lqs = 0.66e-3; % q축 인덕턴스 [H]
P = 8; % 모터 극쌍 수
LAMpm = 0.0563;

% 정격 및 제한 설정
Is_max = 300; % 최대 전류 [A]
Vs_max = 60; % 최대 전압 [V]
Te_max = 500; % 최대 토크 [Nm]

% Sampling time & simulation time
Ts = 0.001; 
T_end = 1; 
t = 0:Ts:T_end; 

% Initial values
Wr = 0; % 초기 속도 [rad/s]
ids = 0; % d축 전류 [A]
iqs = 0; % q축 전류 [A]
vds = 0; % d축 전압 [V]
vqs = 0; % q축 전압 [V]

% Controller parameters
fcc = 100; Wcc = 2*pi*fcc;      % Speed controller bandwidth   (100 Hz)
fcs = fcc/20; Wcs = 2*pi*fcs;   % Current controller bandwidth  (10 Hz)
% PI Controller gains
Kp_s = J*Wcs; Ki_s = J*Wcs^2; 
Kp_d = Lds*Wcc; Ki_d = Rs*Wcc; 
Kp_q = Lqs*Wcc; Ki_q = Rs*Wcc; 


% Speed reference
Wr_ref = 100; 

% Data buffer
Wr_history = zeros(size(t));
ids_history = zeros(size(t));
iqs_history = zeros(size(t));
vds_history = zeros(size(t));
vqs_history = zeros(size(t));
Te_history = zeros(size(t));
Wr_ref_history = Wr_ref * ones(size(t));
ids_ref_history = zeros(size(t));
iqs_ref_history = zeros(size(t));
Te_ref_history = zeros(size(t));

for i = 1:length(t)


    % Speed Errors 
    Wr_err = Wr_ref - Wr;

    % Speed Controller (Speed -> Torque)
    Te_ref = pi_controller(Wr_err, Kp_s, Ki_s, Ts, Te_max);

    % Torque Generator (Torque reference --> d-q axis current reference)
    idqs_ref = Torque_Generator(Te_ref, Lds, Lqs, LAMpm,P);

    ids_ref = idqs_ref(1);
    iqs_ref = idqs_ref(2);

    % Current Errors 
    ids_err = ids_ref - ids;
    iqs_err = iqs_ref - iqs;

    % d-axis Current Controller
    vds_fb = pi_controller(ids_err, Kp_d, Ki_d, Ts, Vs_max);
    vds_ff = -Wr*Lqs*iqs;
    vds = vds_fb + vds_ff;

    % q-axis Current Controller
    vqs_fb = pi_controller(iqs_err, Kp_q, Ki_q, Ts, Vs_max);
    vqs_ff = Wr*(Lds*ids + LAMpm);
    vqs = vqs_fb + vqs_ff;

    % IPMSM Plant dynamics
    [ids, iqs, Wr, Te] = Motor_dynamicFunction(ids, iqs, Wr, vds, vqs, Rs, Lds, Lqs, LAMpm, P, B, J, Ts);

    % Data Buffer
    Wr_history(i) = Wr;
    ids_history(i) = ids;
    iqs_history(i) = iqs;
    vds_history(i) = vds;
    vqs_history(i) = vqs;
    Te_history(i) = Te;

    % Reference values
    ids_ref_history(i) = ids_ref;
    iqs_ref_history(i) = iqs_ref;
    Te_ref_history(i) = Te_ref;
end

close all;
% Plot results
figure;
subplot(6,1,1);
plot(t, Wr_history, t, Wr_ref_history, '--');
title('Speed Response');
xlabel('Time [s]');
ylabel('Speed [rad/s]');
legend('Actual', 'Reference');
grid on;

subplot(6,1,2);
plot(t, ids_history, t, ids_ref_history, '--');
title('d-axis Current');
xlabel('Time [s]');
ylabel('Current [A]');
legend('Actual', 'Reference');
grid on;

subplot(6,1,3);
plot(t, iqs_history, t, iqs_ref_history, '--');
title('q-axis Current');
xlabel('Time [s]');
ylabel('Current [A]');
legend('Actual', 'Reference');
grid on;

subplot(6,1,4);
plot(t, vds_history);
title('d-axis Voltage');
xlabel('Time [s]');
ylabel('Voltage [V]');
grid on;

subplot(6,1,5);
plot(t, vqs_history);
title('q-axis Voltage');
xlabel('Time [s]');
ylabel('Voltage [V]');
grid on;

subplot(6,1,6);
plot(t, Te_history, t, Te_ref_history, '--');
title('Electromagnetic Torque');
xlabel('Time [s]');
ylabel('Torque [Nm]');
legend('Actual', 'Reference');
grid on;

