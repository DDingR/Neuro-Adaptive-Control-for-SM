classdef EnvSimple

    properties (Access = private)
        x (2,1) double {mustBeNumeric}      % State of the system
        y (1,1) double {mustBeNumeric}      % Output of the system
        u (1,1) double {mustBeNumeric}      % Input to the system

        dt (1,1) double {mustBeNumeric}    % Sampling time
    end

    methods
        function obj = EnvSimple(init_x, init_u, sampling_time)
            assert(length(init_x) == 2, 'State must have 2 elements')
            assert(length(init_u) == 1, 'Input must have 1 element')

            % Constructor
            obj.x = init_x;
            obj.y = obj.getOutput();
            obj.u = init_u;
            obj.dt = sampling_time;
        end

        function disp(obj)
            fprintf('Current Information\n')
            fprintf('State: [%.2f, %.2f]\n', obj.x(1), obj.x(2))
            fprintf('Output: [%.2f]\n', obj.y)
            fprintf('Input: [%.2f]\n', obj.u)
            fprintf('Sampling Time: %.2f\n', obj.dt)
            fprintf('\n')
        end

        function y =  getOutput(obj)
            y = [1 0] * obj.x;            
        end

        function hist = getCurrentInfo(obj)
            hist.x = obj.x;
            hist.y = obj.y;
            hist.u = obj.u;
        end

        function grad = getDynamicsGradient(obj)
            grad = [0 1;-2 -3] * obj.x + [0; 1] * obj.u;
        end

        function obj = step(obj, u)
            assert(length(u) == 1, 'Input must have 1 element')
            
            obj.u = u;

            grad = obj.getDynamicsGradient();
            obj.x = obj.x + grad * obj.dt;
            obj.y = obj.getOutput();
        end

    end

end