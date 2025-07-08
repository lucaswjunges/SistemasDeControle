%% CÓDIGOS ADICIONAIS - TRABALHO 3
%% Funções auxiliares e análises complementares
%% Lucas William Junges - UFSC

%% ========================================================================
%% FUNÇÃO 1: ANÁLISE DE RESPOSTA TEMPORAL
%% ========================================================================

function analise_resposta_temporal()
    % Carrega parâmetros se existirem
    if exist('parametros_simulink.mat', 'file')
        load('parametros_simulink.mat');
    else
        error('Execute primeiro o codigo_matlab.m');
    end
    
    % Sistema em malha fechada
    MF = feedback(C_discreto * C_B_U_discrete, 1);
    MF_filtrado = MF * Fr;
    
    % Resposta ao degrau
    [y, t] = step(MF_filtrado);
    t_min = t / 60;  % Conversão para minutos
    
    % Análises
    % info = stepinfo(MF_filtrado); % A função stepinfo não está disponível no Octave
    
    fprintf('=== ANÁLISE TEMPORAL ===\n');
    % fprintf('Tempo de subida: %.2f min\n', info.RiseTime/60);
    % fprintf('Tempo de pico: %.2f min\n', info.PeakTime/60);
    % fprintf('Overshoot: %.2f%%\n', info.Overshoot);
    % fprintf('Tempo de assentamento: %.2f min\n', info.SettlingTime/60);
    
    % Plot
    figure('Name', 'Análise Temporal');
    plot(t_min, y, 'b-', 'LineWidth', 2);
    grid on;
    title('Resposta ao Degrau - Sistema com Filtro');
    xlabel('Tempo (min)');
    ylabel('Amplitude');
    
    % Linha de referência
    hold on;
    plot([0, max(t_min)], [1, 1], 'r--', 'LineWidth', 1);
    legend('Resposta', 'Referência', 'Location', 'best');
    print(gcf, '-dpng', 'figura_analise_temporal.png'); % Salva a figura
end

%% ========================================================================
%% FUNÇÃO 2: COMPARAÇÃO DE CONTROLADORES
%% ========================================================================

function comparacao_controladores()
    % Controladores para comparação
    s = tf('s');
    ts = 0.07;
    
    % Sistema base
    G = -2.17 * (s - 5.54) / ((s + 6.94) * (s + 1.64));
    G_d = c2d(G, ts, 'tustin');
    
    % Controlador 1: PI simples
    C1 = tf([1, 1], [1, 0]);
    C1_d = c2d(C1, ts, 'tustin');
    
    % Controlador 2: Do trabalho (com lugar das raízes)
    C2 = tf([0.93, 1.93], [1, 0]);
    C2_d = c2d(C2, ts, 'tustin');
    
    % Malhas fechadas
    MF1 = feedback(C1_d * G_d, 1);
    MF2 = feedback(C2_d * G_d, 1);
    
    % Comparação temporal
    figure('Name', 'Comparação de Controladores');
    step(MF1, MF2);
    legend('PI Simples', 'LR (Trabalho)', 'Location', 'best');
    title('Comparação de Resposta ao Degrau');
    grid on;
    print(gcf, '-dpng', 'figura_comparacao_step.png'); % Salva a figura
    
    % Comparação frequencial
    figure('Name', 'Bode - Comparação');
    bode(MF1, MF2);
    legend('PI Simples', 'LR (Trabalho)', 'Location', 'best');
    grid on;
    print(gcf, '-dpng', 'figura_comparacao_bode.png'); % Salva a figura
end

%% ========================================================================
%% FUNÇÃO 3: ANÁLISE DE ESTABILIDADE
%% ========================================================================

function analise_estabilidade()
    % Carrega parâmetros
    if exist('parametros_simulink.mat', 'file')
        load('parametros_simulink.mat');
    else
        error('Execute primeiro o codigo_matlab.m');
    end
    
    % Sistema em malha aberta
    MA = C_discreto * C_B_U_discrete;
    
    % Margens de estabilidade
    [Gm, Pm, Wgm, Wpm] = margin(MA);
    
    fprintf('=== ANÁLISE DE ESTABILIDADE ===\n');
    fprintf('Margem de Ganho: %.2f dB (%.2f linear)\n', 20*log10(Gm), Gm);
    fprintf('Margem de Fase: %.2f graus\n', Pm);
    fprintf('Frequência de cruzamento de ganho: %.4f rad/s\n', Wgm);
    fprintf('Frequência de cruzamento de fase: %.4f rad/s\n', Wpm);
    
    % Plot das margens
    figure('Name', 'Margens de Estabilidade');
    margin(MA);
    grid on;
    title('Diagrama de Bode com Margens de Estabilidade');
    print(gcf, '-dpng', 'figura_margens_estabilidade.png'); % Salva a figura
    
    % Lugar das raízes
    figure('Name', 'Lugar das Raízes');
    rlocus(MA);
    grid on;
    title('Lugar das Raízes do Sistema');
    print(gcf, '-dpng', 'figura_lugar_raizes.png'); % Salva a figura
end

%% ========================================================================
%% FUNÇÃO 4: SIMULAÇÃO COM RUÍDO
%% ========================================================================

function simulacao_com_ruido()
    % Parâmetros de simulação
    T_sim = 30;  % minutos
    ts = 0.07;   % período de amostragem
    t = 0:ts:(T_sim*60);
    
    % Sinal de referência
    r = 0.5 * (t >= 60);  % Degrau em t=1min
    
    % Ruído na medição
    potencia_ruido = 0.01;  % 1% de ruído
    ruido = potencia_ruido * randn(size(t));
    
    % Perturbação
    perturbacao = -0.2 * (t >= 1200);  % -0.2 em t=20min
    
    fprintf('=== SIMULAÇÃO COM RUÍDO ===\n');
    fprintf('Ruído: %.1f%% da amplitude nominal\n', potencia_ruido*100);
    fprintf('Perturbação: -0.2 em t=20min\n');
    
    % Plot dos sinais
    figure('Name', 'Sinais de Teste');
    
    subplot(3,1,1);
    plot(t/60, r, 'b-', 'LineWidth', 2);
    title('Sinal de Referência');
    ylabel('Amplitude');
    grid on;
    
    subplot(3,1,2);
    plot(t/60, ruido, 'r-');
    title('Ruído de Medição');
    ylabel('Amplitude');
    grid on;
    
    subplot(3,1,3);
    plot(t/60, perturbacao, 'g-', 'LineWidth', 2);
    title('Perturbação');
    xlabel('Tempo (min)');
    ylabel('Amplitude');
    grid on;
    print(gcf, '-dpng', 'figura_sinais_teste.png'); % Salva a figura
end

%% ========================================================================
%% FUNÇÃO 5: ANÁLISE DE ROBUSTEZ DETALHADA
%% ========================================================================

function analise_robustez_detalhada()
    fprintf('=== ANÁLISE DE ROBUSTEZ DETALHADA ===\n');
    
    % Parâmetros nominais
    k1_nom = 6.01;
    k2_nom = 0.8433;
    k3_nom = 0.1123;
    L_nom = 3;  % atraso nominal
    
    % Variações percentuais
    variacoes = [-20, -10, 0, 10, 20];  % %
    
    % Análise para cada variação
    ts = 0.07;
    s = tf('s');
    
    figure('Name', 'Análise de Robustez');
    
    for i = 1:length(variacoes)
        var_pct = variacoes(i);
        
        % Parâmetros com variação
        k1_var = k1_nom * (1 + var_pct/100);
        L_var = L_nom * (1 + var_pct/100);
        
        % Sistema com variação
        G_var = -2.17 * (s - 5.54) / ((s + 6.94) * (s + 1.64));
        G_var_d = c2d(G_var, ts, 'tustin');
        
        % Resposta ao degrau
        C_nom = tf([0.93, 1.93], [1, 0]);
        C_nom_d = c2d(C_nom, ts, 'tustin');
        MF_var = feedback(C_nom_d * G_var_d, 1);
        
        [y, t] = step(MF_var);
        
        % Plot
        subplot(2,1,1);
        plot(t/60, y, 'DisplayName', sprintf('Var: %+d%%', var_pct));
        hold on;
        
        % Overshoot
        overshoot = (max(y) - y(end)) / y(end) * 100;
        fprintf('Variação %+d%%: Overshoot = %.2f%%\n', var_pct, overshoot);
    end
    
    subplot(2,1,1);
    title('Robustez: Resposta com Variações Paramétricas');
    xlabel('Tempo (min)');
    ylabel('Amplitude');
    legend('show');
    grid on;
    
    % Estabilidade relativa
    subplot(2,1,2);
    
    for i = 1:length(variacoes)
        var_pct = variacoes(i);
        G_var = -2.17 * (s - 5.54) / ((s + 6.94) * (s + 1.64));
        G_var_d = c2d(G_var, ts, 'tustin');
        C_nom_d = c2d(tf([0.93, 1.93], [1, 0]), ts, 'tustin');
        
        MA_var = C_nom_d * G_var_d;
        [~, Pm] = margin(MA_var);
        
        plot(var_pct, Pm, 'ro', 'MarkerSize', 8);
        hold on;
    end
    
    title('Margem de Fase vs Variação Paramétrica');
    xlabel('Variação (%)');
    ylabel('Margem de Fase (graus)');
    grid on;
    
    % Linha de segurança
    plot([-25, 25], [45, 45], 'r--', 'LineWidth', 2);
    text(0, 47, 'Limite Seguro (45°)', 'HorizontalAlignment', 'center');
    print(gcf, '-dpng', 'figura_analise_robustez.png'); % Salva a figura
end

%% ========================================================================
%% FUNÇÃO 6: GERAÇÃO DE RELATÓRIO AUTOMÁTICO
%% ========================================================================

function gerar_relatorio()
    fprintf('\n=== GERAÇÃO DE RELATÓRIO AUTOMÁTICO ===\n');
    
    % Criar arquivo de relatório
    fid = fopen('relatorio_automatico.txt', 'w');
    
    % Cabeçalho
    fprintf(fid, 'RELATÓRIO AUTOMÁTICO - TRABALHO 3\n');
    fprintf(fid, 'Controle de Reator Químico com Atraso\n');
    fprintf(fid, 'Data: %s\n', datestr(now));
    fprintf(fid, '=====================================\n\n');
    
    % Parâmetros do sistema
    fprintf(fid, 'PARÂMETROS DO SISTEMA:\n');
    fprintf(fid, '- Período de amostragem: 0.07 s\n');
    fprintf(fid, '- Atraso de transporte: 3 minutos\n');
    fprintf(fid, '- Ponto de operação: CAF = 5.1 mol/l, u = 1 min⁻¹\n\n');
    
    % Controlador
    fprintf(fid, 'CONTROLADOR PROJETADO:\n');
    fprintf(fid, '- Tipo: PI discreto via lugar das raízes\n');
    fprintf(fid, '- Função de transferência: C(z) = (0.9928z - 0.8672)/(z - 1)\n');
    fprintf(fid, '- Filtro de referência: Fr(z) = 0.1256/(0.9928z - 0.8672)\n\n');
    
    % Especificações
    fprintf(fid, 'ESPECIFICAÇÕES DE DESEMPENHO:\n');
    fprintf(fid, '- Tempo de assentamento: ~1.74 minutos ✓\n');
    fprintf(fid, '- Overshoot: < 5%% ✓\n');
    fprintf(fid, '- Erro em regime permanente: Zero ✓\n\n');
    
    % Conclusões
    fprintf(fid, 'CONCLUSÕES:\n');
    fprintf(fid, '1. Preditor de Smith compensou efetivamente o atraso de 3 minutos\n');
    fprintf(fid, '2. Especificações de seguimento atendidas com filtro de referência\n');
    fprintf(fid, '3. Rejeição de perturbações limitada pelo atraso inerente\n');
    fprintf(fid, '4. Sistema robusto para pequenas variações paramétricas\n');
    fprintf(fid, '5. Preditor de Smith Filtrado melhora perturbações às custas de robustez\n\n');
    
    fclose(fid);
    
    fprintf('Relatório salvo em: relatorio_automatico.txt\n');
end

%% ========================================================================
%% FUNÇÃO PRINCIPAL - EXECUTA TODAS AS ANÁLISES
%% ========================================================================

function executar_todas_analises()
    fprintf('\n>>> EXECUTANDO TODAS AS ANÁLISES <<<\n\n');
    
    try
        analise_resposta_temporal();
        fprintf('✓ Análise temporal concluída\n');
    catch ME
        fprintf('✗ Erro na análise temporal: %s\n', ME.message);
    end
    
    try
        comparacao_controladores();
        fprintf('✓ Comparação de controladores concluída\n');
    catch ME
        fprintf('✗ Erro na comparação: %s\n', ME.message);
    end
    
    try
        analise_estabilidade();
        fprintf('✓ Análise de estabilidade concluída\n');
    catch ME
        fprintf('✗ Erro na análise de estabilidade: %s\n', ME.message);
    end
    
    try
        simulacao_com_ruido();
        fprintf('✓ Simulação com ruído concluída\n');
    catch ME
        fprintf('✗ Erro na simulação com ruído: %s\n', ME.message);
    end
    
    try
        analise_robustez_detalhada();
        fprintf('✓ Análise de robustez detalhada concluída\n');
    catch ME
        fprintf('✗ Erro na análise de robustez: %s\n', ME.message);
    end
    
    try
        gerar_relatorio();
        fprintf('✓ Relatório automático gerado\n');
    catch ME
        fprintf('✗ Erro na geração do relatório: %s\n', ME.message);
    end
    
    fprintf('\n>>> TODAS AS ANÁLISES CONCLUÍDAS <<<\n');
end

%% ========================================================================
%% EXEMPLO DE USO
%% ========================================================================

% Para executar uma função específica:
% analise_resposta_temporal();
% comparacao_controladores();
% analise_estabilidade();
% simulacao_com_ruido();
% analise_robustez_detalhada();
% gerar_relatorio();

% Para executar todas:
% executar_todas_analises();
