# Controle Institucional de Alocação (XP)

Fonte: material interno B2B XP — Governança de Assessores + comunicado "Evolução do Controle Institucional de Alocação" (recebido 03/07/2026)
Última atualização: 03/07/2026
Dashboard: `HUB > Menu > Gestão > Cross-sell e Diversificação > Controle Institucional de Alocações`
Atualização do dashboard: D-2 (dados do dia anterior disponíveis às 19h do dia seguinte)
Dashboard repaginado (acompanhamento histórico e status das notificações) — em implementação pela XP, ainda sem data confirmada.

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

## Novos Gatilhos — Vigência a partir de Agosto/2026

Comunicado da XP (03/07/2026): evolução do Controle Institucional de Alocação, com novos gatilhos monitorados. **Sem efeito retroativo** — aplica-se somente a alocações realizadas a partir de agosto/2026.

| Controle | Público-Alvo | Gatilho | Penalidade |
|---|---|---|---|
| **Crédito Privado (CP)** | PF e PJ | Concentração em único emissor de crédito ≥ 5% do AUC | Ver Playbook B2B |
| **Clientes 80+** | PF ≥ 80 anos | Alocação com vencimento ≥ 5 anos | Ver Playbook B2B |
| **Fundos Fechados** | PF e PJ | Concentração em único veículo de fundo fechado ≥ 10% do AUC | Ver Playbook B2B |
| **COE Emissor** | PF e PJ | Concentração em único veículo de COE ≥ 10% do AUC | Ver Playbook B2B |
| **NTN-B** | PF e PJ | Concentração ≥ 15% do AUC em vencimentos ≥ 2040 | Ver Playbook B2B |
| **COE Classe** | PF e PJ | Limite de 25% do AUC (classe COE) — trava vigente no HUB desde 2025 | Bloqueio automático — sem justificativa |
| **Emissões Bancárias** | PF e PJ | Limite de R$ 180K por emissor high yield — trava vigente no HUB desde 2025 | Bloqueio automático — sem justificativa |

### Regras dos novos gatilhos

- **Justificativa:** possível para todos, exceto as travas (COE Classe e Emissões Bancárias), via **Gopliance!**, prazo de **5 dias** após a notificação.
- **AUC considerado (gatilhos com justificativa):** soma do AUC XP (todas as marcas e contas) + OPIN, na data da alocação/liquidação.
- **AUC considerado (travas — COE Classe e Emissões Bancárias):** AUC XP Brasil, **sem exceção**.
- **Treinamento obrigatório** na Gopliance!, prazo de **60 dias** com aceite registrado. Após o prazo, possível bloqueio de acesso.
- **Descumprimento:** penalidade ao escritório (mesmo modelo do Regulamento de Auditoria de AI). Pode gerar inelegibilidade em rankings, campanhas, missões e Selos.
- **Referência completa:** Playbook B2B (acesso via e-mail de domínio agentinvest) — traz fundamentação técnica, modelos de auditoria aceitos e procedimentos operacionais.
- **Dúvidas:** gov-ass-qualidade@xpi.com.br
- Reforço contínuo previsto em: Kickoffs mensais, Investor Monday, Conselho de Compliance com gestores.

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
| Dúvidas | HUB > Chat > Atendimento B2B (geral) / gov-ass-qualidade@xpi.com.br (novos gatilhos) |
| Novos gatilhos valem para operações já feitas? | Não — só alocações a partir de agosto/2026 |
| Onde estão as regras completas dos novos gatilhos? | Playbook B2B (acesso via e-mail domínio agentinvest) |

---

Ver também: [filtro de carteiras por risco de alocação controlada](filtro_carteiras_alocacao.md)
