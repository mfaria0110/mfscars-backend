const db =
  require("../../shared/database/db")

const {

  preApproval,

  cancelarAssinatura:
    cancelarAssinaturaMP,

  criarPagamentoPix

} = require("./mercadopago.service")

/* =========================
   CRIAR ASSINATURA
========================= */

async function criarAssinatura({

  loja,

  email,

  plano

}) {

  /* =========================
     FOUNDERS
  ========================= */

  const founders =
    await getFounders()

const foundersAtivo =

  founders.restantes > 0 &&

  plano.nome !== "FREE" &&

  Number(
    plano.desconto_founders || 0
  ) > 0

  /* =========================
     DESCONTO
  ========================= */

  const desconto =

    foundersAtivo

      ? Number(
          plano.desconto_founders || 0
        )

      : 0

  const valorFinal =

    foundersAtivo

      ? Number(

          (

            Number(plano.preco) *

            (
              1 - (
                desconto / 100
              )
            )

          ).toFixed(2)

        )

      : Number(plano.preco)

  const response =
    await preApproval.create({

      body: {

        /* =========================
           REFERÊNCIA INTERNA
        ========================= */

        external_reference:
          `loja_${loja.id}_plano_${plano.id}`,

        /* =========================
           DESCRIÇÃO
        ========================= */

        reason:
          `Plano ${plano.nome} - MFS Cars`,

        /* =========================
           RECORRÊNCIA
        ========================= */

        auto_recurring: {

          frequency: 1,

          frequency_type:
            "months",

          transaction_amount:
            valorFinal,

          currency_id:
            "BRL"
        },

        start_date:
          new Date().toISOString(),

        /* =========================
           URL RETORNO
        ========================= */

        back_url:
          "https://app.mfscars.com.br/pagamento/sucesso",

        /* =========================
           WEBHOOK
        ========================= */

        notification_url:
          "https://api.mfscars.com.br/billing/webhook",

        /* =========================
           PAGADOR
        ========================= */

        payer_email:
          email
      }
    })

  /* =========================
     DEBUG MP
  ========================= */

  console.log(

    "📄 PREAPPROVAL RESPONSE:",

    JSON.stringify(response)

  )

  return {

    response,

    founders:
      foundersAtivo,

    desconto,

    valor_original:
      Number(plano.preco),

    valor_final:
      valorFinal
  }
}

/* =========================
   GERAR PIX
========================= */

async function gerarPixPlano({

  loja,

  plano

}) {

  /* =========================
     FOUNDERS
  ========================= */

  const founders =
    await getFounders()

const foundersAtivo =

  founders.restantes > 0 &&

  plano.nome !== "FREE" &&

  Number(
    plano.desconto_founders || 0
  ) > 0

  /* =========================
     DESCONTO
  ========================= */

  const desconto =

    foundersAtivo

      ? Number(
          plano.desconto_founders || 0
        )

      : 0

  const valorFinal =

    foundersAtivo

      ? Number(

          (

            Number(plano.preco) *

            (
              1 - (
                desconto / 100
              )
            )

          ).toFixed(2)

        )

      : Number(plano.preco)

  const pagamento =
    await criarPagamentoPix({

      valor:
        valorFinal,

      email:
        loja.email,

      descricao:
        `Plano ${plano.nome} - MFS Cars`
    })

  return {

    ...pagamento,

    founders:
      foundersAtivo,

    desconto,

    valor_original:
      Number(plano.preco),

    valor_final:
      valorFinal
  }
}

/* =========================
   CANCELAR ASSINATURA
========================= */

async function cancelarAssinatura(
  subscription_id
) {

  return await cancelarAssinaturaMP(
    subscription_id
  )
}

/* =========================================
   FOUNDERS
========================================= */

async function getFounders() {

  const result =
    await db.query(`

      SELECT
        COUNT(
          DISTINCT l.empresa_id
        )::INTEGER AS total

      FROM loja_plano lp

      JOIN loja l
        ON l.id = lp.loja_id

WHERE
  lp.founders = true

  AND lp.status != 'cancelado'

    `)

  const usadas =
    Number(
      result.rows[0].total || 0
    )

  const total = 20

if (
  usadas >= total
) {

  console.log(
    "🚫 Founders encerrado"
  )
}

  return {

    total,

    usadas,

    restantes:
      Math.max(
        total - usadas,
        0
      )
  }
}

/* =========================
   EXPORTS
========================= */

module.exports = {

  criarAssinatura,

  cancelarAssinatura,

  gerarPixPlano,

  getFounders
}