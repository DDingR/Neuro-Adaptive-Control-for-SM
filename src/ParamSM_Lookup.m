classdef ParamSM_Lookup
    properties (Access = public)
        data_path = 'machine_data/machine_pmsm_mtpx.mat'

        isd
        isq
        PSISD
        PSISQ

        LSDD
        LSDQ
        LSQD
        LSQQ

        % system paramters
        L (2,2) double {mustBeNumeric}      % Inductance matrix
        R (2,2) double {mustBeNumeric}      % Resistance matrix
        np (1,1) double {mustBeNumeric}     % Number of pole pairs
        kappa (1,1) double {mustBeNumeric}  %
        Theta (1,1) double {mustBeNumeric}  % Motor inertia 
        J = [0 -1; 1 0] 
    end

    methods
        function obj = ParamSM_Lookup(data_path)
            if nargin == 1
                obj.data_path = data_path;
            end

            load(obj.data_path)

            % current vectors / grids
            obj.isd = machine.psi.s.arg.isd;
            obj.isq = machine.psi.s.arg.isq;

            % flux linkages
            obj.PSISD = machine.psi.s.d;
            obj.PSISQ = machine.psi.s.q;

            % differential inductances
            obj.LSDD = machine.L.s.dd;
            obj.LSDQ = machine.L.s.dq;
            obj.LSQD = machine.L.s.qd;
            obj.LSQQ = machine.L.s.qq;

            % dummy data
            obj.L = zeros(2,2);
            obj.R = eye(2) * machine.Rs;
            
            obj.np = machine.nP;               
            obj.kappa = machine.kappa;          
            obj.Theta = machine.ThetaM;        
        end

        function disp(obj)
            fprintf('*** System Parameters ***\n')
            fprintf('Inductance: [%.2f, %.2f; %.2f, %.2f]\n', obj.L(1,1), obj.L(1,2), obj.L(2,1), obj.L(2,2))
            fprintf('Resistance: [%.2f, %.2f; %.2f, %.2f]\n', obj.R(1,1), obj.R(1,2), obj.R(2,1), obj.R(2,2))
            fprintf('Number of pole pairs: %.2f\n', obj.np)
            fprintf('kappa: %.2f\n', obj.kappa)
            fprintf('Motor inertia: %.2f\n', obj.Theta)
        end

        %% PARAMETER METHODS
        function psi = getPsi(obj, current)
            psi_d = interpolate_from_table(current(1), current(2), obj.isd, obj.isq, obj.PSISD);
            psi_q = interpolate_from_table(current(1), current(2), obj.isd, obj.isq, obj.PSISQ);
            psi = [psi_d; psi_q];
        end

        function L = getL(obj, current)
            L_dd = interpolate_from_table(current(1), current(2), obj.isd, obj.isq, obj.LSDD);
            L_dq = interpolate_from_table(current(1), current(2), obj.isd, obj.isq, obj.LSDQ);
            L_qd = interpolate_from_table(current(1), current(2), obj.isd, obj.isq, obj.LSQD);
            L_qq = interpolate_from_table(current(1), current(2), obj.isd, obj.isq, obj.LSQQ);
            L = [L_dd, L_dq; L_qd, L_qq];
        end
    end
end

%% LOCAL FUNCTIONS
function y = linear_interpolate(x, x1, x2, y1, y2)
    % y = (y2-y1)/(x2-x1) * (x - x1) + y1     
    y = (y2-y1)/(x2-x1) * (x-x1) + y1;
end

function z = bilinear_interpolate(x,y, x1,x2,y1,y2, z11,z12,z21,z22)
    z1 = linear_interpolate(x, x1, x2, z12, z22);
    z2 = linear_interpolate(x, x1, x2, z11, z21);
    z = linear_interpolate(y, y1, y2, z2, z1);
end

function y = interpolate_from_table(x,y, X,Y, Z)
    x_idx = find(X >= x); x_idx = x_idx(1);
    y_idx = find(Y >= y); y_idx = y_idx(1);

    x_upper = X(x_idx); x_lower = X(x_idx-1);
    y_upper = Y(y_idx); y_lower = Y(y_idx-1);

    z_ul = Z(x_idx-1, y_idx-1);
    z_uu = Z(x_idx, y_idx-1);
    z_ll = Z(x_idx-1, y_idx);
    z_lu = Z(x_idx, y_idx);

    y = bilinear_interpolate(x, y, x_lower, x_upper, y_lower, y_upper, z_ul, z_uu, z_ll, z_lu);
end
