---
name: support-triage
description: Triagem automatica de chamados do component core-banking-gestao-contas. Mapeia sintomas do chamado para o cenario de resolucao correto.
---

# Triagem de Chamados - Core Banking Gestao de Contas

## Quando usar
Use esta skill como primeiro passo ao processar qualquer chamado do component `core-banking-gestao-contas`. Ela identifica qual cenario se aplica e direciona para a skill de resolucao correta.

## Mapa de cenarios

| Palavras-chave no chamado | Cenario | Skill |
|---|---|---|
| "bloqueio judicial", "ordem judicial", "judicial", "bloqueio" | Bloqueio Judicial | `judicial-block` |
| "saldo incorreto", "saldo divergente", "saldo CPJ", "saldo BKO", "saldo ERP", "visao geral" | Divergencia de Saldo | `balance-divergence` |
| "transferencia nao identificada", "nao conseguimos identificar", "quais faturas", "extrato RF negativo", "saque automatico" | Transferencia Nao Identificada / Saldo RF | `unidentified-transfer` |

## Como usar no fluxo automatizado

1. Leia o titulo e descricao do chamado
2. Compare com as palavras-chave da tabela acima
3. Carregue a SKILL.md do cenario correspondente em `.claude/skills/<skill>/SKILL.md`
4. Se nenhum cenario corresponder, classifique como "cenario desconhecido"

## Regras de priorizacao

- Se o chamado mencionar mais de um cenario, priorize pelo que aparece primeiro na descricao
- Se houver duvida entre cenarios, inclua ambos na analise
- Chamados reabertos (mencionam "reabrindo", "reaberto") podem ter contexto adicional nos comentarios — leia-os
