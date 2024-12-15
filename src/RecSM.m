classdef RecSM < Recorder
    properties (Access = public)
        trq_hist
    end

    methods
        function obj = RecSM(x0, y0, r0, dt, rpt_dt)
            obj = obj@Recorder(x0, y0, r0, dt, rpt_dt);
            obj.trq_hist = [];
        end

        function disp(obj)
            disp@Recorder(obj);
        end

        %% GET METHODS
        function hist = getHistory(obj)
            hist = getHistory@Recorder(obj);
            hist.trq_hist = obj.trq_hist;
        end

        %% RECORD METHODS
        function report(obj)
            if mod(obj.t_idx, obj.rpt_dt/obj.dt) == 0
                report@Recorder(obj);
                % fprintf('Torque:    %.2f\n', obj.trq_hist(end));
            end
        end

        function obj = record(obj, hist, ref)            
            obj.trq_hist = [obj.trq_hist, hist.trq];
            obj = record@Recorder(obj, hist, ref);

            obj.report();
        end

        %% PLOT METHODS
        function per_plot(obj, hist, color, line_style, name, x_name, y_name)
            per_plot@Recorder(obj, hist, color, line_style, name, x_name, y_name);
        end

        function result_plot(obj)
            figure(1); clf
            obj.per_plot(obj.x_hist(1,:), 'b', '-', ...
                '$\omega_m$', 'Time [s]', '$\omega_m$ [rad/s]');
            obj.per_plot(obj.r_hist, 'g', '-.', ...
                '$\omega_r$', 'Time [s]', '$\omega_r$ [rad/s]');

            figure(2); clf
            tiledlayout(2,1);

            nexttile;
            obj.per_plot(obj.x_hist(2,:), 'b', '-', ...
                '$i_d$', 'Time [s]', '$i_d$ [A]');
            nexttile;
            obj.per_plot(obj.x_hist(3,:), 'b', '-', ...
                '$i_q$', 'Time [s]', '$i_q$ [A]');

            figure(3); clf
            tiledlayout(2,1);

            nexttile;
            obj.per_plot(obj.u_hist(1,:), 'r', '-', ...
                '$v_d$', 'Time [s]', '$v_d$ [V]');
            nexttile;
            obj.per_plot(obj.u_hist(2,:), 'r', '-', ...
                '$v_q$', 'Time [s]', '$v_q$ [V]');

            figure(4); clf 
            obj.per_plot(obj.trq_hist, 'b', '-', ...
                '$m_m$', 'Time [s]', '$m_m$ [Nm]');
        end

    end
end