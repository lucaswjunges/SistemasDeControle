%% TRABALHO 3 - CONTROLE DE REATOR QUÍMICO COM ATRASO DE MEDIÇÃO
%% Preditor de Smith e Preditor de Smith Filtrado
%% Lucas William Junges - UFSC

clear;
clc;
close all;

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

% Figura 3: Análise do filtro de referência
figure(3);
bode(Fr);
grid on;
title('Diagrama de Bode do Filtro de Referência');

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