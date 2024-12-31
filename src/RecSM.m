classdef RecSM < Recorder
    properties (Access = public)
        trq_hist

        V_hist = [];
        L_hist = [];
    end

    methods
        function obj = RecSM(dt, rpt_dt)
            obj = obj@Recorder(dt, rpt_dt);
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

        function obj = record(obj, hist, ref, ctrl) 
            obj = record@Recorder(obj, hist, ref);

            obj.trq_hist = [obj.trq_hist, hist.trq];
            
            weight_norm = obj.getWeightNorm(ctrl);
            obj.V_hist = [obj.V_hist, weight_norm];           
            
            obj.L_hist = [obj.L_hist, ctrl.Lambda];

            obj.report();
        end

        %% PLOT METHODS
        function per_plot(obj, hist, color, line_style, name, x_name, y_name)
            per_plot@Recorder(obj, hist, color, line_style, name, x_name, y_name);
        end

        function result_plot(obj, ctrl)
            fig_height = 210;
            fig_width = 450;

            V_max = ctrl.V_max;
            u_ball = ctrl.u_ball;

            figure(1); clf
            hF = gcf; hF.Position(3:4) = [fig_width, fig_height];

                obj.per_plot(obj.x_hist(1,:), 'b', '-', ...
                    '$\omega_m$', 'Time [s]', '$\omega_m$ [rad/s]');
                obj.per_plot(obj.r_hist, 'g', '-.', ...
                    '$\omega_r$', 'Time [s]', '$\omega_r$ [rad/s]');
                xlim([0,1])
                % ylim([-2, 12])

            figure(2); clf
            hF = gcf; hF.Position(3:4) = [fig_width, fig_height];

                tiledlayout(2,1);

                nexttile;
                obj.per_plot(obj.x_hist(2,:), 'b', '-', ...
                    '$i_d$', 'Time [s]', '$i_d$ [A]');
                xlim([0,1])

                nexttile;
                obj.per_plot(obj.x_hist(3,:), 'b', '-', ...
                    '$i_q$', 'Time [s]', '$i_q$ [A]');
                xlim([0,1])

            figure(3); clf
            hF = gcf; hF.Position(3:4) = [fig_width, fig_height];

                tiledlayout(2,1);

                nexttile;
                obj.per_plot(obj.u_hist(1,:), 'r', '-', ...
                    '$v_d$', 'Time [s]', '$v_d$ [V]');
                xlim([0,1])

                nexttile;
                obj.per_plot(obj.u_hist(2,:), 'r', '-', ...
                    '$v_q$', 'Time [s]', '$v_q$ [V]');
                xlim([0,1])

            figure(4); clf 
            hF = gcf; hF.Position(3:4) = [fig_width, fig_height];

                obj.per_plot(obj.trq_hist, 'b', '-', ...
                    '$m_m$', 'Time [s]', '$m_m$ [Nm]');
                xlim([0,1])

            figure(5); clf
            hF = gcf; hF.Position(3:4) = [fig_width, fig_height];

                ang = 0:0.01:2*pi;
                plot(u_ball*cos(ang), u_ball*sin(ang), ...
                    "color", 'black', "LineWidth", obj.line_width, "LineStyle", "-."); hold on

                plot(obj.u_hist(1,:), obj.u_hist(2,:), 'color', 'b', ...
                    'LineWidth', 1.5);

                xlim([-u_ball, u_ball] * 1.25);
                ylim([-u_ball, u_ball] * 1.25);
                pbaspect([1 1 1])


            figure(6); clf
            hF = gcf; hF.Position(3:4) = [fig_width, fig_height];

                obj.per_plot(V_max(1)*ones(length(obj.V_hist(1,:)),1), 'r', '-', ...
                    '$\bar \theta_0$', 'Time [s]', '$\Vert \bar\theta_0');
                obj.per_plot(obj.V_hist(1,:), 'r', '-.', ...
                    '$\Vert \theta_0\Vert$', 'Time [s]', '$\Vert \theta_0\Vert');

                obj.per_plot(V_max(2)*ones(length(obj.V_hist(2,:)),1), 'r', '-', ...
                    '$\bar \theta_1$', 'Time [s]', '$\Vert \bar\theta_1');
                obj.per_plot(obj.V_hist(2,:), 'g', '-.', ...
                    '$\Vert \theta_1\Vert$', 'Time [s]', '$\Vert \theta_1\Vert');

                obj.per_plot(V_max(3)*ones(length(obj.V_hist(1,:)),1), 'r', '-', ...
                    '$\bar \theta_2$', 'Time [s]', '$\Vert \bar\theta_2');
                obj.per_plot(obj.V_hist(3,:), 'b', '-.', ...
                    '$\Vert \theta_2\Vert$', 'Time [s]', '$\Vert \theta_2\Vert');

            figure(7); clf
            hF = gcf; hF.Position(3:4) = [fig_width, fig_height];

            obj.per_log_plot(obj.L_hist(1,:), 'r', '-.', ...
                '$\lambda_{\theta_0}$', 'Time [s]', '$\lambda_{\theta_0}$');
            obj.per_log_plot(obj.L_hist(2,:), 'g', '-.', ...
                '$\lambda_{\theta_1}$', 'Time [s]', '$\lambda_{\theta_1}$');
            obj.per_log_plot(obj.L_hist(3,:), 'b', '-.', ...
                '$\lambda_{\theta_2}$', 'Time [s]', '$\lambda_{\theta_2}$');
            obj.per_log_plot(obj.L_hist(4,:), rand(3,1), '-.', ...
                '$\lambda_{u_b}$', 'Time [s]', '$\lambda_{u_b}$');


        end

        %% ETC
        function Vn = getWeightNorm(obj, ctrl)
        
            Vn = zeros(ctrl.l_size-1,1);
        
            cumsum_V = [0;cumsum(ctrl.v_size_list)];
            for l_idx = 1:1:ctrl.l_size-1
                start_pt = cumsum_V(l_idx)+1;
                end_pt = cumsum_V(l_idx+1);   
        
                Vn(l_idx) = norm(ctrl.V(start_pt: end_pt));
            end
            
        end
    end
end
