const {
  preApproval
} = require("./mercadopago.service")

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
          frequency_type: "months",
          transaction_amount:
            Number(plano.preco),
          currency_id: "BRL"
        },

        back_url:
          "https://app.mfscars.com.br/pagamento/sucesso",

        payer_email: email,

        status: "pending"
      }
    })

  return response
}

module.exports = {
  criarAssinatura
}
