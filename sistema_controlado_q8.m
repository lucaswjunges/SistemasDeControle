function dydt = sistema_controlado_q8(t, y, t_sim, r_signal, Kc, tau_i)
    % Estados: [CA, CB, xi]
    CA = y(1); CB = y(2); xi = y(3);
    
    % Parametros
    k1 = 6.01; k2 = 0.8433; k3 = 0.1123;
    CAF = 5.1;
    
    % Referencia atual
    r_current = interp1(t_sim, r_signal, t);
    
    % Erro e controle PI
    e = r_current - CB;
    u = Kc * (e + xi/tau_i);
    u = max(0, min(10, u));  % Saturacao
    
    % Dinamica da planta
    dCA_dt = -k1*CA - k3*CA^2 + (CAF - CA)*u;
    dCB_dt = k1*CA - k2*CB - CB*u;
    
    % Dinamica do integrador
    dxi_dt = e;
    
    dydt = [dCA_dt; dCB_dt; dxi_dt];
end