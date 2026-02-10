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