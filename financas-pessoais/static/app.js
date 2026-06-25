// app.js — Finanças Pessoais / Rafa Córdova

// ── Estado ──────────────────────────────────────────────────────────────────
const S = {
  mesRef: new Date(),         // mês sendo visualizado
  historico: {},              // { "2026-06": { receita, contas_status, fatura } }
  contas: [],                 // array de contas fixas
  chartInstance: null,
  editTxId: null,             // id da transação sendo editada
};

// ── Utilitários ──────────────────────────────────────────────────────────────
const MESES_PT = ['Jan','Fev','Mar','Abr','Mai','Jun','Jul','Ago','Set','Out','Nov','Dez'];
const MESES_FULL = ['janeiro','fevereiro','março','abril','maio','junho','julho','agosto','setembro','outubro','novembro','dezembro'];

const fmt = {
  brl: v => new Intl.NumberFormat('pt-BR', { style: 'currency', currency: 'BRL' }).format(v ?? 0),
  chave: d => `${d.getFullYear()}-${String(d.getMonth()+1).padStart(2,'0')}`,
  display: d => `${MESES_FULL[d.getMonth()].charAt(0).toUpperCase()}${MESES_FULL[d.getMonth()].slice(1)} ${d.getFullYear()}`,
  mesPT: d => `${MESES_PT[d.getMonth()]}/${d.getFullYear()}`,
};

const $ = id => document.getElementById(id);
const numPTBR = str => parseFloat(String(str).replace(/\./g,'').replace(',','.')) || 0;

// ── API ──────────────────────────────────────────────────────────────────────
const api = {
  async getDados() {
    const r = await fetch('/api/dados'); return r.json();
  },
  async saveDados(data) {
    await fetch('/api/dados', { method:'POST', headers:{'Content-Type':'application/json'}, body: JSON.stringify(data) });
  },
  async getContas() {
    const r = await fetch('/api/contas'); return r.json();
  },
  async saveContas(data) {
    await fetch('/api/contas', { method:'POST', headers:{'Content-Type':'application/json'}, body: JSON.stringify(data) });
  },
  async getSalario(mesPT) {
    const r = await fetch(`/api/salario?mes=${encodeURIComponent(mesPT)}`); return r.json();
  },
  async processarPDF(base64) {
    const r = await fetch('/api/processar-pdf', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ conteudo: base64 }),
    });
    return r.json();
  },
};

// ── Dados do mês ─────────────────────────────────────────────────────────────
function getMesDados() {
  const chave = fmt.chave(S.mesRef);
  if (!S.historico.meses) S.historico.meses = {};
  if (!S.historico.meses[chave]) {
    S.historico.meses[chave] = { receita: null, receita_fonte: 'manual', contas_status: {}, fatura: { total: 0, transacoes: [] } };
  }
  return S.historico.meses[chave];
}

// ── Render: Visão Geral ───────────────────────────────────────────────────────
function renderVisao() {
  const mes = getMesDados();
  const contasTotal = S.contas.reduce((s, c) => s + (c.valor || 0), 0);
  const contasPago  = S.contas.filter(c => mes.contas_status[c.id]?.pago)
                               .reduce((s,c) => s + (c.valor || 0), 0);
  const contasPend  = contasTotal - contasPago;
  const faturaTotal = mes.fatura?.total || 0;
  const gastosTotal = contasTotal + faturaTotal;
  const receita     = mes.receita ?? 0;
  const sobra       = receita - gastosTotal;

  // Cards
  $('val-receita').textContent = mes.receita != null ? fmt.brl(receita) : 'R$ —';
  $('sub-receita').textContent = mes.receita != null
    ? (mes.receita_fonte === 'comissoes' ? 'importado de comissões' : 'informado manualmente')
    : 'clique para informar';

  $('val-gastos').textContent = gastosTotal > 0 ? fmt.brl(gastosTotal) : 'R$ —';
  $('val-sobra').textContent  = mes.receita != null || gastosTotal > 0 ? fmt.brl(sobra) : 'R$ —';

  const sobCard = $('scard-sobra') || document.querySelector('.scard-sobra');
  if (sobCard) sobCard.classList.toggle('negativo', sobra < 0 && mes.receita != null);

  if (mes.receita != null && gastosTotal > 0) {
    const pct = ((sobra / receita) * 100).toFixed(0);
    $('sub-sobra').textContent = `${pct > 0 ? '+' : ''}${pct}% da receita`;
  } else {
    $('sub-sobra').textContent = '';
  }

  // Barras de progresso
  const base = receita > 0 ? receita : (gastosTotal || 1);

  const pPago = Math.min((contasPago / base) * 100, 100);
  const pPend = Math.min((contasPend / base) * 100, 100 - pPago);
  $('bar-contas-pago').style.width = pPago + '%';
  $('bar-contas-pend').style.width = pPend + '%';
  $('val-contas-bar').textContent = `${fmt.brl(contasPago)} / ${fmt.brl(contasTotal)}`;

  const pFat = Math.min((faturaTotal / base) * 100, 100);
  $('bar-fatura').style.width = pFat + '%';
  $('val-fatura-bar').textContent = fmt.brl(faturaTotal);

  // Gráfico
  renderGrafico(mes, contasPago, contasPend, faturaTotal);
}

// ── Render: Gráfico ──────────────────────────────────────────────────────────
const CORES = {
  'Moradia':     '#3b82f6',
  'Educação':    '#8b5cf6',
  'Saúde':       '#10b981',
  'Alimentação': '#f59e0b',
  'Transporte':  '#6366f1',
  'Lazer':       '#ec4899',
  'Serviços':    '#64748b',
  'Vestuário':   '#d97706',
  'Compras':     '#06b6d4',
  'Viagem':      '#84cc16',
  'Outros':      '#94a3b8',
};

function buildCatData(mes) {
  const map = {};

  // Contas fixas (pagas)
  S.contas.forEach(c => {
    if (mes.contas_status[c.id]?.pago) {
      map[c.categoria] = (map[c.categoria] || 0) + c.valor;
    }
  });

  // Transações da fatura
  (mes.fatura?.transacoes || []).forEach(tx => {
    if (tx.valor > 0) map[tx.categoria] = (map[tx.categoria] || 0) + tx.valor;
  });

  return Object.entries(map).sort((a,b) => b[1]-a[1]);
}

function renderGrafico(mes, contasPago, contasPend, faturaTotal) {
  const cats = buildCatData(mes);
  const noData = cats.length === 0 && contasPend === 0 && faturaTotal === 0;

  $('no-data-msg').classList.toggle('hidden', !noData);
  document.querySelector('.chart-wrap').classList.toggle('hidden', noData);

  if (noData) return;

  const labels = cats.map(([k]) => k);
  const values = cats.map(([,v]) => v);
  const colors = labels.map(l => CORES[l] || '#94a3b8');

  if (S.chartInstance) S.chartInstance.destroy();
  S.chartInstance = new Chart($('chart-cat'), {
    type: 'doughnut',
    data: { labels, datasets: [{ data: values, backgroundColor: colors, borderWidth: 2, borderColor: '#fff' }] },
    options: {
      responsive: false,
      cutout: '68%',
      plugins: { legend: { display: false }, tooltip: {
        callbacks: { label: ctx => ` ${fmt.brl(ctx.parsed)}` }
      }},
    },
  });

  const total = values.reduce((s,v) => s+v, 0);
  const legend = $('chart-legend');
  legend.innerHTML = cats.map(([nome, val]) => `
    <div class="legend-item">
      <span class="legend-dot" style="background:${CORES[nome]||'#94a3b8'}"></span>
      <span class="legend-name">${nome}</span>
      <span class="legend-pct">${total > 0 ? ((val/total)*100).toFixed(0) : 0}%</span>
      <span class="legend-val">${fmt.brl(val)}</span>
    </div>
  `).join('');
}

// ── Render: Contas Fixas ──────────────────────────────────────────────────────
function renderContas() {
  const mes = getMesDados();
  const lista = $('lista-contas');

  if (!S.contas.length) {
    lista.innerHTML = '<div style="padding:20px 16px;color:var(--text-muted);font-size:13px;">Nenhuma conta cadastrada. Clique em "+ Nova Conta" para começar.</div>';
    updateContasFooter(mes);
    return;
  }

  lista.innerHTML = S.contas
    .filter(c => c.ativo !== false)
    .map(c => {
      const pago = !!mes.contas_status[c.id]?.pago;
      return `
      <div class="conta-item" data-id="${c.id}">
        <div class="conta-check ${pago ? 'pago' : ''}" data-id="${c.id}" title="${pago ? 'Marcar como pendente' : 'Marcar como pago'}">
          ${pago ? '✓' : ''}
        </div>
        <div class="conta-info">
          <div class="conta-nome">${c.nome}</div>
          <div class="conta-meta">venc. dia ${c.vencimento} &middot; ${c.categoria}</div>
        </div>
        <div class="conta-valor">${fmt.brl(c.valor)}</div>
        <div class="conta-badge ${pago ? 'badge-pago' : 'badge-pend'}">${pago ? 'Pago' : 'Pendente'}</div>
        <button class="conta-edit" data-id="${c.id}" title="Editar">✎</button>
      </div>`;
    }).join('');

  updateContasFooter(mes);

  lista.querySelectorAll('.conta-check').forEach(el => {
    el.addEventListener('click', () => togglePago(el.dataset.id));
  });
  lista.querySelectorAll('.conta-edit').forEach(el => {
    el.addEventListener('click', () => abrirEditarConta(el.dataset.id));
  });
}

function updateContasFooter(mes) {
  const total = S.contas.reduce((s,c) => s+(c.valor||0), 0);
  const pago  = S.contas.filter(c => mes.contas_status[c.id]?.pago).reduce((s,c) => s+(c.valor||0), 0);
  $('fp-pago').textContent  = fmt.brl(pago);
  $('fp-pend').textContent  = fmt.brl(total - pago);
  $('fp-total').textContent = fmt.brl(total);
}

async function togglePago(id) {
  const mes = getMesDados();
  if (!mes.contas_status[id]) mes.contas_status[id] = {};
  mes.contas_status[id].pago = !mes.contas_status[id].pago;
  await api.saveDados(S.historico);
  renderContas();
  renderVisao();
}

// ── Render: Fatura ────────────────────────────────────────────────────────────
function renderFatura() {
  const mes = getMesDados();
  const txs = mes.fatura?.transacoes || [];

  if (!txs.length) {
    $('fatura-view').classList.add('hidden');
    $('upload-zone-wrap').classList.remove('hidden');
    $('btn-limpar-fatura').classList.add('hidden');
    return;
  }

  $('upload-zone-wrap').classList.add('hidden');
  $('fatura-view').classList.remove('hidden');
  $('btn-limpar-fatura').classList.remove('hidden');

  const busca  = $('busca-tx').value.toLowerCase();
  const filtCat = $('filtro-cat').value;

  const visiveis = txs.filter(tx => {
    if (filtCat && tx.categoria !== filtCat) return false;
    if (busca && !tx.descricao.toLowerCase().includes(busca)) return false;
    return true;
  });

  const totalVis = visiveis.reduce((s,tx) => s + (tx.valor||0), 0);
  $('val-fat-total').textContent = fmt.brl(mes.fatura.total);
  $('tx-count').textContent = `${txs.length} transações`;

  // Atualizar filtro de categorias
  const cats = [...new Set(txs.map(tx => tx.categoria))].sort();
  const catSel = $('filtro-cat').value;
  $('filtro-cat').innerHTML = '<option value="">Todas as categorias</option>' +
    cats.map(c => `<option value="${c}" ${c===catSel?'selected':''}>${c}</option>`).join('');

  $('lista-tx').innerHTML = visiveis.map(tx => `
    <div class="tx-item">
      <span class="tx-data">${tx.data}</span>
      <span class="tx-desc" title="${tx.descricao}">${tx.descricao}</span>
      <span class="tx-cat" data-id="${tx.id}" title="Clique para alterar">${tx.categoria}</span>
      <span class="tx-valor">${fmt.brl(tx.valor)}</span>
    </div>
  `).join('');

  $('lista-tx').querySelectorAll('.tx-cat').forEach(el => {
    el.addEventListener('click', () => abrirEditarCategoria(el.dataset.id));
  });
}

// ── Modals ─────────────────────────────────────────────────────────────────────
function abrirModal(id)   { $(id).classList.remove('hidden'); }
function fecharModal(id)  { $(id).classList.add('hidden'); }

// Modal Receita
async function abrirModalReceita() {
  const mes = getMesDados();
  const mesPT = fmt.mesPT(S.mesRef);
  const infoEl = $('receita-comissoes-info');

  infoEl.classList.add('hidden');
  infoEl.textContent = '';
  $('input-receita').value = mes.receita ?? '';

  abrirModal('modal-receita');

  // Buscar de comissões em paralelo
  const dados = await api.getSalario(mesPT);
  if (dados.salario) {
    infoEl.classList.remove('hidden');
    infoEl.innerHTML = `Dashboard de comissões: <strong>${fmt.brl(dados.salario)}</strong> em ${mesPT}<br>
      <small style="opacity:.8">Clique em Salvar para usar esse valor, ou informe um diferente.</small>`;
    if (!mes.receita) $('input-receita').value = dados.salario;
  }
}

$('card-receita').addEventListener('click', abrirModalReceita);

$('btn-save-receita').addEventListener('click', async () => {
  const val = parseFloat($('input-receita').value);
  if (isNaN(val)) return;
  const mes = getMesDados();
  mes.receita = val;

  // Verificar se o valor veio de comissões
  const mesPT = fmt.mesPT(S.mesRef);
  const dados = await api.getSalario(mesPT);
  mes.receita_fonte = dados.salario === val ? 'comissoes' : 'manual';

  await api.saveDados(S.historico);
  fecharModal('modal-receita');
  renderVisao();
});

$('btn-cancel-receita').addEventListener('click', () => fecharModal('modal-receita'));

// Fechar modal ao clicar no backdrop
document.querySelectorAll('.modal-backdrop').forEach(el => {
  el.addEventListener('click', () => {
    document.querySelectorAll('.modal').forEach(m => m.classList.add('hidden'));
  });
});

// Modal Nova/Editar Conta
$('btn-nova-conta').addEventListener('click', () => {
  $('modal-conta-titulo').textContent = 'Nova Conta';
  $('input-conta-id').value = '';
  $('input-conta-nome').value  = '';
  $('input-conta-valor').value = '';
  $('input-conta-venc').value  = '';
  $('input-conta-cat').value   = 'Moradia';
  $('btn-delete-conta').classList.add('hidden');
  abrirModal('modal-conta');
});

function abrirEditarConta(id) {
  const c = S.contas.find(x => x.id === id);
  if (!c) return;
  $('modal-conta-titulo').textContent = 'Editar Conta';
  $('input-conta-id').value    = c.id;
  $('input-conta-nome').value  = c.nome;
  $('input-conta-valor').value = c.valor;
  $('input-conta-venc').value  = c.vencimento;
  $('input-conta-cat').value   = c.categoria;
  $('btn-delete-conta').classList.remove('hidden');
  abrirModal('modal-conta');
}

$('btn-save-conta').addEventListener('click', async () => {
  const id    = $('input-conta-id').value;
  const nome  = $('input-conta-nome').value.trim();
  const valor = parseFloat($('input-conta-valor').value);
  const venc  = parseInt($('input-conta-venc').value);
  const cat   = $('input-conta-cat').value;

  if (!nome || isNaN(valor) || isNaN(venc)) return;

  if (id) {
    const c = S.contas.find(x => x.id === id);
    Object.assign(c, { nome, valor, vencimento: venc, categoria: cat });
  } else {
    const newId = Date.now().toString();
    S.contas.push({ id: newId, nome, valor, vencimento: venc, categoria: cat, ativo: true });
  }

  await api.saveContas({ contas: S.contas });
  fecharModal('modal-conta');
  renderContas();
  renderVisao();
});

$('btn-delete-conta').addEventListener('click', async () => {
  const id = $('input-conta-id').value;
  if (!id) return;
  if (!confirm('Excluir esta conta?')) return;
  S.contas = S.contas.filter(c => c.id !== id);
  await api.saveContas({ contas: S.contas });
  fecharModal('modal-conta');
  renderContas();
  renderVisao();
});

$('btn-cancel-conta').addEventListener('click', () => fecharModal('modal-conta'));

// Modal Categoria Transação
function abrirEditarCategoria(txId) {
  const mes = getMesDados();
  const tx  = mes.fatura?.transacoes.find(t => t.id === txId);
  if (!tx) return;
  S.editTxId = txId;
  $('modal-cat-tx-desc').textContent = tx.descricao;
  $('input-cat-tx').value = tx.categoria;
  abrirModal('modal-cat-tx');
}

$('btn-save-cat-tx').addEventListener('click', async () => {
  if (!S.editTxId) return;
  const mes = getMesDados();
  const tx  = mes.fatura?.transacoes.find(t => t.id === S.editTxId);
  if (tx) tx.categoria = $('input-cat-tx').value;
  S.editTxId = null;
  await api.saveDados(S.historico);
  fecharModal('modal-cat-tx');
  renderFatura();
  renderVisao();
});

$('btn-cancel-cat-tx').addEventListener('click', () => fecharModal('modal-cat-tx'));

// ── Navegação de mês ──────────────────────────────────────────────────────────
function atualizarMes() {
  $('mes-label').textContent = fmt.display(S.mesRef);
  renderVisao();
  renderContas();
  renderFatura();
}

$('btn-ant').addEventListener('click', () => {
  S.mesRef.setDate(1);
  S.mesRef.setMonth(S.mesRef.getMonth() - 1);
  atualizarMes();
});

$('btn-prox').addEventListener('click', () => {
  S.mesRef.setDate(1);
  S.mesRef.setMonth(S.mesRef.getMonth() + 1);
  atualizarMes();
});

// ── Tabs ──────────────────────────────────────────────────────────────────────
document.querySelectorAll('.tab').forEach(btn => {
  btn.addEventListener('click', () => {
    document.querySelectorAll('.tab').forEach(b => b.classList.remove('active'));
    btn.classList.add('active');
    const tab = btn.dataset.tab;
    document.querySelectorAll('.tab-pane').forEach(p => p.classList.add('hidden'));
    $('tab-' + tab).classList.remove('hidden');
  });
});

// ── Upload de Fatura ──────────────────────────────────────────────────────────
const CATEGORIAS = {
  keywords: [
    { ws: ['ifood','rappi','uber eats','restaurante','lanchonete','pizzaria','sushi','mcdonalds','subway','lanche','padaria','cafe','mercado','supermercado','hortifruti','acougue','feira','sorveteria'], cat: 'Alimentação' },
    { ws: ['uber','taxi','99pop','cabify','shell','ipiranga','posto','estacionamento','metrô','metro','onibus','azul linhas','gol linhas','latam'], cat: 'Transporte' },
    { ws: ['netflix','spotify','amazon prime','disney','hbo','globoplay','deezer','youtube premium','apple tv','apple.com','apple store','ingresso','cinema','teatro','show'], cat: 'Lazer' },
    { ws: ['farmacia','drogaria','droga raia','ultrafarma','panvel','hospital','clinica','medico','laboratorio','exame','dentista','academia','smartfit','bodytech','bio ritmo'], cat: 'Saúde' },
    { ws: ['escola','colegio','universidade','faculdade','curso','ingles','guitarra','musica','idiomas','wizard','wise up'], cat: 'Educação' },
    { ws: ['amazon','mercado livre','shopee','americanas','magazine luiza','magalu','casas bahia','leroy merlin','aliexpress','shein','submarino'], cat: 'Compras' },
    { ws: ['claro','vivo','tim','oi','net internet','sky','live tim','giga','internet'], cat: 'Serviços' },
    { ws: ['renner','zara','c&a','riachuelo','vivara','hering','adidas','nike','farm','arezzo','schutz','animale','reserva'], cat: 'Vestuário' },
    { ws: ['hotel','pousada','airbnb','booking','hostel','resort','voo','passagem','aeroporto'], cat: 'Viagem' },
  ],
  detectar(descricao) {
    const d = descricao.toLowerCase();
    for (const r of this.keywords) {
      if (r.ws.some(w => d.includes(w))) return r.cat;
    }
    return 'Outros';
  },
};

function parsearCSV(texto) {
  const linhas = texto.trim().split(/\r?\n/);

  // Detectar separador
  const sep = linhas[0].includes(';') ? ';' : ',';

  // Pular linhas de cabeçalho
  let dataIdx = -1, descIdx = -1, valIdx = -1;
  let headerRow = -1;

  for (let i = 0; i < Math.min(5, linhas.length); i++) {
    const cols = linhas[i].split(sep).map(c => c.replace(/^"|"$/g,'').trim().toLowerCase());
    const dIdx = cols.findIndex(c => c.includes('data') || c === 'date');
    const dscIdx = cols.findIndex(c => c.includes('descri') || c.includes('lanc') || c === 'description' || c === 'name');
    const vIdx = cols.findIndex(c => c.includes('valor') || c.includes('amount') || c.includes('value'));
    if (dIdx >= 0 || dscIdx >= 0 || vIdx >= 0) {
      dataIdx = dIdx; descIdx = dscIdx; valIdx = vIdx; headerRow = i;
      break;
    }
  }

  if (headerRow < 0) {
    // Tentar formato sem cabeçalho: data, desc, valor
    dataIdx = 0; descIdx = 1; valIdx = 2; headerRow = -1;
  }

  const txs = [];
  for (let i = headerRow + 1; i < linhas.length; i++) {
    const linha = linhas[i].trim();
    if (!linha) continue;
    const cols = linha.split(sep).map(c => c.replace(/^"|"$/g,'').trim());
    const data  = dataIdx  >= 0 ? cols[dataIdx]  : cols[0];
    const desc  = descIdx  >= 0 ? cols[descIdx]  : cols[1];
    const valStr = valIdx  >= 0 ? cols[valIdx]   : cols[cols.length-1];
    const valor  = numPTBR(valStr);
    if (!desc || isNaN(valor) || valor <= 0) continue;

    // Normalizar data
    const dataMatch = data.match(/(\d{1,2})[\\/\-](\d{1,2})(?:[\\/\-]\d{2,4})?/);
    const dataFmt = dataMatch ? `${dataMatch[1].padStart(2,'0')}/${dataMatch[2].padStart(2,'0')}` : data;

    txs.push({
      id: `tx_${Date.now()}_${i}`,
      data: dataFmt,
      descricao: desc.toUpperCase(),
      valor,
      categoria: CATEGORIAS.detectar(desc),
    });
  }
  return txs;
}

function parsearTextoPDF(texto) {
  const linhas = texto.split(/\r?\n/);
  const txs    = [];

  // Padrão XP/Bradesco: DD/MM  DESCRIÇÃO  VALOR
  const REGEX_TX = /^\s*(\d{2}\/\d{2})\s{2,}(.+?)\s{2,}([\d.]+,\d{2})\s*$/;

  linhas.forEach((linha, i) => {
    const m = linha.match(REGEX_TX);
    if (!m) return;
    const [, data, descRaw, valStr] = m;
    const desc  = descRaw.trim().replace(/\s+/g, ' ').toUpperCase();
    const valor = numPTBR(valStr);
    if (valor <= 0) return;
    txs.push({
      id: `tx_${Date.now()}_${i}`,
      data,
      descricao: desc,
      valor,
      categoria: CATEGORIAS.detectar(desc),
    });
  });

  return txs;
}

async function processarArquivo(file) {
  const status = $('upload-status');
  status.className = 'upload-status';
  status.textContent = `Processando ${file.name}...`;
  status.classList.remove('hidden');

  try {
    let txs = [];

    if (file.name.endsWith('.csv')) {
      const texto = await file.text();
      txs = parsearCSV(texto);
    } else if (file.name.endsWith('.pdf')) {
      const buffer  = await file.arrayBuffer();
      const bytes   = new Uint8Array(buffer);
      const bin     = Array.from(bytes).reduce((s,b) => s + String.fromCharCode(b), '');
      const base64  = btoa(bin);
      const resp    = await api.processarPDF(base64);
      if (!resp.ok) {
        status.className = 'upload-status erro';
        status.textContent = `Erro ao processar PDF: ${resp.erro || 'verifique se pdftotext está instalado.'}`;
        return;
      }
      txs = parsearTextoPDF(resp.texto);
    }

    if (!txs.length) {
      status.className = 'upload-status erro';
      status.textContent = 'Nenhuma transação encontrada. Verifique o formato do arquivo.';
      return;
    }

    const mes = getMesDados();
    if (!mes.fatura) mes.fatura = { total: 0, transacoes: [] };
    mes.fatura.transacoes.push(...txs);
    mes.fatura.total = mes.fatura.transacoes.reduce((s,t) => s+(t.valor||0), 0);

    await api.saveDados(S.historico);

    status.textContent = `✓ ${txs.length} transações importadas de ${file.name}.`;
    renderFatura();
    renderVisao();
  } catch(e) {
    status.className = 'upload-status erro';
    status.textContent = `Erro: ${e.message}`;
  }
}

// Upload via input
$('file-input').addEventListener('change', async e => {
  for (const file of e.target.files) await processarArquivo(file);
  e.target.value = '';
});

// Drag & Drop
const zone = $('upload-zone');
zone.addEventListener('dragover',  e => { e.preventDefault(); zone.classList.add('drag-over'); });
zone.addEventListener('dragleave', () => zone.classList.remove('drag-over'));
zone.addEventListener('drop', async e => {
  e.preventDefault();
  zone.classList.remove('drag-over');
  for (const file of e.dataTransfer.files) await processarArquivo(file);
});

// Limpar fatura
$('btn-limpar-fatura').addEventListener('click', async () => {
  if (!confirm('Limpar todas as transações desta fatura?')) return;
  const mes = getMesDados();
  mes.fatura = { total: 0, transacoes: [] };
  await api.saveDados(S.historico);
  renderFatura();
  renderVisao();
});

// Filtros da fatura
$('busca-tx').addEventListener('input',    renderFatura);
$('filtro-cat').addEventListener('change', renderFatura);

// ── Init ──────────────────────────────────────────────────────────────────────
async function init() {
  try {
    const [dadosResp, contasResp] = await Promise.all([api.getDados(), api.getContas()]);
    S.historico = dadosResp;
    S.contas    = contasResp.contas || [];
    atualizarMes();
  } catch(e) {
    console.error('Erro ao inicializar:', e);
    document.body.insertAdjacentHTML('afterbegin',
      '<div style="background:#fee2e2;color:#dc2626;padding:12px 24px;font-size:13px;">Erro ao conectar com o servidor. Verifique se o servidor está rodando.</div>'
    );
  }
}

init();
