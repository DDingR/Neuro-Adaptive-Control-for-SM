classdef Recorder
    properties (Access = public)
        x_hist 
        y_hist
        u_hist 
        r_hist

        t_idx
        dt 
        rpt_dt

        font_size = 12;
        line_width = 2;
        label_font_size = 18;
    end

    methods
        function obj = Recorder(x0, y0, r0, dt, rpt_dt, font_size, line_width, label_font_size)
            obj.x_hist = x0;
            obj.y_hist = y0;
            obj.u_hist = [];
            obj.r_hist = r0;

            obj.t_idx = 1;
            obj.dt = dt;
            obj.rpt_dt = rpt_dt;

            if nargin > 5
                obj.font_size = font_size;
            elseif nargin > 6
                obj.line_width = line_width;
            elseif nargin > 7
                obj.label_font_size = label_font_size;
            end
        end

        function disp(obj)
            fprintf('*** Recorder Parameters ***\n')
            fprintf('Sampling Time: %.2f\n', obj.dt)
            fprintf('Report Rate: %.2f\n', obj.rpt_dt)
            fprintf('font size: %d\n', obj.font_size)
            fprintf('line width: %d\n', obj.line_width)
            fprintf('label font size: %d\n', obj.label_font_size)
        end

        %% RECORD METHODS
        function obj = report(obj)
            if mod(obj.t_idx, obj.rpt_dt/obj.dt) == 0
                fprintf('Simulation Time: %.2f s\n', obj.t_idx*obj.dt);
                % fprintf('State:     ')
                % for i = 1:length(obj.x_hist(:,end))
                %     fprintf('%.2f ', obj.x_hist(i,end))
                % end; fprintf('\n')
                % fprintf('Output:    ')
                % for i = 1:length(obj.y_hist(:,end))
                %     fprintf('%.2f ', obj.y_hist(i,end))
                % end; fprintf('\n')
                % fprintf('Reference: ')
                % for i = 1:length(obj.r_hist(:,end))
                %     fprintf('%.2f ', obj.r_hist(i,end))
                % end; fprintf('\n')
            end
        end

        function obj = record(obj, hist, ref)
            obj.x_hist = [obj.x_hist, hist.x];
            obj.y_hist = [obj.y_hist, hist.y];
            obj.u_hist = [obj.u_hist, hist.u];
            obj.r_hist = [obj.r_hist, ref];

            obj.t_idx = obj.t_idx + 1;
        end

        function hist = getHistory(obj)
            hist.x_hist = obj.x_hist;
            hist.y_hist = obj.y_hist;
            hist.u_hist = obj.u_hist;
            hist.r_hist = obj.r_hist;
        end

        %% PLOT METHODS
        function per_plot(obj, hist, color, line_style, name, x_name, y_name)
            plot(obj.dt*((1:size(hist,2))-1), hist(1,:), ...
                'Color', color, ...
                'LineWidth', obj.line_width, ...
                'LineStyle', line_style, ...
                'DisplayName', name ...
                );  hold on;
            grid on; 

            xlabel(x_name, 'Interpreter', 'latex', 'FontSize', obj.label_font_size);
            ylabel(y_name, 'Interpreter', 'latex', 'FontSize', obj.label_font_size);
        end

    end
end