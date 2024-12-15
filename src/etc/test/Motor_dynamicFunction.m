function [ids, iqs, Wr, Te] = Motor_dynamicFunction(ids, iqs, Wr, vds, vqs, Rs, Lds, Lqs, LAMpm, P, B, J, Ts)
    % Calculate current derivatives
    ids_dot = (vds - Rs * ids + Wr * Lqs * iqs) / Lds;
    iqs_dot = (vqs - Rs * iqs - Wr * (Lds * ids + LAMpm)) / Lqs;

    % Update currents
    ids = ids + ids_dot * Ts;
    iqs = iqs + iqs_dot * Ts;

    % Calculate electromagnetic torque
    k1 = 3/2*P*LAMpm;
    k2 = 3/2*P*(Lds-Lqs);
    Te = (k1 + k2*ids)*iqs;

    % Calculate speed dynamics
    Wr_dot = (Te - B * Wr) / J;
    Wr = Wr + Wr_dot * Ts;
end
