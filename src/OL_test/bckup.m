clear

%% NEURAL NETWORK SETTING
nn = NN([2, 16, 1] , 1e-3, 0e-3, 1);
lbd = 0e-0;

%% SYSTEM DYNAMICS
func = @(x) 5e0 * ((x(1)) + sin(x(2).^2));

%%
iter = 1e+4;
epoch = 1e+1;
batch = 64;

%%
error_hist = zeros(1, iter);
V_norm_hist = zeros(1, iter);
% data = 1e1 * rand(2, batch * iter);

%%
for iter_idx = 1:1:iter
    train_data = 1e0 * rand(2, batch);
    % train_data = data(:, (iter_idx-1)*batch+1:iter_idx*batch);

    for epc_idx = 1:1:epoch
        labels = zeros(1, batch);
        outputs = zeros(1, batch);
        nnGrads = zeros(nn.v_size, batch);

        for b_idx = 1:1:batch    
            x = train_data(:, b_idx);
            y = func(x);

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
        nn.V  = nn.V + mean(V_grad,2) - lbd * nn.V;
        V_norm_hist(iter_idx) = norm(nn.V); 
        
    end


    val_data = 1e0 * rand(2, batch);
    % val_data = data(:, (iter_idx-1)*batch+1:iter_idx*batch);

    for b_idx = 1:1:batch    
        x = val_data(:, b_idx);
        y = func(x);

        % forward
        [nn, out, ~] = nn.forward(x);

        labels(b_idx) = y;
        outputs(b_idx) = out;
    end

    errors = labels - outputs;
    e_norm = mean(sqrt(sum(errors.^2,2)));
    
    error_hist(iter_idx) = e_norm;
    fprintf('iter: %d, Error: %f\n', iter_idx, e_norm);

    if e_norm < 1e-2
        % break
    elseif isnan(e_norm)
        break
    end
end

    %%
figure(1); clf
plot(error_hist)

%%
figure(2); clf
[X1, X2] = meshgrid(0:0.1:1, 0:0.1:1);
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

%%
figure(3); clf
plot(V_norm_hist)