function [u_out, CB_pred, CB_measured] = smith_predictor_step_q3_2(r, CB_delayed, ...
    Gp_model, Gp_model_delay, Gc, estados)
    
    % Estados: [estados_planta, estados_controlador, buffer_atraso]
    
    % Predicao da saida sem atraso
    CB_pred = lsim(Gp_model, estados.u_hist(end), 1);
    
    % Predicao da saida com atraso (modelo)
    CB_model_delay = lsim(Gp_model_delay, estados.u_hist(end), 1);
    
    % Sinal de feedback compensado
    CB_comp = CB_pred + (CB_delayed - CB_model_delay);
    
    % Erro
    e = r - CB_comp;
    
    % Acao de controle
    u_out = lsim(Gc, e, 1);
    u_out = max(0, min(10, u_out));  % Saturacao
    
    CB_measured = CB_delayed;
end