function [t_out, x_out, u_out] = simular_malha_fechada_q8(t_sim, r_signal, Kc, tau_i)
    % Condicoes iniciais
    x0 = [0.8; 4.81];  % [CA; CB] de equilibrio
    
    % Estados do controlador PI (integral)
    xi_0 = 0;  % Estado integral inicial
    
    % Simulacao usando ode45 com controlador
    [t_out, y_out] = ode45(@(t, y) sistema_controlado_q8(t, y, t_sim, r_signal, Kc, tau_i), ...
                           t_sim, [x0; xi_0]);
    
    x_out = y_out(:, 1:2);  % Estados da planta
    xi_out = y_out(:, 3);   % Estado integral
    
    % Recalcular sinal de controle para plotagem
    u_out = zeros(size(t_out));
    for i = 1:length(t_out)
        r_current = interp1(t_sim, r_signal, t_out(i));
        e = r_current - x_out(i, 2);  % Erro de CB
        u_out(i) = Kc * (e + xi_out(i)/tau_i);
        u_out(i) = max(0, min(0, u_out(i)));  % Saturacao 0-10
    end
end