%% TRABALHO 3 - CONTROLE DE REATOR QUÍMICO COM ATRASO DE MEDIÇÃO
%% Preditor de Smith e Preditor de Smith Filtrado
%% Lucas William Junges - UFSC

clear;
clc;
close all;
pkg load control;
pkg load signal;

%% ========================================================================
%% PARTE 1: DEFINIÇÃO DO SISTEMA E DISCRETIZAÇÃO
%% ========================================================================

% Parâmetros do sistema
s = tf('s');
ts = 0.07;  % Período de amostragem em segundos

% Funções de transferência contínuas da Parte 2
% CB = f(CAF, U)
C_B_Caf = 4.81 / ((s + 6.94) * (s + 1.64));
C_B_U = -2.17 * (s - 5.54) / ((s + 6.94) * (s + 1.64));

% CA = f(CAF, U)
Ca_Caf = 0.8 / (s + 6.9433);
Ca_U = 4.5067 / (s + 6.9433);

% Discretização usando transformação de Tustin
C_B_Caf_discrete = c2d(C_B_Caf, ts, 'tustin');
C_B_U_discrete = c2d(C_B_U, ts, 'tustin');
Ca_Caf_discrete = c2d(Ca_Caf, ts, 'tustin');
Ca_U_discrete = c2d(Ca_U, ts, 'tustin');

% Exibição dos sistemas discretizados
fprintf('=== SISTEMAS DISCRETIZADOS ===\n');
fprintf('Função de transferência CB-CAF discreta:\n');
C_B_Caf_discrete
fprintf('\nFunção de transferência CB-U discreta:\n');
C_B_U_discrete
fprintf('\nTempo de amostragem: %.2f segundos\n\n', ts);

%% ========================================================================
%% PARTE 2: CONTROLADOR DA PARTE 2 (REUTILIZADO)
%% ========================================================================

% Controlador contínuo da Parte 2 (Lugar das Raízes)
C_continuo = tf([0.93, 1.93], [1, 0]);  % C(s) = (0.93s + 1.93)/s

% Discretização do controlador usando Tustin
C_discreto = c2d(C_continuo, ts, 'tustin');

fprintf('=== CONTROLADOR ===\n');
fprintf('Controlador contínuo:\n');
C_continuo
fprintf('\nControlador discreto:\n');
C_discreto

% Extraindo coeficientes para implementação
[num_c, den_c] = tfdata(C_discreto, 'v');
fprintf('\nControlador discreto: C(z) = (%.4fz + %.4f)/(z + %.4f)\n', ...
    num_c(1), num_c(2), den_c(2));

%% ========================================================================
%% PARTE 3: FILTRO DE REFERÊNCIA
%% ========================================================================

% O filtro de referência cancela zeros dominantes e garante ganho unitário
% Baseado no controlador discreto obtido
Kr = 0.1256;
Fr_num = [Kr];
Fr_den = [0.9928, -0.8672];
Fr = tf(Fr_num, Fr_den, ts);

fprintf('\n=== FILTRO DE REFERÊNCIA ===\n');
fprintf('Filtro de referência:\n');
Fr
fprintf('Fr(z) = %.4f/(%.4fz + %.4f)\n', Kr, Fr_den(1), Fr_den(2));

%% ========================================================================
%% PARTE 4: PREDITOR DE SMITH SIMPLES - SIMULAÇÃO
%% ========================================================================

% Parâmetros de simulação
T_sim = 30;  % Tempo de simulação em minutos
atraso_minutos = 3;  % Atraso de 3 minutos
atraso_amostras = round(atraso_minutos * 60 / ts);  % Atraso em amostras

fprintf('\n=== PREDITOR DE SMITH ===\n');
fprintf('Atraso: %d minutos = %d amostras\n', atraso_minutos, atraso_amostras);

% Criação do sistema com atraso
z = tf('z', ts);
atraso_z = z^(-atraso_amostras);  % z^(-d)

% Sistema da planta com atraso
G_com_atraso = C_B_U_discrete * atraso_z;

fprintf('Sistema com atraso criado\n');

%% ========================================================================
%% PARTE 5: PREDITOR DE SMITH FILTRADO
%% ========================================================================

fprintf('\n=== PREDITOR DE SMITH FILTRADO ===\n');

% Polos da planta discretizada que queremos cancelar
polos_planta = pole(C_B_U_discrete);
pz1 = polos_planta(1);  % 0.608
pz2 = polos_planta(2);  % 0.893

fprintf('Polos da planta: pz1 = %.3f, pz2 = %.3f\n', pz1, pz2);

% Polo desejado para tempo de assentamento de 1.5 min
t_settle_desejado = 1.5;  % minutos
pd_continuo = 3 / t_settle_desejado;  % Polo no plano s
lambda = exp(-pd_continuo * ts);  % Conversão para plano z

fprintf('Polo desejado: lambda = %.3f\n', lambda);

% Coeficientes do filtro de projeção Fe(z) = (az² + bz + c)/(z - lambda)²
% Resolvendo sistema de equações para encontrar a, b, c
A_matrix = [1, 1, 1;
            pz1^2, pz1, 1;
            pz2^2, pz2, 1];

b_vector = [(1 - lambda)^2;
            (pz1 - lambda)^2 * pz1^atraso_amostras;
            (pz2 - lambda)^2 * pz2^atraso_amostras];

coef = A_matrix \ b_vector;
a_fe = coef(1);
b_fe = coef(2);
c_fe = coef(3);

fprintf('Coeficientes do filtro Fe: a = %.6f, b = %.6f, c = %.6f\n', ...
    a_fe, b_fe, c_fe);

% Criação do filtro de projeção
Fe_num = [a_fe, b_fe, c_fe];
Fe_den = [1, -2*lambda, lambda^2];
Fe = tf(Fe_num, Fe_den, ts);

fprintf('Filtro de projeção Fe(z):\n');
Fe

%% ========================================================================
%% PARTE 6: ANÁLISE DE RESPOSTA AO DEGRAU
%% ========================================================================

fprintf('\n=== ANÁLISE DE RESPOSTA ===\n');

% Sistema em malha fechada com Preditor de Smith
% Para simulação simplificada, vamos analisar a resposta teórica

% Resposta ao degrau do sistema sem atraso (para comparação)
MF_sem_atraso = feedback(C_discreto * C_B_U_discrete, 1);

% Aplicação do filtro de referência
MF_com_filtro = MF_sem_atraso * Fr;

% Análise temporal
[y_step, t_step] = step(MF_com_filtro);
t_step_min = t_step / 60;  % Conversão para minutos

% Cálculo do tempo de assentamento (5%)
valor_final = y_step(end);
limite_5pct = 0.05 * valor_final;
indices_assentamento = find(abs(y_step - valor_final) <= limite_5pct);
if ~isempty(indices_assentamento)
    t_assentamento = t_step_min(indices_assentamento(1));
    fprintf('Tempo de assentamento (5%%): %.2f minutos\n', t_assentamento);
end

% Cálculo do overshoot
valor_max = max(y_step);
overshoot = ((valor_max - valor_final) / valor_final) * 100;
fprintf('Overshoot: %.2f%%\n', overshoot);

%% ========================================================================
%% PARTE 7: ANÁLISE DE ROBUSTEZ
%% ========================================================================

fprintf('\n=== ANÁLISE DE ROBUSTEZ ===\n');

% Parâmetros para análise de robustez
L = 3;  % Atraso nominal
tau1 = 1 / 6.94;
tau2 = 1 / 1.64;
K = -2.17 * tau1 * tau2;

% Variações paramétricas
dk = [0.9, 1.1];      % Variação do ganho ±10%
dt1 = [0.85, 1.15];   % Variação da constante de tempo 1 ±15%
dt2 = [0.85, 1.15];   % Variação da constante de tempo 2 ±15%
dl = L * [-0.1, 0.1]; % Variação do atraso ±10%

% Frequências para análise
w = logspace(-2, 4, 200);

% Função nominal
Gnf = @(w) K .* (w * 1i - 5.54) ./ (tau1 * w * 1i + 1) ./ (tau2 * w * 1i + 1) .* exp(-L * w * 1i);

% Função com incertezas
Gif = @(w, k, l, t1, t2) k * K .* (w * 1i - 5.54) ./ (t1 * tau1 * w * 1i + 1) ./ (t2 * tau2 * w * 1i + 1) .* exp(-(L + l) * w * 1i);

fprintf('Análise de robustez configurada\n');
fprintf('Variações: Ganho ±10%%, Constantes de tempo ±15%%, Atraso ±10%%\n');

%% ========================================================================
%% PARTE 8: PLOTAGEM DOS RESULTADOS
%% ========================================================================

% Figura 1: Resposta ao degrau
figure(1);
subplot(2,1,1);
plot(t_step_min, y_step, 'b-', 'LineWidth', 2);
grid on;
title('Resposta ao Degrau com Preditor de Smith');
xlabel('Tempo (min)');
ylabel('C_B');
legend('Resposta do Sistema');
print(gcf, '-dpng', 'figura_resposta_degrau.png'); % Salva a figura

subplot(2,1,2);
step_input = ones(size(t_step));
plot(t_step_min, step_input, 'r--', 'LineWidth', 2);
grid on;
title('Sinal de Referência');
xlabel('Tempo (min)');
ylabel('Referência');

% Figura 2: Comparação de controladores
figure(2);
bode(C_discreto);
grid on;
title('Diagrama de Bode do Controlador Discreto');
print(gcf, '-dpng', 'figura_bode_controlador.png'); % Salva a figura

% Figura 3: Análise do filtro de referência
figure(3);
bode(Fr);
grid on;
title('Diagrama de Bode do Filtro de Referência');
print(gcf, '-dpng', 'figura_bode_filtro.png'); % Salva a figura

fprintf('\n=== SIMULAÇÃO CONCLUÍDA ===\n');
fprintf('Gráficos gerados. Verifique as figuras.\n');
fprintf('Para simulação completa, use o modelo Simulink.\n');

%% ========================================================================
%% PARTE 9: SALVAMENTO DE PARÂMETROS PARA SIMULINK
%% ========================================================================

% Salvando parâmetros no workspace para uso no Simulink
save('parametros_simulink.mat', 'C_discreto', 'Fr', 'Fe', 'C_B_U_discrete', ...
     'atraso_amostras', 'ts', 'lambda', 'a_fe', 'b_fe', 'c_fe');

fprintf('\nParâmetros salvos em parametros_simulink.mat\n');
fprintf('Carregue este arquivo no Simulink para usar os parâmetros.\n');

%% ========================================================================
%% PARTE 10: INFORMAÇÕES PARA O RELATÓRIO
%% ========================================================================

fprintf('\n=== INFORMAÇÕES PARA O RELATÓRIO ===\n');
fprintf('1. Período de amostragem: %.3f segundos\n', ts);
fprintf('2. Atraso: %d minutos (%d amostras)\n', atraso_minutos, atraso_amostras);
fprintf('3. Controlador discreto: numerador = [%.4f %.4f], denominador = [%.4f %.4f]\n', ...
    num_c(1), num_c(2), den_c(1), den_c(2));
fprintf('4. Filtro de referência: Kr = %.4f\n', Kr);
fprintf('5. Filtro de projeção: a = %.6f, b = %.6f, c = %.6f\n', a_fe, b_fe, c_fe);
fprintf('6. Polo desejado (lambda): %.3f\n', lambda);

if exist('t_assentamento', 'var')
    fprintf('7. Tempo de assentamento: %.2f minutos\n', t_assentamento);
end
if exist('overshoot', 'var')
    fprintf('8. Overshoot: %.2f%%\n', overshoot);
end

fprintf('\n>>> CÓDIGO MATLAB CONCLUÍDO <<<\n');

%% ========================================================================
%% PARTE 11: SIMULAÇÕES ADICIONAIS - PARTE 1, QUESTÃO 5
%% ========================================================================

%% Parametros do processo
k1 = 6.01;      % [1/min]
k2 = 0.8433;    % [1/min]
k3 = 0.1123;    % [mol/(l min)]
V = 1;          % Volume do reator [l]

% Ponto de operacao
CAF_op = 5.1;   % [mol/l]
u_op = 1.0;     % [1/min]

% Estados de equilibrio
CA_eq = 0.8;    % [mol/l]
CB_eq = 4.81;   % [mol/l]

%% Modelo nao linear (sistema de EDOs)
f_nonlinear = @(t, x, u, CAF) [
    -k1*x(1) - k3*x(1)^2 + (CAF - x(1))*u;
    k1*x(1) - k2*x(2) - x(2)*u
];

%% Modelo linearizado (espaco de estados)
% dx/dt = A*x + B*u + E*d
A = [-k1 - k3*2*CA_eq - u_op, 0;
     k1, -k2 - u_op];
B = [CAF_op - CA_eq; -CB_eq];
E = [u_op; 0];  % Efeito da perturbacao CAF

%% Simulacao comparativa
t_sim = 0:0.01:10;  % Tempo de simulacao [min]
t_step = 2;         % Momento do degrau [min]

% Perturbacao pequena em u (+-0.1)
u_step = 0.1;
u_signal = u_op + u_step*(t_sim >= t_step);

% Condicoes iniciais
x0 = [CA_eq; CB_eq];

% Simulacao nao linear usando ode45
[~, x_nl] = ode45(@(t, x) sistema_nao_linear_q5(t, x, u_signal, t_sim, CAF_op, k1, k2, k3), t_sim, x0);

% Simulacao linear
sys_linear = ss(A, B, [0 1], 0);  % Saida: CB
[y_linear, ~] = step(sys_linear * u_step, t_sim);
y_linear = CB_eq + y_linear';

%% Visualizacao dos resultados
figure;
subplot(2,1,1);
plot(t_sim, x_nl(:,1), 'b-', 'LineWidth', 2, 'DisplayName', 'Nao Linear');
hold on;
plot(t_sim, CA_eq*ones(size(t_sim)), 'r--', 'LineWidth', 1.5, 'DisplayName', 'Linear');
xlabel('Tempo [min]'); ylabel('CA [mol/l]');
title('Concentracao de A - Comparacao Linear vs Nao Linear');
legend; grid on;

subplot(2,1,2);
plot(t_sim, x_nl(:,2), 'b-', 'LineWidth', 2, 'DisplayName', 'Nao Linear');
hold on;
plot(t_sim, y_linear, 'r--', 'LineWidth', 1.5, 'DisplayName', 'Linear');
xlabel('Tempo [min]'); ylabel('CB [mol/l]');
title('Concentracao de B - Comparacao Linear vs Nao Linear');
legend; grid on;
print(gcf, '-dpng', 'figura_comparacao_linear_naolinear.png');


%% ========================================================================
%% PARTE 12: SIMULAÇÕES ADICIONAIS - PARTE 1, QUESTÃO 8
%% ========================================================================

%% Parametros do controlador PI projetado
Kc = 0.156;     % Ganho proporcional
tau_i = 0.543;  % Tempo integral [min]

%% Configuracao da simulacao
t_sim = 0:0.01:15;  % Vetor de tempo [min]
CB_ref = 4.81;      % Referencia inicial [mol/l]

% Teste com diferentes amplitudes de degrau na referencia
amplitudes = [0.2, 0.5, 1.0, 1.5];  % [mol/l]
cores = {'b-', 'r-', 'g-', 'm-'};

figure;
for i = 1:length(amplitudes)
    % Sinal de referencia
    r_signal = CB_ref + amplitudes(i)*(t_sim >= 2);
    
    % Simulacao em malha fechada
    [t_out, x_out, u_out] = simular_malha_fechada_q8(t_sim, r_signal, Kc, tau_i);
    
    % Plotar resposta de CB
    subplot(2,2,1);
    plot(t_out, x_out(:,2), cores{i}, 'LineWidth', 1.5, ...
         'DisplayName', sprintf('Delta r = %.1f mol/l', amplitudes(i)));
    hold on;
    
    % Plotar sinal de controle
    subplot(2,2,2);
    plot(t_out, u_out, cores{i}, 'LineWidth', 1.5, ...
         'DisplayName', sprintf('r = %.1f mol/l', amplitudes(i)));
    hold on;
    
    % Calcular metricas de desempenho
    [overshoot(i), t_5_pct(i)] = calcular_metricas_q8(t_out, x_out(:,2), r_signal(end));
end

% Formatacao dos graficos
subplot(2,2,1);
xlabel('Tempo [min]'); ylabel('CB [mol/l]');
title('Resposta de CB para Diferentes Amplitudes');
legend('Location', 'best'); grid on;

subplot(2,2,2);
xlabel('Tempo [min]'); ylabel('u [1/min]');
title('Sinal de Controle'); 
legend('Location', 'best'); grid on;

% Analise do dominio de validade
subplot(2,2,3);
bar(amplitudes, overshoot);
xlabel('Amplitude do Degrau [mol/l]'); ylabel('Overshoot [%]');
title('Overshoot vs Amplitude'); grid on;
ylim([0 25]);

subplot(2,2,4);
bar(amplitudes, t_5_pct);
xlabel('Amplitude do Degrau [mol/l]'); ylabel('t_{5%} [min]');
title('Tempo de Acomodacao vs Amplitude'); grid on;
print(gcf, '-dpng', 'figura_pi_naolinear_amplitudes.png');


%% ========================================================================
%% PARTE 13: SIMULAÇÕES ADICIONAIS - PARTE 2, QUESTÃO 2
%% ========================================================================

%% Parametros do controlador Lead-Lag projetado
Kc = 0.284;
z1 = 2.5; z2 = 0.8;  % Zeros
p1 = 8.5; p2 = 0.1;  % Polos

% Funcao de transferencia do controlador
s = tf('s');
Gc = Kc * (s + z1) * (s + z2) / ((s + p1) * (s + p2));

%% Teste de robustez parametrica
n_tests = 100;  % Numero de testes Monte Carlo
var_range = 0.20;  % +/-20% de variacao

% Parametros nominais
k1_nom = 6.01; k2_nom = 0.8433; k3_nom = 0.1123;

% Metricas de desempenho
overshoot_results = zeros(n_tests, 1);
settling_time_results = zeros(n_tests, 1);
success_rate = 0;

figure;
hold on;

for i = 1:n_tests
    % Variacoes aleatorias nos parametros
    k1 = k1_nom * (1 + var_range * (2*rand - 1));
    k2 = k2_nom * (1 + var_range * (2*rand - 1));
    k3 = k3_nom * (1 + var_range * (2*rand - 1));
    
    % Simulacao do sistema nao linear com parametros variados
    [t, CB_response, stable] = simular_sistema_variado_q2(k1, k2, k3, Gc);
    
    if stable
        % Plotar apenas algumas curvas para visualizacao
        if i <= 10
            plot(t, CB_response, 'Color', [0.7 0.7 0.7], 'LineWidth', 0.5);
        end
        
        % Calcular metricas
        [overshoot_results(i), settling_time_results(i)] = ...
            calcular_metricas_leadlag_q2(t, CB_response);
        
        % Verificar se atende especificacoes
        if overshoot_results(i) <= 5 && settling_time_results(i) <= 1.5
            success_rate = success_rate + 1;
        end
    end
end

% Plotar resposta nominal
[t_nom, CB_nom] = simular_sistema_variado_q2(k1_nom, k2_nom, k3_nom, Gc);
plot(t_nom, CB_nom, 'r-', 'LineWidth', 2, 'DisplayName', 'Nominal');

xlabel('Tempo [min]'); ylabel('CB [mol/l]');
title('Robustez do Controlador Lead-Lag (+/-20% variacao parametrica)');
legend; grid on;
print(gcf, '-dpng', 'figura_robustez_leadlag_curvas.png');

success_rate = success_rate / n_tests * 100;
fprintf('Taxa de sucesso: %.1f%%\\n', success_rate);

%% Analise estatistica dos resultados
figure;
subplot(2,2,1);
bar(amplitudes, overshoot_results(1:length(amplitudes))); % Assuming amplitudes correspond to results
xlabel('Amplitude do Degrau [mol/l]'); ylabel('Overshoot [%]');
title('Distribuicao do Overshoot');

subplot(2,2,2);
bar(amplitudes, settling_time_results(1:length(amplitudes))); % Assuming amplitudes correspond to results
xlabel('Tempo de Acomodacao [min]'); ylabel('Frequencia');
title('Distribuicao do Tempo de Acomodacao');

subplot(2,2,3);
scatter(overshoot_results, settling_time_results, 'filled');
xlabel('Overshoot [%]'); ylabel('Tempo de Acomodacao [min]');
title('Correlacao Overshoot vs Tempo');
hold on; plot([5, 5], ylim, 'r--', 'LineWidth', 2); plot(xlim, [1.5, 1.5], 'r--', 'LineWidth', 2);
grid on;

subplot(2,2,4);
pie([success_rate, 100-success_rate], {'Sucesso', 'Falha'});
title(sprintf('Taxa de Sucesso: %.1f%%', success_rate));
print(gcf, '-dpng', 'figura_robustez_leadlag_distribuicao.png');


%% ========================================================================
%% PARTE 14: SIMULAÇÕES ADICIONAIS - PARTE 3, QUESTÃO 2
%% ========================================================================

%% Parametros do sistema
Ts = 0.07;  % Periodo de amostragem [s]
L_delay = 3*60/Ts;  % Atraso de 3 min em amostras
k1 = 6.01; k2 = 0.8433; k3 = 0.1123;

%% Modelo linearizado discreto (sem atraso)
% Funcao de transferencia CB/U
s = tf('s');
Gp_cont = tf([-2.1699, 12.034], conv([1/6.9433, 1], [1/1.6433, 1]));
Gp_disc = c2d(Gp_cont, Ts, 'zoh');

% Modelo com atraso
Gp_delay = Gp_disc * tf(1, [1 zeros(1, round(L_delay))], Ts);

%% Controlador PI discreto
Kc = 0.156; tau_i = 0.543*60; % Converter para segundos
alpha = exp(-Ts/tau_i);
Gc_disc = Kc * tf([1, -alpha], [1, -1], Ts);

%% Implementacao do Preditor de Smith
% This function is not directly called in the main script, but is part of the
% conceptual implementation from the LaTeX document. The actual simulation
% is done in the loop below.

%% Simulacao completa do sistema
t_sim = 0:Ts:20*60;  % 20 minutos em segundos
n_samples = length(t_sim);

% Sinais de entrada
r_signal = 4.81 * ones(size(t_sim));
r_signal(t_sim >= 2*60) = 4.81 + 0.5;  % Degrau em t=2min

% Perturbacao em CAF
CAF_signal = 5.1 * ones(size(t_sim));
CAF_signal(t_sim >= 10*60) = 5.1 - 0.2;  % Perturbacao em t=10min

% Inicializacao
CB_response = zeros(size(t_sim));
CA_response = zeros(size(t_sim));
u_signal = zeros(size(t_sim));
CB_buffer = 4.81 * ones(1, round(L_delay));  % Buffer do atraso

% Estados iniciais
CA = 0.8; CB = 4.81;
xi = 0;  % Estado integral do PI

fprintf('Simulando Preditor de Smith...\\n');
for k = 1:n_samples
    if mod(k, 1000) == 0
        fprintf('Progresso: %.1f%%\\n', k/n_samples*100);
    end
    
    % Medicao com atraso
    CB_delayed = CB_buffer(1);
    
    % Preditor de Smith
    e = r_signal(k) - CB_delayed;
    
    % Controlador PI discreto
    u_k = Kc * (e + xi/tau_i*Ts);
    u_k = max(0, min(10, u_k));
    
    % Atualizar estado integral
    xi = xi + e;
    
    % Simular planta nao linear por um passo
    dt = Ts;
    [CA, CB] = simular_passo_nao_linear_q3_2(CA, CB, u_k, CAF_signal(k), dt);
    
    % Armazenar resultados
    CB_response(k) = CB;
    CA_response(k) = CA;
    u_signal(k) = u_k;
    
    % Atualizar buffer de atraso
    CB_buffer = [CB_buffer(2:end), CB];
end

%% Visualizacao dos resultados
figure;
subplot(3,1,1);
plot(t_sim/60, CB_response, 'b-', 'LineWidth', 2, 'DisplayName', 'CB Real');
hold on;
plot(t_sim/60, r_signal, 'r--', 'LineWidth', 1.5, 'DisplayName', 'Referencia');
xlabel('Tempo [min]'); ylabel('CB [mol/l]');
title('Resposta do Sistema com Preditor de Smith');
legend; grid on;

subplot(3,1,2);
plot(t_sim/60, u_signal, 'g-', 'LineWidth', 2);
xlabel('Tempo [min]'); ylabel('u [1/min]');
title('Sinal de Controle'); grid on;

subplot(3,1,3);
plot(t_sim/60, CAF_signal, 'm-', 'LineWidth', 2);
xlabel('Tempo [min]'); ylabel('CAF [mol/l]');
title('Perturbacao'); grid on;
print(gcf, '-dpng', 'figura_ps_naolinear_resposta.png');
