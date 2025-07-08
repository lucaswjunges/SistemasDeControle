function [t, CB_response, stable] = simular_sistema_variado_q2(k1, k2, k3, Gc)
    try
        % Simulacao em malha fechada com controlador lead-lag
        t_sim = 0:0.01:10;
        CB_ref = 4.81 + 0.5;  % Degrau de 0.5 mol/l
        
        % Condicoes iniciais
        x0 = [0.8; 4.81];  % [CA; CB]
        
        % Estados do controlador (2 polos, 2 zeros -> 2 estados internos)
        xc0 = [0; 0];
        
        % Simulacao
        [t, y] = ode45(@(t, y) sistema_leadlag_q2(t, y, CB_ref, k1, k2, k3, Gc), ...
                       t_sim, [x0; xc0]);
        
        CB_response = y(:, 2);
        stable = true;
        
        % Verificar estabilidade
        if any(isnan(CB_response)) || any(CB_response < 0) || max(CB_response) > 10
            stable = false;
        end
        
    catch
        t = []; CB_response = []; stable = false;
    end
end