---
name: judicial-block
description: Identifica e reconcilia bloqueios judiciais nao registrados que causam divergencia entre saldo contabil e saldo disponivel do cliente.
---

# Bloqueio Judicial

## Como identificar

Ocorre quando uma ordem judicial bloqueia parte ou todo o saldo do cliente, mas o bloqueio nao foi registrado corretamente no sistema, gerando divergencia entre saldo disponivel e saldo contabil.

**Indicadores:**
- Saldo contabil maior que o saldo disponivel para o cliente
- Cliente reporta incapacidade de movimentar fundos apesar do saldo positivo
- Notificacao de bloqueio judicial recebida mas nao processada
- Auditoria identifica valores bloqueados nao registrados
- Mencao a "ordem judicial", "bloqueio judicial" no chamado

## Como resolver

### Scripts disponiveis

**1. `find_judicial_block.sh` - Detectar bloqueios**
```bash
./scripts/find_judicial_block.sh <TENANT_ID> <YEAR> <MONTH> <DAY>
```
- Busca o extrato via API do cb-profile
- Detecta transacoes com `transaction_type: "judicial_order"`
- Extrai `reference` (transaction ID) e `amount_cents`
- Retorna JSON estruturado com bloqueios encontrados
- Exit codes: 0 (encontrado), 1 (nao encontrado), 2 (erro)

**2. `apply_judicial_block.sh` - Aplicar bloqueios**
```bash
./scripts/apply_judicial_block.sh <TENANT_ID> <TRANSACTION_ID> <AMOUNT> [USER_ID]
```
- Converte valor para decimal (divide por 100, remove sinal negativo)
- Chama endpoint do balance-ledger:
  ```
  POST http://cb-balance-ledger.dev.contaazul.local/private-api/rest/v1/accounts/jud-block
  Headers: X-TenantId, X-UserId
  Body: {"transactionId": "<reference>", "amount": <decimal_value>}
  ```
- Exit codes: 0 (sucesso), 1 (falha), 2 (erro de parametros)

**3. `reconcile_judicial_block.sh` - Orquestrador completo**
```bash
# Dry-run (apenas detecta, nao aplica):
./scripts/reconcile_judicial_block.sh <TENANT_ID> <YEAR> <MONTH> <DAY> --dry-run

# Com confirmacao interativa:
./scripts/reconcile_judicial_block.sh <TENANT_ID> <YEAR> <MONTH> <DAY>

# Automatico (sem confirmacao):
./scripts/reconcile_judicial_block.sh <TENANT_ID> <YEAR> <MONTH> <DAY> <USER_ID> --auto-apply
```

### Workflow recomendado

1. **Extrair o TENANT_ID** da descricao do chamado (campo "ID empresa" ou numero isolado)
2. **Executar dry-run** para verificar se ha bloqueios:
   ```bash
   ./scripts/reconcile_judicial_block.sh <TENANT_ID> 2026 04 15 --dry-run
   ```
3. Se bloqueios encontrados, **aplicar com confirmacao**:
   ```bash
   ./scripts/reconcile_judicial_block.sh <TENANT_ID> 2026 04 15
   ```
4. Verificar no sistema que o saldo foi ajustado

### Exemplo pratico

**Cenario:** Ordem judicial detectada no extrato do tenant 1819905 em 05/03/2026

```bash
# Detectar
./scripts/reconcile_judicial_block.sh 1819905 2026 03 05 --dry-run

# Aplicar
./scripts/reconcile_judicial_block.sh 1819905 2026 03 05
```
