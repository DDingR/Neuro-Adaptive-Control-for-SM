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

env = EnvSM(x0, u0, dt);

%% REFERENCE
ref = @(t) 1*heaviside(t-0.1);
% ref = @(t) sin(t)*0.2;

%% CONTROLLER
% ctrl = CtrlPID(50, 20, 0, ctrl_dt);
ctrl = CtrlBSC(10, 150, ref(0), ctrl_dt);
% ctrl = CtrlNAC_BSC(10, 150, ref(0), ctrl_dt);

%% RECORDER
rec = RecSM(x0, env.getOutput(), ref(0), dt, rpt_dt);

%% MAIN LOOP
for t_idx = 1:length(t)
    r = ref(t(t_idx));
    y = env.getOutput();
    
    if t_idx ==1 || mod(t_idx, ctrl_dt/dt) == 0
        [ctrl, u] = ctrl.getControl(y, r);
    end
    
    env = env.step(u);

    rec = rec.record(env.getInfo(), r);
    % rec = rec.record(env.getInfo(), r, ctrl.getInfo());
end

%% PLOT
rec.result_plot();
