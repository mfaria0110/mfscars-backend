const {
  MercadoPagoConfig,
  PreApproval
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
   EXPORTS
========================= */

module.exports = {

  preApproval,

  cancelarAssinatura
}