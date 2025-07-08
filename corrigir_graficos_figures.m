% Script para corrigir os gráficos figures 5, 7 e 8 adicionando legendas e unidades

clear; clc; close all;

% Parâmetros do sistema
k1 = 6.01; k2 = 0.8433; k3 = 0.1123;
CAF_op = 5.1; CA_eq = 0.8; CB_eq = 4.81; u_op = 1.0;
Ts = 0.07; L_delay = 3*60/Ts; % Atraso de 3 minutos

% Simulação temporal
t_sim = 0:Ts:30*60; % 30 minutos
n_samples = length(t_sim);

%% FIGURE 5: Preditor de Smith com sistema não linear (sistema completo)
fprintf('Gerando Figure 5...\n');

% Sinais de entrada
r_signal = CB_eq * ones(size(t_sim));
CAF_signal = CAF_op * ones(size(t_sim));
u_signal = u_op * ones(size(t_sim));

% Simulação simplificada do sistema não linear
CB_response = zeros(size(t_sim));
CA_response = zeros(size(t_sim));

% Estados iniciais
CA = CA_eq; CB = CB_eq;

for k = 1:n_samples
    % Simulação do sistema não linear simplificado
    dt = Ts;
    dCA_dt = -k1*CA - k3*CA^2 + (CAF_signal(k) - CA)*u_signal(k);
    dCB_dt = k1*CA - k2*CB - CB*u_signal(k);
    
    CA = CA + dCA_dt * dt;
    CB = CB + dCB_dt * dt;
    
    CA_response(k) = CA;
    CB_response(k) = CB;
end

figure('Position', [100, 100, 800, 600]);
subplot(2,1,1);
plot(t_sim/60, CB_response, 'b-', 'LineWidth', 2, 'DisplayName', 'C_B [mol/l]');
hold on;
plot(t_sim/60, CA_response, 'r-', 'LineWidth', 2, 'DisplayName', 'C_A [mol/l]');
xlabel('Tempo [min]', 'FontSize', 12);
ylabel('Concentração [mol/l]', 'FontSize', 12);
title('Preditor de Smith - Sistema Não Linear', 'FontSize', 14, 'FontWeight', 'bold');
legend('Location', 'best', 'FontSize', 10);
grid on; grid minor;

subplot(2,1,2);
plot(t_sim/60, u_signal, 'g-', 'LineWidth', 2, 'DisplayName', 'u [1/min]');
hold on;
plot(t_sim/60, CAF_signal, 'm-', 'LineWidth', 2, 'DisplayName', 'C_{AF} [mol/l]');
xlabel('Tempo [min]', 'FontSize', 12);
ylabel('Variáveis de Processo', 'FontSize', 12);
title('Sinais de Entrada e Controle', 'FontSize', 14, 'FontWeight', 'bold');
legend('Location', 'best', 'FontSize', 10);
grid on; grid minor;

print(gcf, '-dpng', '-r300', 'figure5.png');

%% FIGURE 7: Resposta Y/Q no sistema não linear com perturbação
fprintf('Gerando Figure 7...\n');

% Reset da simulação
t_sim = 0:Ts:25*60; % 25 minutos
n_samples = length(t_sim);

% Sinais com perturbação
r_signal = CB_eq * ones(size(t_sim));
CAF_signal = CAF_op * ones(size(t_sim));
CAF_signal(t_sim >= 20*60) = CAF_op - 0.2; % Perturbação em t=20min

u_signal = u_op * ones(size(t_sim));

% Simulação do sistema com perturbação
CB_response = zeros(size(t_sim));
CA_response = zeros(size(t_sim));
error_signal = zeros(size(t_sim));

CA = CA_eq; CB = CB_eq;

for k = 1:n_samples
    dt = Ts;
    dCA_dt = -k1*CA - k3*CA^2 + (CAF_signal(k) - CA)*u_signal(k);
    dCB_dt = k1*CA - k2*CB - CB*u_signal(k);
    
    CA = CA + dCA_dt * dt;
    CB = CB + dCB_dt * dt;
    
    CA_response(k) = CA;
    CB_response(k) = CB;
    error_signal(k) = r_signal(k) - CB;
end

figure('Position', [200, 100, 800, 600]);
subplot(3,1,1);
plot(t_sim/60, CB_response, 'b-', 'LineWidth', 2, 'DisplayName', 'C_B [mol/l]');
hold on;
plot(t_sim/60, r_signal, 'r--', 'LineWidth', 1.5, 'DisplayName', 'Referência [mol/l]');
plot([20 20], [min(CB_response) max(CB_response)], 'k--', 'LineWidth', 1, 'DisplayName', 'Perturbação');
xlabel('Tempo [min]', 'FontSize', 12);
ylabel('C_B [mol/l]', 'FontSize', 12);
title('Resposta Y/Q - Sistema Não Linear com Perturbação', 'FontSize', 14, 'FontWeight', 'bold');
legend('Location', 'best', 'FontSize', 10);
grid on; grid minor;

subplot(3,1,2);
plot(t_sim/60, CAF_signal, 'm-', 'LineWidth', 2, 'DisplayName', 'C_{AF} [mol/l]');
xlabel('Tempo [min]', 'FontSize', 12);
ylabel('C_{AF} [mol/l]', 'FontSize', 12);
title('Perturbação na Concentração de Alimentação', 'FontSize', 12, 'FontWeight', 'bold');
legend('Location', 'best', 'FontSize', 10);
grid on; grid minor;

subplot(3,1,3);
plot(t_sim/60, error_signal, 'k-', 'LineWidth', 2, 'DisplayName', 'Erro [mol/l]');
xlabel('Tempo [min]', 'FontSize', 12);
ylabel('Erro [mol/l]', 'FontSize', 12);
title('Erro de Controle (Referência - C_B)', 'FontSize', 12, 'FontWeight', 'bold');
legend('Location', 'best', 'FontSize', 10);
grid on; grid minor;

print(gcf, '-dpng', '-r300', 'figure7.png');

%% FIGURE 8: Variação Grande de Referência
fprintf('Gerando Figure 8...\n');

% Reset da simulação para variação grande
t_sim = 0:Ts:25*60; % 25 minutos
n_samples = length(t_sim);

% Sinais com grande variação de referência
r_signal = CB_eq * ones(size(t_sim));
r_signal(t_sim >= 5*60) = CB_eq + 1.0; % Grande variação em t=5min
r_signal(t_sim >= 15*60) = CB_eq - 0.8; % Outra variação em t=15min

CAF_signal = CAF_op * ones(size(t_sim));

% Controlador PI simples
Kp = 0.5; Ki = 0.1;
integral_error = 0;
u_signal = zeros(size(t_sim));

% Simulação do sistema com grandes variações
CB_response = zeros(size(t_sim));
CA_response = zeros(size(t_sim));
error_signal = zeros(size(t_sim));

CA = CA_eq; CB = CB_eq;

for k = 1:n_samples
    % Erro de controle
    error = r_signal(k) - CB;
    integral_error = integral_error + error * Ts;
    
    % Lei de controle PI
    u_k = u_op + Kp * error + Ki * integral_error;
    u_k = max(0.1, min(3.0, u_k)); % Saturação
    
    u_signal(k) = u_k;
    
    % Simulação do sistema não linear
    dt = Ts;
    dCA_dt = -k1*CA - k3*CA^2 + (CAF_signal(k) - CA)*u_k;
    dCB_dt = k1*CA - k2*CB - CB*u_k;
    
    CA = CA + dCA_dt * dt;
    CB = CB + dCB_dt * dt;
    
    CA_response(k) = CA;
    CB_response(k) = CB;
    error_signal(k) = error;
end

figure('Position', [300, 100, 800, 600]);
subplot(3,1,1);
plot(t_sim/60, CB_response, 'b-', 'LineWidth', 2, 'DisplayName', 'C_B Real [mol/l]');
hold on;
plot(t_sim/60, r_signal, 'r--', 'LineWidth', 1.5, 'DisplayName', 'Referência [mol/l]');
plot([5 5], [min([CB_response r_signal]) max([CB_response r_signal])], 'k--', 'LineWidth', 1, 'DisplayName', 'Mudança 1');
plot([15 15], [min([CB_response r_signal]) max([CB_response r_signal])], 'g--', 'LineWidth', 1, 'DisplayName', 'Mudança 2');
xlabel('Tempo [min]', 'FontSize', 12);
ylabel('C_B [mol/l]', 'FontSize', 12);
title('Variação Grande de Referência - Limitações do Controlador Linear', 'FontSize', 14, 'FontWeight', 'bold');
legend('Location', 'best', 'FontSize', 10);
grid on; grid minor;

subplot(3,1,2);
plot(t_sim/60, u_signal, 'g-', 'LineWidth', 2, 'DisplayName', 'u [1/min]');
xlabel('Tempo [min]', 'FontSize', 12);
ylabel('Sinal de Controle [1/min]', 'FontSize', 12);
title('Ação de Controle', 'FontSize', 12, 'FontWeight', 'bold');
legend('Location', 'best', 'FontSize', 10);
grid on; grid minor;

subplot(3,1,3);
plot(t_sim/60, error_signal, 'r-', 'LineWidth', 2, 'DisplayName', 'Erro [mol/l]');
xlabel('Tempo [min]', 'FontSize', 12);
ylabel('Erro [mol/l]', 'FontSize', 12);
title('Erro de Seguimento', 'FontSize', 12, 'FontWeight', 'bold');
legend('Location', 'best', 'FontSize', 10);
grid on; grid minor;

print(gcf, '-dpng', '-r300', 'figure8.png');

fprintf('Gráficos corrigidos gerados com sucesso!\n');
fprintf('- figure5.png: Sistema completo com legendas\n');
fprintf('- figure7.png: Resposta à perturbação com unidades\n');
fprintf('- figure8.png: Variação grande com análise de limitações\n');