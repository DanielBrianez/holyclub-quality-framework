# 📜 Regras de Negócio Globais — HolyClub

Este documento consolida as regras de negócio essenciais para a integridade competitiva, matchmaking e sistema de punições da HolyClub.

**Convenção de IDs:**
- `RN-MM`: Regras de Matchmaking
- `RN-PEN`: Regras de Penalidades
- `RN-TS`: Regras de Trust Score
- `RN-ELO`: Regras de Pontuação/Ranking

---

## 1. Regras de Matchmaking & Lobby (Fluxo E)

O matchmaking é o coração da experiência. O objetivo é criar partidas equilibradas e justas, priorizando a qualidade sobre o tempo de fila.

| ID | Nome da Regra | Descrição / Lógica |
|:---:|:---|:---|
| **RN-MM-01** | **A Regra da "Maçã Podre"** | Ao buscar uma partida em grupo (Lobby), o sistema deve considerar o **Trust Score mais baixo** do grupo para o pareamento. <br>_Motivo: Impede que um cheater (Trust Baixo) seja carregado por amigos (Trust Alto) para estragar jogos de alto nível._ |
| **RN-MM-02** | **Limitação de Disparidade de ELO** | Jogadores em um mesmo lobby não podem ter uma diferença de ELO maior que `500 pontos` (configurável), **EXCETO** se estiverem em um lobby completo (5 jogadores). <br>_Motivo: Evita desbalanceamento, mas permite que grupos de amigos completos joguem juntos._ |
| **RN-MM-03** | **Proteção de "Cold Start"** | Contas com menos de `10 partidas` jogam exclusivamente contra outras contas novas ou com Trust Score "Neutro". <br>_Motivo: Cria um "Sandbox" para evitar que smurfs ou cheaters caiam direto contra veteranos._ |
| **RN-MM-04** | **Prioridade de Latência (Ping)** | O matchmaking deve priorizar servidores onde a média de ping de todos os jogadores seja `< 50ms`. Se não encontrar em 2 minutos, expande o critério para `< 80ms`. |

---

## 2. Regras de Penalidades & Abandono (Fluxo F e H)

Abandonar uma partida de CS2 estraga a experiência de outros 9 jogadores. As punições devem ser severas e progressivas.

| ID | Nome da Regra | Descrição / Lógica |
|:---:|:---|:---|
| **RN-PEN-01** | **Escala Exponencial de Cooldown** | O tempo de banimento por abandono deve seguir a escala: <br>1. 1ª vez: 30 min <br>2. 2ª vez: 2 horas <br>3. 3ª vez: 24 horas <br>4. 4ª vez: 7 dias <br>_Reset: A escala volta um nível a cada 7 dias sem infrações._ |
| **RN-PEN-02** | **Cancelamento Precoce (Remake)** | Se um jogador abandonar ou for detectado como AFK durante o **aquecimento** ou até o **final do 2º round**, a partida é cancelada sem perda de ELO para os presentes. O infrator recebe penalidade dobrada. |
| **RN-PEN-03** | **Vínculo de Hardware (HWID)** | Se uma conta for banida permanentemente por uso de trapaça (Cheat), o **Hardware ID** da máquina deve ser marcado. <br>_Consequência: Qualquer outra conta que logar nessa máquina terá o Trust Score drasticamente reduzido (Shadowban)._ |
| **RN-PEN-04** | **Dano a Aliados (Team Damage)** | Se um jogador causar `X` de dano a aliados ou matar aliados `3 vezes` na mesma partida, ele deve ser expulso (Kick) automaticamente e receber penalidade de abandono. |

---

## 3. Regras de Trust Score & Reputação (Fluxo I)

O sistema deve diferenciar o jogador ruim do jogador tóxico, e proteger os bons jogadores de denúncias falsas.

| ID | Nome da Regra | Descrição / Lógica |
|:---:|:---|:---|
| **RN-TS-01** | **Decaimento de Reports (Anti-Rage)** | Denúncias recebidas de jogadores que *também* possuem Trust Score baixo têm peso reduzido em 50%. <br>_Motivo: Jogadores tóxicos tendem a denunciar os outros por frustração (rage report)._ |
| **RN-TS-02** | **Bônus de Fidelidade** | Contas com mais de 1 ano de cadastro na HolyClub sem banimentos recebem um multiplicador de `1.1x` no ganho de Trust Score. |
| **RN-TS-03** | **Voto de Confiança (Overwatch)** | Se um jogador for denunciado por Cheat, mas analisado e inocentado pela moderação/IA, seu Trust Score deve receber um pequeno boost para compensar o falso-positivo. |
| **RN-TS-04** | **Silenciamento Automático (Gag)** | Jogadores com excesso de denúncias confirmadas por "Comunicação Abusiva" devem iniciar as partidas automaticamente mutados (Global Mute) para os outros jogadores. |

---

## 4. Regras de Pontuação e ELO (Geral)

Regras para garantir que o ranking reflita a habilidade real, mitigando fatores externos.

| ID | Nome da Regra | Descrição / Lógica |
|:---:|:---|:---|
| **RN-ELO-01** | **Mitigação de Derrota Desleal** | Se um time perder a partida tendo jogado com um jogador a menos (bot/leaver) por mais de 5 rounds, a perda de pontos (ELO) dos jogadores restantes é reduzida em 30%. |
| **RN-ELO-02** | **Anulação por Cheater** | Se um jogador for banido por Cheat, todas as partidas que ele jogou nas últimas 24h são anuladas (o ELO é revertido para todos os participantes, ganhadores e perdedores). |