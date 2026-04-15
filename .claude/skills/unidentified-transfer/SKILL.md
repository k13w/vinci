---
name: unidentified-transfer
description: Investiga transferencias que nao podem ser vinculadas a faturas/cobrancas e problemas de saldo negativo no extrato RF causados por saque automatico.
---

# Transferencia Nao Identificada / Saldo RF

## Como identificar

Ocorre quando:
- Uma transferencia foi realizada mas nao se sabe a quais faturas/cobrancas ela se refere
- O saldo do extrato RF ficou negativo apos uma transferencia
- O saque automatico (auto_withdraw) esta gerando saidas inesperadas

**Indicadores no chamado:**
- "nao conseguimos identificar de quais faturas"
- "transferencia realizada para banco X"
- "saldo do extrato RF ficou negativo"
- "saque automatico", "auto_withdraw"
- Mencao a banco externo (CORA, Bradesco, etc.) como destino

## Dados a extrair do chamado

- **Tenant/Empresa ID:** "ID empresa: XXXXXX"
- **Valor da transferencia:** ex: "R$ 4.793,62"
- **Data da transferencia:** ex: "dia 13/04/26"
- **Banco destino:** ex: "CORA"
- **Tipo de conta:** UNIFICADO ou SEGREGADO (se mencionado)

## Como resolver

### Passo 1: Entender o contexto

O relacionamento entre cobrancas e transferencias e processado sobre o extrato financeiro do fornecedor. Nem sempre e possivel identificar essa relacao diretamente.

**Pontos a verificar:**
1. Cliente e UNIFICADO ou SEGREGADO?
2. Qual a conta de recebimento atual? (CPJ, CORA, etc.)
3. O auto_withdraw esta habilitado na IUGU?
4. As compensacoes estao passando pela CPJ antes de ir para o banco destino?

### Passo 2: Diagnostico

| Situacao | Causa provavel | Acao |
|---|---|---|
| Cliente UNIFICADO + auto_withdraw habilitado | Cobrancas compensam na CPJ e saque automatico envia para banco domicilio | Verificar se o saldo RF reflete corretamente as saidas |
| Transferencia sem faturas associadas | Relacionamento cobranca-transferencia nao processado | Analise manual do extrato financeiro do fornecedor |
| Saldo RF negativo apos transferencia | Saida registrada no RF sem entrada correspondente | Verificar se a entrada foi registrada em outra conta |

### Passo 3: Acao corretiva

> **TODO:** Documentar scripts para:
> - Consultar configuracao de auto_withdraw na IUGU
> - Consultar extrato financeiro do fornecedor
> - Vincular transferencias a cobrancas manualmente

### Checklist de investigacao

- [ ] Identificar o tenant e o valor da transferencia
- [ ] Verificar tipo de conta (UNIFICADO/SEGREGADO)
- [ ] Verificar conta de recebimento atual
- [ ] Verificar se auto_withdraw esta habilitado
- [ ] Consultar extrato do RF na data da transferencia
- [ ] Consultar extrato da CPJ na mesma data
- [ ] Identificar se ha descompasso entre entradas e saidas
