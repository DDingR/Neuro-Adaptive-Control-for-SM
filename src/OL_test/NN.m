classdef NN
    properties
        V
        tape

        alpha = 1e1;
        rho = 1e-3;

        NN_size = [3,8,8,2]
        l_size
        t_size             % total tape number
        v_size_list             % total weight number (will be calc-ed)
        v_size             % total weight number
        
        act_func % activation function
        e_tol = 0;

        dt 
    end

    methods
        function obj = NN(NN_size, alpha, rho, dt)
            obj.NN_size = NN_size;
            obj.alpha = alpha;
            obj.rho = rho;
            obj.dt = dt;

            init_range = 1e-3;
            obj.act_func = "tanh";
            % obj.act_func = "ReLU";

            obj.l_size = length(obj.NN_size);
            obj.t_size = sum(obj.NN_size(1:end-1));
            obj.v_size_list = zeros(obj.l_size-1 ,1);    
            for idx = 1:1:obj.l_size-1
                obj.v_size_list(idx) = (obj.NN_size(idx)+1) * obj.NN_size(idx+1);
            end
        
            obj.v_size = sum(obj.v_size_list);    

            obj.V = (rand(obj.v_size,1)-1/2)*2*init_range;
            obj.tape = zeros(obj.t_size, 1);
        end

        function disp(obj)
            fprintf('*** Neural Network Parameters ***\n')
            fprintf('NN size: ')
            for idx = 1:1:obj.l_size
                fprintf('%d ', obj.NN_size(idx))
            end
            fprintf('\n')
            fprintf('Activation Function: %s\n', obj.act_func)
            fprintf('Learning Rate: %f\n', obj.alpha)
            fprintf('Weight Number: %d\n', obj.v_size)
            
            
        end

        %% GET METHODS
        function info = getInfo(obj)
            info.V_norm = obj.V_norm();
        end

        %% FORWARD AND BACKWARD PROPAGATION
        function [obj, out, info] = forward(obj, in)
            pt_V = 1;
            pt_tape = 1;

            if obj.act_func == "tanh"
                act = @tanh;
            elseif obj.act_func == "ReLU"
                act = @ReLU;
            end

            % forward
            obj.tape(1: 1+obj.NN_size(1)-1) = in;
            pt_tape = pt_tape + obj.NN_size(1);

            for l_idx = 1:1:obj.l_size-1
                n = obj.NN_size(l_idx)+1;
                m = obj.NN_size(l_idx+1);

                % get V weight
                V = reshape(obj.V(pt_V: pt_V+(n*m)-1), n,m);
            
                % phi_k = act(nn_out); 1]
                if l_idx == 1
                    in = [in; 1]; % only one augmentation for 1st layer
                else
                    in = [act(in); 1];
                end

                % forward
                in = V'*in;
                
                % save to gradient tape
                if l_idx~=obj.l_size-1
                    obj.tape(pt_tape: pt_tape+m-1) = in;
                end

                % pointer to next
                pt_V = pt_V + (n*m);
                pt_tape = pt_tape + m;
            end

            % error check
            assert(pt_V-1 == obj.v_size);
        %     assert(pt_tape-1 == obj.t_size);

            % termination
            out = in;
            info = NaN;
        end

        function [obj, info] = backward_batch(obj, E)
            nnGrad = obj.getGrad();

            % dead-zone
            % if norm(E) < obj.e_tol
            %     info = NaN;
            %     return;
            % end

            V_grad =  - obj.alpha * -nnGrad' * E;
            V_grad = V_grad - obj.rho * sqrt(sum(E.^2,2)) * obj.V;
            V_grad = V_grad * obj.dt;

            obj.V = obj.V + mean(V_grad,2);

            % termination
            info = NaN;
        end

        function [obj, info] = backward(obj, e)
            assert(size(e,1) == 1);

            nnGrad = obj.getGrad();

            % dead-zone
            % if norm(e) < obj.e_tol
            %     info = NaN;
            %     return;
            % end

            V_grad =  - obj.alpha * -nnGrad' * e;
            V_grad = V_grad - obj.rho * norm(e) * obj.V;
            V_grad = V_grad * obj.dt;

            obj.V = obj.V + V_grad;

            % termination
            info = NaN;
        end
        
        %% ETC
        function total_grad = getGrad(obj)
            total_grad = zeros(obj.NN_size(end), obj.v_size);
            
            pt_V = obj.v_size;
            pt_tape = obj.t_size;

            grad_to_back = 1;

            if obj.act_func == "tanh"
                act = @tanh;
                act_dot = @tanh_dot;
            elseif obj.act_func == "ReLU"
                act = @ReLU;
                act_dot = @ReLU_dot;
            end
        
            % backward (chain rule)
            for l_idx = flip(2:1:obj.l_size)
                l2 = obj.NN_size(l_idx);        
                l1 = obj.NN_size(l_idx-1);        
                
                % pre_Phi
                Phi = obj.tape(pt_tape-l1+1: pt_tape);
                aug_phi = [act(Phi); 1];

                % (I \otimes phi_k^T)
                grad = kron(eye(l2), aug_phi');
                if l_idx ~= obj.l_size
                    n = l2+1; m = obj.NN_size(l_idx+1);
                    % get phi_dot
                    phi_dot = act_dot(pre_Phi);
                    % get V weight
                    V = reshape(obj.V(pt_V-(n*m)+1: pt_V), n,m);
                    grad_to_back = grad_to_back * V'*phi_dot;

                    % pointer to next
                    pt_V = pt_V - (n*m);
                end
                grad = grad_to_back*grad;

                % save to total grad
                total_grad(:, pt_V-((l1+1)*l2)+1: pt_V) = grad;

                % pointer to next
                pt_tape = pt_tape - l1;

                % for efficiency
                pre_Phi = Phi;

            end

            assert(pt_V == (obj.NN_size(1)+1)*obj.NN_size(2));
            assert(pt_tape == 0);
        end

        function Vn = V_norm(obj)
            Vn = zeros(obj.l_size-1,1);

            cumsum_V = [0;cumsum(obj.v_size_list)];
            for l_idx = 1:1:obj.l_size-1
                start_pt = cumsum_V(l_idx)+1;
                end_pt = cumsum_V(l_idx+1);   
        
                Vn(l_idx) = norm(obj.V(start_pt: end_pt));
            end
        end



    end
end

%% ACTIVATION FUNCTION
function phi_dot = tanh_dot(Phi)
    phi_dot = zeros(length(Phi)+1, length(Phi));
    for idx = 1:1:length(Phi)
        phi_dot(idx,idx) = 1-tanh(Phi(idx))^2;
    end
end

function y = ReLU(x)
    y = max(0,x);
end
function phi_dot = ReLU_dot(Phi)
    phi_dot = zeros(length(Phi)+1, length(Phi));
    for idx = 1:1:length(Phi)
        if Phi(idx) > 0
            phi_dot(idx,idx) = 1;
        else
            phi_dot(idx,idx) = 0;
        end
    end
end