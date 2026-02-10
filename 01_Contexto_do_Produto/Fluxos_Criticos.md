# Fluxo Crítico A — Autenticação, Acesso e Validação de Jogador

## Objetivo

Garantir que apenas jogadores elegíveis tenham acesso às funcionalidades competitivas da HolyClub, respeitando:

- Autenticação via Steam
- Restrições e banimentos da Steam
- Histórico e punições internas da HolyClub
- Integridade da sessão do usuário
- Experiência clara e transparente para o jogador

Este é um fluxo **P0**, pois qualquer falha compromete a segurança, a confiança e a credibilidade da plataforma.

---

## Atores Envolvidos

- Jogador (novo ou recorrente)
- Steam (provedor de autenticação)
- Sistema HolyClub (Frontend + Backend)

---

## Pré-condições

- Usuário possui uma conta Steam válida
- Usuário acessa a plataforma web da HolyClub
- Serviço de autenticação Steam disponível

---

## Fluxo Principal (Happy Path)

### A1 — Acesso à Plataforma
- Usuário acessa a HolyClub
- Sistema exibe a opção **“Entrar com Steam”**

**Validações QA:**
- Botão visível e funcional
- Nenhuma sessão criada neste momento

---

### A2 — Autenticação Steam
- Usuário realiza login com sucesso na Steam
- Steam retorna:
  - SteamID
  - Nickname
  - Status de restrições (VAC, bans, comunidade)

**Validações QA:**
- Callback da Steam ocorre corretamente
- Tokens são válidos
- Nenhuma sessão HolyClub é criada antes da validação completa

---

### A3 — Validação de Restrições Steam
O sistema verifica se o usuário possui:
- Ban VAC
- Ban de jogo
- Restrição de comunidade

**Regra de Negócio:**
> Qualquer tipo de restrição Steam impede o acesso às funcionalidades competitivas da HolyClub.

- Se **não houver restrições**, o fluxo continua
- Se **houver restrição**, o acesso competitivo é bloqueado

---

### A4 — Validação de Histórico HolyClub
O sistema consulta o banco interno utilizando o `SteamID`.

Campos críticos avaliados:
- `account_status` (active, restricted, temporarily_banned, permanently_banned)
- `restriction_type`
- `restriction_start_date`
- `restriction_end_date` (quando aplicável)

---

### A5 — Criação de Sessão e Redirecionamento
Se o usuário:
- Não possui restrições na Steam
- Não possui restrições ativas na HolyClub

Então:
- O sistema cria a sessão
- Redireciona o usuário para a Home
- Exibe mensagem personalizada

**Exemplo:**
> *“Bem-vindo de volta, Jogador”*

**Validações QA:**
- Nickname correto
- Sessão persistente
- Nenhum dado de outro usuário é exibido

---

## Fluxos Alternativos e Cenários Negativos

### A6 — Falha na Autenticação Steam
- Login falha
- Usuário permanece deslogado
- Mensagem clara é exibida

**Não pode acontecer:**
- Criação de sessão parcial
- Redirecionamento indevido
- Acesso a perfis de terceiros

---

### A7 — Restrição Steam Detectada
- Login é bloqueado
- Sistema exibe:
  - Notificação flutuante
  - Mensagem fixa no perfil

**Exemplo de mensagem:**
> *“Opa, parece que você possui um banimento VAC ativo.  
Jogadores com restrições na Steam não podem participar da HolyClub.”*

---

### A8 — Restrição Temporária HolyClub
- Login permitido
- Acesso parcial ao sistema
- Funcionalidades bloqueadas:
  - Matchmaking
  - Campeonatos
  - Eventos competitivos

**Mensagem exibida deve conter:**
- Motivo da restrição
- Data de término (quando aplicável)

---

### A9 — Banimento Permanente HolyClub
- Acesso bloqueado ou permitido apenas em modo leitura (decisão de produto)
- Nenhuma funcionalidade competitiva disponível
- Mensagem clara e definitiva exibida ao usuário

---

## Pós-condições

- Usuário autenticado corretamente ou bloqueado conforme regras
- Sessões criadas apenas para usuários elegíveis
- Restrições respeitadas mesmo após logout/login

---

## Pontos Críticos de Qualidade (P0)

- Usuário nunca deve acessar conta de terceiros
- Sessão não pode ser criada antes da validação completa
- Restrições não podem ser ignoradas após novo login
- Status HolyClub tem prioridade sobre status Steam
- Mensagens genéricas ou silenciosas não são aceitáveis

---

## Observações de QA

Este fluxo deve ser utilizado como base para:
- Casos de teste manuais
- Testes automatizados de autenticação
- Cenários BDD
- Testes de regressão
- Validação de segurança e integridade de sessão
  
## Fluxo Crítico B — Acesso à Aba Campeonatos (Estado: Sem Campeonatos Ativos)

**Objetivo:**  
Informar o usuário de forma clara sobre a indisponibilidade de campeonatos e oferecer alternativas.

**Regra de Negócio:**
> Quando não houver campeonatos ativos ou abertos para inscrição, o sistema deve informar claramente o usuário e impedir qualquer tentativa de inscrição.

**O que não pode acontecer (P0):**
- Exibição de erro técnico ou stack trace
- Botão de inscrição ativo sem campeonato disponível
- Redirecionamento quebrado ou página em branco
- Mensagem genérica que não explique o estado do sistema

**Pré-condições:**  
- Usuário autenticado
- Nenhum campeonato ativo ou aberto para inscrição

**Comportamento esperado:**  
- Exibição de mensagem informativa sobre indisponibilidade
- CTA para ativar notificações de novos campeonatos
- Opção de acesso ao matchmaking
- Opção de retorno à Home da aba Campeonatos

**Resultado esperado:**  
- Usuário entende o estado do sistema
- Nenhum erro técnico exibido
- Navegação funciona corretamente

**Observação de QA:**
Este fluxo está diretamente conectado ao Fluxo Crítico C (Inscrição em Campeonatos) e deve ser validado sempre que houver alterações no módulo de campeonatos.

# Fluxo Crítico C — Inscrição em Campeonato 

## Objetivo

Garantir que apenas jogadores elegíveis consigam se inscrever em campeonatos da HolyClub, respeitando regras competitivas, limite de vagas, estado do campeonato e status do jogador, assegurando justiça, confiabilidade e boa experiência do usuário.

Este é um fluxo **P0**, pois falhas impactam diretamente a credibilidade competitiva da plataforma.

---

## Atores Envolvidos

- Jogador autenticado
- Sistema HolyClub (Frontend + Backend)
- Serviço de Campeonatos

---

## Pré-condições

- Usuário autenticado e elegível (Fluxo Crítico A)
- Serviço de campeonatos disponível
- Existe ao menos um campeonato criado no sistema

---

## Estados Possíveis de um Campeonato

- Não existente
- Em breve
- Inscrições abertas
- Inscrições encerradas
- Lotado
- Em andamento
- Encerrado
- Cancelado

> Este fluxo cobre especificamente o estado **Inscrições abertas**.  
Os demais estados são tratados como fluxos alternativos.

---

## Fluxo Principal (Happy Path)

### C1 — Acesso à Aba Campeonatos
- Usuário acessa a aba Campeonatos
- O sistema exibe campeonatos com inscrições abertas

**Validações QA:**
- Lista carrega corretamente
- Informações visíveis:
  - Nome do campeonato
  - Datas
  - Número de vagas
  - Requisitos de participação

---

### C2 — Seleção do Campeonato
- Usuário seleciona um campeonato disponível para inscrição

**Validações QA:**
- Página de detalhes carrega corretamente
- Regras do campeonato são exibidas de forma clara

---

### C3 — Validação de Elegibilidade do Jogador
Antes de permitir a inscrição, o sistema valida automaticamente:

- Usuário autenticado
- Ausência de restrições Steam
- Ausência de restrições HolyClub
- Atendimento aos requisitos do campeonato, como:
  - ELO mínimo e/ou máximo
  - Região
  - Rank
  - Idade mínima da conta (quando aplicável)

**Regra de Negócio:**
> A validação de elegibilidade deve ocorrer antes da tentativa de inscrição.

---

### C4 — Solicitação de Inscrição
- Usuário clica em **“Inscrever-se”**

O sistema:
- Revalida o estado do campeonato
- Revalida a elegibilidade do jogador
- Verifica disponibilidade de vagas
- Impede inscrições duplicadas

---

### C5 — Confirmação da Inscrição
- Sistema confirma a inscrição com sucesso
- Atualiza o número de vagas disponíveis
- Exibe feedback claro ao usuário

**Exemplo de mensagem:**
> *“Inscrição realizada com sucesso! Boa sorte no campeonato.”*

---

## Fluxos Alternativos e Cenários Negativos

### C6 — Campeonato Lotado
- Inscrição é bloqueada
- Mensagem clara informa que não há mais vagas disponíveis

---

### C7 — Inscrições Encerradas
- Botão de inscrição desativado ou bloqueado
- Mensagem informativa exibida ao usuário

---

### C8 — Jogador Inelegível
Possíveis motivos:
- ELO fora do intervalo permitido
- Restrição Steam ativa
- Restrição HolyClub ativa

**Comportamento esperado:**
- Inscrição bloqueada
- Mensagem específica informando o motivo da inelegibilidade

---

### C9 — Tentativa de Inscrição Duplicada
- Sistema impede nova inscrição no mesmo campeonato
- Mensagem informativa exibida ao usuário

---

### C10 — Concorrência de Inscrição (Race Condition)
- Dois ou mais jogadores tentam ocupar a última vaga simultaneamente

**Resultado esperado:**
- Apenas um jogador é inscrito
- Os demais recebem mensagem de campeonato lotado
- Nenhuma inconsistência no número de vagas

---

## Pós-condições

- Jogador inscrito corretamente no campeonato
- Estado do campeonato atualizado
- Inscrição persistente após refresh, logout ou novo login

---

## O que NÃO pode acontecer (P0)

- Jogador inelegível inscrito em campeonato
- Inscrição duplicada
- Contador de vagas incorreto
- Inscrição realizada após encerramento
- Falta de feedback claro ao usuário
- Inscrição sem validação completa das regras

---

## Observações de QA

Este fluxo deve ser utilizado como base para:
- Casos de teste manuais
- Testes automatizados de API e UI
- Testes de concorrência
- Cenários BDD
- Testes de regressão sempre que regras de campeonatos forem alteradas
# Fluxo Crítico D — Recuperação de Senha e Autenticação 🔐

## Objetivo

Garantir que o processo de autenticação e recuperação de senha da HolyClub seja **seguro, confiável e à prova de falhas críticas**, protegendo contas de jogadores contra acesso indevido, sequestro de conta (account takeover) e erros de autenticação.

Este é um fluxo **P0 absoluto**, pois qualquer falha compromete segurança, confiança do usuário e integridade da plataforma.

---

## Atores Envolvidos

- Jogador
- Sistema HolyClub (Frontend + Backend)
- Serviço de Autenticação
- Serviço de E-mail / Notificações
- Steam (quando aplicável)

---

## Pré-condições

- Jogador possui conta criada na HolyClub
- Serviço de autenticação ativo
- Serviço de envio de e-mails disponível
- Base de usuários acessível

---

## Fluxos Abrangidos

- Login
- Logout
- Recuperação de senha
- Redefinição de senha
- Tratamento de erros de autenticação
- Proteções contra abuso

---

## Fluxo Principal — Autenticação (Happy Path)

### D1 — Acesso à Tela de Login
- Jogador acessa a tela de login da HolyClub

**Validações QA:**
- Campos de entrada visíveis e funcionais
- Mensagens de erro não exibidas previamente
- Opção “Esqueci minha senha” disponível

---

### D2 — Inserção de Credenciais Válidas
- Jogador informa e-mail/usuário e senha corretos

**Validações QA:**
- Dados enviados via conexão segura (HTTPS)
- Nenhum dado sensível exposto no frontend

---

### D3 — Validação das Credenciais
O sistema:
- Valida usuário e senha
- Verifica status da conta
- Verifica restrições HolyClub e Steam
- Valida tokens de sessão

---

### D4 — Login Bem-sucedido
- Jogador é autenticado
- Sessão é criada com segurança
- Usuário é redirecionado corretamente para a Home

**Exemplo de mensagem:**
> *“Bem-vindo de volta, Sombra.”*

---

## Fluxo Alternativo — Recuperação de Senha

### D5 — Solicitação de Recuperação
- Jogador clica em **“Esqueci minha senha”**
- Informa e-mail cadastrado

**Comportamento esperado:**
- Sistema não revela se o e-mail existe ou não
- Mensagem genérica exibida ao usuário

**Exemplo:**
> *“Se existir uma conta associada a este e-mail, você receberá as instruções em breve.”*

---

### D6 — Envio de Link de Recuperação
O sistema:
- Gera token único, temporário e seguro
- Envia link de redefinição por e-mail

**Regras:**
- Token com expiração
- Token de uso único
- Associação direta ao usuário

---

### D7 — Redefinição de Senha
- Jogador acessa o link recebido
- Define nova senha válida

**Validações QA:**
- Token ainda válido
- Token não reutilizado
- Regras de senha respeitadas

---

### D8 — Confirmação de Redefinição
- Senha atualizada com sucesso
- Sessões ativas anteriores são invalidadas
- Feedback claro ao usuário

---

## Fluxos de Erro e Cenários Negativos

### D9 — Credenciais Inválidas
- Login bloqueado
- Mensagem clara, sem expor detalhes

---

### D10 — Token Expirado ou Inválido
- Redefinição bloqueada
- Usuário orientado a solicitar novo link

---

### D11 — Conta com Restrição
- Login permitido ou bloqueado conforme regra
- Restrição exibida claramente no perfil e via notificação

**Exemplo:**
> *“Sua conta possui uma restrição ativa e não pode participar de partidas no momento.”*

---

### D12 — Tentativas Excessivas de Login
- Sistema aplica rate limit ou bloqueio temporário
- Usuário informado sem revelar critérios internos

---

## Pós-condições

- Sessões válidas e seguras
- Senha atualizada corretamente (quando aplicável)
- Tokens antigos invalidados
- Usuário corretamente autenticado ou bloqueado

---

## O que NÃO pode acontecer (P0)

- Login em conta de terceiros
- Redirecionamento incorreto após login
- Vazamento de informações sensíveis
- Recuperação de senha sem validação
- Token reutilizável ou sem expiração
- Exposição da existência de contas por e-mail
- Falha silenciosa sem feedback ao usuário

---

## Observações de QA

Este fluxo deve ser utilizado como base para:
- Testes de segurança
- Testes de autenticação e sessão
- Testes de API
- Testes de abuso (brute force)
- Testes de regressão
- Cenários BDD e automação

# Fluxo Crítico E — Matchmaking e Criação de Partida 

## Objetivo

Garantir que o processo de matchmaking da HolyClub seja **justo, seguro, previsível e consistente**, conectando apenas jogadores elegíveis, respeitando regras competitivas, critérios de pareamento e integridade da sessão.

Este é um fluxo **P0**, pois falhas afetam diretamente:
- Experiência do jogador
- Integridade competitiva
- Confiança na plataforma
- Retenção de usuários

---

## Atores Envolvidos

- Jogador autenticado
- Sistema HolyClub (Frontend + Backend)
- Serviço de Matchmaking
- Serviço de Partidas
- Steam (quando aplicável)

---

## Pré-condições

- Usuário autenticado e elegível (Fluxo Crítico A)
- Usuário não possui restrições ativas que impeçam matchmaking
- Serviço de matchmaking disponível
- Não existe partida ativa associada ao jogador

---

## Conceitos Importantes

- **Fila de Matchmaking:** Conjunto de jogadores aguardando pareamento
- **Critérios de Match:** Regras usadas para formar partidas (ELO, região, ping, modo)
- **Partida Ativa:** Jogo criado e em andamento ou em fase de preparação
- **Timeout de Fila:** Tempo máximo permitido aguardando match

---

## Fluxo Principal (Happy Path)

### E1 — Acesso ao Matchmaking
- Jogador acessa a funcionalidade de matchmaking
- Sistema exibe opções disponíveis (modo, tipo de partida, região)

**Validações QA:**
- Botão de matchmaking visível
- Nenhuma partida ativa associada ao jogador
- Estado da conta válido

---

### E2 — Solicitação de Entrada na Fila
- Jogador clica em **“Buscar Partida”**

O sistema:
- Valida novamente elegibilidade do jogador
- Valida ausência de restrições Steam e HolyClub
- Valida critérios mínimos do modo selecionado

---

### E3 — Entrada na Fila de Matchmaking
- Jogador é adicionado à fila
- Sistema inicia contagem de tempo na fila
- Feedback visual exibido ao usuário

**Exemplo de mensagem:**
> *“Buscando partida… preparando o melhor match pra você.”*

---

### E4 — Pareamento de Jogadores
O sistema:
- Analisa jogadores na fila
- Aplica critérios de pareamento:
  - ELO compatível
  - Região
  - Latência
  - Modo de jogo
- Seleciona jogadores elegíveis

**Regra de Negócio:**
> Jogadores fora dos critérios definidos não devem ser pareados, mesmo que o tempo de fila aumente, salvo regras explícitas de relaxamento progressivo.

---

### E5 — Criação da Partida
- Sistema cria a partida
- Associa jogadores à partida
- Define estado inicial (ex: `preparing`, `ready`, `live`)
- Remove jogadores da fila

---

### E6 — Redirecionamento para a Partida
- Jogadores são redirecionados corretamente
- Informações da partida são exibidas
- Sessões permanecem válidas

**Validações QA:**
- Nenhum jogador entra na partida errada
- Todos os jogadores do match estão presentes
- Dados consistentes entre frontend e backend

---

## Fluxos Alternativos e Cenários Negativos

### E7 — Jogador Inelegível
Possíveis motivos:
- Restrição HolyClub ativa
- Restrição Steam detectada
- Requisitos do modo não atendidos

**Comportamento esperado:**
- Entrada na fila bloqueada
- Mensagem clara informando o motivo

---

### E8 — Timeout de Matchmaking
- Tempo máximo de fila atingido
- Jogador removido automaticamente da fila

**Mensagem exibida:**
> *“Não encontramos uma partida compatível no momento. Tente novamente mais tarde.”*

---

### E9 — Cancelamento Manual da Fila
- Jogador cancela a busca
- Sistema remove o jogador da fila
- Nenhuma penalidade aplicada

---

### E10 — Falha na Criação da Partida
- Erro técnico ocorre durante o pareamento ou criação

**Resultado esperado:**
- Jogadores retornam ao estado anterior
- Nenhuma partida parcial criada
- Mensagem clara exibida ao usuário

---

### E11 — Desconexão Durante o Matchmaking
- Jogador perde conexão antes da criação da partida

**Comportamento esperado:**
- Jogador removido da fila
- Nenhum slot fantasma permanece ocupado

---

### E12 — Tentativa de Matchmaking com Partida Ativa
- Sistema impede nova entrada na fila
- Mensagem informativa exibida ao usuário

---

## Pós-condições

- Partida criada corretamente **ou**
- Jogador removido da fila sem inconsistências
- Nenhum jogador duplicado em filas ou partidas
- Estado do sistema consistente após falhas

---

## O que NÃO pode acontecer (P0)

- Jogador inelegível entrando em partida
- Jogador em duas filas simultâneas
- Jogador em duas partidas ao mesmo tempo
- Partida criada sem todos os jogadores necessários
- Partida fantasma sem jogadores
- Falta de feedback em caso de erro ou timeout
- Inconsistência entre estado da fila e estado da partida

---

## Observações de QA

Este fluxo deve ser utilizado como base para:
- Casos de teste manuais de matchmaking
- Testes automatizados de fila e pareamento
- Testes de concorrência
- Testes de desconexão
- Testes de regressão
- Cenários BDD relacionados a partidas e matchmaking


# Fluxo Crítico F — Abandono de Partida / AFK / Desconexão

## Objetivo

Definir como o sistema HolyClub detecta, registra e penaliza abandonos de partida, garantindo integridade competitiva, proteção aos jogadores prejudicados e evitando exploração de falhas por desconexões intencionais.

Este é um fluxo **P0**, pois impacta diretamente:
- Justiça competitiva
- Experiência dos jogadores
- Credibilidade do sistema de matchmaking e ELO

---

## Atores Envolvidos

- Jogador participante da partida
- Demais jogadores da partida
- Sistema HolyClub (Frontend + Backend)
- Serviço de Matchmaking
- Serviço de Penalidades / Fair Play

---

## Pré-condições

- Partida criada com sucesso (Fluxo Crítico E)
- Jogador confirmado na partida
- Partida em estado **Em andamento** ou **Prestígio de início confirmado**

---

## Definições Importantes

### Abandono de Partida
Considera-se abandono quando o jogador:

- Sai voluntariamente da partida
- Fecha o jogo/aplicação
- Perde conexão e não retorna dentro do tempo limite
- Permanece AFK além do tempo permitido
- Não entra na partida após a confirmação de início

> **Regra de Negócio:**  
> O sistema **não diferencia intenção**. Todo abandono é tratado como evento técnico.

---

## Fluxo Principal (Happy Path)

### F1 — Monitoramento da Partida
- O sistema monitora continuamente:
  - Conectividade
  - Presença ativa
  - Eventos de saída
  - Status AFK

---

### F2 — Detecção de Evento de Abandono
O sistema detecta um dos eventos abaixo:
- Desconexão
- Saída voluntária
- AFK prolongado
- Não comparecimento inicial

---

### F3 — Janela de Reconexão (quando aplicável)
- Sistema inicia contagem de tempo para reconexão
- Jogador é notificado (quando possível)

**Exemplo:**
> *“Você foi desconectado. Retorne à partida em até X minutos para evitar penalidades.”*

---

### F4 — Retorno Bem-sucedido
- Jogador retorna dentro do tempo limite
- Evento de abandono é descartado
- Partida segue normalmente

---

## Fluxos Alternativos e Cenários Negativos

### F5 — Abandono Confirmado
O abandono é confirmado quando:
- Jogador não retorna dentro do tempo limite
- Jogador sai voluntariamente
- AFK excede o tempo permitido

**Ações do sistema:**
- Registra abandono no histórico do jogador
- Notifica os demais jogadores
- Aplica penalidade correspondente

---

### F6 — Penalidade Aplicada
Tipos de penalidade possíveis (progressivas):

- Aviso formal
- Bloqueio temporário de matchmaking
- Bloqueio de inscrição em campeonatos
- Redução de ELO
- Restrição temporária ou permanente na HolyClub

> As penalidades devem considerar histórico recente de abandonos.

---

### F7 — Impacto no ELO
- Jogador que abandona:
  - Recebe penalidade de ELO
- Jogadores prejudicados:
  - ELO ajustado conforme regra definida
  - Proteção parcial ou total contra perda injusta

---

### F8 — Reincidência de Abandono
- Sistema identifica reincidência em janela de tempo configurável
- Penalidades escalam automaticamente

**Exemplo:**
- 1º abandono: aviso
- 2º abandono: bloqueio temporário
- 3º abandono: penalidade severa

---

## Pós-condições

- Abandono registrado corretamente
- Penalidades aplicadas e persistidas
- Histórico do jogador atualizado
- Dados disponíveis para auditoria e suporte

---

## O que NÃO pode acontecer (P0)

- Abandono não registrado
- Jogador abandonar sem penalidade
- Penalidade aplicada sem registro de evento
- Penalidade sem feedback ao jogador
- ELO ajustado incorretamente
- Exploração de desconexões para evitar derrota

---

## Mensagens ao Usuário (Exemplos)

- *“Você abandonou a partida e recebeu uma penalidade.”*
- *“Reincidência de abandono detectada. Penalidade agravada.”*
- *“Você está temporariamente impedido de entrar em partidas.”*

---

## Observações de QA

Este fluxo deve ser validado com:
- Testes de desconexão forçada
- Testes de AFK
- Testes de concorrência
- Testes de reincidência
- Testes de impacto no ELO
- Testes de persistência pós-refresh e novo login

# Fluxo Crítico G — Denúncia, Fair Play e Moderação 

## Objetivo

Definir como a HolyClub permite que jogadores denunciem comportamentos inadequados, como o sistema processa essas denúncias e como decisões de fair play são aplicadas de forma segura, auditável e justa.

Este é um fluxo **P0**, pois impacta diretamente:
- Integridade competitiva
- Confiança da comunidade
- Retenção de jogadores
- Risco legal e reputacional da plataforma

---

## Atores Envolvidos

- Jogador denunciante
- Jogador denunciado
- Sistema HolyClub (Frontend + Backend)
- Serviço de Fair Play / Moderação
- Suporte / Admin HolyClub

---

## Pré-condições

- Jogador autenticado (Fluxo B)
- Partida finalizada ou em andamento (Fluxo E ou F)
- Jogador participou da partida relacionada à denúncia

---

## Tipos de Denúncia

- Abandono de partida recorrente
- AFK intencional
- Toxicidade / assédio
- Uso de trapaças (cheat, exploit)
- Manipulação de resultado
- Comportamento antidesportivo

---

## Fluxo Principal (Happy Path)

### G1 — Acesso à Opção de Denúncia
- Jogador acessa:
  - Tela de resultados da partida **ou**
  - Perfil de um jogador da partida
- Seleciona a opção **“Denunciar jogador”**

---

### G2 — Seleção do Motivo
- Sistema apresenta lista de motivos padronizados
- Jogador seleciona um ou mais motivos
- Campo opcional para comentário adicional

> **Regra de Negócio:**  
> Denúncias devem sempre estar associadas a uma partida válida.

---

### G3 — Envio da Denúncia
- Jogador confirma o envio
- Sistema valida:
  - Participação na partida
  - Jogador denunciado
  - Integridade dos dados

---

### G4 — Registro da Denúncia
- Denúncia é registrada com:
  - ID da partida
  - ID do denunciante
  - ID do denunciado
  - Timestamp
  - Motivo(s)
  - Status inicial: **Em análise**

---

## Fluxos Alternativos e Cenários Negativos

### G5 — Denúncia Inválida
A denúncia é recusada quando:
- Jogador não participou da partida
- Tentativa de denúncia duplicada
- Partida inexistente ou inválida

**Ação do sistema:**
- Exibe mensagem de erro clara ao usuário
- Nenhum registro é criado

---

### G6 — Análise Automática (quando aplicável)
O sistema pode aplicar análise automática com base em:
- Logs de abandono
- Histórico de AFK
- Dados de desconexão
- Reincidência de denúncias

**Resultado possível:**
- Arquivamento automático
- Escalonamento para análise manual
- Aplicação direta de penalidade (casos claros)

---

### G7 — Análise Manual (Moderação)
- Moderador acessa painel administrativo
- Avalia:
  - Histórico do jogador
  - Logs da partida
  - Denúncias anteriores
- Define decisão final

---

## Decisões Possíveis

- Arquivamento da denúncia
- Aviso formal ao jogador
- Penalidade temporária
- Penalidade permanente
- Ajuste de ELO
- Restrição de funcionalidades

---

## Comunicação ao Jogador

### Jogador Denunciado
- Notificação clara e objetiva
- Motivo da penalidade (quando aplicável)
- Duração da restrição
- Canal de suporte para contestação

### Jogador Denunciante
- Confirmação de recebimento da denúncia
- Atualização quando houver decisão (quando permitido)

---

## Pós-condições

- Denúncia registrada e auditável
- Decisão aplicada corretamente
- Histórico do jogador atualizado
- Dados disponíveis para suporte e compliance

---

## O que NÃO pode acontecer (P0)

- Denúncia sem vínculo com partida
- Penalidade sem evidência registrada
- Falta de notificação ao jogador penalizado
- Exposição de identidade do denunciante
- Possibilidade de spam de denúncias
- Decisões sem log ou rastreabilidade

---

## Mensagens ao Usuário (Exemplos)

- *“Sua denúncia foi registrada e está em análise.”*
- *“Uma ação foi tomada com base na sua denúncia.”*
- *“Você recebeu uma penalidade por violar as regras de fair play.”*

---

## Observações de QA

Este fluxo deve ser validado com:
- Testes de denúncia duplicada
- Testes de denúncia inválida
- Testes de análise automática
- Testes de escalonamento manual
- Testes de reincidência
- Testes de auditoria e logs

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