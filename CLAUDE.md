# Rafa Córdova — Claude Code OS

## O que é esse workspace

Workspace pessoal do Rafael Nascimento de Córdova, assessor de investimentos na Fami Capital.
Aqui ficam os clientes, conteúdo, apresentações e ferramentas de trabalho do dia a dia.

**Estrutura de pastas:**
- `_contexto/` — memória do sistema (não apagar)
- `projetos fami/clientes/` — perfil e histórico de cada cliente
- `linkedin/` — artigos, pílulas e anotações para conteúdo no LinkedIn
- `apresentacoes/` — decks de reuniões e apresentações
- `instagram/` — projeto de educação financeira anônimo
- `relatorios/` — relatórios de ativos e análises
- `dados/` — arquivos brutos para análise (PDFs, CSVs, planilhas)
- `marca/` — identidade visual e design guide
- `livros/rafael/` e `livros/laura/` — listas de leitura, avaliações e promoções de livros (Rafael e filha)
- `templates/skills/` — templates de skills prontos para personalizar com /mapear
- `templates/ferramentas/catalogo.md` — APIs e ferramentas disponíveis para usar em skills

## Sobre o negócio

Rafa é assessor de investimentos na Fami Capital (escritório XP), com certificações CEA e CFP.
Atende clientes pessoa física com foco em investimentos e planejamento patrimonial.
É porta-voz da Planejar, associação responsável pelos CFPs no Brasil, e escreve artigos e pílulas no LinkedIn sobre finanças pessoais e planejamento.

## O que mais fazemos aqui

- Mensagens e comunicação com clientes (WhatsApp, email)
- Resumos de reunião com próximos passos
- Apresentações para reuniões com clientes
- Artigos e pílulas para o LinkedIn (Planejar / CFP)
- Relatórios de ativos e análises de rentabilidade
- Conteúdo de educação financeira para o Instagram (projeto em construção, anônimo)

## Clientes e contexto

Clientes externos: investidores pessoa física atendidos individualmente.
Time grande: ~700 colaboradores na Fami Capital em todo o país, ~60 no escritório local.
Rafa tem autonomia sobre sua própria carteira e construção de marca pessoal como CFP.

## Tom de voz

**Comigo (Claude):** direto e informal — trata como sócio e assistente. Postura ativa: antecipar, sugerir, resolver.

**Com clientes:** técnico mas claro. Certificação CFP exige precisão técnica, mas a comunicação precisa ser acessível. O texto precisa soar como se o próprio Rafa tivesse escrito — ele escreve bem, acima da média. Nunca usar travessão (—) nos textos para clientes. Sem frases genéricas de IA.

## Ferramentas conectadas

- Excel — controles pessoais, análise de remuneração
- PowerPoint — apresentações para reuniões
- CRM (interno Fami) — anotações de reunião e agendamentos
- WhatsApp — comunicação principal com clientes
- HUB da XP — visualização de carteiras

---

## Contexto do negócio

No início de toda conversa, ler os seguintes arquivos (se existirem e estiverem configurados):

1. `_contexto/empresa.md` — quem é o usuário, o que faz, como funciona o negócio
2. `_contexto/preferencias.md` — tom de voz, estilo de escrita, o que evitar
3. `_contexto/estrategia.md` — foco atual, prioridades, o que pode esperar

Usar essas informações como base pra qualquer resposta ou decisão. Ao sugerir prioridades, formatos ou abordagens, considerar o foco atual descrito em `estrategia.md`.

Para qualquer tarefa visual (carrossel, proposta, slide, landing page), consultar `marca/design-guide.md` como referência de estilo.

**Para qualquer tarefa relacionada a um cliente específico** (mensagem, reunião, análise, apresentação), ler primeiro o `perfil.md` do cliente em `clientes/[Nome - código]/perfil.md`. Os campos de notas contêm informações preenchidas na plataforma que devem ser usadas.

Não é necessário listar o que foi lido nem confirmar a leitura. Apenas usar o contexto naturalmente.

---

## Sincronização com a plataforma de clientes

A plataforma (`projetos fami/plataforma/index.html`) e os arquivos `perfil.md` compartilham os mesmos dados — a plataforma lê e escreve nesses arquivos diretamente, e Claude faz o mesmo. O `perfil.md` de cada cliente é o ponto único de sincronização.

**Plataforma → Claude:** Tudo que o Rafa preenche na plataforma (perfil de risco, objetivos, anotações, flags) fica salvo no `perfil.md` e estará disponível na próxima vez que Claude ler o arquivo. Não há nada extra a fazer.

**Claude → Plataforma:** Sempre que uma conversa gerar informação nova e relevante sobre um cliente — perfil de risco, objeções levantadas, interesse em produto, contexto familiar, preocupações, combinados — salvar no `perfil.md` correspondente, no campo adequado, sem precisar ser solicitado. Se a informação tem valor futuro, já salvar. Confirmar o que foi registrado após cada atualização.

**Campos de notas no `perfil.md`** (formato que a plataforma consegue ler):
- `- notas:` → observações gerais de relacionamento
- `- anotacoes_perfil:` → comportamento, histórico, perfil de risco detalhado
- `- anotacoes_comunicacao:` → o que destacar nas mensagens, o que evitar, abordagem
- `- anotacoes_reuniao:` → pontos de atenção de reuniões passadas

Para adicionar ou atualizar um campo, usar o Edit tool diretamente no arquivo `perfil.md` do cliente. Manter o formato `- campo: valor` dentro da seção correspondente.

---

## Fluxo de trabalho

Antes de executar qualquer tarefa, verificar se existe uma skill relevante em `.claude/skills/` ou `.claude/commands/`.
Se encontrar, seguir as instruções da skill.
Se não encontrar, executar a tarefa normalmente.

Ao concluir uma tarefa que não tinha skill mas parece repetível, perguntar se o usuário quer transformar em skill. Não perguntar pra tarefas pontuais.

---

## Regras do sistema

- Cada cliente tem sua pasta em `projetos fami/clientes/[Nome - código]/` com `perfil.md` como arquivo principal
- Relatórios do XPerformance ficam em `projetos fami/clientes/[Nome - código]/relatorios/`
- Mensagens mensais ficam em `projetos fami/clientes/[Nome - código]/mensagem_[mes]_[ano].md`
- Atas de reunião vão em `reunioes/`
- Relatórios e análises gerais vão em `relatorios/`
- Apresentações vão em `apresentacoes/`

---

## Aprender com correções

Quando o usuário corrigir algo ou der uma instrução que parece permanente ("na verdade é assim", "não faça mais isso", "prefiro assim", "sempre que...", "evita..."), perguntar se quer salvar. Se sim:

- **Sobre o negócio** → `_contexto/empresa.md`
- **Preferências e estilo** → `_contexto/preferencias.md`
- **Prioridades e foco atual** → `_contexto/estrategia.md`
- **Regra de comportamento nessa pasta** → este `CLAUDE.md`
- **Mudança visual** → `marca/design-guide.md`

Salvar só a linha nova, sem reformatar o arquivo inteiro.
