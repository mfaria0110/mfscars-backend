const {
  preApproval,
  cancelarAssinatura:
    cancelarAssinaturaMP
} = require("./mercadopago.service")

/* =========================
   CRIAR ASSINATURA
========================= */

async function criarAssinatura({
  email,
  plano
}) {

  const response =
    await preApproval.create({

      body: {

        reason:
          `Plano ${plano.nome} - MFS Cars`,

        auto_recurring: {

          frequency: 1,

          frequency_type:
            "months",

          transaction_amount:
            Number(plano.preco),

          currency_id: "BRL"
        },

        back_url:
          "https://app.mfscars.com.br/pagamento/sucesso",

        notification_url:
          "https://api.mfscars.com.br/billing/webhook",

        external_reference:
          String(plano.id),

        payer_email:
          email,

        status: "pending"
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