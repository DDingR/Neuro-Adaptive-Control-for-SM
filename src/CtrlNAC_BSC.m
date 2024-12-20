classdef CtrlNAC_BSC < ParamSM_Lookup & NN_CoNAC
    properties (Access = public)
        k1 (1,1) double {mustBeNumeric}
        K2 (2,2) double {mustBeNumeric}

        ctrl_dt (1,1) double {mustBeNumeric} 

        pre_r (:,1) double {mustBeNumeric}

        r2 (:,1) double {mustBeNumeric}
        rd2 (:,1) double {mustBeNumeric}

        f1 (1,2) double {mustBeNumeric}
        f2 (2,1) double {mustBeNumeric}
        g (2,2) double {mustBeNumeric}

    end

    methods
        function obj = CtrlNAC_BSC(k1, k2, r, ctrl_dt)
            obj@ParamSM_Lookup();
            obj@NN_CoNAC(ctrl_dt);

            obj.k1 = k1;
            obj.K2 = k2 * eye(2);
            obj.pre_r = r;
            obj.ctrl_dt = ctrl_dt;
        end

        function disp(obj)
            fprintf('*** BSC Controller Parameters ***\n')
            fprintf('k1: %.2f\n', obj.k1)
            fprintf('K2: [%.2f, %.2f; %.2f, %.2f]\n', obj.K2(1,1), obj.K2(1,2), obj.K2(2,1), obj.K2(2,2))
            fprintf('Control dt: %f\n', obj.ctrl_dt)
        end

        %% GET METHODS
        function info = getInfo(obj)
            info = getInfo@NN_CoNAC(obj);
        end

        %% SYSTEM METHODS
        function psi = getPsi(obj, y)
            psi = getPsi@ParamSM_Lookup(obj, y(2:3));
            psi = psi + ones(size(psi)) * 1e-3;
        end

        function L = getL(obj, y)
            L = getL@ParamSM_Lookup(obj, y(2:3));
            L = L + ones(size(L)) * 1e-3;
        end
        
        function obj = getSys(obj, y)
            psi = obj.getPsi(y);
            L = obj.getL(y);

            inv_L = matInv22(L);

            obj.f1 = (2*obj.np)/(3*obj.kappa^2*obj.Theta)*psi'*obj.J';
            obj.f2 = inv_L * (-obj.R * y(2:3) - y(1)/obj.np*obj.J*psi);
            obj.g = inv_L;
        end

        %% CONTROL METHODS
        function obj = preControl(obj, y, r)
            e = y(1) - r;

            obj = obj.getSys(y);
            rd1 = (r-obj.pre_r) / obj.ctrl_dt;
            d = 0;
            
            obj.r2 = (1/(obj.f1*obj.f1'))*obj.f1'*(-obj.k1*e - d + rd1);
            % obj.r2 = obj.f1'*(-obj.k1*e - d + rd1);
            obj.rd2 = [0;0]; % not implemented
        end

        function obj = postControl(obj, y, r, e, u)
            obj.pre_r = r;

            obj = postControl@NN_CoNAC(obj, e(2:3), u);
        end

        function [obj, u] = getControl(obj, y, r)
            obj = obj.preControl(y, r);
            e = y - [r; obj.r2];

            u = -1 * getControl@NN_CoNAC(obj, e);
            
            assert(~isnan(norm(u)), 'Control signal is NaN')

            obj = obj.postControl(y, r, e, u);
        end

    end
end

function inv_M = matInv22(M)
    det = M(1,1)*M(2,2) - M(1,2)*M(2,1);
    assert(det ~= 0, 'Matrix is singular and cannot be inverted')

    inv_M = (1/det) * [
        +M(2,2), -M(1,2); 
        -M(2,1), +M(1,1)
    ];
end