const vendaRepository = require("./venda.repository");
const gerarPDF = require("../../shared/utils/gerarPDF");
const template = require("./contrato.template");

/* ===============================
   REGISTRAR VENDA
============================== */
exports.criar = async (
  empresaId,
  lojaId,
  dados
) => {
    dados.valor_venda =
      limparMoeda(dados.valor_venda)

    dados.renda =
      limparMoeda(dados.renda)

  if (dados.veiculos_entrada?.length) {
    dados.veiculos_entrada =
      dados.veiculos_entrada.map(
        item => ({
          ...item,
          valor_entrada:
            limparMoeda(
              item.valor_entrada
            )
        })
      )
  }

  return await vendaRepository
    .criarVendaComTransacao(
      empresaId,
      lojaId,
      dados
    )
}
/* ===============================
   LISTAR VENDAS
============================== */
exports.listar = async (
  empresaId,
  lojaId
) => {
  return await vendaRepository.listar(
    empresaId,
    lojaId
  )
}

/* ===============================
   DETALHES
============================== */
exports.detalhes = async (
  id,
  empresaId,
  lojaId
) => {
  return await vendaRepository
    .detalhes(
      id,
      empresaId,
      lojaId
    )
}

/* ===============================
   CANCELAR
============================== */
exports.cancelar = async (
  empresaId,
  lojaId,
  veiculoId,
  motivo
) => {
  const venda =
    await vendaRepository
      .cancelarVenda(
        empresaId,
        lojaId,
        veiculoId,
        motivo
      )

  return (
    venda || {
      msg:
        "Venda cancelada ou não encontrada"
    }
  )
}

exports.atualizar = async (
  id,
  empresaId,
  lojaId,
  dados
) => {
  dados.valor_venda =
    limparMoeda(dados.valor_venda)

  dados.renda =
    limparMoeda(dados.renda)

  if (dados.veiculos_entrada?.length) {
    dados.veiculos_entrada =
      dados.veiculos_entrada.map(
        item => ({
          ...item,
          valor_entrada:
            limparMoeda(
              item.valor_entrada
            )
        })
      )
  }

return await vendaRepository.atualizarVenda(
  id,
  empresaId,
  lojaId,
  dados
)
}

exports.gerarContratoPDF = async (
  id,
  empresaId,
  lojaId
) => {

  const dados =
    await vendaRepository.buscarContrato(
      id,
      empresaId,
      lojaId
    );

  if (!dados) {
    throw new Error(
      "Venda não encontrada"
    );
  }

  const html =
    await template(dados);

  const pdf =
    await gerarPDF(
      html,
      dados
    );

  return pdf;
};

function limparMoeda(valor) {
  if (!valor) return null

  if (typeof valor === "number") {
    return valor
  }

  return Number(
    valor.replace(/\D/g, "")
  ) / 100
}