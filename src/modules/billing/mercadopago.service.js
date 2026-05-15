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

async function buscarAssinatura(
  subscription_id
) {

  return await preApproval.get({
    id: subscription_id
  })
}

/* =========================
   CRIAR PIX
========================= */

async function criarPagamentoPix({

  valor,

  email,

  descricao

}) {

  return await payment.create({

    body: {

      transaction_amount:
        Number(valor),

      description:
        descricao,

      payment_method_id:
        "pix",

      payer: {
        email
      }
    }
  })
}

/* =========================
   EXPORTS
========================= */

module.exports = {

  preApproval,

  payment,

  cancelarAssinatura,

  buscarPagamento,

  buscarAssinatura,

  criarPagamentoPix
}