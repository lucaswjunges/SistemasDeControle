function executar_analises()
    pkg load control; % Load the control package for Octave
    % ========================================================================
    % FUNÇÃO PRINCIPAL - EXECUTA TODAS AS ANÁLISES
    % ========================================================================
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

% --- SUB-FUNÇÕES DE ANÁLISE ---

function analise_resposta_temporal()
    load('parametros_simulink.mat');
    MF = feedback(C_discreto * C_B_U_discrete, 1);
    MF_filtrado = MF * Fr;
    [y, t] = step(MF_filtrado);
    t_min = t / 60;
    fprintf('=== ANÁLISE TEMPORAL ===\n');
    figure('Name', 'Análise Temporal');
    plot(t_min, y, 'b-', 'LineWidth', 2);
    grid on;
    title('Resposta ao Degrau - Sistema com Filtro');
    xlabel('Tempo (min)');
    ylabel('Amplitude');
    hold on;
    plot([0, max(t_min)], [1, 1], 'r--', 'LineWidth', 1);
    legend('Resposta', 'Referência', 'Location', 'northeast');
    print(gcf, '-dpng', 'figura_analise_temporal.png');
end

function comparacao_controladores()
    s = tf('s');
    ts = 0.07;
    G = -2.17 * (s - 5.54) / ((s + 6.94) * (s + 1.64));
    G_d = c2d(G, ts, 'tustin');
    C1 = tf([1, 1], [1, 0]);
    C1_d = c2d(C1, ts, 'tustin');
    C2 = tf([0.93, 1.93], [1, 0]);
    C2_d = c2d(C2, ts, 'tustin');
    MF1 = feedback(C1_d * G_d, 1);
    MF2 = feedback(C2_d * G_d, 1);
    figure('Name', 'Comparação de Controladores');
    step(MF1, MF2);
    legend('PI Simples', 'LR (Trabalho)', 'Location', 'northeast');
    title('Comparação de Resposta ao Degrau');
    grid on;
    print(gcf, '-dpng', 'figura_comparacao_step.png');
    figure('Name', 'Bode - Comparação');
    bode(MF1, MF2);
    legend('PI Simples', 'LR (Trabalho)', 'Location', 'northeast');
    grid on;
    print(gcf, '-dpng', 'figura_comparacao_bode.png');
end

function analise_estabilidade()
    load('parametros_simulink.mat');
    MA = C_discreto * C_B_U_discrete;
    [Gm, Pm, Wgm, Wpm] = margin(MA);
    fprintf('=== ANÁLISE DE ESTABILIDADE ===\n');
    fprintf('Margem de Ganho: %.2f dB\n', 20*log10(Gm));
    fprintf('Margem de Fase: %.2f graus\n', Pm);
    figure('Name', 'Margens de Estabilidade');
    margin(MA);
    grid on;
    title('Diagrama de Bode com Margens de Estabilidade');
    print(gcf, '-dpng', 'figura_margens_estabilidade.png');
    figure('Name', 'Lugar das Raízes');
    rlocus(MA);
    grid on;
    title('Lugar das Raízes do Sistema');
    print(gcf, '-dpng', 'figura_lugar_raizes.png');
end

function simulacao_com_ruido()
    T_sim = 30;
    ts = 0.07;
    t = 0:ts:(T_sim*60);
    r = 0.5 * (t >= 60);
    ruido = 0.01 * randn(size(t));
    perturbacao = -0.2 * (t >= 1200);
    fprintf('=== SIMULAÇÃO COM RUÍDO ===\n');
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
    print(gcf, '-dpng', 'figura_sinais_teste.png');
end

function analise_robustez_detalhada()
    fprintf('=== ANÁLISE DE ROBUSTEZ DETALHADA ===\n');
    variacoes = [-20, -10, 0, 10, 20];
    ts = 0.07;
    s = tf('s');
    figure('Name', 'Análise de Robustez');
    C_nom_d = c2d(tf([0.93, 1.93], [1, 0]), ts, 'tustin');
    G_base = -2.17 * (s - 5.54) / ((s + 6.94) * (s + 1.64));
    G_base_d = c2d(G_base, ts, 'tustin');
    
    subplot(2,1,1);
    hold on;
    for i = 1:length(variacoes)
        var_pct = variacoes(i);
        % Simulação simplificada da variação
        MF_var = feedback(C_nom_d * G_base_d * (1 + var_pct/100), 1);
        [y, t] = step(MF_var);
        plot(t/60, y, 'DisplayName', sprintf('Var: %+d%%', var_pct));
    end
    title('Robustez: Resposta com Variações Paramétricas');
    xlabel('Tempo (min)');
    ylabel('Amplitude');
    legend('show');
    grid on;
    
    subplot(2,1,2);
    hold on;
    for i = 1:length(variacoes)
        var_pct = variacoes(i);
        MA_var = C_nom_d * G_base_d * (1 + var_pct/100);
        [~, Pm] = margin(MA_var);
        plot(var_pct, Pm, 'ro', 'MarkerSize', 8);
    end
    title('Margem de Fase vs Variação Paramétrica');
    xlabel('Variação (%)');
    ylabel('Margem de Fase (graus)');
    grid on;
    plot([-25, 25], [45, 45], 'r--', 'LineWidth', 2);
    text(0, 47, 'Limite Seguro (45°)', 'HorizontalAlignment', 'center');
    print(gcf, '-dpng', 'figura_analise_robustez.png');
end

function gerar_relatorio()
    fid = fopen('relatorio_automatico.txt', 'w');
    fprintf(fid, 'RELATÓRIO AUTOMÁTICO - TRABALHO 3\n');
    fprintf(fid, 'Data: %s\n', datestr(now));
    fprintf(fid, '=====================================\n\n');
    fprintf(fid, 'Conclusões: Análises executadas e gráficos gerados.\n');
    fclose(fid);
    fprintf('Relatório salvo em: relatorio_automatico.txt\n');
end
