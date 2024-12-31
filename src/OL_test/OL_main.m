clear

%% SIMULATION SETTING
T = 10;
ctrl_dt = 1e-3;
% dt = ctrl_dt * 1/10;
dt = 1e-4;
rpt_dt = 0.1;
t = 0:dt:T;
seed = 1; rng(seed);

%% SYSTEM DYNAMICS
func = @(x) 5e0 * (tanh(x(1)) + sin(x(2).^2));
sys_func = @(x,u) [x(2); func(x)];
ref = @(t) [sin(t); cos(t)];

x = [10; 0];
u = 0;

x_num = length(x);
t_num = length(t);

%% NEURAL NETWORK SETTING
nn = NN([x_num, 16, 1] , 1e-3, 0e-3, 1);
lbd = 0e-0;

buffer_size = 1e3;
replayBuffer.x = zeros(2, buffer_size);
replayBuffer.y = zeros(1, buffer_size);

collecting_iter = 1e1;
pre_train_iter = 1e1;
batch_size = 64;
epoch = 1e1;

%% 
x_hist = zeros(x_num, t_num);
u_hist = zeros(1, t_num);
r_hist = zeros(x_num, t_num);
V_norm_hist = zeros(1, pre_train_iter);

%%
for idx = 1:1:collecting_iter
    x = 10*[rand-0.5; 0];
    
    for t_idx = 1:1:t_num
        pre_x = x;
        u = 10*(rand-1)/2;
                
        x = x + (sys_func(x,u) + [0;u]) *dt;

        replayBuffer.x = push_buffer(replayBuffer.x, pre_x, buffer_size);
        replayBuffer.y = push_buffer(replayBuffer.y, func(pre_x), buffer_size);


        x_hist(:, t_idx) = x;
        u_hist(t_idx) = u;
    end

    fprintf('max_x: %f, min_x: %f\n', max(x_hist(1,:)), min(x_hist(1,:)))

    for train_idx = 1:1:pre_train_iter
        for epc_idx = 1:1:epoch
            nn = train_nn(nn, replayBuffer);
        end
    end
    V_norm_hist(idx) = norm(nn.V); 
end

% %% VALIDATE
% x = [10; 0]; K = [-2, -1];

% for t_idx = 1:1:t_num
%     r = ref(t(t_idx));

%     [nn, func_pred] = nn.forward(x);
%     u = -func_pred - K*(x - r);

%     x = x + (sys_func(x,u) + [0;u]) *dt;

%     replayBuffer.x = push_buffer(replayBuffer.x, pre_x, buffer_size);
%     replayBuffer.y = push_buffer(replayBuffer.y, func(pre_x), buffer_size);

%     x_hist(:, t_idx) = x;
%     u_hist(t_idx) = u;
%     r_hist(:, t_idx) = r;
%     if mod(t_idx, ctrl_dt/dt) == 0
%         nn = train_nn(nn, replayBuffer);
%         fprintf("t: %f, x: %f, u: %f, r: %f\n", t(t_idx), x(1), u, r(1))
%     end
% end

% figure(1);clf
% tl = tiledlayout(2,1);
% nexttile
% plot(t, x_hist(1,:)); hold on
% plot(t, r_hist(1, :)); hold on

% nexttile
% plot(t, x_hist(2,:)); hold on
% plot(t, r_hist(2, :)); hold on

%% PLOT
figure(2); clf
range_x1 = 5;
range_x2 = 5;
[X1, X2] = meshgrid(-range_x1:0.1:range_x1, -range_x2:0.1:range_x2);
Y = zeros(size(X1, 1), size(X2, 2));
for x1_idx = 1:1:length(X1)
    for x2_idx = 1:1:length(X2)
        x = [X1(x1_idx, x2_idx); X2(x1_idx, x2_idx)];
        [nn, out, ~] = nn.forward(x);
        Y(x1_idx, x2_idx) = out - func(x);
    end
end

surf(X1, X2, Y)
view(2)
colorbar

figure(3); clf
plot(V_norm_hist)


%% LOCAL FUNCTION
function buffer = push_buffer(buffer, data, max_size)
    if size(buffer,2) < max_size
        buffer = [data, buffer];
    else
        buffer = [data, buffer(:, 1:end-1)];
    end
end

function nn = train_nn(nn, replayBuffer)
    batch_size = 64;
    epoch = 1e1;

    buffer_size = size(replayBuffer.x, 2);
    random_idx = randi(buffer_size, batch_size, 1);
    random_x = replayBuffer.x(:, random_idx);
    random_y = replayBuffer.y(:, random_idx);


    for epc_idx = 1:1:epoch
        labels = zeros(1, batch_size);
        outputs = zeros(1, batch_size);
        nnGrads = zeros(nn.v_size, batch_size);

        for b_idx = 1:1:batch_size    
            x = random_x(:, b_idx);
            y = random_y(:, b_idx);

            % forward
            [nn, out, ~] = nn.forward(x);

            nnGrad = nn.getGrad();
            nnGrads(:, b_idx) = nnGrad';    
            labels(b_idx) = y;
            outputs(b_idx) = out;
        end

        % backward
        E = labels - outputs;
        V_grad = -nn.alpha * -nnGrads * E';        
        % V_grad = V_grad - nn.rho * abs(E) .* nn.V;
        nn.V  = nn.V + mean(V_grad,2);
        
    end
end