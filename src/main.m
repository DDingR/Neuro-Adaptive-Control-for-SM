clear 

%% SIMULATION SETTING
T = 1;
ctrl_dt = 1/5e3;
dt = ctrl_dt * 1/10;
rpt_dt = 0.1;
t = 0:dt:T;
seed = 1; rng(seed);

%% SYSTEM DYNAMICS
x0 = [0; 0; 0];
u0 = [0;0];
data_path = 'machine_data/machine_pmsm_mtpx.mat';

env = EnvSM(x0, u0, dt, data_path);

%% REFERENCE
% ref = @(t) 1e2*heaviside(t-0.1);
ref = @(t) sin(10*t)*1e2;

%% CONTROLLER
% ctrl = CtrlPID(50, 20, 0, ctrl_dt);
% ctrl = CtrlBSC(5, 15, ref(0), ctrl_dt);
ctrl = CtrlNAC_BSC(5, 15, ref(0), ctrl_dt);

%% RECORDER
rec = RecSM(dt, rpt_dt);
rec = rec.record(env.getInfo(), ref(0), ctrl);

%% MAIN LOOP
for t_idx = 1:length(t)
    r = ref(t(t_idx));
    y = env.getOutput();
    
    if t_idx ==1 || mod(t_idx, ctrl_dt/dt) == 0
        [ctrl, u] = ctrl.getControl(y, r);
    end
    
    env = env.step(u);

    rec = rec.record(env.getInfo(), r, ctrl);
end

%% PLOT
rec.result_plot(ctrl);

% f_name = "BSC_NAC";
% % f_name = "BSC";

% for idx = 1:1:4
%     fprintf('Saving figure %d\n', idx)
%     % saveas(figure(idx), f_name+".png");
%     exportgraphics(figure(idx), f_name+string(idx)+'.eps')
% end