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