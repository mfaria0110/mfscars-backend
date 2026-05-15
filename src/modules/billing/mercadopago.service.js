const {
  MercadoPagoConfig,
  PreApproval,
  Payment
} = require("mercadopago")

/* =========================
   CLIENT MP
========================= */

const client =
  new MercadoPagoConfig({

    accessToken:
      process.env.MP_ACCESS_TOKEN
  })

/* =========================
   PRE APPROVAL
========================= */

const preApproval =
  new PreApproval(client)

/* =========================
   PAYMENT
========================= */

const payment =
  new Payment(client)

/* =========================
   CANCELAR ASSINATURA
========================= */

async function cancelarAssinatura(
  subscription_id
) {

  return await preApproval.update({

    id: subscription_id,

    body: {
      status: "cancelled"
    }
  })
}

/* =========================
   BUSCAR PAGAMENTO
========================= */

async function buscarPagamento(
  payment_id
) {

  return await payment.get({
    id: payment_id
  })
}

/* =========================
   EXPORTS
========================= */

module.exports = {

  preApproval,

  payment,

  cancelarAssinatura,

  buscarPagamento
}