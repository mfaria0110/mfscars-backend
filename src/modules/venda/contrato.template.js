const db =
  require("../../shared/database/db")

function moeda(valor) {
  return Number(valor || 0).toLocaleString(
    "pt-BR",
    {
      minimumFractionDigits: 2,
      maximumFractionDigits: 2
    }
  )
}

function dataBR(data) {
  if (!data) return "-"

  return new Date(data)
    .toLocaleDateString("pt-BR")
}

function formatCPF_CNPJ(valor) {
  const v = String(valor || "").replace(/\D/g, "")

  if (v.length <= 11) {
    return v.replace(
      /(\d{3})(\d{3})(\d{3})(\d{2})/,
      "$1.$2.$3-$4"
    )
  }

  return v.replace(
    /(\d{2})(\d{3})(\d{3})(\d{4})(\d{2})/,
    "$1.$2.$3/$4-$5"
  )
}

function formatTelefone(valor) {
  const v = String(valor || "").replace(/\D/g, "")

  if (v.length === 11) {
    return v.replace(
      /(\d{2})(\d{5})(\d{4})/,
      "($1) $2-$3"
    )
  }

  return v.replace(
    /(\d{2})(\d{4})(\d{4})/,
    "($1) $2-$3"
  )
}

function formatCEP(valor) {
  const v = String(valor || "").replace(/\D/g, "")

  return v.replace(
    /(\d{5})(\d{3})/,
    "$1-$2"
  )
}

function htmlSeguro(valor) {

  if (!valor) return ""

  if (typeof valor === "string") {
    return valor
  }

  if (typeof valor === "object") {

    if (valor.html) {
      return valor.html
    }

    return JSON.stringify(valor)
  }

  return String(valor)
}

const BASE_URL =
  process.env.BASE_URL ||
  "https://api.mfscars.com.br"

async function buscarClausulas(lojaId) {

  try {

    const result =
      await db.query(
        `
        SELECT
          clausulas,
          garantia,
          transferencia

        FROM loja_clausula

        WHERE loja_id = $1

        LIMIT 1
        `,
        [lojaId]
      )

    return (
      result.rows[0] || {}
    )

  } catch(err) {

    console.error(err)

    return {}
  }
}


  /* =========================
     VEÍCULOS ENTRADA HTML
  ========================= */

module.exports = async function gerarContrato(
  dados
) {

const clausulasLoja =
  await buscarClausulas(
    dados.loja_id
  )

const entradasHtml =
  dados.entradas?.length
    ? `
      <table>
        <tr>
          <th colspan="4">
            VEÍCULOS DE ENTRADA
          </th>
        </tr>

        ${dados.entradas
          .map(
            (e, i) => `
              <tr>
                <td colspan="4">
                  <strong>Veículo ${i + 1}</strong>
                </td>
              </tr>

              <tr>
                <td class="label">Marca</td>
                <td>${e.marca || "-"}</td>

                <td class="label">Modelo</td>
                <td>${e.modelo || "-"}</td>
              </tr>

              <tr>
                <td class="label">Tipo</td>
                <td>${e.tipo || "-"}</td>

                <td class="label">Placa</td>
                <td>${e.placa || "-"}</td>
              </tr>

              <tr>
                <td class="label">Ano</td>
                <td>${e.ano_modelo || "-"}</td>

                <td class="label">Cor</td>
                <td>${e.cor || "-"}</td>
              </tr>

              <tr>
                <td class="label">Chassi</td>
                <td>${e.chassi || "-"}</td>

                <td class="label">Renavam</td>
                <td>${e.renavam || "-"}</td>
              </tr>

              <tr>
                <td class="label">KM</td>
                <td>${e.km || "-"}</td>

                <td class="label">Valor</td>
                <td>
                  R$ ${moeda(e.valor_entrada)}
                </td>
              </tr>
            `
          )
          .join("")}
      </table>
    `
    : ""

  /* =========================
     RESUMO FINANCEIRO
  ========================= */
  const valorVenda =
    Number(
      dados.valor_venda || 0
    )

  const entradaDinheiro =
    Number(
      dados.valor_entrada || 0
    )

  const totalVeiculosEntrada =
    dados.entradas?.reduce(
      (total, item) =>
        total +
        Number(
          item.valor_entrada || 0
        ),
      0
    ) || 0

  const totalPago =
    entradaDinheiro +
    totalVeiculosEntrada

  const saldoRestante =
    valorVenda - totalPago

  const valorParcela =
    Number(dados.valor_parcela) || 0;

  return `
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">

<style>
body {
  font-family: Arial;
  font-size: 12px;
  padding: 5px 10px;
  margin: 0;
}

h1 {
  text-align: center;
  margin-bottom: 20px;
}

table {
  width: 100%;
  border-collapse: collapse;
  margin-bottom: 12px;
}

td {
  border: 1px solid #ccc;
  padding: 4px;
  vertical-align: top;
}

.titulo td {
background: #0d6efd;
color: #fff;
  font-weight: bold;
  text-align: center;
}

.label {
  width: 120px;
  font-weight: bold;
  white-space: nowrap;
}

.valor {
  font-weight: bold;
}

.clausulas {
  margin-top: 20px;
  font-size: 11px;
  line-height: 1.6;
}

.clausulas h3 {
  page-break-after: avoid;
}

.lista {
  page-break-inside: avoid;
  margin-left: 18px;
}

.lista li {
  margin-bottom: 4px;
}

.assinatura {
  margin-top: 40px;
  text-align: center;
}

table {
  page-break-inside: avoid;
}

.observacoes {
  page-break-inside: avoid;
}

.clausulas {
  page-break-before: auto;
  page-break-inside: auto;
}

.assinatura {
  page-break-inside: avoid;
}    
</style>
</head>

<body>
<div class="conteudo">
<div style="
  display:flex;
  align-items:center;
  justify-content:space-between;
  margin-bottom:8px;
">

  <!-- LOGO -->
  ${
    dados.loja_logo
      ? `
        <img
          src="${
            dados.loja_logo?.startsWith("http")
              ? dados.loja_logo
              : `${BASE_URL}${dados.loja_logo}`
          }"
          style="
            height:40px;
            object-fit:contain;
          "
        />
      `
      : "<div style='width:50px;'></div>"
  }

  <!-- TÍTULO -->
  <h1 style="
    flex:1;
    text-align:center;
    margin:0;
  ">
    Contrato de Venda
  </h1>

  <!-- ESPAÇO DIREITA -->
  <div style="width:50px;"></div>

</div>

<!-- LOJA -->
<table>
  <tr class="titulo">
    <td colspan="4">
      DADOS DA LOJA
    </td>
  </tr>

  <tr>
    <td class="label">
      Nome
    </td>
    <td>
      ${dados.loja_nome || "-"}
    </td>

    <td class="label">
      CNPJ
    </td>
    <td>
       ${formatCPF_CNPJ(dados.loja_cnpj) || "-"}
    </td>
  </tr>

  <tr>
    <td class="label">
      Estado
    </td>
    <td>
      ${dados.loja_estado || "-"}
    </td>

    <td class="label">
      Cidade
    </td>
    <td>
      ${dados.loja_cidade || "-"}
    </td>
  </tr>

  <tr>
    <td class="label">
      Endereço
    </td>
    <td>
      ${dados.loja_endereco || "-"}
    </td>

    <td class="label">
      Número
    </td>
    <td>
      ${dados.loja_numero || "-"}
    </td>
  </tr>

  <tr>
    <td class="label">
      Bairro
    </td>
    <td>
      ${dados.loja_bairro || "-"}
    </td>

    <td class="label">
      CEP
    </td>
    <td>
      ${formatCEP(dados.loja_cep) || "-"}
    </td>
  </tr>

  <tr>
    <td class="label">
      Telefone
    </td>
    <td>
      ${formatTelefone(dados.loja_telefone) || "-"}
    </td>

    <td class="label">
      Vendedor
    </td>
    <td>
      ${dados.vendedor || "-"}
    </td>
  </tr>
</table>

<!-- CLIENTE -->
<table>
  <tr class="titulo">
    <td colspan="4">
      CLIENTE
    </td>
  </tr>

  <tr>
    <td class="label">Nome</td>
    <td>${dados.nome_comprador || "-"}</td>

    <td class="label">RG</td>
    <td>${dados.rg_comprador || "-"}</td>
  </tr>

  <tr>
    <td class="label">CPF/CNPJ</td>
    <td>${formatCPF_CNPJ(dados.cpf_comprador) || "-"}</td>
    <td class="label">Telefone</td>
    <td>${formatTelefone(dados.telefone_comprador) || "-"}</td>
  </tr>

  <tr>
    <td class="label">Endereço</td>
    <td>${dados.endereco || "-"}</td>

    <td class="label">Número</td>
    <td>${dados.numero || "-"}</td>
  </tr>

  <tr>
    <td class="label">Complemento</td>
    <td>${dados.complemento || "-"}</td>

    <td class="label">Bairro</td>
    <td>${dados.bairro || "-"}</td>
  </tr>

  <tr>
    <td class="label">Cidade</td>
    <td>${dados.cidade || "-"}</td>

    <td class="label">Estado</td>
    <td>${dados.estado || "-"}</td>
  </tr>

  <tr>
    <td class="label">CEP</td>
    <td>${formatCEP(dados.cep) || "-"}</td>

    <td class="label">Email</td>
    <td>${dados.email || "-"}</td>
  </tr>

  <tr>
    <td class="label">Profissão</td>
    <td colspan="3">
      ${dados.profissao || "-"}
    </td>
  </tr>
</table>

<!-- VEÍCULO -->
<table>
  <tr class="titulo">
    <td colspan="4">
      VEÍCULO VENDIDO
    </td>
  </tr>

  <tr>
    <td class="label">Marca</td>
    <td>${dados.marca || "-"}</td>

    <td class="label">Modelo</td>
    <td>${dados.modelo || "-"}</td>
  </tr>

  <tr>
    <td class="label">Tipo</td>
    <td>${dados.tipo || "-"}</td>

    <td class="label">Placa</td>
    <td>${dados.placa || "-"}</td>
  </tr>

  <tr>
    <td class="label">Ano Fab/Mod</td>
    <td>${dados.ano_modelo || "-"}</td>

    <td class="label">Renavam</td>
    <td>${dados.renavam || "-"}</td>
  </tr>

  <tr>
    <td class="label">Chassi</td>
    <td>${dados.chassi || "-"}</td>

    <td class="label">Cor</td>
    <td>${dados.cor || "-"}</td>
  </tr>

  <tr>
    <td class="label">Combustível</td>
    <td>${dados.combustivel || "-"}</td>

    <td class="label">KM</td>
    <td>${dados.km || "-"}</td>
  </tr>

  <tr>
    <td class="label">Valor Venda</td>
    <td>
      R$ ${moeda(
        dados.valor_venda
      )}
    </td>

    <td class="label">
      Entrada Dinheiro
    </td>
    <td>
      R$ ${moeda(
        dados.valor_entrada
      )}
    </td>
  </tr>
</table>


${entradasHtml}


<!-- RESUMO FINANCEIRO -->
<table>
  <tr class="titulo">
    <td colspan="4">
      RESUMO FINANCEIRO
    </td>
  </tr>

  <tr>
    <td class="label">
      Valor Venda
    </td>
    <td>
      R$ ${moeda(valorVenda)}
    </td>

    <td class="label">
      Entrada Dinheiro
    </td>
    <td>
      R$ ${moeda(
        entradaDinheiro
      )}
    </td>
  </tr>

  <tr>
    <td class="label">
      Total Veículos
    </td>
    <td>
      R$ ${moeda(
        totalVeiculosEntrada
      )}
    </td>

    <td class="label">
      Total Pago
    </td>
    <td>
      R$ ${moeda(
        totalPago
      )}
    </td>
  </tr>

  <tr>
    <td class="label">
      Saldo Restante
    </td>
    <td>
      R$ ${moeda(
        saldoRestante
      )}
    </td>

    <td class="label">
      Forma Pgto
    </td>
    <td>
      ${
        dados.condicao_pagamento ||
        "-"
      }
    </td>
  </tr>

  <tr>
    <td class="label">
      Parcelas
    </td>
    <td>
      ${dados.parcelas || "-"}
    </td>

    <td class="label">
      Banco
    </td>
    <td>
      ${
        dados.banco_financiamento ||
        "-"
      }
    </td>
  </tr>

  <tr>
    <td class="label">
      Valor Parcela
    </td>
    <td colspan="3">
      R$ ${moeda(
        valorParcela
      )}
    </td>
  </tr>
</table>


<!-- OBSERVAÇÕES -->
<table class="observacoes">
  <tr class="titulo">
    <td>
      OBSERVAÇÕES
    </td>
  </tr>

  <tr>
    <td>
      ${
        dados.observacoes ||
        "Sem observações."
      }
    </td>
  </tr>
</table>


<!-- CLÁUSULAS -->
<div class="clausulas">


<h3>
  CLÁUSULAS CONTRATUAIS
</h3>

<div>
  ${
    htmlSeguro(
  clausulasLoja.clausulas
)||

    `
      <p>
        Nenhuma cláusula cadastrada.
      </p>
    `
  }
</div>

<br/>

<h3>
  CONDIÇÕES GERAIS DE GARANTIA
</h3>

<div>
  ${
    htmlSeguro(
  clausulasLoja.garantia
) ||

    `
      <p>
        Garantia conforme legislação vigente.
      </p>
    `
  }
</div>

<br/>

<h3>
  TRANSFERÊNCIA DE PROPRIEDADE
</h3>

<div>
  ${
    htmlSeguro(
  clausulasLoja.transferencia
) ||

    `
      <p>
        Transferência sob responsabilidade do comprador.
      </p>
    `
  }
</div>


<br/>

${
  dados.entradas?.length
    ? `
    <h3>VEÍCULO(S) DADO(S) COMO ENTRADA</h3>

    <p>
    O(s) veículo(s) entregue(s) como parte de pagamento foi(ram) avaliado(s) pelas partes e aceito(s) no estado em que se encontra(m), sendo de inteira responsabilidade do COMPRADOR quanto à procedência, débitos, multas, tributos e regularização documental.
    </p>

    <p>
    O COMPRADOR declara que possui plena propriedade do(s) veículo(s) de entrada, estando livre(s) e desembaraçado(s) de quaisquer ônus, gravames ou restrições.
    </p>
    `
    : ""
}      

</div>

<div>
Fica eleito o foro da comarca de ${dados.loja_cidade || ""}/${dados.loja_estado || ""} para dirimir quaisquer dúvidas oriundas deste contrato.
</div>

<div class="assinatura">

  <div style="
    display:flex;
    justify-content:space-between;
    margin-top:50px;
  ">

<div style="margin-top:20px;">
  ${dados.loja_cidade || ""} - ${dados.loja_estado || ""}, 
  ${dataBR(new Date())}
</div>


    <div style="width:45%; text-align:center;">
      <p>______________________________________</p>
      <p>Assinatura do Comprador</p>
    </div>

    <div style="width:45%; text-align:center;">
      <p>______________________________________</p>
      <p>Assinatura do Vendedor</p>
    </div>

  </div>

</div>
</div>

</body>
</html>
`
}