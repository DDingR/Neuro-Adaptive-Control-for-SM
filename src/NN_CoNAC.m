classdef NN_CoNAC < NN
    properties


    end

    methods
        function obj = NN_CoNAC()
            NN_size = [3, 8,2];   
            alpha = 1e+4;
            rho = alpha*1e-2;

            obj = obj@NN(NN_size, alpha, rho);

        end

        function disp(obj)
            disp@NN(obj);
        end

        %% GET METHODS
        function info = getInfo(obj)
            info = getInfo@NN(obj);
        end

        %% NEURAL NETWORK METHODS
        function [obj, out, info] = forward(obj, in)
            [obj, out, info] = forward@NN(obj, in);
        end

        function [obj, info] = backward(obj, e)
            [obj, info] = backward@NN(obj, e);
        end

        %% CONTROL METHODS
        function out = getControl(obj, in)
            [~, out, ~] = obj.forward(in);
        end

        function obj = postControl(obj, e)
            [obj, ~] = obj.backward(e);
        end

        %% ETC
        function grad = getGrad(obj)
            grad = getGrad@NN(obj);
        end

    end
end