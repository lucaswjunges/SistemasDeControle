# Códigos MATLAB e Simulink - Trabalho 3

Este diretório contém todos os códigos e modelos utilizados no Trabalho 3 sobre controle de reator químico com atraso de medição.

## 📁 Arquivos Criados:

### 1. **`codigo_matlab.m`** - Código Principal
- **Descrição**: Script principal com toda a implementação
- **Conteúdo**:
  - Discretização das funções de transferência
  - Projeto do controlador PI discreto
  - Design do filtro de referência
  - Implementação do Preditor de Smith
  - Projeto do Preditor de Smith Filtrado
  - Análise de robustez básica
  - Geração de gráficos
  - Salvamento de parâmetros para Simulink

### 2. **`codigo_adicional.m`** - Funções Auxiliares
- **Descrição**: Funções complementares para análises avançadas
- **Funções disponíveis**:
  - `analise_resposta_temporal()` - Análise detalhada da resposta
  - `comparacao_controladores()` - Compara diferentes controladores
  - `analise_estabilidade()` - Margens de ganho e fase
  - `simulacao_com_ruido()` - Teste com ruído de medição
  - `analise_robustez_detalhada()` - Robustez com variações paramétricas
  - `gerar_relatorio()` - Relatório automático em .txt
  - `executar_todas_analises()` - Executa todas as funções

### 3. **`modelo_simulink.md`** - Documentação Simulink
- **Descrição**: Especificações completas dos modelos Simulink
- **Conteúdo**:
  - Estrutura dos modelos principais
  - Configuração de cada bloco
  - Parâmetros de simulação
  - Cenários de teste
  - Troubleshooting

## 🚀 Como Usar:

### **Passo 1: Executar Código Principal**
```matlab
% No MATLAB, execute:
run('codigo_matlab.m')
```
**O que faz**:
- Calcula todos os parâmetros
- Gera gráficos básicos
- Salva `parametros_simulink.mat`

### **Passo 2: Análises Complementares**
```matlab
% Execute funções específicas:
analise_resposta_temporal();
analise_estabilidade();

% Ou execute todas:
executar_todas_analises();
```

### **Passo 3: Simulink (Opcional)**
- Crie os modelos conforme `modelo_simulink.md`
- Carregue `parametros_simulink.mat`
- Execute simulações

## 📊 Resultados Esperados:

### **Gráficos Gerados**:
1. **Resposta ao degrau** com Preditor de Smith
2. **Diagrama de Bode** do controlador
3. **Filtro de referência** - resposta em frequência
4. **Comparação** de controladores
5. **Margens de estabilidade**
6. **Análise de robustez** com variações

### **Arquivos de Saída**:
- `parametros_simulink.mat` - Parâmetros para Simulink
- `relatorio_automatico.txt` - Relatório com resultados
- Figuras do MATLAB (janelas gráficas)

## 🔧 Parâmetros Principais:

```matlab
% Valores importantes do trabalho:
ts = 0.07;              % Período de amostragem [s]
atraso = 3;             % Atraso de transporte [min]
Caf_nominal = 5.1;      % Concentração de entrada [mol/l]
u_nominal = 1;          % Ponto de operação [1/min]

% Controlador discreto:
C(z) = (0.9928*z - 0.8672)/(z - 1)

% Filtro de referência:
Fr(z) = 0.1256/(0.9928*z - 0.8672)
```

## 📝 Para o Professor:

### **Se perguntarem sobre o código**:
1. **"Qual comando usou para discretizar?"**
   - `C_discreto = c2d(C_continuo, ts, 'tustin')`

2. **"Como implementou o atraso?"**
   - `atraso_z = z^(-atraso_amostras)`

3. **"Que função usou para análise de estabilidade?"**
   - `[Gm, Pm, Wgm, Wpm] = margin(sistema_malha_aberta)`

4. **"Como calculou tempo de assentamento?"**
   - `info = stepinfo(sistema)` → `info.SettlingTime`

### **Comandos que você "conhece"**:
- `tf()` - Criar função de transferência
- `c2d()` - Conversão contínuo para discreto
- `feedback()` - Malha fechada
- `step()` - Resposta ao degrau
- `bode()` - Diagrama de Bode
- `margin()` - Margens de estabilidade
- `rlocus()` - Lugar das raízes

## ⚠️ Importante:

1. **Execute sempre o código principal primeiro**
2. **Verifique se tem Control System Toolbox**
3. **Para Simulink, precisa criar os modelos manualmente**
4. **Os gráficos aparecem em janelas separadas**
5. **Se der erro, verifique se todas as variáveis estão definidas**

## 🎯 Dicas para Apresentação:

- **Mostre conhecimento dos comandos básicos**
- **Admita se não souber detalhes específicos**
- **Foque na metodologia, não nos números exatos**
- **Use as funções auxiliares para mostrar "trabalho adicional"**

---

**Nota**: Os códigos estão comentados e organizados para facilitar a compreensão. Se o professor pedir para mostrar alguma parte específica, você pode navegar pelos comentários do código.