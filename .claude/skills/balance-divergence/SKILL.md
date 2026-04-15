---
name: balance-divergence
description: Investiga e resolve divergencias entre saldo da Conta PJ (CPJ), saldo no BKO (backoffice) e saldo exibido na visao geral do ERP.
---

# Divergencia de Saldo

## Como identificar

Ocorre quando o saldo exibido em diferentes visoes do sistema nao confere. Os casos mais comuns:

| Tipo | Exemplo |
|---|---|
| CPJ != BKO | "Conta PJ: R$ 60.026,33 / BKO: R$ 0,00" |
| ERP != CPJ | "Visao geral ERP: R$ 39.912,10 / CPJ: R$ 13.404,15" |
| Saldo negativo inesperado | "Saldo ficou negativo apos transferencia" |

**Indicadores no chamado:**
- "saldo incorreto", "saldo divergente"
- Mencao a "Conta PJ", "CPJ", "BKO", "ERP", "visao geral"
- Dois valores diferentes sendo comparados
- Pedidos de "correcao" ou "ajuste" de saldo

## Dados a extrair do chamado

- **Tenant/Empresa ID:** geralmente aparece como "ID empresa: XXXXXX" ou numero isolado no inicio
- **Saldo reportado em cada visao:** CPJ, BKO, ERP
- **Diferenca entre os valores:** calcular automaticamente

## Como resolver

### Passo 1: Investigar a causa da divergencia

Possiveis causas (verificar nesta ordem):

1. **Bloqueio judicial nao registrado** → Usar skill `judicial-block`
   ```bash
   ./scripts/find_judicial_block.sh <TENANT_ID> <YEAR> <MONTH> <DAY>
   ```

2. **Transacao nao contabilizada** → Verificar extrato no cb-profile
   - Comparar extrato contabil vs extrato real
   - Identificar transacoes pendentes ou nao processadas

3. **Cache desatualizado no ERP** → Verificar se o problema persiste apos refresh
   - Saldo no BKO e a fonte de verdade
   - Se BKO esta correto mas ERP diverge, pode ser cache

4. **Saque automatico (auto_withdraw)** → Verificar config na IUGU
   - Se auto_withdraw habilitado, transferencias saem automaticamente
   - Pode gerar saldo negativo no extrato RF

### Passo 2: Acao corretiva

> **TODO:** Documentar scripts especificos para cada causa raiz.
> Por enquanto, a resolucao requer analise manual com base na causa identificada no Passo 1.

### Checklist de investigacao

- [ ] Verificar saldo no BKO (fonte de verdade)
- [ ] Verificar saldo na CPJ
- [ ] Verificar saldo no ERP/visao geral
- [ ] Buscar bloqueios judiciais no extrato
- [ ] Verificar transacoes pendentes/nao processadas
- [ ] Verificar configuracao de auto_withdraw
- [ ] Verificar se cliente e UNIFICADO ou SEGREGADO
