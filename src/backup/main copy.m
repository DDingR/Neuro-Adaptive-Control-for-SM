clear 

%% SIMULATION SETTING
T = 1;
ctrl_dt = 1/5e3;
dt = ctrl_dt * 1/10;
rpt_dt = 0.1;
t = 0:dt:T;

%% SYSTEM DYNAMICS
x0 = [0; 0; 0];
u0 = [0;0];

env = env_SM_linear(x0, u0, dt);

%% REFERENCE
ref = @(t) 1*heaviside(t-0.1);
% ref = @(t) sin(t)*0.2;

%% CONTROLLER
% ctrl = ctrl_PID(50, 20, 0, ctrl_dt);
ctrl = ctrl_BSC(10, 50, ref(0), ctrl_dt);

%% RECORDER
rec = recorder(x0, env.getOutput(), ref(0), dt, rpt_dt);

%% MAIN LOOP
for t_idx = 1:length(t)
    r = ref(t(t_idx));
    y = env.getOutput();
    
    if t_idx ==1 || mod(t_idx, ctrl_dt/dt) == 0
        [ctrl, u] = ctrl.getControl(y, r);
    end
    
    env = env.step(u);

    rec = rec.record(env.getCurrentInfo(), r);
end

%% PLOT
[x_hist, y_hist, u_hist, r_hist] = rec.getHistory();

figure(1); clf
plot(dt*((1:size(x_hist,2))-1), x_hist(1,:), 'r', 'LineWidth', 2, ...
'LineStyle', '-');  hold on;
plot(dt*((1:size(x_hist,2))-1), r_hist, 'g', 'LineWidth', 2, ...
'LineStyle', '-.'); hold on;
grid on;
xlabel('Time [s]', 'Interpreter', 'latex', 'FontSize', 12);
ylabel('$\omega_m$ [rad/s]', 'Interpreter', 'latex', 'FontSize', 12);

figure(2); clf
tiledlayout(2,1);

nexttile;
plot(dt*((1:size(x_hist,2))-1), x_hist(2,:), 'r', 'LineWidth', 2); hold on;
grid on;
xlabel('Time [s]', 'Interpreter', 'latex', 'FontSize', 12);
ylabel('$i_d$ [A]', 'Interpreter', 'latex', 'FontSize', 12);

nexttile;
plot(dt*((1:size(x_hist,2))-1), x_hist(3,:), 'r', 'LineWidth', 2); hold on;
grid on;
xlabel('Time [s]', 'Interpreter', 'latex', 'FontSize', 12);
ylabel('$i_q$ [A]', 'Interpreter', 'latex', 'FontSize', 12);

figure(3); clf
tiledlayout(2,1);

nexttile;
plot(dt*((1:size(u_hist,2))-1), u_hist(1,:), 'r', 'LineWidth', 2); hold on;
grid on;
xlabel('Time [s]', 'Interpreter', 'latex', 'FontSize', 12);
ylabel('$v_d$ []', 'Interpreter', 'latex', 'FontSize', 12);

nexttile;
plot(dt*((1:size(u_hist,2))-1), u_hist(2,:), 'r', 'LineWidth', 2); hold on;
grid on
xlabel('Time [s]', 'Interpreter', 'latex', 'FontSize', 12);
ylabel('$v_q$ []', 'Interpreter', 'latex', 'FontSize', 12);