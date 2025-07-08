function [overshoot, t_5_pct] = calcular_metricas_q8(t, y, y_final)
    % Overshoot
    y_max = max(y);
    overshoot = max(0, (y_max - y_final)/y_final * 100);
    
    % Tempo de acomodacao (5%)
    banda_5pct = 0.05 * abs(y_final - y(1));
    idx_settle = find(abs(y - y_final) <= banda_5pct, 1, 'first');
    if ~isempty(idx_settle)
        t_5_pct = t(idx_settle);
    else
        t_5_pct = t(end);
    end
end