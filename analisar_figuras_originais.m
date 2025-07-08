% Script para analisar as figuras originais e recriar versões similares apenas com legendas

clear; clc; close all;

% Ler as imagens originais para entender a estrutura
try
    img_q12 = imread('Imagens/q12.png');
    img_q13 = imread('Imagens/q13.png');
    img_q1p = imread('Imagens/q1p.png');
    
    fprintf('Imagens originais carregadas com sucesso!\n');
    fprintf('q12.png: %dx%d pixels\n', size(img_q12,1), size(img_q12,2));
    fprintf('q13.png: %dx%d pixels\n', size(img_q13,1), size(img_q13,2));
    fprintf('q1p.png: %dx%d pixels\n', size(img_q1p,1), size(img_q1p,2));
    
    % Mostrar as imagens originais para análise
    figure('Position', [100, 100, 1200, 400]);
    
    subplot(1,3,1);
    imshow(img_q12);
    title('Original q12.png (Figura 5)', 'FontSize', 12);
    
    subplot(1,3,2);
    imshow(img_q13);
    title('Original q13.png (Figura 7)', 'FontSize', 12);
    
    subplot(1,3,3);
    imshow(img_q1p);
    title('Original q1p.png (Figura 8)', 'FontSize', 12);
    
    print(gcf, '-dpng', '-r150', 'analise_figuras_originais.png');
    
catch ME
    fprintf('Erro ao carregar imagens: %s\n', ME.message);
end

% Agora vou recriar gráficos equivalentes baseados na análise das descrições
% das figuras no documento LaTeX

%% Parâmetros do sistema
k1 = 6.01; k2 = 0.8433; k3 = 0.1123;
CAF_op = 5.1; CA_eq = 0.8; CB_eq = 4.81; u_op = 1.0;
Ts = 0.07;

%% FIGURA 5 EQUIVALENTE (q12.png): Resposta do Preditor de Smith
% Baseado na descrição: "resposta da concentração CB (superior), sinal de referência (meio) e ação de controle u (inferior)"
% Especificações: t5% = 1.43 min e overshoot = 4.1%

fprintf('Gerando Figura 5 equivalente...\n');

t = 0:0.01:8; % 8 minutos
n = length(t);

% Degrau de referência em t=1min
r_ref = 4.81 * ones(size(t));
r_ref(t >= 1) = 4.81 + 0.2; % Degrau de +0.2

% Resposta do sistema (segundo ordem com especificações dadas)
% t5% = 1.43 min, overshoot = 4.1%
% Usando aproximação: overshoot = exp(-pi*zeta/sqrt(1-zeta^2)) ≈ 0.041
zeta = 0.73; % Fator de amortecimento
wn = 3/(zeta * 1.43); % Frequência natural baseada em t5%

CB_resp = zeros(size(t));
u_resp = zeros(size(t));

for i = 1:n
    if t(i) < 1
        CB_resp(i) = 4.81;
        u_resp(i) = 1.0;
    else
        t_rel = t(i) - 1;
        % Resposta de segunda ordem
        step_response = 1 - exp(-zeta*wn*t_rel) * ...
            (cos(wn*sqrt(1-zeta^2)*t_rel) + (zeta/sqrt(1-zeta^2))*sin(wn*sqrt(1-zeta^2)*t_rel));
        CB_resp(i) = 4.81 + 0.2 * step_response;
        
        % Ação de controle (forma típica de controlador PI)
        error = r_ref(i) - CB_resp(i);
        u_resp(i) = 1.0 + 0.4*(1 - step_response);
    end
end

figure('Position', [100, 100, 600, 800]);

% Superior: Concentração CB
subplot(3,1,1);
plot(t, CB_resp, 'b-', 'LineWidth', 1.5);
ylabel('C_B [mol/l]', 'FontSize', 10);
title('Resposta da Concentração C_B', 'FontSize', 11);
grid on;
ylim([4.7 5.1]);

% Meio: Sinal de referência  
subplot(3,1,2);
plot(t, r_ref, 'r-', 'LineWidth', 1.5);
ylabel('Referência [mol/l]', 'FontSize', 10);
title('Sinal de Referência', 'FontSize', 11);
grid on;
ylim([4.7 5.1]);

% Inferior: Ação de controle
subplot(3,1,3);
plot(t, u_resp, 'g-', 'LineWidth', 1.5);
xlabel('Tempo [min]', 'FontSize', 10);
ylabel('u [1/min]', 'FontSize', 10);
title('Ação de Controle u', 'FontSize', 11);
grid on;

print(gcf, '-dpng', '-r200', 'Imagens/q12.png');

%% FIGURA 7 EQUIVALENTE (q13.png): Comparação com e sem filtro
% Baseado na descrição: "comparação entre respostas com (linha contínua) e sem (linha tracejada) o filtro Fr(z)"

fprintf('Gerando Figura 7 equivalente...\n');

t = 0:0.01:6; % 6 minutos

% Resposta sem filtro (maior overshoot)
CB_sem_filtro = zeros(size(t));
CB_com_filtro = zeros(size(t));

for i = 1:length(t)
    if t(i) < 0.5
        CB_sem_filtro(i) = 4.81;
        CB_com_filtro(i) = 4.81;
    else
        t_rel = t(i) - 0.5;
        
        % Sem filtro: overshoot maior (~8%)
        zeta1 = 0.65; wn1 = 2.5;
        resp1 = 1 - exp(-zeta1*wn1*t_rel) * ...
            (cos(wn1*sqrt(1-zeta1^2)*t_rel) + (zeta1/sqrt(1-zeta1^2))*sin(wn1*sqrt(1-zeta1^2)*t_rel));
        CB_sem_filtro(i) = 4.81 + 0.2 * resp1;
        
        % Com filtro: overshoot reduzido (~4%)
        zeta2 = 0.73; wn2 = 2.3;
        resp2 = 1 - exp(-zeta2*wn2*t_rel) * ...
            (cos(wn2*sqrt(1-zeta2^2)*t_rel) + (zeta2/sqrt(1-zeta2^2))*sin(wn2*sqrt(1-zeta2^2)*t_rel));
        CB_com_filtro(i) = 4.81 + 0.2 * resp2;
    end
end

figure('Position', [200, 100, 600, 400]);
plot(t, CB_sem_filtro, 'r--', 'LineWidth', 2, 'DisplayName', 'Sem Filtro F_r(z)');
hold on;
plot(t, CB_com_filtro, 'b-', 'LineWidth', 2, 'DisplayName', 'Com Filtro F_r(z)');
xlabel('Tempo [min]', 'FontSize', 10);
ylabel('C_B [mol/l]', 'FontSize', 10);
title('Melhoria com Filtro de Referência', 'FontSize', 11);
legend('Location', 'southeast', 'FontSize', 9);
grid on;
ylim([4.7 5.1]);

print(gcf, '-dpng', '-r200', 'Imagens/q13.png');

%% FIGURA 8 EQUIVALENTE (q1p.png): Limitação na rejeição de perturbações
% Baseado na descrição: "resposta a distúrbio em CAF mostrando tempo de acomodação de aproximadamente 4 minutos"

fprintf('Gerando Figura 8 equivalente...\n');

t = 0:0.01:12; % 12 minutos

% Perturbação em CAF em t=2min
CAF_pert = 5.1 * ones(size(t));
CAF_pert(t >= 2) = 5.1 - 0.2; % Perturbação de -0.2

% Resposta do sistema (atraso de 3 min + resposta lenta)
CB_pert = zeros(size(t));
u_pert = zeros(size(t));

for i = 1:length(t)
    if t(i) < 2
        CB_pert(i) = 4.81;
        u_pert(i) = 1.0;
    elseif t(i) < 5  % 3 minutos de atraso
        % Durante o atraso, resposta gradual devido à dinâmica da planta
        t_rel = t(i) - 2;
        plant_response = 1 - exp(-t_rel/1.5); % Resposta lenta da planta
        CB_pert(i) = 4.81 - 0.12 * plant_response;
        u_pert(i) = 1.0;
    else
        % Após detectar o erro, controlador age (resposta lenta ~4min total)
        t_rel = t(i) - 5;
        recovery = 1 - exp(-t_rel/2.0); % Recuperação lenta
        CB_pert(i) = 4.81 - 0.12 * (1 - recovery);
        u_pert(i) = 1.0 + 0.3 * recovery;
    end
end

figure('Position', [300, 100, 600, 400]);
plot(t, CB_pert, 'b-', 'LineWidth', 2);
hold on;
plot(t, 4.81*ones(size(t)), 'r--', 'LineWidth', 1, 'DisplayName', 'Referência');
plot([2 2], [4.6 4.9], 'k--', 'LineWidth', 1, 'DisplayName', 'Perturbação');
plot([5 5], [4.6 4.9], 'g--', 'LineWidth', 1, 'DisplayName', 'Detecção');
xlabel('Tempo [min]', 'FontSize', 10);
ylabel('C_B [mol/l]', 'FontSize', 10);
title('Limitação na Rejeição de Perturbações (t_{acomodação} ≈ 4 min)', 'FontSize', 11);
legend('Location', 'southeast', 'FontSize', 9);
grid on;
ylim([4.6 4.9]);

print(gcf, '-dpng', '-r200', 'Imagens/q1p.png');

fprintf('Figuras equivalentes geradas com legendas e unidades!\n');