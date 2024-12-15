function idqs_ref = Torque_Generator(Te_ref, Lds, Lqs, LAMpm, P)

persistent ids_ref iqs_ref
if (isempty(ids_ref) || isempty(iqs_ref)), ids_ref = 0.0; iqs_ref = 0.0; end

k1 = 1.5*P*LAMpm; k2 = 1.5*P*(Lds-Lqs);

MTPA_tmp1 = k2*iqs_ref;
MTPA_tmp2 = k1 + k2*ids_ref;
MTPA_tmp3 = (MTPA_tmp1*ids_ref + Te_ref)/(MTPA_tmp1*MTPA_tmp1 + MTPA_tmp2*MTPA_tmp2);

%% d-q Reference Current
ids_ref = MTPA_tmp1*MTPA_tmp3;
iqs_ref = MTPA_tmp2*MTPA_tmp3;

idqs_ref = [ids_ref;iqs_ref];

end







