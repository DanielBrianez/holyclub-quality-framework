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