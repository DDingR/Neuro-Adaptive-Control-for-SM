classdef env_SM_linear 

    properties (Access = public)
        x (3,1) double {mustBeNumeric}      % State of the system
                                            % [motor_ang_speed, i_d, i_q]
        y (3,1) double {mustBeNumeric}      % Output of the system
                                            % [motor_ang_speed]
        u (2,1) double {mustBeNumeric}      % Input to the system
                                            % [v_d, v_q]
        dt (1,1) double {mustBeNumeric}     % Sampling time
    end

    properties (Access = private)
        % system paramters
        L (2,2) double {mustBeNumeric}      % Inductance matrix
        R (2,2) double {mustBeNumeric}      % Resistance matrix
        np (1,1) double {mustBeNumeric}     % Number of pole pairs
        kappa (1,1) double {mustBeNumeric}  %
        Theta (1,1) double {mustBeNumeric}  % Motor inertia    
    end

    methods
        function obj = env_SM_linear(init_x, init_u, sampling_time)
            assert(length(init_x) == 3, 'State must have 3 elements')
            assert(length(init_u) == 2, 'Input must have 2 elements')
            
            % Constructor
            obj.x = init_x;
            obj.y = obj.getOutput();
            obj.u = init_u;
            obj.dt = sampling_time;

            obj.L = [
                3e-1     0;
                0     3e-1
            ];
            obj.R = [
                .45     0;
                0     .45;
            ];
            
            obj.np = 4;               
            obj.kappa = 2/3;          
            obj.Theta = 0.005;        
        end

        function y =  getOutput(obj)
            y = obj.x;       
        end

        function hist = getCurrentInfo(obj)
            hist.x = obj.x;
            hist.y = obj.y;
            hist.u = obj.u;
        end

        function inv_L = getInvL(obj)
            det_L = obj.L(1,1)*obj.L(2,2) - obj.L(1,2)*obj.L(2,1);
            assert(det_L ~= 0, 'Matrix is singular and cannot be inverted')

            inv_L = (1/det_L) * [
                +obj.L(2,2), -obj.L(1,2); 
                -obj.L(2,1), +obj.L(1,1)
            ];
        end

        function psi = getPsi(obj)
            psi = obj.L * obj.x(2:3) + [5e-2; 5e-2];
        end

        function trq_l = getLowTorque(obj)
            trq_l = 0;
        end

        function grad = getDynamicsGradient(obj)
            psi = obj.getPsi();
            J = [0 -1; 1 0];

            trq = (2*obj.np)/(3*obj.kappa^2) * obj.x(2:3)'*J*psi;
            trq_l = obj.getLowTorque();
            grad_1 = 1/obj.Theta * (trq - trq_l);   

            inv_L = obj.getInvL();
            grad_2 = inv_L * (-obj.R*obj.x(2:3) - obj.x(1)/obj.np*J*psi + obj.u);

            grad = [grad_1; grad_2];
        end

        function obj = step(obj, u)
            assert(length(u) == 2, 'Input must have 2 elements')

            obj.u = u;

            grad = obj.getDynamicsGradient();
            obj.x = obj.x + grad * obj.dt;
            obj.y = obj.getOutput();
        end

    end

end