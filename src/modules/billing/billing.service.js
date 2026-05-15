const {
  preApproval,
  cancelarAssinatura:
    cancelarAssinaturaMP
} = require("./mercadopago.service")

/* =========================
   CRIAR ASSINATURA
========================= */

async function criarAssinatura({

  loja,

  email,

  plano
}) {

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
            Number(plano.preco),

          currency_id:
            "BRL"
        },

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
          email,

        /* =========================
           STATUS INICIAL
        ========================= */

        status:
          "pending"
      }
    })

  return response
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

/* =========================
   EXPORTS
========================= */

module.exports = {

  criarAssinatura,

  cancelarAssinatura
}