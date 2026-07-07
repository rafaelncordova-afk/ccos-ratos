# Skill: mensagens-mensais

Gera os rascunhos de mensagem de WhatsApp para envio mensal aos clientes, por grupo de prioridade, com base nos dados de performance e no perfil de cada investidor.

## Quando usar

Início de cada mês, após receber e distribuir os PDFs do XPerformance. Disparar com `/mensagens-mensais` ou quando o Rafa pedir para montar as mensagens do mês.

## Fontes de dados

1. `projetos fami/clientes/grupos_envio_mensagens.md` — quem recebe mensagem, em qual ordem, e quais contas são vinculadas (🔗)
2. `projetos fami/clientes/tabela_clientes.md` — dados de performance (patrimônio, rentabilidade, %CDI, ganho real)
3. `projetos fami/clientes/[Nome - código]/perfil.md` — notas personalizadas de cada cliente (destacar, evitar, tom, família)

## Fluxo

1. Ler os três grupos no `grupos_envio_mensagens.md`
2. Começar pelo **Grupo 1 (fee fixo)** — prioridade de envio
3. Para cada conta principal (que não tem 🔗 apontando para outra):
   - Ler a `tabela_clientes.md` para os dados de performance
   - Se tiver contas vinculadas (🔗), ler os dados dessas também
   - Ler o `perfil.md` de todas as contas envolvidas
   - Gerar o rascunho da mensagem
   - Salvar em `projetos fami/clientes/[Nome - código]/mensagem_[mes]_[ano].md`
4. Continuar com Grupo 2 e Grupo 3

## Regras de conteúdo — o que destacar

Buscar sempre o ponto mais positivo disponível, nesta ordem de preferência:

| Situação | O que dizer |
|---|---|
| Carteira acima do CDI no período | Mencionar o percentual exato e a comparação com o CDI |
| Rentabilidade próxima de 1% ao mês | Reforçar como referência de qualidade e consistência |
| Período curto (Jan-Mês) fraco | Buscar janela de 12M ou 24M — usar a melhor que existir |
| Ganho nominal (R$) expressivo | Mencionar o valor gerado — torna o resultado concreto e tangível |
| Ganho real acima do IPCA | Reforçar a proteção do patrimônio contra a inflação |
| Vencimentos próximos | Mencionar como oportunidade de realocação em taxas melhores |

Nunca esconder um resultado ruim com linguagem vaga. Se não há nada positivo em nenhuma janela, ser honesto com leveza — contexto de mercado, estratégia de longo prazo.

## Tom e estilo

- Canal: WhatsApp — tom próximo, direto, sem formalidade excessiva
- Técnico mas claro — falar a mesma língua do investidor
- Nunca usar travessão (—)
- Sem frases genéricas de IA ("espero que esteja bem", "fico à disposição para quaisquer dúvidas")
- O texto deve soar como se o Rafa tivesse escrito — ele escreve bem, acima da média
- **Números certos, não números demais:** escolher os destaques que realmente merecem ênfase (o mais forte da hierarquia de conteúdo, geralmente 2-3 números concretos) e apresentá-los com clareza — mas dentro de uma mensagem que soa como conversa, não como relatório. O problema não é ter número, é ter número solto sem calor humano em volta.
- Priorizar proximidade JUNTO com o dado: abrir com algo pessoal quando fizer sentido (perguntar como a pessoa está, referenciar contexto de vida já registrado no perfil — mudança, reunião marcada, objetivo pessoal), e ainda assim entregar os números concretos que sustentam a boa notícia. Uma mensagem calorosa sem nenhum dado soa vaga; o objetivo é ter as duas coisas.
- Assinar sempre: `Rafael Córdova, CFP®`

## Grupo 1 — Fee Fixo (prioridade e tom especial)

- Ênfase em proximidade e relacionamento com a família do investidor
- Tom mais consultivo e personalizado
- Quando relevante, mencionar os benefícios do modelo de fee fixo (alinhamento de interesses)

## Contas vinculadas (🔗)

- Uma mensagem só, endereçada ao responsável principal
- Incluir dados de todas as contas vinculadas na mesma mensagem
- Exemplo: Tiana 8480375 cobre Tiana 4347476 e Silvana 4502419 — uma mensagem com os três resultados

## Período de referência

- Identificar o mês atual automaticamente
- Mensagem fala do retorno de **janeiro ao mês anterior**
- Exemplo: se estamos em julho → retorno de janeiro a junho (Jan-Jun)
- O campo `Rent. Jan-Mai` da tabela indica qual período está disponível nos dados

## Estrutura da mensagem

```
[Cumprimento pessoal + intenção de proximidade]

[Resultado(s) da(s) carteira(s) — usando a melhor janela disponível]
[Contexto adicional se relevante: vencimentos, realocações, mercado]

[Fechamento próximo]
Rafael Córdova, CFP®
```

## Referência de estilo

Mensagem do Marcelo + Integrasul (jun/2026) é o modelo de referência:
`projetos fami/clientes/Marcelo - 3355473/mensagem_junho_2026.md`

## Após gerar

- Confirmar quantas mensagens foram geradas e para quais grupos
- Listar os clientes que ficaram sem dados suficientes (sem PDF ou tabela incompleta)
- Perguntar se quer revisar alguma antes de enviar
