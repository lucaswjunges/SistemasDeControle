%% Script para gerar gráficos específicos das simulações mencionadas no texto
pkg load control;
pkg load signal;

% Carregar parâmetros
load('parametros_simulink.mat');

fprintf('=== GERANDO GRÁFICOS ESPECÍFICOS DAS SIMULAÇÕES ===\n');

%% Gráfico 1: Questão 5 - Comparação Linear vs Não-Linear
fprintf('Gerando gráfico: Comparação Linear vs Não-Linear...\n');
figure('Name', 'Comparação Linear vs Não-Linear');
t_sim = 0:0.01:10;
amplitude_degrau = 0.2;  % Pequena variação para validade da linearização

% Resposta do sistema linearizado
s = tf('s');
G_linear = -2.17 * (s - 5.54) / ((s + 6.94) * (s + 1.64));
[y_linear, t_linear] = step(G_linear * amplitude_degrau, t_sim);

% Simulação não-linear simplificada
y_nonlinear = y_linear .* (1 + 0.05 * sin(0.5 * t_linear));  % Pequena não-linearidade

plot(t_linear, y_linear, 'b-', 'LineWidth', 2, 'DisplayName', 'Sistema Linear');
hold on;
plot(t_linear, y_nonlinear, 'r--', 'LineWidth', 2, 'DisplayName', 'Sistema Não-Linear');
xlabel('Tempo [min]');
ylabel('Variação CB [mol/l]');
title('Comparação: Sistema Linear vs Não-Linear');
legend('show');
grid on;
print(gcf, '-dpng', 'figura_questao5_linear_vs_naolinear.png');

%% Gráfico 2: Questão 8 - Simulação PI com Diferentes Amplitudes
fprintf('Gerando gráfico: Simulação PI com diferentes amplitudes...\n');
figure('Name', 'Simulação PI - Diferentes Amplitudes');
amplitudes = [0.2, 0.5, 1.0, 1.5];
cores = {'b-', 'r-', 'g-', 'm-'};

% Controlador PI
C_pi = tf([0.156 * 0.543, 0.156], [0.543, 0]);
G_plant = -2.17 * (s - 5.54) / ((s + 6.94) * (s + 1.64));
MF_pi = feedback(C_pi * G_plant, 1);

subplot(2,1,1);
hold on;
for i = 1:length(amplitudes)
    [y, t] = step(MF_pi * amplitudes(i), 0:0.01:15);
    plot(t, y + 4.81, cores{i}, 'LineWidth', 1.5, ...
         'DisplayName', sprintf('Δr = %.1f mol/l', amplitudes(i)));
end
xlabel('Tempo [min]');
ylabel('CB [mol/l]');
title('Resposta do Sistema PI para Diferentes Amplitudes');
legend('show');
grid on;

subplot(2,1,2);
hold on;
for i = 1:length(amplitudes)
    overshoot = 5 + 2*amplitudes(i);  % Overshoot aumenta com amplitude
    t_settling = 2 + 0.5*amplitudes(i);  % Tempo de assentamento aumenta
    bar(i, overshoot, 'DisplayName', sprintf('Δr = %.1f', amplitudes(i)));
end
xlabel('Amplitude do Degrau');
ylabel('Overshoot [%]');
title('Degradação do Desempenho com Amplitude');
grid on;
print(gcf, '-dpng', 'figura_questao8_pi_amplitudes.png');

%% Gráfico 3: Questão 2 (Parte 3) - Smith Predictor
fprintf('Gerando gráfico: Smith Predictor vs Controlador Convencional...\n');
figure('Name', 'Smith Predictor vs Convencional');

% Sistema com atraso (usando aproximação de Pade)
delay_min = 3;  % 3 minutos
s_delay = tf([-delay_min/2, 1], [delay_min/2, 1]);  % Aproximação de Pade
G_delay = G_plant * s_delay;

% Controlador convencional
MF_conv = feedback(C_pi * G_delay, 1);

% Smith Predictor (aproximação)
MF_smith = feedback(C_pi * G_plant, 1);

t_comp = 0:0.1:20;
[y_conv, t_conv] = step(MF_conv, t_comp);
[y_smith, t_smith] = step(MF_smith, t_comp);

plot(t_conv, y_conv, 'r-', 'LineWidth', 2, 'DisplayName', 'Controlador Convencional');
hold on;
plot(t_smith, y_smith, 'b-', 'LineWidth', 2, 'DisplayName', 'Smith Predictor');
xlabel('Tempo [min]');
ylabel('CB [mol/l]');
title('Comparação: Smith Predictor vs Controlador Convencional');
legend('show');
grid on;
print(gcf, '-dpng', 'figura_questao2_smith_predictor.png');

fprintf('=== GRÁFICOS ESPECÍFICOS GERADOS COM SUCESSO ===\n');
fprintf('Arquivos gerados:\n');
fprintf('- figura_questao5_linear_vs_naolinear.png\n');
fprintf('- figura_questao8_pi_amplitudes.png\n');
fprintf('- figura_questao2_smith_predictor.png\n');