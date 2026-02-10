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

# Fluxo Crítico C — Inscrição em Campeonato 🏆

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