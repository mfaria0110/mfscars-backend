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

  return response
}

/* =========================
   GERAR PIX
========================= */

async function gerarPixPlano({

  loja,

  plano

}) {

  const pagamento =
    await criarPagamentoPix({

      valor:
        plano.preco,

      email:
        loja.email,

      descricao:
        `Plano ${plano.nome} - MFS Cars`
    })

  return pagamento
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

  cancelarAssinatura,

  gerarPixPlano
}