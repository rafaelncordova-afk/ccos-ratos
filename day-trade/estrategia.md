# Estratégia de Day Trade — Fluxo Institucional + Tendência

Projeto pessoal, em construção com o tio do Rafa (especialista em fluxo de ordens). Objetivo: sinalizar entradas de day trade em contratos futuros (WDO/WIN), sem automatizar o envio da ordem — o sistema avisa, Rafa decide e manda manualmente.

## Status: rascunho v2 — aguardando validação de números com o tio e testes no Profit

## Filosofia
Menos operações, mais seletivas. Só sinaliza quando tendência de curto prazo (médias móveis) e fluxo de grandes players (volume) apontam pro mesmo lado. Prioriza taxa de acerto sobre volume de operações.

## Configuração da estratégia

### Contrato
- Começar com um único contrato: **WDO** (mini dólar) — leitura de fluxo mais limpa que WIN
- Expandir pra WIN depois de validar

### Módulo de tendência
- EMA 9 e EMA 21 (períodos a confirmar com backtest)
- Alta: preço acima das duas EMAs e EMA9 > EMA21
- Baixa: preço abaixo das duas EMAs e EMA9 < EMA21
- Lateral (EMAs entrelaçadas): não sinaliza

### Módulo de fluxo institucional
- Proxy programável: volume do candle acima de X vezes a média de volume (ex: 3x a média de 20 candles) — versão automatizável em NTSL
- Versões mais refinadas (tape reading tick a tick, identificação de corretora/player) exigiriam programa externo via Profit API — não automatizável em NTSL puro, ficou fora da v1/v2

### Regra de sinal
- Só sinaliza quando os dois módulos concordam: tendência de alta + volume forte = sinal de compra; tendência de baixa + volume forte = sinal de venda
- **Sem envio automático de ordem** — Rafa confirma e manda manualmente

### Stop loss e alvo (a calibrar)
- Pensado como técnico (abaixo/acima de topo ou fundo recente) com teto máximo em pontos
- Relação risco:retorno mínima sugerida: 1:1,5 a 1:2
- Números exatos ainda não calibrados — depende de backtest real no Profit, não de referência de blog

### Gestão de risco (a validar com o tio)
- Risco por operação: prática de mercado geral é 1-2% do capital, no máximo 3%
- Máximo de 2-3 operações por dia
- Stop diário e meta diária — como o envio é manual, o controle fica na mão do Rafa (não depende do NTSL, que tem limitação conhecida nisso — ver seção "Notas técnicas")
- Capital mínimo sugerido por praticantes: R$ 5-10 mil pra operar WIN/WDO com gestão adequada (referência de mercado, não validado com dados próprios)

### Janela de operação
- Foco na abertura (09:00–10:00)

### Filtros de exclusão
- Dias de divulgação de dados de alto impacto (Copom, payroll) — fora da v1
- Véspera de feriado prolongado — fora da v1

## Perguntas pendentes pro tio
- [ ] Quantos contratos por operação?
- [ ] Stop loss em quantos pontos (ou é dinâmico, baseado em topo/fundo)?
- [ ] Alvo: pontos fixos, trailing, ou "sai quando sente que acabou o movimento"?
- [ ] O threshold de "volume grande" que eles usam de fato é baseado em volume agregado do candle, tamanho de negociação individual (tape) ou identificação de corretora/player? (confirmado: é candle → decisão já tomada, seguir com NTSL puro)
- [ ] Confirmar períodos exatos das médias móveis usadas (assumido EMA9/EMA21 como placeholder)

## Decisões já tomadas
- **Arquitetura**: sinal/alerta, não automação de ordem — reduz risco técnico e de compliance
- **Plataforma**: Profit (Nelogica), via NTSL, modelo de estratégia "Alarme"/"Indicador" (não "Execução")
- **Corretora**: XP (grupo XP — Fami é ligada à XP). Considerado também Clear (corretagem zero, condição de gratuidade do Profit historicamente mais fácil de bater) e Rico, mas Rafa optou por ficar na XP
- **Custo da plataforma**: XP tem campanha promocional "Uptrade" — Profit gratuito por até 3 meses operando 1 minicontrato/mês com RLP ativo. **Atenção: é temporário, não permanente.** Depois disso volta à regra padrão (~200 minicontratos/mês ou R$139,90/mês)

## Pendência importante antes de contratar a plataforma
Confirmar direto com o suporte da XP:
1. Se a campanha de 1 minicontrato libera **Profit Trader** ou **Profit Pro**
2. Se o Profit Trader (versão básica) permite rodar um script de Alarme/Indicador NTSL **ao vivo** no gráfico (não só em backtest) sem precisar do módulo de Automação de Estratégias pago (esse módulo parece ser só pra quem envia ordem automática de verdade — não é o nosso caso, mas vale confirmar)

## Notas técnicas (limitações conhecidas do NTSL)
- Controle preciso de resultado/operações do dia via código (`DailyResult`) tem bug relatado e a própria comunidade oficial reconhece limitação em tempo real (funciona em backtest, falha ao vivo em alguns casos) — por isso a decisão de manter o controle de risco diário manual, já que o envio da ordem também é manual
- Sintaxe do NTSL tem variações entre versões (função clássica `BuyAtMarket` vs estilo EasyLanguage `Buy("Nome") N contracts next bar at market`) — não usado na v2 porque não estamos automatizando envio de ordem, mas registrar caso avancemos pra automação real no futuro

## Referências
- Manual NTSL (Nelogica): https://downloadserver-cdn.nelogica.com.br/content/profit/manual_ntsl/ManualNTSL.pdf
- Central de ajuda NTSL: https://ajuda.nelogica.com.br/hc/pt-br/articles/360046443212
- Comparativo de plataformas XP: https://web.xpi.com.br/xp/documentos/comparativo-de-plataformas/

## Próximos passos
1. Levantar com o tio os números pendentes (lista acima)
2. Confirmar com suporte XP a questão Profit Trader x Profit Pro pro nosso caso de uso
3. Atualizar o código NTSL (`alerta_tendencia_volume.ntsl`) com os números reais
4. Testar/backtest no Profit
5. Rodar em observação (sinal ao vivo, sem operar) por um período antes de usar de verdade
