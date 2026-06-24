# Controle Institucional de Alocação (XP)

Fonte: material interno B2B XP — Governança de Assessores
Última atualização: 16/06/2026
Dashboard: `HUB > Menu > Gestão > Cross-sell e Diversificação > Controle Institucional de Alocações`
Atualização do dashboard: D-2 (dados do dia anterior disponíveis às 19h do dia seguinte)

---

## Conceito

A área de Compliance monitora continuamente alocações que fujam dos padrões da XP (Alocações Controladas).
- Apenas operações **intermediadas pelo assessor** são monitoradas — operações self-service do cliente são desconsideradas.
- Somente **novas alocações** (não retroativo para o estoque).
- Monitoramento por **conta** (não por cliente consolidado).
- Justificativas pelo próprio assessor via plataforma.

---

## Alocações Controladas — Tabela de Gatilhos e Penalidades

| Controle | Público-Alvo | Gatilho | Penalidade |
|---|---|---|---|
| **Ativos Incentivados** (LCI, LCA, CRI, CRA, Debêntures Incentivadas) | PJ com custódia ≥ R$ 50K | PJ comprando ativo isento de IR (isenção é exclusiva de PF) | 100% do ROA por evento |
| **Recompra RF – Rolagem Inversa** | PF e PJ | Venda de título + recompra do mesmo com vencimento igual e taxa **menor** que a de venda | 100% do ROA por evento |
| **Flipagem IPO / Follow On B3** | PF e PJ | Venda de cotas de Fundos Listados na B3 em até **1 mês** após o fim do lockup | 100% do ROA por evento |
| **Flipagem de Fundos Balcão** | PF e PJ | Venda de Fundos de Balcão em até **6 meses** após a aquisição | 100% do ROA por evento |
| **Previdência PGBL** | PF | Resgate > R$ 100K com ≥ 30% do valor em alíquota ≥ 15% | 2% do volume resgatado indevidamente |
| **Previdência VGBL** | PF | Mesma regra acima | 2% do volume resgatado indevidamente |

> Multa é **por cliente** — cada justificativa recusada gera penalidade individual.

---

## Controles Pré-Trade (COE)

- Bloqueio automático se a operação exceder o limite de exposição ao emissor (2,5% a 30% do PL, conforme rating de crédito)
- Bloqueio automático para clientes **> 70 anos**
- Em desenvolvimento: limite máximo de **25% do PL total** por cliente em COE

---

## Por que cada controle existe?

### 1. Ativos Incentivados — PJ comprando isento
LCI, LCA, CRI, CRA e Debêntures Incentivadas não têm isenção de IR para PJ. A isenção é exclusiva de PF.
Uma PJ comprando ativo isento contrata retorno inferior ao risco assumido — alocação inadequada.
**Regra prática:** sempre verificar a **taxa de gross-up** no HUB antes de sugerir ativo incentivado para PJ.
> Exceção: PJ em Lucro Real pode justificar via declaração do contador ou ECF.

### 2. Recompra RF — Rolagem Inversa
Ao realocar renda fixa, a nova taxa deve ser comparada com a **taxa de VENDA** (não de compra).
**Exemplo:** comprou IPCA+4%, mercado atual está pagando IPCA+6% (taxa de venda). Só vale realocar se a nova taxa for superior a IPCA+6%.
Nunca tem justificativa para: mesmo papel + mesmo vencimento + taxa inferior à de venda.

### 3. Flipagem de IPO e Fundos Listados B3
Fundos em estágio inicial ainda estão investindo os recursos captados — carregamento abaixo do potencial.
Vender nesse período prejudica o cliente (preço inferior à oferta) e impacta negativamente o mercado.

### 4. Flipagem de Fundos de Balcão
Mesma lógica: fundos de renda precisam de tempo para carregar; a permanência proporciona melhor experiência.

### 5 e 6. Resgate de Previdência PGBL e VGBL
- Antes de 8 anos de aplicação → carga tributária elevada.
- **PGBL:** IR incide sobre o **total investido** (não só rendimentos).
- **VGBL:** deve ser o **último recurso** da carteira.
- Desde Lei 14.803/24: opção de regime (progressivo/regressivo) feita no **primeiro resgate** — essencial orientar o cliente antes.
- Clientes com planos pré-10/01/2024 sem resgate ainda podem alterar o regime até a primeira movimentação (identificados como "Retratáveis" no HUB).

---

## Fluxo de Tratativas

1. Compliance identifica alocação controlada → notifica o assessor
2. Assessor tem prazo determinado para apresentar justificativa
3. Justificativa aceita → arquivado
4. Justificativa não aceita ou não apresentada → penalidade aplicada
5. Assessor não é penalizado se comprovar que a ordem foi originada diretamente pelo cliente (com evidências)

---

## Justificativas e Evidências

| Situação | Evidência aceita |
|---|---|
| Cliente com PL adicional em outro banco | Extrato Financeiro Oficial ou Open Finance (não balanço patrimonial) |
| PJ comprando ativo isento (Lucro Real) | Declaração assinada pelo contador ou ECF |
| Ordem originada diretamente pelo cliente | Comprovação de autoria pelo cliente |
| Previdência por emergência | Justificativa via plataforma — assessor tem oportunidade de não ser penalizado |
| De acordo do cliente | Pode ser coletado **após** a operação (apenas para Alocação Controlada — NÃO para Auditoria de Ordens) |

---

## FAQ Resumido

| Pergunta | Resposta |
|---|---|
| Controle é só para R$300K+? | Não — aplica-se a todos, conforme o público-alvo de cada gatilho |
| Atinge o estoque? | Não — somente novas alocações |
| PL considerado | PL XP + Open Finance + XP Internacional (posição final do mês) |
| Multa por notificação ou por cliente? | Por **cliente** — cada justificativa recusada = penalidade individual |
| Cliente > 70 anos e COE? | Operação automaticamente bloqueada pré-trade |
| Dúvidas | HUB > Chat > Atendimento B2B |

---

Ver também: [filtro de carteiras por risco de alocação controlada](filtro_carteiras_alocacao.md)
