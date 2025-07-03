# Modelos Simulink - Trabalho 3

## Estrutura dos Modelos Simulink Utilizados

### 1. **Modelo Principal: `preditor_smith_main.slx`**

#### Blocos necessários:
- **Reference Signal**: Step ou Signal Generator para referência
- **Smith Predictor Structure**: Subsystem principal
- **Plant with Delay**: Modelo não-linear do reator com atraso
- **Scopes**: Para visualização dos resultados

#### Configuração dos blocos:

**1.1. Reference Signal (Step)**
```
Step time: 1
Initial value: 0
Final value: 0.5
Sample time: 0.07
```

**1.2. Smith Predictor Subsystem**
- Input: Error signal (r - y_delayed)
- Output: Control signal (u)
- Contains: Controller, Reference Filter, Plant Model (no delay)

**1.3. Plant with Delay**
- Input: Control signal (u)
- Output: Delayed output (y_delayed)
- Contains: Nonlinear reactor model + Transport Delay

---

### 2. **Subsystem: `smith_predictor_controller.slx`**

#### Estrutura interna:
```
[Reference] ---> [Reference Filter] ---> [+] ---> [Controller] ---> [Output]
                                          ^
                                          |
[Plant Output] ---> [Plant Model] -------+
                         |
[Delay] <----------------+
```

#### Blocos do controlador:

**2.1. Reference Filter**
```
Transfer Function: 0.1256/(0.9928*z - 0.8672)
Sample time: 0.07
```

**2.2. Controller (Discrete)**
```
Transfer Function: (0.9928*z - 0.8672)/(z - 1)
Sample time: 0.07
```

**2.3. Plant Model (sem atraso)**
```
Transfer Function: (-0.04658*z^2 + 0.02241*z + 0.069)/(z^2 - 1.501*z + 0.543)
Sample time: 0.07
```

---

### 3. **Modelo Não-Linear: `reator_nao_linear.slx`**

#### Equações diferenciais implementadas:
```matlab
% No bloco MATLAB Function:
function [dCa_dt, dCb_dt] = reator_dynamics(Ca, Cb, u, Caf)
    % Parâmetros do reator
    k1 = 6.01;    % [1/min]
    k2 = 0.8433;  % [1/min] 
    k3 = 0.1123;  % [mol/(l·min)]
    
    % Equações diferenciais
    dCa_dt = -k1*Ca - k3*Ca^2 + u*(Caf - Ca);
    dCb_dt = k1*Ca - k2*Cb - u*Cb;
end
```

#### Blocos necessários:
- **MATLAB Function**: Com as equações acima
- **Integrator** (2x): Para Ca e Cb
- **Transport Delay**: Atraso de 3 minutos
- **Constant**: Para Caf = 5.1

---

### 4. **Modelo Smith Filtrado: `smith_filtrado.slx`**

#### Diferença do modelo básico:
- Adiciona o **Filtro de Projeção Fe(z)**
- Estrutura mais complexa para melhor rejeição de perturbações

**4.1. Filtro de Projeção**
```
Transfer Function: (0.409141*z^2 - 0.61412*z + 0.222141)/(z^2 - 1.738*z + 0.755)
Sample time: 0.07
```

---

## Configurações Gerais dos Modelos

### Solver Configuration:
```
Type: Fixed-step
Solver: ode4 (Runge-Kutta)
Fixed-step size: 0.07
Stop time: 1800  (30 minutos)
```

### Data Import/Export:
```
Time: tout
Output: yout
Format: Array
```

---

## Como usar os modelos:

### 1. **Preparação**:
```matlab
% Execute primeiro o código MATLAB principal
run('codigo_matlab.m')

% Carregue os parâmetros
load('parametros_simulink.mat')
```

### 2. **Configuração de parâmetros no Simulink**:
- Abra o modelo .slx
- Vá em Model Settings > Model Properties > Callbacks
- No InitFcn callback, adicione:
```matlab
load('parametros_simulink.mat')
```

### 3. **Simulação**:
- Configure tempo de simulação: 30 minutos (1800 segundos)
- Execute a simulação
- Visualize resultados nos Scopes

---

## Cenários de Teste

### Teste 1: Seguimento de Referência
```
Reference: Step de 0 para 0.5 em t=1min
Perturbation: 0
Expected: t_settle ≈ 1.74min, overshoot < 5%
```

### Teste 2: Rejeição de Perturbação
```
Reference: 0
Perturbation: Step de -0.2 em Caf em t=20min
Expected: Rejeição em ~3-6 minutos
```

### Teste 3: Robustez
```
Reference: Step de 0 para 0.5
Perturbation: Variações nos parâmetros ±10%
Expected: Sistema estável, desempenho degradado aceitável
```

---

## Blocos Importantes e Configurações

### Transport Delay Block:
```
Delay time: 180  (3 minutos em segundos)
Initial output: 0
```

### Discrete Transfer Function:
```
Sample time: 0.07
Initial states: 0
```

### Scope Configuration:
```
Number of input ports: 3
Time range: auto
Y-limits: auto
Data history: 10000
```

---

## Troubleshooting

### Problema: Simulação instável
**Solução**: 
- Verifique step size (deve ser 0.07)
- Confirme que parâmetros foram carregados
- Verifique condições iniciais

### Problema: Resultados não coincidem
**Solução**:
- Execute código MATLAB primeiro
- Carregue parametros_simulink.mat
- Verifique configurações de amostragem

### Problema: Atraso não funciona
**Solução**:
- Transport Delay deve estar em segundos (180s)
- Verifique se Sample Time está correto
- Confirme que Initial Output = 0

---

## Arquivos Necessários

1. `codigo_matlab.m` - Código principal
2. `parametros_simulink.mat` - Parâmetros (gerado automaticamente)
3. `preditor_smith_main.slx` - Modelo principal
4. `smith_predictor_controller.slx` - Subsystem do controlador
5. `reator_nao_linear.slx` - Modelo não-linear da planta
6. `smith_filtrado.slx` - Versão com filtro de projeção

**Nota**: Os arquivos .slx precisam ser criados no Simulink seguindo as especificações acima.