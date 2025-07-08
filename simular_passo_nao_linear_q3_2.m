function [CA_new, CB_new] = simular_passo_nao_linear_q3_2(CA, CB, u, CAF, dt)
    % Integracao usando Euler
    dCA_dt = -6.01*CA - 0.1123*CA^2 + (CAF - CA)*u;
    dCB_dt = 6.01*CA - 0.8433*CB - CB*u;
    
    CA_new = CA + dt * dCA_dt;
    CB_new = CB + dt * dCB_dt;
    
    % Garantir valores fisicos
    CA_new = max(0, CA_new);
    CB_new = max(0, CB_new);
end