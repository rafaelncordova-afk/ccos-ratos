# Controle de Comissoes -- Fev/2026

Fonte: relatorio XP (CSV) | Referencia: Comissao Liquida (apos repasse)
Gerado automaticamente + ajuste manual em: 22/06/2026

> Nota: valores do script base corrigidos manualmente para itens nao capturados automaticamente.
> Ver secao "Ajustes manuais" para detalhes.

---

## RESUMO EXECUTIVO

| Bloco | Liquido |
|---|---|
| **Recorrente (A)** | **R$ 10.402** |
| Semirrecorrente (B) | R$ 10.742 |
| Nao Recorrente (C) | R$ 64 |
| **TOTAL BRUTO** | **R$ 21.208** |
| Deducoes (saude + multa) | - R$ 1.166 |
| **TOTAL LIQUIDO** | **R$ 20.042** |
| **Total sem campanhas** | **R$ 20.042** |

> % Recorrente: **51,9%** | Sem campanhas: **51,9%** (sem campanhas em fevereiro)

---

## BLOCO A -- RECORRENTE

### A1. Fee Fixo (18 clientes ativos)

| Cliente | Codigo | Liquido |
|---|---|---|
| INTEGRASUL SOLUCOES EM INFORMATICA LTDA | 3424140 | R$ 1.299 |
| FERNANDA MARIA COELHO VASQUES | 8227409 | R$ 599 |
| MARCELO DANEMBERG MARSILI | 2143369 | R$ 471 |
| GILBERTO ROSSATO DE MEDEIROS | 2861533 | R$ 426 |
| MARTIN JOSE CAMMAROTA GEROSA | 2498565 | R$ 252 |
| RICARDO ADAIL ALVES | 2010572 | R$ 233 |
| REGINALDO LOPES DE JESUS | 2112212 | R$ 203 |
| FRANCISCO DONIZETE GOMES | 4547934 | R$ 189 |
| MARCELO TRAVI PACHECO | 3355473 | R$ 172 |
| ARTECASA COMERCIO DE MATERIAIS DE CONSTRUCAO LTDA | 2978828 | R$ 171 |
| SILVIO LUIZ FRASSON | 3242303 | R$ 156 |
| IRONITA TEREZINHA MATTIOLLO | 3950461 | R$ 132 |
| MARISA GAZZI KLOSS | 4571340 | R$ 108 |
| CARLA VALENTINI | 18382970 | R$ 103 |
| TAINE MELLO VIDALETTI | 18295452 | R$ 103 |
| JOAO PEDRO DELLA MEA MAGRO | 5892942 | R$ 101 |
| NELIO ENDERLE | 5993019 | R$ 84 |
| BRUNA VALENTINI SIEGA | 18382020 | R$ 84 |
| Fee de Plataforma (custo) | | R$ 0 |
| **TOTAL FEE FIXO** | | **R$ 4.887** |

> Francisco Ricardo (19119719) sem competencia em fevereiro -- 18 clientes vs 19 em marco.

---

### A2. MFO -- Family Office

| Linha | Liquido |
|---|---|
| Consultoria MFO | R$ 2.323 |
| Carteira ADM (5 contas Persevera) | R$ 1.775 |
| **TOTAL MFO** | **R$ 4.097** |

---

### A3. TX ADM

| Categoria | Liquido |
|---|---|
| TX ADM Fundos Recorrentes | R$ 763 |
| TX ADM Fundos Imobiliarios | R$ 21 |
| **TOTAL TX ADM** | **R$ 785** |

---

### A4. Previdencia

> Total consolidado. Ver CSV para detalhamento por cliente.

**TOTAL PREVIDENCIA: R$ 600**

---

### A5. Seguros

| Cliente | Produto | Liquido |
|---|---|---|
| MARIETA LUCE MADEIRA | A. Patrimonial / PRUDENTIAL | R$ 28 |
| RAFAEL NASCIMENTO DE CORDOVA | A. Patrimonial / PRUDENTIAL | R$ 5 |
| **TOTAL SEGUROS** | | **R$ 33** |

---

### TOTAL RECORRENTE: R$ 10.402

---

## BLOCO B -- SEMIRRECORRENTE

| Categoria | Liquido | Obs |
|---|---|---|
| B1. Renda Variavel | R$ 3.209 | Inclui PE R$940 + BM&F R$70 (ajuste manual) |
| B2. COE produto | R$ 0 | |
| B3. Renda Fixa | R$ 1.300 | |
| B4. FIIs Primario | R$ 25 | Adriano Forlin BOVESPA FIIs |
| B5. Oferta Fundos | R$ 4.418 | Patria PIDI11 (7 clientes) + Jive BossaNova (Valdir) |
| B6. Banking | R$ 1.790 | Diego consorcio R$1.649 + Marcelo Dom R$141 |
| B7. Internacional | R$ 1 | Rafael Hernandez + Nestor Giacomin |
| **TOTAL SEMIRRECORRENTE** | **R$ 10.742** | |

Oferta Fundos detalhado (PIDI11): Leonardo R$2.389, Diego R$573, Adriano R$478, Valdir Jive R$309, Maristela R$239, Nestor R$191, Vagner R$96

PE detalhado (ajuste): Booster Shield Sob Custodia Diego R$601, Put Leonardo R$164, Booster sob custodia Diego R$92, Put Diego R$82

BM&F Mesa detalhado (ajuste): Diego R$62, Leonardo R$4, Camile R$2, Nelio R$2

---

## BLOCO C -- NAO RECORRENTE

| Item | Liquido |
|---|---|
| Campanhas | R$ 0 |
| Estornos (3 ESTORNO Desconto de Transf.) | R$ 64 |
| **TOTAL NAO RECORRENTE** | **R$ 64** |

---

## DEDUCOES

| Item | Valor |
|---|---|
| Fee de Plataforma | R$ 0 |
| Saude (Co Partic. + Unimed NE titular + dependente) | - R$ 1.124 |
| MULTA Desconto Transf. Joao Pedro (ajuste manual) | - R$ 42 |
| **TOTAL DEDUCOES** | **- R$ 1.166** |

---

## AJUSTES MANUAIS (itens nao capturados pelo script)

| Item | Valor | Motivo do gap |
|---|---|---|
| PE / Opcoes (Booster Shield + Puts Diego e Leonardo) | + R$ 940 | Tipo = PE, Cat = OPERACOES ESTRUTURADAS -- sem filtro |
| BM&F Mesa (Diego, Leonardo, Camile, Nelio) | + R$ 70 | Cat = BM&F, Tipo = Renda Variavel -- filtro usa Tipo BMF |
| MULTA Joao Pedro (Desconto Transf.) | - R$ 42 | Deducao com prefixo [MULTA] -- script captura so [ESTORNO] |
| **TOTAL AJUSTE** | **+ R$ 968** | |

Script base gerou: R$19.074 | Apos ajuste: **R$20.042**

---

## TOP CLIENTES -- Fev/2026

| # | Cliente | Codigo | Receita Liquida |
|---|---|---|---|
| 1 | DIEGO EDUARDO PIRES DE BORBA | 242706 | R$ 4.379 |
| 2 | LEONARDO MASCARENHAS LEITE | 6761987 | R$ 3.378 |
| 3 | MARIA NORMA CRUZ PINTO COELHO | AF | R$ 2.323 |
| 4 | INTEGRASUL SOLUCOES EM INFORMATICA LTDA | 3424140 | R$ 1.299 |
| 5 | FERNANDA MARIA COELHO VASQUES | 8227409 | R$ 599 |
| 6 | YVONNE MARIA KFOURI COSTA HERNANDEZ MENDES | 4590586 | R$ 516 |
| 7 | ADRIANO ESPINDULA | 3547280 | R$ 500 |
| 8 | MARCELO DANEMBERG MARSILI | 2143369 | R$ 471 |
| 9 | VALDIR JOSE MATTIOLLO | 2656669 | R$ 460 |
| 10 | GILBERTO ROSSATO DE MEDEIROS | 2861533 | R$ 426 |

> Nota: o script agrega todos os itens por cliente (incluindo PE e BM&F).
> Os valores de Diego e Leonardo ja refletem os produtos de opcoes capturados na agregacao por cliente.

Diego destaque: consorcio Banking R$1.649 + Booster Shield R$601 + PIDI11 R$573 + Booster Sob Custodia R$92 + Puts R$82 + BOVESPA R$550 + outros

---

## ANALISE COMPARATIVA

| Indicador | Fev/2026 | Mar/2026 | Abr/2026 | Mai/2026 |
|---|---|---|---|---|
| Total Liquido | R$ 20.042 | R$ 20.066 | R$ 19.769 | R$ 28.460 |
| Total sem campanhas | R$ 20.042 | R$ 17.601 | R$ 18.355 | R$ 20.413 |
| Recorrente | R$ 10.402 | R$ 12.240 | R$ 11.185 | R$ 11.579 |
| % Recorrente | 51,9% | 61,0% | 56,6% | 40,7% |
| % Rec sem camp | 51,9% | 69,5% | 60,9% | 56,7% |
| Fee Fixo | R$ 4.887 | R$ 6.072 | R$ 5.593 | R$ 5.649 |
| MFO + ADM | R$ 4.097 | R$ 4.227 | R$ 4.071 | R$ 4.161 |
| Oferta Fundos | R$ 4.418 | R$ 0 | R$ 0 | R$ 274 |
| Banking | R$ 1.790 | R$ 2.288 | R$ 1.956 | R$ 832 |
| RV | R$ 3.209 | R$ 1.268 | R$ 2.943 | R$ 1.214 |
| Campanhas | R$ 0 | R$ 2.465 | R$ 1.414 | R$ 8.047 |

**Destaques de fevereiro:**
- Sem campanhas: total sem camp = total liquido -- referencia limpa para benchmark estrutural
- Oferta PIDI11 expressiva: R$4.418 -- maior item do mes, 7 clientes participantes
- RV alta para o periodo: R$3.209 -- PE sozinho contribuiu R$940 (Diego + Leonardo com opcoes)
- Fee Fixo menor: R$4.887 vs R$6.072 em marco -- Francisco Ricardo ausente em fev
- Banking consistente: Diego consorcio R$1.649 como principal item recorrente do bloco B
- MULTA Joao Pedro -R$42: deducao pontual, verificar se se repete

---

## NUMEROS PARA CONTROLE

| Indicador | Fev/2026 |
|---|---|
| Total Liquido | R$ 20.042 |
| Total sem campanhas | R$ 20.042 |
| Recorrente | R$ 10.402 |
| % Recorrente | 51,9% |
| % Recorrente sem camp | 51,9% |
| Fee Fixo | R$ 4.887 |
| MFO + Carteira ADM | R$ 4.097 |
| TX ADM | R$ 785 |
| Previdencia | R$ 600 |
| Seguros | R$ 33 |
| RV (incl. PE + BM&F) | R$ 3.209 |
| COE produto | R$ 0 |
| RF | R$ 1.300 |
| FIIs primario | R$ 25 |
| Oferta Fundos | R$ 4.418 |
| Banking | R$ 1.790 |
| Internacional | R$ 1 |
| Campanhas | R$ 0 |
| Clientes FF ativos | 18 |
| Fee Plataforma pago | R$ 0 |
