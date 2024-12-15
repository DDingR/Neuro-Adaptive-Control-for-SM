% Made by SHJ 2024-12-13
% PI Controller W/ Output Saturation and Anti-windup

function Return = pi_controller(err, Kp, Ki, Ts, Out_sat)

    persistent error_sum Out
    if (isempty(error_sum) || isempty(Out)), error_sum = 0; Out = 0.0; end

    error_sum = error_sum + (err) * Ts;
    Out = Kp * err + Ki * error_sum;

    % Limitter (Output saturation)
    if Out > Out_sat
        Out = Out_sat;
    elseif Out < -Out_sat
        Out = -Out_sat;
    end

    Return = Out;
end