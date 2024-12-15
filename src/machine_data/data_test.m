clear

load('machine_pmsm_mtpx');

isd = machine.psi.s.arg.isd;
isq = machine.psi.s.arg.isq;
[ISD, ISQ] = ndgrid(isd, isq);
% flux linkages
PSISD = machine.psi.s.d;
PSISQ = machine.psi.s.q;

% differential inductances
LSDD = machine.L.s.dd;
LSDQ = machine.L.s.dq;
LSQD = machine.L.s.qd;
LSQQ = machine.L.s.qq;

id = 0;
iq = 0;


psid = interpolate_from_table(id, iq, isd, isq, PSISD)
psiq = interpolate_from_table(id, iq, isd, isq, PSISQ)
lsdd = interpolate_from_table(id, iq, isd, isq, LSDD)
lsdq = interpolate_from_table(id, iq, isd, isq, LSDQ)
lsqd = interpolate_from_table(id, iq, isd, isq, LSQD)
lsqq = interpolate_from_table(id, iq, isd, isq, LSQQ)




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

