classdef CtrlPID
   properties (Access = private)
      Kp (1,1) double {mustBeNumeric}
      Ki (1,1) double {mustBeNumeric}
      Kd (1,1) double {mustBeNumeric}

      ctrl_dt (1,1) double {mustBeNumeric}

      cur_e (:,1) double {mustBeNumeric}
      der_e (:,1) double {mustBeNumeric}
      int_e (:,1) double {mustBeNumeric}

      pre_e (:,1) double {mustBeNumeric}

   end

   methods
      function obj = CtrlPID(Kp, Ki, Kd, ctrl_dt)
         obj.Kp = Kp;
         obj.Ki = Ki;
         obj.Kd = Kd;

         obj.ctrl_dt = ctrl_dt;

         obj.cur_e = 0;
         obj.der_e = 0;
         obj.int_e = 0;

         obj.pre_e = 0;
      end

      %% CONTROL METHODS
      function obj = preControl(obj, e)
         obj.cur_e = e;
         obj.int_e = obj.int_e + obj.cur_e * obj.ctrl_dt;
         obj.der_e = (obj.cur_e - obj.pre_e) / obj.ctrl_dt;
      end

      function obj = postControl(obj)
         obj.pre_e = obj.cur_e;
      end

      function [obj, u] = getControl(obj, y, r)
         e = y-r;
         obj = obj.preControl(e);
         
         u = obj.Kp * obj.cur_e + obj.Ki * obj.int_e + obj.Kd * obj.der_e / obj.ctrl_dt;
         u = -u;

         obj = obj.postControl();
      end

   end
end