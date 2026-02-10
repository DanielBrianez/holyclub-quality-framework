# Mapa Geral — Fluxos Críticos da HolyClub 🧭

## Objetivo do Documento

Este documento consolida **todos os fluxos críticos (P0)** da plataforma HolyClub, servindo como:
- Visão macro do produto
- Guia de navegação da documentação
- Base para QA, desenvolvimento, arquitetura e auditoria

Cada fluxo representa uma cadeia essencial para o funcionamento seguro, competitivo e confiável da plataforma.

---

## Visão Geral dos Fluxos

| Código | Fluxo | Descrição Resumida |
|------|------|--------------------|
| A | Criação de Perfil | Criação inicial de conta e vínculo com Steam |
| B | Autenticação & Login | Login seguro, sessão e validações de acesso |
| C | Inscrição em Campeonato | Elegibilidade e controle de inscrições |
| D | Recuperação de Senha | Segurança de autenticação e recuperação |
| E | Criação & Entrada em Partida | Matchmaking e início de partidas |
| F | Abandono de Partida | AFK, desconexões e penalidades automáticas |
| G | Denúncias de Jogadores | Reportes e geração de eventos de fair play |
| H | Penalidades & Recursos | Contestação, moderação e auditoria |
| I | Reputação & Trust Score | Consolidação histórica e decisões sistêmicas |

---

## Dependência Entre Fluxos

```text
Fluxo A
  ↓
Fluxo B
  ↓
Fluxo E ───────────────┐
  ↓                    │
Fluxo F                │
  ↓                    │
Fluxo G                │
  ↓                    │
Fluxo H                │
  ↓                    │
Fluxo I ◄──────────────┘

Fluxo C depende de:
- Fluxo A
- Fluxo B
- Fluxo I

Fluxo D é transversal e impacta:
- Fluxo B

### Fluxo I — Histórico, Reputação e Trust Score 📊
- Consolida comportamento e histórico do jogador
- Impacta matchmaking, penalidades e acesso a campeonatos
- Depende dos Fluxos E, F, G e H