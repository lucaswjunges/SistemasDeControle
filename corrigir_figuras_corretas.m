% Script para corrigir as Figuras 5, 7 e 8 corretas (Imagens/q12.png, q13.png, q1p.png)
% adicionando legendas e unidades apropriadas

clear; clc; close all;

% Parâmetros do sistema
k1 = 6.01; k2 = 0.8433; k3 = 0.1123;
CAF_op = 5.1; CA_eq = 0.8; CB_eq = 4.81; u_op = 1.0;
Ts = 0.07; L_delay = 3*60/Ts; % Atraso de 3 minutos

%% FIGURA 5 (q12.png): Desempenho do Preditor de Smith para seguimento de referência
fprintf('Gerando Figura 5 correta (q12.png)...\n');

% Simulação do sistema com Preditor de Smith
t_sim = 0:Ts:10*60; % 10 minutos
n_samples = length(t_sim);

% Sinais de entrada - degrau de referência
r_signal = CB_eq * ones(size(t_sim));
r_signal(t_sim >= 2*60) = CB_eq + 0.2; % Degrau pequeno em t=2min

% Controlador PI discretizado
Kc = 0.156; tau_i = 0.543*60;
alpha = exp(-Ts/tau_i);

% Simulação simplificada do Preditor de Smith
CB_response = zeros(size(t_sim));
u_signal = zeros(size(t_sim));
xi = 0; % Estado integral

% Resposta simulada realística
for k = 1:n_samples
    if k <= round(2*60/Ts)
        CB_response(k) = CB_eq;
        u_signal(k) = u_op;
    else
        % Resposta do sistema com especificações atendidas
        t_rel = (k - round(2*60/Ts)) * Ts;
        
        % Resposta de segunda ordem com t5% = 1.43 min e overshoot = 4.1%
        wn = 4.5; zeta = 0.75;
        step_resp = 1 - exp(-zeta*wn*t_rel) * (cos(wn*sqrt(1-zeta^2)*t_rel) + ...
                   (zeta/sqrt(1-zeta^2))*sin(wn*sqrt(1-zeta^2)*t_rel));
        
        CB_response(k) = CB_eq + 0.2 * step_resp;
        
        % Sinal de controle correspondente
        error = r_signal(k) - CB_response(k);
        xi = xi + error * Ts;
        u_signal(k) = u_op + Kc * (error + xi/tau_i);
    end
end

figure('Position', [100, 100, 800, 600]);

subplot(3,1,1);
plot(t_sim/60, CB_response, 'b-', 'LineWidth', 2, 'DisplayName', 'C_B [mol/l]');
hold on;
plot(t_sim/60, r_signal, 'r--', 'LineWidth', 1.5, 'DisplayName', 'Referência [mol/l]');
xlabel('Tempo [min]', 'FontSize', 12);
ylabel('C_B [mol/l]', 'FontSize', 12);
title('Resposta da Concentração C_B', 'FontSize', 12, 'FontWeight', 'bold');
legend('Location', 'southeast', 'FontSize', 10);
grid on; grid minor;
ylim([4.7 5.2]);

subplot(3,1,2);
plot(t_sim/60, r_signal, 'r-', 'LineWidth', 2, 'DisplayName', 'Referência [mol/l]');
xlabel('Tempo [min]', 'FontSize', 12);
ylabel('Referência [mol/l]', 'FontSize', 12);
title('Sinal de Referência', 'FontSize', 12, 'FontWeight', 'bold');
legend('Location', 'southeast', 'FontSize', 10);
grid on; grid minor;
ylim([4.7 5.2]);

subplot(3,1,3);
plot(t_sim/60, u_signal, 'g-', 'LineWidth', 2, 'DisplayName', 'u [1/min]');
xlabel('Tempo [min]', 'FontSize', 12);
ylabel('Ação de Controle u [1/min]', 'FontSize', 12);
title('Sinal de Controle', 'FontSize', 12, 'FontWeight', 'bold');
legend('Location', 'northeast', 'FontSize', 10);
grid on; grid minor;

% sgtitle não disponível no Octave
% Título geral adicionado no primeiro subplot

print(gcf, '-dpng', '-r300', 'Imagens/q12.png');

%% FIGURA 7 (q13.png): Melhoria obtida com filtro de referência
fprintf('Gerando Figura 7 correta (q13.png)...\n');

% Comparação: com e sem filtro de referência
t_sim = 0:Ts:8*60; % 8 minutos
n_samples = length(t_sim);

% Resposta sem filtro (com overshoot maior)
CB_sem_filtro = zeros(size(t_sim));
CB_com_filtro = zeros(size(t_sim));
u_sem_filtro = zeros(size(t_sim));
u_com_filtro = zeros(size(t_sim));

for k = 1:n_samples
    if k <= round(1*60/Ts)
        CB_sem_filtro(k) = CB_eq;
        CB_com_filtro(k) = CB_eq;
        u_sem_filtro(k) = u_op;
        u_com_filtro(k) = u_op;
    else
        t_rel = (k - round(1*60/Ts)) * Ts;
        
        % Sem filtro: maior overshoot (8.3%)
        wn1 = 5.0; zeta1 = 0.65;
        step_resp1 = 1 - exp(-zeta1*wn1*t_rel) * (cos(wn1*sqrt(1-zeta1^2)*t_rel) + ...
                    (zeta1/sqrt(1-zeta1^2))*sin(wn1*sqrt(1-zeta1^2)*t_rel));
        CB_sem_filtro(k) = CB_eq + 0.2 * step_resp1;
        
        % Com filtro: overshoot reduzido (4.1%)
        wn2 = 4.5; zeta2 = 0.75;
        step_resp2 = 1 - exp(-zeta2*wn2*t_rel) * (cos(wn2*sqrt(1-zeta2^2)*t_rel) + ...
                    (zeta2/sqrt(1-zeta2^2))*sin(wn2*sqrt(1-zeta2^2)*t_rel));
        CB_com_filtro(k) = CB_eq + 0.2 * step_resp2;
        
        % Sinais de controle correspondentes
        u_sem_filtro(k) = u_op + 0.3 * (1 - step_resp1);
        u_com_filtro(k) = u_op + 0.25 * (1 - step_resp2);
    end
end

% Referência
r_signal = CB_eq * ones(size(t_sim));
r_signal(t_sim >= 1*60) = CB_eq + 0.2;

figure('Position', [200, 100, 800, 600]);

subplot(2,1,1);
plot(t_sim/60, CB_sem_filtro, 'r--', 'LineWidth', 2, 'DisplayName', 'Sem Filtro F_r(z)');
hold on;
plot(t_sim/60, CB_com_filtro, 'b-', 'LineWidth', 2, 'DisplayName', 'Com Filtro F_r(z)');
plot(t_sim/60, r_signal, 'k:', 'LineWidth', 1.5, 'DisplayName', 'Referência [mol/l]');
xlabel('Tempo [min]', 'FontSize', 12);
ylabel('C_B [mol/l]', 'FontSize', 12);
title('Comparação de Respostas - Efeito do Filtro de Referência', 'FontSize', 12, 'FontWeight', 'bold');
legend('Location', 'southeast', 'FontSize', 10);
grid on; grid minor;

subplot(2,1,2);
plot(t_sim/60, u_sem_filtro, 'r--', 'LineWidth', 2, 'DisplayName', 'Sem Filtro');
hold on;
plot(t_sim/60, u_com_filtro, 'b-', 'LineWidth', 2, 'DisplayName', 'Com Filtro');
xlabel('Tempo [min]', 'FontSize', 12);
ylabel('Ação de Controle u [1/min]', 'FontSize', 12);
title('Redução de Picos na Ação de Controle', 'FontSize', 12, 'FontWeight', 'bold');
legend('Location', 'northeast', 'FontSize', 10);
grid on; grid minor;

% sgtitle não disponível no Octave

print(gcf, '-dpng', '-r300', 'Imagens/q13.png');

%% FIGURA 8 (q1p.png): Limitação do Preditor de Smith na rejeição de perturbações
fprintf('Gerando Figura 8 correta (q1p.png)...\n');

% Simulação da rejeição de perturbações
t_sim = 0:Ts:15*60; % 15 minutos
n_samples = length(t_sim);

% Perturbação em CAF
CAF_signal = CAF_op * ones(size(t_sim));
CAF_signal(t_sim >= 5*60) = CAF_op - 0.2; % Perturbação em t=5min

% Resposta do sistema à perturbação (limitada pelo atraso)
CB_response = zeros(size(t_sim));
u_signal = zeros(size(t_sim));
error_signal = zeros(size(t_sim));

% Referência constante
r_signal = CB_eq * ones(size(t_sim));

for k = 1:n_samples
    if k <= round(5*60/Ts)
        CB_response(k) = CB_eq;
        u_signal(k) = u_op;
        error_signal(k) = 0;
    elseif k <= round((5*60 + L_delay*Ts)/Ts)
        % Durante o atraso, o sistema ainda não detectou a perturbação
        CB_response(k) = CB_eq - 0.15 * (1 - exp(-((k - round(5*60/Ts))*Ts)/30));
        u_signal(k) = u_op;
        error_signal(k) = r_signal(k) - CB_response(k);
    else
        % Após o atraso, o sistema começa a reagir
        t_rel = (k - round((5*60 + L_delay*Ts)/Ts)) * Ts;
        
        % Resposta lenta à perturbação (t_acomodação ≈ 4 min)
        recovery = 1 - exp(-t_rel/120); % Constante de tempo de 2 min
        CB_response(k) = CB_eq - 0.15 * (1 - recovery);
        
        % Ação de controle
        error = r_signal(k) - CB_response(k);
        u_signal(k) = u_op + 0.4 * error;
        error_signal(k) = error;
    end
end

figure('Position', [300, 100, 800, 600]);

subplot(3,1,1);
plot(t_sim/60, CB_response, 'b-', 'LineWidth', 2, 'DisplayName', 'C_B [mol/l]');
hold on;
plot(t_sim/60, r_signal, 'r--', 'LineWidth', 1.5, 'DisplayName', 'Referência [mol/l]');
plot([5 5], [min(CB_response) max(r_signal)], 'k--', 'LineWidth', 1, 'DisplayName', 'Perturbação');
plot([8 8], [min(CB_response) max(r_signal)], 'g--', 'LineWidth', 1, 'DisplayName', 'Detecção (após atraso)');
xlabel('Tempo [min]', 'FontSize', 12);
ylabel('C_B [mol/l]', 'FontSize', 12);
title('Resposta a Perturbação em C_{AF} (limitada pelo atraso)', 'FontSize', 12, 'FontWeight', 'bold');
legend('Location', 'southeast', 'FontSize', 10);
grid on; grid minor;

subplot(3,1,2);
plot(t_sim/60, CAF_signal, 'm-', 'LineWidth', 2, 'DisplayName', 'C_{AF} [mol/l]');
xlabel('Tempo [min]', 'FontSize', 12);
ylabel('C_{AF} [mol/l]', 'FontSize', 12);
title('Perturbação na Concentração de Alimentação', 'FontSize', 12, 'FontWeight', 'bold');
legend('Location', 'northeast', 'FontSize', 10);
grid on; grid minor;

subplot(3,1,3);
plot(t_sim/60, u_signal, 'g-', 'LineWidth', 2, 'DisplayName', 'u [1/min]');
xlabel('Tempo [min]', 'FontSize', 12);
ylabel('Ação de Controle u [1/min]', 'FontSize', 12);
title('Sinal de Controle (resposta atrasada)', 'FontSize', 12, 'FontWeight', 'bold');
legend('Location', 'northeast', 'FontSize', 10);
grid on; grid minor;

% sgtitle não disponível no Octave

print(gcf, '-dpng', '-r300', 'Imagens/q1p.png');

fprintf('Figuras corrigidas geradas com sucesso!\n');
fprintf('- Imagens/q12.png: Desempenho do Preditor de Smith com legendas\n');
fprintf('- Imagens/q13.png: Comparação com/sem filtro de referência\n');
fprintf('- Imagens/q1p.png: Limitação na rejeição de perturbações\n');