# Filtro de Carteiras — Controle Institucional de Alocação

Última atualização: 16/06/2026
Fonte: HUB > Gestão > Cross-sell e Diversificação > Controle Institucional de Alocações (D-2)

> Preencher mensalmente ou antes de qualquer operação relevante nas áreas monitoradas.
> Campos marcados com (HUB) devem ser consultados diretamente no dashboard.

---

## 1. Clientes PJ — Risco: Ativos Incentivados

**Regra:** Nunca alocar LCI, LCA, CRI, CRA ou Debêntures Incentivadas para PJ sem antes verificar a taxa de **gross-up** no HUB.
Penalidade: 100% do ROA por evento. Exceção: PJ em Lucro Real com declaração do contador ou ECF.

| Cliente | Código | Custódia mín. R$50K? | Regime Tributário | Gross-up disponível | Observação |
|---|---|---|---|---|---|
| Integrasul | 3424140 | Sim (R$9,3MM) | _verificar_ | HUB | PJ confirmada — fee fixo |
| Artecasa | 2978828 | Sim (R$931K) | _verificar_ | HUB | PJ confirmada — fee fixo |
| Francisco Ricardo LTDA | 19119719 | Sim (R$363K) | _verificar_ | HUB | PJ confirmada — fee fixo |
| Globus | 9416824 | _verificar_ | _verificar_ | HUB | Nome sugere PJ — confirmar |
| Servitec | 3342459 | _verificar_ | _verificar_ | HUB | Nome sugere PJ — confirmar |
| CS Administracao | 15734244 | _verificar_ | _verificar_ | HUB | Nome sugere PJ — confirmar |
| Perfetti | 14398910 | _verificar_ | _verificar_ | HUB | Nome sugere PJ — confirmar |

> Para PJ em Lucro Real: aceita justificativa via modelo de e-mail do Playbook + consentimento do cliente.

---

## 2. Previdência XP — Risco: Resgate Indevido

**Regra:** Resgate PGBL ou VGBL acima de R$100K com ≥30% do valor em alíquota ≥15% → penalidade de 2% do volume resgatado.
Recomendação: previdência é o **último recurso** da carteira; orientar sempre antes do resgate.
Desde Lei 14.803/24: opção de regime (progressivo/regressivo) é feita no **primeiro resgate** — confirmar antes.

| Cliente | Código | Tipo | Valor aprox. (HUB) | Regime | Alíquota atual | Retratável? | Observação |
|---|---|---|---|---|---|---|---|
| Fernanda | 8227409 | PGBL/VGBL | _verificar_ | _verificar_ | _verificar_ | _verificar_ | Tem previdência BB (~R$300K fora XP) |
| _(demais clientes com previdência XP)_ | | | | | | | _(preencher via HUB)_ |

> Verificar no HUB clientes com previdência XP e alíquota atual ≥15%. Identificar os "Retratáveis" antes de qualquer movimentação.

---

## 3. Fundos com Carência — Risco: Flipagem

**Regra B3:** não vender cotas de Fundos Listados na B3 em até **1 mês** após o fim do lockup.
**Regra Balcão:** não vender Fundos de Balcão em até **6 meses** após a aquisição.
Penalidade: 100% do ROA por evento.

| Cliente | Código | Fundo | Tipo | Data Aquisição | Livre a partir de | Status |
|---|---|---|---|---|---|---|
| _(preencher via HUB ao fazer qualquer operação em fundos)_ | | | | | | |

> Antes de qualquer resgate de fundo, verificar a data de aquisição no HUB e calcular a carência.
> B3: data livre = data fim do lockup + 1 mês
> Balcão: data livre = data de aquisição + 6 meses

---

## 4. COE — Risco: Sobrealimentação

**Regra:** exposição ao emissor entre 2,5% e 30% do PL do cliente (conforme rating).
**Novo controle (em implementação):** máximo 25% do PL total por cliente em COE.
Bloqueio automático pré-trade para clientes **>70 anos**.

| Cliente | Código | PL XP (HUB) | Valor COE | % do PL | Limite p/ rating | Status | Idade >70? |
|---|---|---|---|---|---|---|---|
| _(preencher via HUB para clientes com COE em carteira)_ | | | | | | | |

> PL considerado = PL XP + Open Finance + XP Internacional (posição final do mês).
> Verificar rating do emissor no HUB para definir o limite exato (varia entre 2,5% e 30%).

---

## 5. Recompra RF — Risco: Rolagem Inversa

**Regra:** só realocar renda fixa se a nova taxa for **superior à taxa de VENDA** do ativo atual (não à de compra).
Proibido: mesmo papel + mesmo vencimento + taxa inferior à de venda.
Não há justificativa aceita para esse tipo de operação.

> Verificar sempre no HUB a **taxa de venda atual** antes de sugerir realocação de RF.
> Ferramenta de gross-up do HUB mostra a comparação correta.

Clientes com RF de longo prazo (maior risco de tentação de rolagem em cenário de abertura de taxas):

| Cliente | Código | Ativo RF principal | Taxa compra | Taxa venda atual (HUB) | Observação |
|---|---|---|---|---|---|
| Integrasul | 3424140 | vários vencimentos jul-set/2026 | _verificar_ | _verificar_ | Vencimentos próximos — oportunidade de realocação |
| _(demais clientes com RF longa)_ | | | | | |

---

## Checklist Rápido — Antes de Executar uma Operação

- [ ] Cliente é PJ? → verificar gross-up antes de qualquer ativo incentivado
- [ ] Operação envolve fundo? → verificar data de aquisição (carência B3: 1 mês / Balcão: 6 meses)
- [ ] Operação envolve COE? → verificar % do PL e idade do cliente
- [ ] Operação envolve realocação de RF? → comparar com taxa de VENDA (não de compra)
- [ ] Cliente vai resgatar previdência? → confirmar alíquota, regime e se é "Retratável"

---

Ver também: [resumo das regras de alocação controlada](resumo_controle_alocacao.md)
