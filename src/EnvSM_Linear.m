classdef EnvSM_Linear < ParamSM_Linear

    properties (Access = public)
        x (3,1) double {mustBeNumeric}      % State of the system
                                            % [motor_ang_speed, i_d, i_q]
        y (3,1) double {mustBeNumeric}      % Output of the system
                                            % [motor_ang_speed]
        u (2,1) double {mustBeNumeric}      % Input to the system
                                            % [v_d, v_q]
        dt (1,1) double {mustBeNumeric}     % Sampling time

        trq (1,1) double {mustBeNumeric}    % Torque
    end

    methods
        function obj = EnvSM_Linear(init_x, init_u, sampling_time)
            obj = obj@ParamSM_Linear();

            assert(length(init_x) == 3, 'State must have 3 elements')
            assert(length(init_u) == 2, 'Input must have 2 elements')
            
            % Constructor
            obj.x = init_x;
            obj.y = obj.getOutput();
            obj.u = init_u;
            obj.dt = sampling_time;

        end

        function disp(obj)
            fprintf('*** Current Information ***\n')
            fprintf('State: [%.2f, %.2f, %.2f]\n', obj.x(1), obj.x(2), obj.x(3))
            fprintf('Output: [%.2f, %.2f, %.2f]\n', obj.y(1), obj.y(2), obj.y(3))
            fprintf('Torque: [%.2f]\n', obj.trq)
            fprintf('Sampling Time: %.2f\n', obj.dt)
            fprintf('\n')
            obj.disp@ParamSM_Linear();
        end

        %% GET METHODS
        function y =  getOutput(obj)
            y = obj.x;       
        end

        function hist = getInfo(obj)
            hist.x = obj.x;
            hist.y = obj.y;
            hist.u = obj.u;
            hist.trq = obj.trq;
        end

        %% SYSTEM METHODS
        function obj = renewPsiAndL(obj)
            obj = renewPsiAndL@ParamSM_Linear(obj, obj.x(2:3));
        end

        function inv_L = getInvL(obj)
            inv_L = getInvL@ParamSM_Linear(obj);
        end

        function psi = getPsi(obj)
            psi = getPsi@ParamSM_Linear(obj, obj.x(2:3));
        end

        function trq_l = getLowTorque(obj)
            trq_l = 0;
        end

        function [obj, grad] = getGrad(obj)
            obj = obj.renewPsiAndL();
            psi = obj.getPsi();

            obj.trq = (2*obj.np)/(3*obj.kappa^2) * obj.x(2:3)'*obj.J*psi;
            trq_l = obj.getLowTorque();
            grad_1 = 1/obj.Theta * (obj.trq - trq_l);   

            inv_L = obj.getInvL();
            grad_2 = inv_L * (-obj.R*obj.x(2:3) - obj.x(1)/obj.np*obj.J*psi + obj.u);

            grad = [grad_1; grad_2];
        end

        function obj = step(obj, u)
            assert(length(u) == 2, 'Input must have 2 elements')

            obj.u = u;

            [obj, grad] = obj.getGrad();
            obj.x = obj.x + grad * obj.dt;
            obj.y = obj.getOutput();
        end

    end
end