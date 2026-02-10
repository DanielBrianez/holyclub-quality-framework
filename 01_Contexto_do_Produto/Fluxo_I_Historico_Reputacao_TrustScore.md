# Fluxo A — Criação de Perfil 👤

## Classificação
**Criticidade:** P0  
**Tipo:** Fluxo Primário  
**Impacta diretamente:** Todos os fluxos subsequentes

---

## Objetivo do Fluxo

Garantir a criação segura, única e validada do perfil do jogador na HolyClub, estabelecendo sua **identidade base** dentro da plataforma e criando o vínculo inicial com a Steam.

Este fluxo é responsável por impedir:
- Contas duplicadas
- Fraudes de identidade
- Criação de contas por usuários previamente banidos
- Entrada de jogadores sem elegibilidade mínima

---

## Atores Envolvidos

- Jogador
- HolyClub API
- Steam API
- Banco de Dados
- Sistema de Reputação (inicialização)

---

## Pré-condições

- Jogador **não possui conta ativa** na HolyClub
- Steam ID válido e acessível
- Serviços de autenticação disponíveis

---

## Pós-condições

- Perfil criado com sucesso
- Steam ID vinculado
- Status inicial definido
- Trust Score inicial atribuído
- Jogador apto a autenticar (Fluxo B)

---

## Passo a Passo do Fluxo

### 1. Acesso à Tela de Cadastro
O jogador acessa a opção **Criar Conta** na plataforma HolyClub.

---

### 2. Autenticação via Steam
- Jogador é redirecionado para autenticação Steam
- HolyClub recebe:
  - SteamID
  - Nickname
  - Avatar
  - Status da conta Steam

---

### 3. Validações Críticas

#### 3.1 SteamID já existe?
- **Sim:**  
  → Bloquear criação  
  → Retornar erro: `Conta já existente`
- **Não:**  
  → Prosseguir

#### 3.2 SteamID consta em blacklist?
(Ex: banimentos permanentes anteriores)

- **Sim:**  
  → Bloquear criação  
  → Registrar tentativa  
  → Retornar erro: `Conta inelegível`
- **Não:**  
  → Prosseguir

---

### 4. Criação do Perfil

Campos mínimos criados:
- user_id (UUID)
- steam_id
- nickname
- avatar_url
- data_criacao
- status_conta (ACTIVE)
- trust_score_inicial (ex: 100)
- flags (array vazio)

---

### 5. Inicialização de Reputação

- Criação do registro no sistema de reputação
- Trust Score inicial padronizado
- Histórico zerado

---

### 6. Confirmação ao Jogador

- Retorno de sucesso
- Redirecionamento para login
- Perfil pronto para autenticação

---

## Fluxos Alternativos

### A1 — Steam indisponível
- Exibir mensagem amigável
- Logar falha técnica
- Permitir nova tentativa

---

### A2 — Tentativa de burlar criação
- Detectar múltiplas tentativas
- Ativar rate limit
- Registrar evento de segurança

---

## Regras de Negócio

- Um SteamID = Um perfil
- SteamID banido **nunca** pode criar novo perfil
- Trust Score inicial **não é neutro**, é conservador
- Nenhuma conta nasce com privilégios

---

## Eventos Gerados

- `PROFILE_CREATED`
- `STEAM_LINKED`
- `TRUST_SCORE_INITIALIZED`

---

## Dependências Técnicas

- Steam OpenID
- Serviço de Reputação
- Banco de Usuários
- Serviço de Logs & Auditoria

---

## Riscos Mapeados

| Risco | Mitigação |
|-----|---------|
| Contas duplicadas | Validação única por SteamID |
| Criação por banido | Blacklist persistente |
| Fraude automatizada | Rate limit + logs |

---

## Observações Importantes

Este fluxo **não concede acesso à plataforma**, apenas cria identidade.  
O acesso real ocorre **exclusivamente no Fluxo B — Autenticação & Login**.

# Fluxo Crítico B — Autenticação, Sessão, MFA e Recuperação de Senha 🔐

## Objetivo

Definir como a HolyClub realiza a autenticação segura dos jogadores, gerenciamento de sessão, múltiplos fatores de autenticação (MFA) e recuperação de acesso, garantindo segurança, continuidade de uso e prevenção de fraudes.

Este é um fluxo **P0**, pois impacta diretamente:
- Segurança da plataforma
- Proteção de contas
- Confiabilidade do ecossistema
- Todos os fluxos subsequentes (C a I)

---

## Atores Envolvidos

- Jogador
- Sistema HolyClub (Frontend + Backend)
- Serviço de Autenticação
- Serviço de MFA
- Serviço de Notificação (Email / SMS / Push)
- Serviço de Segurança / Antifraude

---

## Pré-condições

- Conta criada com sucesso (Fluxo A)
- Jogador não banido permanentemente
- Serviços de autenticação ativos

---

## Fluxo Principal (Happy Path)

### B1 — Acesso à Tela de Login
- Jogador acessa a aplicação
- Sistema exibe campos:
  - Email / Username
  - Senha
- Opções adicionais:
  - “Esqueci minha senha”
  - “Entrar com MFA” (se aplicável)

---

### B2 — Validação de Credenciais
- Jogador envia credenciais
- Sistema valida:
  - Existência da conta
  - Senha correta
  - Status da conta

**Falhas possíveis:**
- Credenciais inválidas
- Conta bloqueada
- Tentativas excessivas

---

### B3 — Verificação de MFA (quando ativo)
- Se MFA estiver habilitado:
  - Sistema solicita segundo fator:
    - Código via app autenticador
    - SMS
    - Email
- Jogador informa o código

**Regra de Negócio:**  
Sem MFA válido, a sessão **não é criada**.

---

### B4 — Criação de Sessão
- Sistema cria sessão autenticada
- Gera:
  - Token de acesso
  - Token de refresh
- Registra:
  - IP
  - Dispositivo
  - Timestamp

---

### B5 — Acesso ao Sistema
- Jogador é redirecionado para:
  - Dashboard
  - Última tela acessada
- Sessão ativa e monitorada

---

## Fluxos Alternativos e Cenários Negativos

### B6 — Credenciais Inválidas
- Sistema:
  - Exibe mensagem genérica
  - Incrementa contador de tentativas
- Após limite:
  - Conta temporariamente bloqueada

---

### B7 — MFA Inválido ou Expirado
- Sistema:
  - Informa erro
  - Permite nova tentativa limitada
- Excesso de falhas:
  - Bloqueio temporário
  - Alerta de segurança

---

### B8 — Sessão Expirada
- Token expira
- Sistema tenta refresh automático
- Se falhar:
  - Jogador é redirecionado ao login

---

## Recuperação de Senha

### B9 — Solicitação de Recuperação
- Jogador clica em **“Esqueci minha senha”**
- Informa email/username
- Sistema confirma solicitação (sem revelar existência da conta)

---

### B10 — Envio de Link Seguro
- Sistema gera token temporário
- Envia link por:
  - Email (prioritário)
- Token possui:
  - Expiração
  - Uso único

---

### B11 — Redefinição de Senha
- Jogador acessa link
- Define nova senha
- Sistema:
  - Valida critérios de segurança
  - Invalida sessões ativas
  - Confirma alteração

---

## Gerenciamento de MFA

### B12 — Ativação de MFA
- Jogador acessa:
  - Perfil → Segurança
- Ativa MFA
- Sistema:
  - Exibe QR Code / método
  - Valida primeiro código

---

### B13 — Recuperação de MFA
- Em caso de perda do segundo fator:
  - Processo exige verificação reforçada
  - Pode envolver suporte/manual review

---

## Pós-condições

- Sessão criada ou negada corretamente
- Logs de autenticação registrados
- Tentativas suspeitas monitoradas
- Sessões inválidas encerradas

---

## O que NÃO pode acontecer (P0)

- Login sem validação completa
- Sessão criada sem MFA quando ativo
- Recuperação de senha sem expiração
- Mensagens que confirmem existência de conta
- Sessões órfãs após troca de senha
- Vazamento de tokens

---

## Regras de Negócio Importantes

- MFA é opcional, mas recomendado
- Penalidades graves podem bloquear login
- Tentativas excessivas disparam mecanismos antifraude
- Toda autenticação é auditável

---

## Observações de QA

Este fluxo deve ser validado com:
- Login válido e inválido
- MFA ativo e inativo
- Expiração de sessão
- Recuperação de senha
- Ataques de força bruta
- Logout forçado após reset de senha
- Persistência entre dispositivos

# Fluxo Crítico C — Perfil do Jogador e Dados da Conta 👤

## Objetivo

Definir como a HolyClub exibe, gerencia e protege os dados do **perfil do jogador**, garantindo consistência das informações, segurança, personalização da experiência e integração com os demais fluxos críticos.

Este é um fluxo **P0**, pois impacta diretamente:
- Experiência do usuário
- Segurança e privacidade
- Comunicação com outros jogadores
- Elegibilidade para partidas, eventos e campeonatos

---

## Atores Envolvidos

- Jogador autenticado
- Sistema HolyClub (Frontend + Backend)
- Serviço de Perfil
- Serviço de Autenticação
- Serviço de Reputação / Penalidades
- Serviço de Integrações (Steam, etc.)

---

## Pré-condições

- Jogador autenticado com sucesso (Fluxo B)
- Conta ativa (não banida permanentemente)
- Perfil criado automaticamente no Fluxo A

---

## Fluxo Principal (Happy Path)

### C1 — Acesso ao Perfil
- Jogador acessa:
  - Menu → **Perfil**
- Sistema carrega dados do perfil do jogador

---

### C2 — Exibição das Informações do Perfil
O sistema exibe, no mínimo:
- Nickname
- Avatar
- ID interno HolyClub
- Status da conta
- Data de criação
- Integrações ativas (ex: Steam)
- Status de reputação (nível, não numérico)
- Avisos ativos (penalidades, restrições)

**Exemplo de mensagem:**
> *“Bem-vindo de volta, Sombra”*

---

### C3 — Edição de Dados Permitidos
Jogador pode editar:
- Avatar
- Preferências visuais
- Configurações de privacidade
- Configurações de notificações

> **Regra de Negócio:**  
> Dados sensíveis (email, autenticação, MFA) **não são editados diretamente aqui**.

---

### C4 — Salvamento das Alterações
- Jogador confirma alterações
- Sistema valida dados
- Atualiza perfil
- Registra log da alteração

---

### C5 — Integrações Externas
- Jogador visualiza integrações ativas:
  - Steam (obrigatória para partidas)
- Sistema exibe:
  - Status da integração
  - Restrições detectadas (ex: VAC ban)

---

## Fluxos Alternativos e Cenários Negativos

### C6 — Perfil com Restrições
Se o jogador possuir restrições:
- Sistema exibe aviso destacado no perfil
- Detalha:
  - Tipo da restrição
  - Impacto funcional
  - Link para mais informações

**Exemplo:**
> *“Sua conta possui uma restrição ativa e não pode participar de partidas no momento.”*

---

### C7 — Tentativa de Edição Não Permitida
- Jogador tenta editar campo sensível
- Sistema:
  - Bloqueia ação
  - Exibe mensagem explicativa

---

### C8 — Integração Inválida ou Revogada
- Integração (ex: Steam) falha ou é revogada
- Sistema:
  - Atualiza status
  - Limita funcionalidades dependentes
  - Notifica o jogador

---

## Pós-condições

- Perfil consistente e atualizado
- Alterações registradas em log
- Status da conta refletido corretamente
- Dados disponíveis para matchmaking e eventos

---

## O que NÃO pode acontecer (P0)

- Perfil carregar dados de outro jogador
- Exposição de dados sensíveis
- Edição de dados críticos sem autenticação
- Perfil ignorar penalidades ou restrições
- Informações inconsistentes entre serviços

---

## Regras de Negócio Importantes

- Perfil é criado automaticamente no Fluxo A
- Alterações devem ser auditáveis
- Restrições sempre têm prioridade visual
- Nicknames não podem causar impersonação
- Integrações externas determinam elegibilidade funcional

---

## Observações de QA

Este fluxo deve ser validado com:
- Perfil recém-criado
- Perfil com histórico longo
- Perfil com penalidades ativas
- Tentativas de edição inválidas
- Falhas de integração externa
- Persistência após logout/login

# Fluxo Crítico D — Validação de Conta, Restrições e Elegibilidade 🔍

## Objetivo

Garantir que apenas jogadores **elegíveis** possam participar de partidas e eventos na HolyClub, validando:
- Restrições da Steam (VAC, Game Ban, Trade Ban, Community Ban)
- Penalidades internas da HolyClub
- Status geral da conta

Este fluxo é **P0 absoluto**, pois protege:
- Integridade competitiva
- Confiança da comunidade
- Credibilidade da plataforma

---

## Atores Envolvidos

- Jogador
- Sistema HolyClub (Frontend + Backend)
- Steam API
- Serviço de Antifraude
- Sistema de Penalidades HolyClub
- Serviço de Notificações

---

## Pré-condições

- Jogador autenticado com sucesso (Fluxo B)
- Conta Steam vinculada
- Serviços de verificação ativos

---

## Fluxo Principal (Happy Path)

### D1 — Acesso ao Sistema ou Funcionalidade Competitiva
- Jogador tenta:
  - Entrar em partida
  - Criar partida
  - Inscrever-se em evento/campeonato
- Sistema inicia validações automáticas

---

### D2 — Verificação de Restrições Steam
- Sistema consulta Steam API
- Valida:
  - VAC Ban
  - Game Ban
  - Community Ban
  - Trade Ban

**Regra de Negócio:**  
Qualquer tipo de ban relevante **impede participação** em partidas/eventos.

---

### D3 — Verificação de Penalidades Internas (HolyClub)
- Sistema verifica:
  - Suspensão temporária
  - Banimento permanente
  - Restrições parciais (ex: apenas matchmaking bloqueado)
- Considera histórico e reincidência

---

### D4 — Consolidação de Elegibilidade
- Sistema cruza dados:
  - Steam
  - Penalidades internas
- Define status do jogador:
  - ✅ Elegível
  - ⚠️ Elegível com restrições
  - ❌ Inelegível

---

### D5 — Autorização de Acesso
- Se elegível:
  - Jogador prossegue normalmente
- Sistema registra auditoria da validação

---

## Fluxos Alternativos e Cenários Negativos

### D6 — Banimento Detectado na Steam
- Sistema bloqueia ação
- Exibe:
  - Notificação flutuante
  - Aviso no perfil do jogador

**Mensagem sugerida:**  
> "Opa, parece que sua conta Steam possui um banimento ativo (VAC / Game Ban).  
> Se acredita que isso seja um erro, entre em contato com o suporte."

---

### D7 — Penalidade Interna Ativa
- Sistema bloqueia funcionalidades conforme regra
- Exibe mensagem clara:
  - Tipo da penalidade
  - Duração (se aplicável)

---

### D8 — Falha na Consulta à Steam API
- Sistema:
  - Não libera participação
  - Exibe mensagem genérica
- Registra incidente técnico
- Evita qualquer bypass

---

### D9 — Restrição Temporária Expirada
- Sistema detecta expiração
- Remove restrição automaticamente
- Atualiza status do jogador

---

## Pós-condições

- Jogador autorizado ou bloqueado corretamente
- Logs de validação registrados
- Status refletido no perfil
- Nenhuma ação crítica executada sem validação

---

## O que NÃO pode acontecer (P0)

- Jogador com VAC/Game Ban participando de partidas
- Bypass de validação por falha externa
- Mensagens confusas ou genéricas demais
- Divergência entre status real e perfil exibido
- Falta de auditoria das decisões

---

## Regras de Negócio Importantes

- Restrições Steam têm prioridade máxima
- Penalidades internas podem ser temporárias ou permanentes
- Falhas externas **bloqueiam**, nunca liberam
- Todas as decisões devem ser auditáveis

---

## Observações de QA

Este fluxo deve ser testado com:
- Conta Steam limpa
- Conta com VAC Ban
- Conta com Game Ban
- Penalidade interna temporária
- Penalidade permanente
- Falha simulada na Steam API
- Expiração automática de restrição

# Fluxo Crítico E — Criação, Entrada e Gerenciamento de Partidas 🎮

## Objetivo

Definir como a HolyClub permite que jogadores criem, entrem e participem de partidas, garantindo integridade competitiva, validações de elegibilidade e uma experiência estável do início ao fim da partida.

---

## Escopo do Fluxo

Este fluxo contempla:

- Criação de partidas (casuais, ranqueadas ou privadas)
- Entrada de jogadores em partidas existentes
- Validações de elegibilidade do jogador
- Estado da partida (aguardando, em andamento, finalizada)
- Tratamento de erros e bloqueios
- Gerenciamento de abandono ou desconexão (alto nível)

---

## Pré-requisitos

- Usuário autenticado com sucesso
- Conta Steam vinculada e validada
- Usuário **sem restrições ativas**, incluindo:
  - Banimento VAC
  - Restrições temporárias ou permanentes aplicadas pela HolyClub
- Perfil ativo e completo

---

## Fluxo Principal — Criação de Partida

1. Usuário acessa a aba **Criar Partida**
2. Sistema valida:
   - Autenticação ativa
   - Status da conta Steam
   - Ausência de restrições internas ou externas
3. Usuário define:
   - Tipo de partida (casual / ranqueada / privada)
   - Número de jogadores
   - Regras específicas (quando aplicável)
4. Sistema cria a partida com status **Aguardando Jogadores**
5. Usuário é redirecionado para a sala da partida
6. Interface exibe:
   - Jogadores conectados
   - Slots disponíveis
   - Status da partida

---

## Fluxo Principal — Entrada em Partida Existente

1. Usuário acessa a lista de partidas disponíveis
2. Sistema exibe apenas partidas compatíveis com:
   - Tipo de conta do jogador
   - Região (se aplicável)
   - Regras de elegibilidade
3. Usuário seleciona uma partida
4. Sistema valida novamente:
   - Autenticação
   - Restrições Steam e HolyClub
   - Disponibilidade de vagas
5. Usuário entra na sala da partida
6. Status da partida é atualizado em tempo real

---

## Validações Críticas

O sistema **deve bloquear imediatamente** a criação ou entrada em partidas caso:

- O jogador possua banimento VAC
- O jogador esteja com restrição temporária ou permanente na HolyClub
- A conta Steam não esteja acessível ou válida
- A partida esteja cheia ou em estado incompatível

### Mensagens de Erro

- Notificação flutuante (toast)
- Mensagem fixa na tela ou na sala da partida

Exemplo:
> "Opa! Sua conta possui uma restrição ativa e não pode participar de partidas no momento. Caso acredite que isso seja um erro, entre em contato com o suporte."

---

## Estados da Partida

- **Aguardando Jogadores**
- **Pronta para Iniciar**
- **Em Andamento**
- **Finalizada**
- **Cancelada por erro ou falta de jogadores**

Cada estado deve refletir claramente na interface do usuário.

---

## Cenários de Erro e Exceção

- Falha na comunicação com a Steam
- Desconexão do usuário antes do início da partida
- Tentativa de entrada em partida inexistente ou encerrada
- Erro interno na criação da sala

Em todos os casos:
- O usuário deve receber feedback claro
- O sistema não deve deixar partidas “fantasma” ativas

---

## O que NÃO pode acontecer

- Jogadores inelegíveis acessarem partidas
- Partidas iniciarem com validações pendentes
- Usuários ficarem presos em estados inconsistentes
- Falta de feedback visual ou mensagens genéricas de erro

---

## Pós-condições

- Partidas ativas refletem corretamente seus estados
- Logs de criação, entrada e erros são registrados
- O sistema permanece estável mesmo em cenários de falha

---

## Observações

- Fluxos detalhados de **abandono de partida**, **desconexão** e **penalizações** serão tratados em fluxos críticos específicos (ex: Fluxo F).
- Este fluxo serve como base para matchmaking e campeonatos futuros.

# Fluxo Crítico F — Abandono de Partida, Desconexão e Penalizações ⚠️

## Objetivo

Definir como a HolyClub lida com abandono de partidas, desconexões voluntárias ou involuntárias, garantindo justiça competitiva, rastreabilidade e aplicação correta de penalizações quando necessário.

---

## Escopo do Fluxo

Este fluxo contempla:

- Abandono voluntário de partida
- Desconexão involuntária (queda de internet, crash, Steam offline)
- Janela de reconexão
- Classificação de abandono
- Aplicação de penalizações temporárias ou permanentes
- Comunicação clara com o jogador

---

## Pré-requisitos

- Partida em estado **Em Andamento** ou **Pronta para Iniciar**
- Jogador autenticado e validado
- Jogador vinculado à partida ativa

---

## Tipos de Saída de Partida

### 1. Abandono Voluntário

Ocorre quando o jogador:

- Clica explicitamente em **Sair da Partida**
- Fecha o jogo ou a aplicação intencionalmente
- Recusa confirmação de início da partida após aceite

➡️ Deve ser tratado como **abandono direto**, salvo exceções definidas por regra.

---

### 2. Desconexão Involuntária

Ocorre quando:

- Há queda de conexão
- Steam fica temporariamente indisponível
- Crash inesperado do cliente

➡️ Deve acionar o **fluxo de reconexão**.

---

## Fluxo Principal — Desconexão com Reconexão

1. Sistema detecta desconexão do jogador
2. Jogador recebe status **Desconectado**
3. Sistema inicia temporizador de reconexão (ex: 3–5 minutos)
4. Interface informa aos demais jogadores o status do jogador desconectado
5. Caso o jogador retorne dentro do tempo:
   - Status volta para **Conectado**
   - Partida continua normalmente
6. Caso o tempo expire:
   - Desconexão é convertida em **abandono**

---

## Fluxo Principal — Abandono Confirmado

1. Sistema classifica o evento como abandono
2. Sistema registra:
   - Tipo (voluntário / involuntário)
   - Momento da partida
   - Histórico do jogador
3. Sistema aplica regras de penalização
4. Jogador recebe:
   - Notificação flutuante
   - Registro no perfil

---

## Penalizações Possíveis

As penalizações devem ser progressivas e configuráveis:

- Aviso (warning)
- Bloqueio temporário de partidas
- Bloqueio temporário de matchmaking
- Restrição total de eventos ou campeonatos
- Banimento permanente (casos extremos)

> A gravidade deve considerar reincidência e contexto.

---

## Validações Críticas

O sistema **não pode**:

- Penalizar jogadores sem registro de evento
- Penalizar desconexões dentro da janela de tolerância
- Aplicar penalizações duplicadas para o mesmo evento
- Permitir manipulação do fluxo (ex: forçar crash para evitar penalidade)

---

## Comunicação com o Jogador

### Notificação Exemplo

> "Você abandonou uma partida em andamento. Isso pode gerar penalizações caso se repita."

### Perfil do Jogador

Deve exibir:
- Tipo de penalização
- Duração
- Motivo
- Data de expiração (quando aplicável)

---

## Cenários de Erro e Exceção

- Falha na detecção de status de conexão
- Steam indisponível durante a partida
- Erro interno ao aplicar penalização

Nestes casos:
- O sistema deve **priorizar não penalizar injustamente**
- Evento deve ser logado para revisão manual

---

## O que NÃO pode acontecer

- Penalização silenciosa sem aviso
- Partidas ficarem travadas aguardando jogador indefinidamente
- Jogadores abusarem de desconexão para evitar derrotas
- Falta de histórico ou transparência no perfil

---

## Pós-condições

- Estado da partida é resolvido corretamente
- Penalizações (quando aplicáveis) estão registradas
- Logs completos disponíveis para auditoria
- Integridade competitiva preservada

---

## Observações

- Regras exatas de tempo e penalização devem ser parametrizáveis
- Este fluxo impacta diretamente matchmaking, rankings e campeonatos
- Fluxos de **contestação de penalidade** podem ser tratados separadamente

# Fluxo Crítico G — Histórico do Jogador, Logs e Auditoria 📊

## Objetivo

Definir como a HolyClub registra, organiza e disponibiliza o histórico completo de atividades do jogador, garantindo transparência, rastreabilidade, suporte a decisões automatizadas e base sólida para auditoria, suporte e penalizações.

---

## Escopo do Fluxo

Este fluxo contempla:

- Histórico de partidas
- Histórico de autenticações e sessões
- Registro de penalizações e restrições
- Logs de eventos críticos
- Visão do jogador e visão administrativa
- Base para suporte e contestação

---

## Tipos de Histórico Registrado

### 1. Histórico de Partidas

Para cada partida, registrar:

- ID da partida
- Tipo (casual / ranqueada / privada)
- Data e horário
- Status final (concluída, abandonada, cancelada)
- Resultado (quando aplicável)
- Ocorrências relevantes (abandono, desconexão, punições)

---

### 2. Histórico de Autenticação e Sessão

Registrar eventos como:

- Login bem-sucedido
- Tentativas falhas de login
- Ativação / falha de MFA
- Troca de senha
- Expiração de sessão
- Logout forçado

Dados mínimos:
- Data e hora
- IP (ou hash)
- Dispositivo / origem
- Resultado da tentativa

---

### 3. Histórico de Penalizações

Cada penalização deve conter:

- Tipo de penalização
- Motivo
- Fluxo de origem (ex: abandono, fraude, abuso)
- Data de aplicação
- Duração
- Status (ativa / expirada / revogada)

---

## Fluxo Principal — Registro Automático

1. Evento crítico ocorre em qualquer fluxo (A–F)
2. Sistema registra o evento automaticamente
3. Evento é classificado por tipo e severidade
4. Dados são persistidos de forma imutável (append-only)
5. Evento fica disponível para:
   - Consulta do jogador (visão limitada)
   - Consulta administrativa (visão completa)

---

## Visão do Jogador

O jogador deve ter acesso a:

- Histórico de partidas
- Penalizações ativas e passadas
- Avisos e alertas relevantes

### Regras Importantes

- Logs sensíveis (IP, antifraude, score interno) **não devem ser exibidos**
- Informações devem ser claras e compreensíveis
- Penalizações devem ter motivo explícito

---

## Visão Administrativa

Admins e suporte podem acessar:

- Histórico completo do jogador
- Linha do tempo de eventos
- Correlação entre eventos (ex: abandono + penalização)
- Logs técnicos e antifraude
- Exportação para análise

---

## Auditoria e Integridade

O sistema deve garantir:

- Logs imutáveis
- Ordenação cronológica confiável
- Identificação do sistema ou agente que gerou o evento
- Proteção contra edição ou exclusão indevida

---

## Validações Críticas

O sistema **não pode**:

- Perder logs de eventos críticos
- Permitir edição manual de histórico sem rastreio
- Exibir dados sensíveis ao jogador
- Aplicar penalizações sem registro associado

---

## Cenários de Erro e Exceção

- Falha momentânea ao persistir logs
- Inconsistência entre eventos distribuídos
- Indisponibilidade de serviço de auditoria

Nestes casos:
- O sistema deve reprocessar eventos
- Nenhuma ação punitiva deve ocorrer sem log válido

---

## Pós-condições

- Histórico completo e consistente
- Base confiável para suporte e disputas
- Dados disponíveis para análises futuras
- Suporte a decisões automatizadas (ex: Fluxo F e H)

---

## Observações

- Este fluxo é transversal e impacta todos os outros
- Deve ser considerado **P0 estrutural**
- Logs podem ser utilizados futuramente para:
  - Rankings
  - Matchmaking
  - Machine Learning
  - Detecção de abuso

# Fluxo Crítico H — Penalidades, Recursos e Contestação 🛡️

## Objetivo

Definir como a HolyClub permite que jogadores visualizem penalidades aplicadas, entrem com recurso (contestação) e como o sistema processa essas solicitações de forma segura, justa e auditável.

Este é um fluxo **P0**, pois impacta diretamente:
- Confiança do usuário
- Risco jurídico e reputacional
- Transparência do sistema de Fair Play
- Retenção de jogadores penalizados

---

## Atores Envolvidos

- Jogador penalizado
- Sistema HolyClub (Frontend + Backend)
- Serviço de Penalidades / Fair Play
- Suporte / Moderação HolyClub

---

## Pré-condições

- Jogador autenticado (Fluxo B)
- Jogador possui ao menos uma penalidade ativa ou histórica
- Penalidade registrada corretamente (Fluxos F ou G)

---

## Tipos de Penalidade

- Aviso formal
- Bloqueio temporário de matchmaking
- Bloqueio de campeonatos
- Redução de ELO
- Restrição funcional
- Banimento permanente

---

## Fluxo Principal (Happy Path)

### H1 — Acesso à Área de Penalidades
- Jogador acessa:
  - Perfil → **Penalidades & Fair Play**
- Sistema exibe lista de penalidades:
  - Ativas
  - Expiradas
  - Permanentes

---

### H2 — Visualização de Detalhes
Para cada penalidade, o sistema exibe:
- Motivo
- Data de aplicação
- Duração (quando aplicável)
- Fluxo de origem (abandono, denúncia, etc.)
- Status atual

> **Regra de Negócio:**
> Nenhuma penalidade pode existir sem um motivo claro e registrado.

---

### H3 — Solicitação de Recurso
- Jogador seleciona uma penalidade
- Clica em **“Solicitar recurso”**
- Sistema informa se a penalidade é elegível para contestação

---

### H4 — Envio do Recurso
- Jogador preenche:
  - Justificativa textual
  - Informações adicionais (opcional)
- Confirma envio

---

### H5 — Registro do Recurso
- Sistema cria registro com:
  - ID da penalidade
  - ID do jogador
  - Timestamp
  - Status inicial: **Em análise**
- Penalidade permanece ativa durante análise (por padrão)

---

## Fluxos Alternativos e Cenários Negativos

### H6 — Penalidade Não Elegível para Recurso
Exemplos:
- Banimento permanente confirmado
- Penalidade já analisada anteriormente
- Tentativas excessivas de recurso

**Ação do sistema:**
- Exibe mensagem clara ao jogador
- Bloqueia envio do recurso

---

### H7 — Análise do Recurso (Moderação)
- Moderador acessa painel administrativo
- Avalia:
  - Histórico do jogador
  - Logs técnicos
  - Evidências da penalidade
  - Justificativa apresentada

---

### H8 — Decisão do Recurso
Decisões possíveis:
- Indeferido (penalidade mantida)
- Parcialmente deferido (redução de duração)
- Deferido (penalidade removida)
- Agravamento (em caso de má-fé comprovada)

---

## Comunicação ao Jogador

### Resultado do Recurso
- Sistema notifica o jogador com:
  - Decisão final
  - Justificativa objetiva
  - Ação aplicada

**Exemplos:**
- *“Seu recurso foi analisado e a penalidade foi mantida.”*
- *“Sua penalidade foi reduzida após análise.”*
- *“A penalidade foi removida com sucesso.”*

---

## Pós-condições

- Decisão registrada e auditável
- Penalidade atualizada corretamente
- Histórico do jogador atualizado
- Logs disponíveis para suporte e compliance

---

## O que NÃO pode acontecer (P0)

- Penalidade sem possibilidade de visualização
- Recurso sem resposta
- Decisão sem justificativa registrada
- Alteração de penalidade sem log
- Vazamento de informações internas de moderação
- Possibilidade de spam infinito de recursos

---

## Regras de Negócio Importantes

- Recursos possuem limite por penalidade
- Reincidência de recursos abusivos pode gerar nova penalidade
- Penalidades críticas podem não ser elegíveis para contestação
- Toda decisão deve ser rastreável

---

## Observações de QA

Este fluxo deve ser validado com:
- Testes de penalidade ativa e expirada
- Testes de elegibilidade de recurso
- Testes de decisão manual
- Testes de concorrência de recursos
- Testes de auditoria e logs
- Testes de persistência pós-login

# Fluxo Crítico I — Histórico, Reputação e Trust Score 📊

## Objetivo

Definir como a HolyClub consolida o histórico competitivo e comportamental dos jogadores em um **sistema de reputação (Trust Score)**, utilizado para decisões automatizadas de matchmaking, campeonatos, penalidades e prevenção de abusos.

Este é um fluxo **P0**, pois impacta diretamente:
- Qualidade das partidas
- Justiça competitiva
- Retenção de bons jogadores
- Prevenção de toxicidade e exploits

---

## Atores Envolvidos

- Jogador autenticado
- Sistema HolyClub (Frontend + Backend)
- Serviço de Matchmaking
- Serviço de Penalidades / Fair Play
- Serviço de Reputação / Trust Score

---

## Pré-condições

- Jogador autenticado (Fluxo B)
- Jogador possui histórico mínimo de partidas ou ações na plataforma
- Eventos anteriores registrados (Fluxos E, F, G e H)

---

## Conceitos-Chave

### Trust Score
Pontuação dinâmica que representa a confiabilidade do jogador na HolyClub, baseada em:

- Conclusão de partidas
- Abandonos
- Penalidades
- Recursos aceitos ou negados
- Denúncias recebidas e confirmadas
- Tempo de conta
- Frequência de partidas

> **Regra de Negócio:**
> Trust Score **não é visível em valor numérico bruto para outros jogadores**, apenas em níveis ou estados.

---

## Estados de Reputação (Exemplo)

- **Excellent** (Prioridade em matchmaking, acesso a drops/benefícios)
- **Good** (Padrão)
- **Neutral** (Contas novas ou pouco ativas)
- **Suspicious** (Shadowban / Low Priority)
- **Restricted** (Funcionalidades bloqueadas)

---

## Matriz de Fatores de Impacto (Black Box)

Embora a fórmula exata seja secreta (para evitar exploração), os fatores conhecidos incluem:

| Fator | Impacto | Observação |
|-------|---------|------------|
| Tempo de conta Steam | 🟢 Positivo | Contas antigas tendem a ser mais seguras |
| Valor do inventário | 🟢 Positivo | Jogadores com skins caras evitam banimento |
| Número de jogos na Steam | 🟢 Positivo | Perfil "gamer" real vs. conta descartável |
| Denúncias (Report Spam) | 🔴 Negativo (Ponderado) | Requer validação para evitar falso-positivo |
| Vínculo de HWID/IP | 🔴 Crítico | Se um PC tem banimento, todas as contas nele perdem score |
| Kick por votação | 🔴 Negativo | Ser expulso da partida recorrentemente |
| Dano a aliados | 🔴 Negativo | Fogo amigo intencional |

---

## Fluxo Principal (Happy Path)

### I1 — Consolidação de Eventos
- Sistema coleta eventos do jogador:
  - Partidas concluídas
  - Abandonos
  - Penalidades
  - Recursos
  - Denúncias

---

### I2 — Cálculo do Trust Score
- Serviço de reputação processa os dados
- Aplica pesos e regras de negócio
- Atualiza o Trust Score do jogador

**Exemplo de fatores positivos:**
- Sequência de partidas concluídas
- Longo período sem penalidades

**Exemplo de fatores negativos:**
- Abandonos recentes
- Penalidades ativas
- Reincidência de infrações

---

### I3 — Atualização do Perfil do Jogador
- Perfil exibe:
  - Status de reputação (nível)
  - Histórico resumido
  - Avisos quando em estado de risco

**Exemplo de mensagem:**
> *“Sua reputação está em risco. Evite abandonos para manter acesso ao matchmaking.”*

---

### I4 — Uso do Trust Score no Matchmaking
- Matchmaking considera o Trust Score para:
  - Agrupamento de jogadores
  - Fila prioritária ou restrita
  - Limitação de acesso a certos modos

---

## Fluxos Alternativos e Cenários Negativos

### I5 — Trust Score em Estado Crítico
Quando o jogador entra em estado **Risco** ou **Restrito**:

- Matchmaking pode ser limitado
- Campeonatos podem ser bloqueados
- Avisos claros são exibidos no perfil

---

### I6 — Recuperação de Reputação
- Sistema permite recuperação gradual:
  - Partidas completas sem incidentes
  - Tempo sem novas penalidades
- Trust Score melhora progressivamente

> **Regra Importante:**
> Recuperação nunca é instantânea.

---

### I7 — Proteção Contra Manipulação
- Sistema detecta:
  - Padrões artificiais
  - Tentativas de farmar reputação
- Eventos suspeitos não impactam positivamente o Trust Score

---

### I8 — Shadowban (Pool de Isolamento)
Em vez de banir imediatamente um jogador suspeito (mas sem prova cabal de cheat), o sistema:
- Marca o jogador como `SUSPICIOUS`
- O coloca em uma fila de matchmaking separada (Shadow Queue)
- O pareia **apenas** com outros jogadores `SUSPICIOUS` ou `TOXIC`

**Objetivo:**
- Proteger a base de jogadores legítimos (`GREEN TRUST`)
- Coletar mais dados sobre o comportamento do suspeito
- Frustrar o cheater/tóxico sem dar feedback imediato de bloqueio

---

### I9 — Calibração de Contas Novas (Anti-Smurf)
- Contas recém-criadas (Fluxo A) iniciam em estado `PROVISIONAL`
- Matchmaking restrito a outros jogadores novos ou de baixo nível
- **Vínculo de Confiança:** Se a conta nova for vinculada (mesmo telefone/email/HWID) a uma conta `EXCELLENT`, ela herda parte do bônus. Se vinculada a uma banida, nasce `RESTRICTED`.

---

## Pós-condições

- Trust Score atualizado corretamente
- Histórico consistente e auditável
- Decisões automatizadas baseadas na reputação
- Feedback claro ao jogador

---

## O que NÃO pode acontecer (P0)

- Trust Score desatualizado
- Penalidade não refletida na reputação
- Reputação alterada sem evento registrado
- Recuperação instantânea após penalidade grave
- Jogadores tóxicos misturados com jogadores confiáveis
- Exposição excessiva de dados sensíveis de reputação

---

## Regras de Negócio Importantes

- Trust Score influencia, mas não substitui regras fixas
- Penalidades graves têm peso maior que eventos positivos
- Histórico nunca é apagado, apenas perde peso com o tempo
- Toda alteração deve ser rastreável
- **Decaimento Temporal:** Infrações perdem peso ao longo do tempo (ex: um abandono perde 50% do impacto negativo após 30 dias de bom comportamento).
- **Proteção de Review Bomb:** Um pico repentino de denúncias em curto período deve acionar um "Cool Down" de análise manual, e não baixar o score automaticamente.

---

## Observações de QA

Este fluxo deve ser validado com:
- Testes de cálculo incremental
- Testes de regressão após penalidades
- Testes de recuperação gradual
- Testes de matchmaking com diferentes reputações
- Testes de auditoria e logs
- Testes de persistência pós-login
- **Teste de Vínculo (HWID):** Simular login de conta limpa em máquina "suja" para validar queda de score.