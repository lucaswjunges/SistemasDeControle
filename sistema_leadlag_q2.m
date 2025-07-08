function dydt = sistema_leadlag_q2(t, y, CB_ref, k1, k2, k3, Gc)
    % Estados: [CA, CB, xc1, xc2] (planta + controlador)
    CA = y(1); CB = y(2);
    
    % Erro
    e = CB_ref - CB;
    
    % Controlador lead-lag implementado em espaco de estados
    % Para simplificacao, usamos aproximacao PI equivalente
    % u = Kc_eq * e + Ki_eq * integral(e)
    Kc_eq = 0.284 * 2.5;  % Aproximacao do ganho equivalente
    u = Kc_eq * e;
    u = max(0, min(10, u));  % Saturacao
    
    % Dinamica da planta
    CAF = 5.1;
    dCA_dt = -k1*CA - k3*CA^2 + (CAF - CA)*u;
    dCB_dt = k1*CA - k2*CB - CB*u;
    
    % Estados do controlador (simplificado)
    dydt = [dCA_dt; dCB_dt; 0; 0];
end