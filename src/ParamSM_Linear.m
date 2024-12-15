classdef ParamSM_Linear
    properties (Access = public)
        % system paramters
        L (2,2) double {mustBeNumeric}      % Inductance matrix
        R (2,2) double {mustBeNumeric}      % Resistance matrix
        np (1,1) double {mustBeNumeric}     % Number of pole pairs
        kappa (1,1) double {mustBeNumeric}  %
        Theta (1,1) double {mustBeNumeric}  % Motor inertia 
        J = [0 -1; 1 0]   

        bias_psi = [5e-2; 5e-2]
    end

    methods
        function obj = ParamSM_Linear()
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

        function disp(obj)
            fprintf('*** System Parameters ***\n')
            fprintf('Inductance: [%.2f, %.2f; %.2f, %.2f]\n', obj.L(1,1), obj.L(1,2), obj.L(2,1), obj.L(2,2))
            fprintf('Resistance: [%.2f, %.2f; %.2f, %.2f]\n', obj.R(1,1), obj.R(1,2), obj.R(2,1), obj.R(2,2))
            fprintf('Number of pole pairs: %.2f\n', obj.np)
            fprintf('kappa: %.2f\n', obj.kappa)
            fprintf('Motor inertia: %.2f\n', obj.Theta)
            fprintf('Bias of psi: [%.2f, %.2f]\n', obj.bias_psi(1), obj.bias_psi(2))
        end

        %% PARAMETER METHODS
        function psi = getPsi(obj, current)
            psi = obj.L * current + obj.bias_psi;
        end

        function L = getL(obj, current)
            return;
        end
    end
end