% Script para executar todas as análises e gerar os gráficos

% Carrega o pacote de controle de sinais
pkg load control;

% Executa o script principal que define os parâmetros
disp('Executando codigo_matlab.m...');
run('codigo_matlab.m');
disp('Concluído.');

% Carrega e executa o script de análise reestruturado
disp('Executando o script de análise...');
executar_analises();
disp('Análises concluídas. Gráficos gerados.');
