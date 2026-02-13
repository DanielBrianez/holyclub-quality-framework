# language: pt
Funcionalidade: Matchmaking e Sistema de Confiança (Trust Score)
  Como um jogador competitivo
  Quero ser pareado com jogadores de nível e comportamento similares
  Para que as partidas sejam justas e livres de toxicidade

  Contexto:
    Dado que o sistema de matchmaking está ativo

  @RN-MM-01 @Critico @Matchmaking
  Cenario: Aplicar regra da "Maçã Podre" em Lobby misto
    O sistema deve nivelar o lobby por baixo para evitar "boosting" por cheaters.

    Dado que o jogador "Sombra" tem Trust Score "Excellent"
    E o jogador "Tóxico_01" tem Trust Score "Restricted"
    Quando eles formam um lobby juntos para buscar partida
    Então o sistema deve considerar o Trust Score do lobby como "Restricted"
    E o pareamento deve buscar oponentes com status "Restricted" ou inferior

  @RN-MM-03 @AntiSmurf
  Cenario: Sandbox para contas novas (Cold Start)
    Contas novas não devem jogar contra veteranos imediatamente.

    Dado que o jogador "Novato_Steam" possui apenas 5 partidas jogadas
    Quando ele iniciar a busca por uma partida casual
    Então o sistema deve restringir a busca apenas a outros jogadores com menos de 10 partidas
    E jogadores com Trust Score "Neutral"

  @RN-PEN-01 @Penalidade
  Esquema do Cenario: Escala progressiva de banimento por abandono
    A punição deve aumentar conforme a reincidência.

    Dado que o jogador "Leaver" possui <reincidencia> abandonos prévios ativos
    Quando ele abandonar uma partida em andamento
    Então ele deve receber um banimento temporário de <tempo_banimento>

    Exemplos:
      | reincidencia | tempo_banimento |
      | 0            | 30 minutos      |
      | 1            | 2 horas         |
      | 2            | 24 horas        |
      | 3            | 7 dias          |

  @RN-PEN-03 @Seguranca @HWID
  Cenario: Bloqueio de Hardware (Shadowban)
    Se um PC foi usado para cheat, outras contas nele devem ser penalizadas.

    Dado que a máquina com HWID "PC-X99" teve uma conta banida por Cheat permanentemente
    Quando o jogador "Inocente_Fake" logar nesta mesma máquina "PC-X99"
    Então o sistema deve identificar o vínculo de hardware
    E alterar o Trust Score da conta "Inocente_Fake" para "Suspicious" imediatamente