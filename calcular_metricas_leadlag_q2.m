function [overshoot, settling_time] = calcular_metricas_leadlag_q2(t, y)
    y_final = y(end);
    y_inicial = y(1);
    
    % Overshoot
    if y_final > y_inicial
        y_max = max(y);
        overshoot = (y_max - y_final) / (y_final - y_inicial) * 100;
    else
        overshoot = 0;
    end
    
    % Tempo de acomodacao (5%)
    banda = 0.05 * abs(y_final - y_inicial);
    idx = find(abs(y - y_final) <= banda, 1, 'first');
    if ~isempty(idx)
        settling_time = t(idx);
    else
        settling_time = t(end);
    end
end