# Plano de Automacao Jira - Auto-Transicao de Issues para "Em Andamento"

## Objetivo

Automatizar a transicao de issues do tipo **Chamado** no projeto **CHAMADO** (Suporte) do Jira para que, ao serem criadas no status "Tarefas pendentes", sejam movidas automaticamente para o status **"Em andamento"**.

---

## Contexto

- **Organizacao:** ContaAzul
- **Jira URL:** `https://contaazul.atlassian.net`
- **Projeto:** `CHAMADO` (nome: Suporte)
- **Tipo de Issue:** Chamado
- **Status Inicial:** Tarefas pendentes
- **Status Destino:** Em andamento
- **Transicao ID:** `151` (Iniciar Atendimento)
- **Board:** https://contaazul.atlassian.net/jira/software/c/projects/AZUL/boards/1421
- **Usuario:** gilmar.filho@contaazul.com
- **Ferramenta:** MCP Atlassian (`mcp-atlassian`) via Claude Code
- **Data:** 2026-04-15

---

## Configuracao do MCP

Arquivo `.mcp.json` criado em `/Users/gilmar.filho/Documents/vinci/.mcp.json`:

```json
{
  "mcpServers": {
    "mcp-atlassian": {
      "type": "stdio",
      "command": "docker",
      "args": [
        "run", "-i", "--rm",
        "-e", "CONFLUENCE_URL",
        "-e", "CONFLUENCE_USERNAME",
        "-e", "CONFLUENCE_API_TOKEN",
        "-e", "JIRA_URL",
        "-e", "JIRA_USERNAME",
        "-e", "JIRA_API_TOKEN",
        "ghcr.io/sooperset/mcp-atlassian:latest"
      ],
      "env": {
        "CONFLUENCE_URL": "https://contaazul.atlassian.net/wiki",
        "CONFLUENCE_USERNAME": "gilmar.filho@contaazul.com",
        "CONFLUENCE_API_TOKEN": "${input:confluence-api-token}",
        "JIRA_URL": "https://contaazul.atlassian.net",
        "JIRA_USERNAME": "gilmar.filho@contaazul.com",
        "JIRA_API_TOKEN": "${input:jira-api-token}"
      }
    }
  }
}
```

---

## Plano de Acao

### Etapa 1: Reiniciar Sessao e Validar MCP
**Objetivo:** Confirmar que o MCP Atlassian esta conectado e funcional.

- Reiniciar o Claude Code (para carregar o `.mcp.json`)
- O Claude Code pedira os API tokens interativamente
- Testar a ferramenta `searchJiraIssuesUsingJql` com:
  ```
  project = CHAMADO AND type = Chamado AND status = "Tarefas pendentes" ORDER BY created DESC
  ```
- Validar que retorna issues corretamente

### Etapa 2: Mapear Workflow do Projeto CHAMADO
**Objetivo:** Identificar os IDs de transicao disponiveis.

- Pegar uma issue existente do projeto CHAMADO
- Usar `getTransitionsForJiraIssue` para listar transicoes disponiveis
- Resultado mapeado:
  - **ID `151`** - "Iniciar Atendimento" → "Em andamento" (sem tela, execucao direta)
  - ID `341` - "Comentar Zendesk" → "Tarefas pendentes" (loop)
  - ID `261` - "Trocar Responsavel" → "Tarefas pendentes" (loop)
  - ID `41` - "Finalizar Chamado" → "Concluido"

### Etapa 3: Testar Transicao Manual
**Objetivo:** Validar que a transicao funciona via MCP.

- Selecionar uma issue de teste no status "Tarefas pendentes"
- Executar `transitionJiraIssue` com transicao ID `151`
- Confirmar no Jira que o status mudou para "Em andamento"
- **Testado com sucesso:** CHAMADO-65984 transicionado em 2026-04-15

### Etapa 4: Configurar Agendamento Automatico
**Objetivo:** Criar um agente agendado que roda periodicamente.

- Usar o recurso de **schedule/cron** do Claude Code
- Intervalo: **a cada 1 minuto**
- O agente agendado ira:
  1. Buscar issues com JQL:
     ```
     project = CHAMADO AND type = Chamado AND component = "core-banking-gestao-contas" AND statusCategory = "Itens Pendentes" ORDER BY created ASC
     ```
  2. Para cada issue encontrada com status "Tarefas pendentes", executar a transicao ID `151` ("Iniciar Atendimento") para "Em andamento"
  3. Logar as issues transicionadas

> **Nota (2026-04-15):** O JQL original usava `status = "Tarefas pendentes"`, mas ao combinar com o filtro `component`, a API retornava 0 resultados (bug do MCP/JQL). A solucao foi usar `statusCategory = "Itens Pendentes"` que funciona corretamente.

### Etapa 5: Validacao Final
**Objetivo:** Garantir que a automacao funciona de ponta a ponta.

- Criar uma issue de teste tipo "Chamado" no projeto CHAMADO
- Aguardar o proximo ciclo do cron
- Verificar se foi transicionada automaticamente

---

## Riscos e Mitigacoes

| Risco | Mitigacao |
|-------|-----------|
| Transicionar issue que nao deveria | JQL filtra por `project = CHAMADO AND type = Chamado AND component = "core-banking-gestao-contas"` |
| MCP server desconectado | Monitoramento via logs do cron |
| Rate limit da API Jira | Intervalo de 10 min entre execucoes |
| Nome do tipo "Suporte" diferente | Mapeado: tipo real e "Chamado", projeto "CHAMADO" |
| Status "To Do" com nome diferente | Mapeado: status real e "Tarefas pendentes" |
| JQL `status + component` retorna 0 | Usar `statusCategory = "Itens Pendentes"` em vez de `status = "Tarefas pendentes"` |

---

## Proximo Passo Imediato

Etapas 1-5 concluidas com sucesso. Cron corrigido e ativo (job ID: `a0627771`).

### Historico de execucao (2026-04-15):
- **Cron v1** (`beee0bd7`): JQL com `status = "Tarefas pendentes"` — retornava 0 resultados (bug)
- **Cron v2** (`a0627771`): JQL corrigido com `statusCategory = "Itens Pendentes"` — funcional
- **Issues transicionadas manualmente:** CHAMADO-66084, CHAMADO-66081
