const db =
  require("../../shared/database/db")  

const billingService =
  require("./billing.service")

const {
  buscarPagamento,
  buscarAssinatura
} = require(
  "./mercadopago.service"
)  

/* =========================================
   TESTE
========================================= */

exports.testar = async (
  req,
  res
) => {

  try {

    res.json({
      ok: true,
      mercado_pago: true,
      token:
        process.env.MP_ACCESS_TOKEN
          ? "CONFIGURADO"
          : "ERRO"
    })

  } catch (e) {

    console.error(e)

    res.status(500).json({
      erro:
        "Erro Mercado Pago"
    })
  }
}

/* =========================================
   CRIAR ASSINATURA
========================================= */

exports.assinar = async (
  req,
  res
) => {

  try {

    const {
      loja_id,
      plano_id
    } = req.body

    if (
      !loja_id ||
      !plano_id
    ) {

      return res
        .status(400)
        .json({
          erro:
            "loja_id e plano_id obrigatórios"
        })
    }

    /* =========================
       LOJA
    ========================= */

    const lojaRes =
      await db.query(`
        SELECT *
        FROM loja
        WHERE id = $1
      `, [loja_id])

    if (
      !lojaRes.rows.length
    ) {

      return res
        .status(404)
        .json({
          erro:
            "Loja não encontrada"
        })
    }

    const loja =
      lojaRes.rows[0]

    /* =========================
       PLANO
    ========================= */

    const planoRes =
      await db.query(`
        SELECT *
        FROM plano
        WHERE id = $1
      `, [plano_id])

    if (
      !planoRes.rows.length
    ) {

      return res
        .status(404)
        .json({
          erro:
            "Plano não encontrado"
        })
    }

    const plano =
      planoRes.rows[0]

/* =========================
   EXPIRA PENDENTES ANTIGAS
========================= */

await db.query(`
  UPDATE loja_plano
  SET
    status = 'cancelado',
    data_cancelamento = NOW()
  WHERE status = 'pendente'
  AND criado_em < NOW() - INTERVAL '15 minutes'
`)


/* =========================
   ASSINATURA PENDENTE
========================= */

const assinaturaPendente =
  await db.query(`
    SELECT *
    FROM loja_plano
    WHERE loja_id = $1
    AND status = 'pendente'
    ORDER BY id DESC
    LIMIT 1
  `, [loja_id])

if (
  assinaturaPendente.rows.length
) {

  const pendente =
    assinaturaPendente.rows[0]

  /*
    TEMPO PENDENTE
  */

  const criadoEm =
    new Date(
      pendente.criado_em
    )

  const agora =
    new Date()

  const diffMinutos =
    (
      agora - criadoEm
    ) / 1000 / 60

/*
  REUTILIZA SOMENTE
  SE CHECKOUT FOR VÁLIDO
*/

const webhookData =
  pendente.webhook_data || {}

const valorValido =
  Number(
    pendente.valor_pago
  ) >= 0.5

const possuiCheckout =
  Boolean(
    webhookData?.init_point
  )

if (

  diffMinutos < 15 &&

  pendente.plano_id === plano_id &&

  valorValido &&

  possuiCheckout
) 
{

  console.log(
    "♻️ Reutilizando checkout pendente"
  )

  return res.json({

    ok: true,

    reutilizado: true,

    init_point:
      webhookData.init_point
  })
}

/*
  PENDENTE INVÁLIDA
*/

console.log(
  "🗑️ Cancelando pendente inválida"
)

await db.query(`
  UPDATE loja_plano
  SET
    status = 'cancelado',
    data_cancelamento = NOW()
  WHERE id = $1
`, [pendente.id])

/*
  PLANO DIFERENTE
*/

if (
  pendente.plano_id !== plano_id
)
 {

  console.log(
    "🔄 Cancelando pendente de outro plano"
  )

  await db.query(`
    UPDATE loja_plano
    SET
      status = 'cancelado',
      data_cancelamento = NOW()
    WHERE id = $1
  `, [pendente.id])
}

}

    /* =========================
       ASSINATURA MP
    ========================= */
    const assinatura =
      await billingService
        .criarAssinatura({

          loja,

          email:
            loja.email,

          plano
        })

    /* =========================
       SALVAR loja_plano
    ========================= */

    await db.query(`
      INSERT INTO loja_plano (
        loja_id,
        plano_id,
        data_inicio,
        ciclo_inicio,
        ciclo_fim,
        status,
        gateway,
        subscription_id,
        webhook_data,
        valor_pago,
        criado_em
      )
      VALUES (
        $1,
        $2,
        NOW(),
        NOW(),
        NOW() + INTERVAL '30 days',
        'pendente',
        'mercadopago',
        $3,
        $4,
        $5,
        NOW()
      )
    `, 
    [
      loja_id,
      plano_id,
      assinatura.id,
      JSON.stringify(
        assinatura
      ),
      plano.preco
    ]
    )

    res.json({

      ok: true,

      init_point:
        assinatura.init_point,

      assinatura
    })

  } catch (e) {

    console.error(e)

    res.status(500).json({
      erro:
        "Erro ao criar assinatura"
    })
  }
}

/* =========================================
   GERAR PIX
========================================= */

exports.gerarPix = async (
  req,
  res
) => {

  try {

    const {
      loja_id,
      plano_id
    } = req.body

    if (
      !loja_id ||
      !plano_id
    ) {

      return res
        .status(400)
        .json({
          erro:
            "loja_id e plano_id obrigatórios"
        })
    }

    /*
      LOJA
    */

    const lojaRes =
      await db.query(`
        SELECT *
        FROM loja
        WHERE id = $1
      `, [loja_id])

    if (
      !lojaRes.rows.length
    ) {

      return res
        .status(404)
        .json({
          erro:
            "Loja não encontrada"
        })
    }

    const loja =
      lojaRes.rows[0]

    /*
      PLANO
    */

    const planoRes =
      await db.query(`
        SELECT *
        FROM plano
        WHERE id = $1
      `, [plano_id])

    if (
      !planoRes.rows.length
    ) {

      return res
        .status(404)
        .json({
          erro:
            "Plano não encontrado"
        })
    }

    const plano =
      planoRes.rows[0]

/*
  VALOR MÍNIMO PIX
*/

if (
  Number(plano.preco) < 0.5
) {

  return res
    .status(400)
    .json({

      erro:
        "Plano FREE não pode ser assinado via PIX"
    })
}

/* =========================
   PIX PENDENTE
========================= */

const pixPendente =
  await db.query(`
    SELECT

      lc.*,

      lp.id
        AS loja_plano_id,

      lp.plano_id

    FROM loja_cobranca lc

    INNER JOIN loja_plano lp
      ON lp.id = lc.loja_plano_id

    WHERE lp.loja_id = $1

    AND lp.status = 'pendente'

    AND lc.status = 'pendente'

    AND lp.gateway =
      'mercadopago_pix'

    ORDER BY lc.criado_em DESC

    LIMIT 1
  `, [loja_id])

if (
  pixPendente.rows.length
) {

  const pendente =
    pixPendente.rows[0]

  /*
    TEMPO
  */

  const criadoEm =
    new Date(
      pendente.criado_em
    )

  const agora =
    new Date()

  const diffMinutos =
    (
      agora - criadoEm
    ) / 1000 / 60


/*
  VALIDA VALOR ATUAL
*/

const valorPlanoAtual =
  Number(plano.preco)

const valorPixPendente =
  Number(
    pendente.valor
  )

const mesmoValor =
  valorPlanoAtual ===
  valorPixPendente

/*
  PIX AINDA VÁLIDO
*/

if (

  diffMinutos < 15 &&

  pendente.plano_id ===
    plano_id &&

  pendente.copiaecola &&

  mesmoValor

) {

  console.log(
    "♻️ Reutilizando PIX pendente"
  )

  return res.json({

    ok: true,

    reutilizado: true,

    payment_id:
      pendente.payment_id,

    qr_code:
      pendente.qr_code,

    copiaecola:
      pendente.copiaecola
  })
}

/*
  VALOR ALTERADO
*/

if (!mesmoValor) {

  console.log(
    "💰 Valor alterado, expirando PIX antigo"
  )
}


  /*
    EXPIRA PIX ANTIGO
  */

  console.log(
    "⌛ Expirando PIX pendente"
  )

  await db.query(`
    UPDATE loja_cobranca
    SET

      status = 'expirado',

      atualizado_em = NOW()

    WHERE id = $1
  `, [pendente.id])

  /*
    CANCELA PLANO PENDENTE
  */

  await db.query(`
    UPDATE loja_plano
    SET

      status = 'cancelado',

      data_cancelamento = NOW()

    WHERE id = $1
  `, [
    pendente.loja_plano_id
  ])
}


    /*
      GERA PIX
    */

    const pagamento =
      await billingService
        .gerarPixPlano({

          loja,

          plano
        })

    /*
      CRIA ASSINATURA
    */

    const assinatura =
      await db.query(`
        INSERT INTO loja_plano (

          loja_id,

          plano_id,

          data_inicio,

          ciclo_inicio,

          ciclo_fim,

          status,

          gateway,

          valor_pago,

          criado_em

        )
        VALUES (

          $1,

          $2,

          NOW(),

          NOW(),

          NOW() + INTERVAL '30 days',

          'pendente',

          'mercadopago_pix',

          $3,

          NOW()

        )
        RETURNING *
      `,
      [
        loja_id,

        plano_id,

        plano.preco
      ])

    const lojaPlano =
      assinatura.rows[0]

    /*
      NORMALIZA RESPONSE MP
    */

    const paymentData =
      pagamento.body || pagamento

    /*
      PAYMENT ID
    */

    const paymentId =
      paymentData.id

    /*
      DADOS PIX
    */

    const qrData =
      paymentData
        ?.point_of_interaction
        ?.transaction_data

    /*
      SALVA COBRANÇA
    */
    await db.query(`
      INSERT INTO loja_cobranca (

        loja_plano_id,

        gateway,

        payment_id,

        valor,

        status,

        qr_code,

        copiaecola,

        vencimento,

        webhook_data

      )
      VALUES (

        $1,

        $2,

        $3,

        $4,

        $5,

        $6,

        $7,

        NOW() + INTERVAL '15 minutes',

        $8

      )
    `,
    [

      lojaPlano.id,

      'mercadopago_pix',

      paymentId,

      plano.preco,

      'pendente',

      qrData?.qr_code_base64,

      qrData?.qr_code,

      JSON.stringify(
        pagamento
      )
    ])

    return res.json({

      ok: true,

payment_id:
  paymentId,

      qr_code:
        qrData?.qr_code_base64,

      copiaecola:
        qrData?.qr_code
    })

  } catch (e) {

    console.error(e)

    return res
      .status(500)
      .json({

        erro:
          "Erro ao gerar PIX"
      })
  }
}

/* =========================================
   STATUS PIX
========================================= */

exports.statusPix = async (
  req,
  res
) => {

  try {

    const {
      payment_id
    } = req.params

  const cobranca =
    await db.query(`
      SELECT
        *
      FROM loja_cobranca
      WHERE payment_id = $1
      LIMIT 1
    `,
    [payment_id])

    if (
      !cobranca.rows.length
    ) {

      return res
        .status(404)
        .json({
          erro:
            "Cobrança não encontrada"
        })
    }

    return res.json(
      cobranca.rows[0]
    )

  } catch (e) {

    console.error(e)

    return res
      .status(500)
      .json({
        erro:
          "Erro ao consultar status"
      })
  }
}

/* =========================================
   WEBHOOK MERCADO PAGO
========================================= */

exports.webhook = async (
  req,
  res
) => {

  try {

    console.log(
      "🔥 WEBHOOK MP:",
      JSON.stringify(req.body)
    )

const {
  type,
  action,
  data
} = req.body

/* =========================
   PAYMENT
========================= */

if (
  type === "payment" ||
  action?.startsWith("payment.")
)
{

  const paymentId =
    data.id

  console.log(
    "💰 PAYMENT:",
    paymentId
  )

  /*
    CONSULTA MP
  */

  const pagamento =
    await buscarPagamento(
      paymentId
    )

  console.log(
    "📄 PAYMENT:",
    JSON.stringify(
      pagamento
    )
  )

  /*
    STATUS REAL
  */

  const status =
    pagamento.status

  console.log(
    "📌 STATUS:",
    status
  )

/*
  APROVADO
*/

if (
  status === "approved"
) {

  /*
    ASSINATURA RECORRENTE
  */

  const subscriptionId =
    pagamento.preapproval_id

  /*
    ===================================
    FLUXO PIX
    ===================================
  */

  if (
    !subscriptionId
  ) {

    console.log(
      "💠 PAGAMENTO PIX"
    )

    /*
      COBRANÇA
    */

    const cobranca =
      await db.query(`
        SELECT *
        FROM loja_cobranca
        WHERE payment_id = $1
        LIMIT 1
      `, [paymentId])

    if (
      !cobranca.rows.length
    ) {

      console.log(
        "⚠️ Cobrança não encontrada"
      )

      return res.sendStatus(200)
    }

    const cobrancaData =
      cobranca.rows[0]

    /*
      JÁ PROCESSADO
    */

    if (

      cobrancaData.status ===
        "pago" ||

      cobrancaData.status ===
        "cancelado" ||

      cobrancaData.status ===
        "expirado"

    ) {

      console.log(
        "ℹ️ PIX já processado"
      )

      return res.sendStatus(200)
    }

    /*
      ATUALIZA COBRANÇA
    */

    await db.query(`
      UPDATE loja_cobranca
      SET

        status = 'pago',

        pago_em = NOW(),

        webhook_data = $1,

        atualizado_em = NOW()

      WHERE id = $2
    `,
    [
      JSON.stringify(
        pagamento
      ),

      cobrancaData.id
    ])

/*
  DADOS DO NOVO PLANO
*/

const novoPlano =
  await db.query(`
    SELECT *
    FROM loja_plano
    WHERE id = $1
    LIMIT 1
  `,
  [
    cobrancaData.loja_plano_id
  ])

if (
  novoPlano.rows.length
) {

  const planoNovo =
    novoPlano.rows[0]

  /*
    CANCELA PLANOS ANTIGOS
  */

  await db.query(`
    UPDATE loja_plano
    SET

      status = 'cancelado',

      data_cancelamento = NOW()

    WHERE loja_id = $1

    AND status = 'ativo'

    AND id != $2
  `,
  [
    planoNovo.loja_id,

    planoNovo.id
  ])

  console.log(
    "🗑️ Plano antigo cancelado"
  )
}


    /*
      ATIVA PLANO
    */

    await db.query(`
      UPDATE loja_plano
      SET

        status = 'ativo',

        data_pagamento = NOW(),

        ciclo_inicio = NOW(),

        ciclo_fim =
          NOW() + INTERVAL '30 days'

      WHERE id = $1
    `,
    [
      cobrancaData.loja_plano_id
    ])

    console.log(
      "✅ Plano ativado via PIX"
    )

    return res.sendStatus(200)
  }

  /*
    ===================================
    FLUXO ASSINATURA ANTIGO
    ===================================
  */

  const novaAssinatura =
    await db.query(`
      SELECT *
      FROM loja_plano
      WHERE subscription_id = $1
      LIMIT 1
    `, [subscriptionId])

  if (
    novaAssinatura.rows.length
  ) {

    const nova =
      novaAssinatura.rows[0]

    /*
      CANCELA ANTIGA
    */

    await db.query(`
      UPDATE loja_plano
      SET

        status = 'cancelado',

        data_cancelamento = NOW()

      WHERE loja_id = $1

      AND status = 'ativo'

      AND id != $2
    `,
    [
      nova.loja_id,

      nova.id
    ])

    /*
      ATIVA NOVA
    */

    await db.query(`
      UPDATE loja_plano
      SET

        status = 'ativo',

        data_pagamento = NOW(),

        ciclo_inicio = NOW(),

        ciclo_fim =
          NOW() + INTERVAL '30 days'

      WHERE id = $1
    `,
    [nova.id])

    console.log(
      "✅ Plano ativado via PAYMENT"
    )
  }
}

  /* REJEITADO*/
  if (
    status === "rejected"
  ) 
  {

    await db.query(`
      UPDATE loja_plano
      SET
        status = 'inadimplente'
      WHERE subscription_id = $1
    `, [
      pagamento.preapproval_id
    ])

    console.log(
      "🚫 Pagamento rejeitado"
    )
  }
}


    /* =========================
       ASSINATURA
    ========================= */
    if (
      type === "subscription_preapproval" ||
      action === "subscription_preapproval"
    )

    {

      const subscriptionId =
        data.id

      if (
        action === "created"
      ) {

        console.log(
          "ℹ️ Assinatura criada aguardando pagamento"
        )

        return res.sendStatus(200)
      }

/*
  CONSULTA MP
*/

const assinaturaMp =
  await buscarAssinatura(
    subscriptionId
  )

console.log(
  "📄 ASSINATURA MP:",
  JSON.stringify(
    assinaturaMp
  )
)

const status =
  assinaturaMp.status

      console.log(
        "📦 Assinatura:",
        subscriptionId
      )

      console.log(
        "📌 STATUS:",
        status
      )

      /* =========================
         APROVADO
      ========================= */

      if (
        status === "authorized"
      ) 

      {

        /*
          NOVA ASSINATURA
        */

        const novaAssinatura =
          await db.query(`
            SELECT *
            FROM loja_plano
            WHERE subscription_id = $1
            LIMIT 1
          `, [subscriptionId])

        if (
          novaAssinatura.rows.length
        ) {

          const nova =
            novaAssinatura.rows[0]

            /*
              JÁ ATIVO
            */

            if (
              nova.status === "ativo"
            ) {

              console.log(
                "ℹ️ Assinatura já ativa"
              )

              return res.sendStatus(200)
            }

          /*
            ASSINATURA ANTIGA
          */

          const assinaturaAntiga =
            await db.query(`
              SELECT *
              FROM loja_plano
              WHERE loja_id = $1
              AND status = 'ativo'
              AND id != $2
              ORDER BY id DESC
              LIMIT 1
            `, [
              nova.loja_id,
              nova.id
            ])

          /*
            CANCELA ANTIGA
          */

          if (
            assinaturaAntiga.rows.length
          ) {

            const antiga =
              assinaturaAntiga.rows[0]

            /*
              CANCELA MP ANTIGO
            */

            if (
              antiga.subscription_id
            ) {

              try {

                await billingService
                  .cancelarAssinatura(
                    antiga.subscription_id
                  )

              } catch (e) {

                console.error(
                  "Erro cancelando assinatura antiga MP:",
                  e
                )
              }
            }

            /*
              CANCELA LOCAL
            */

            await db.query(`
              UPDATE loja_plano
              SET
                status = 'cancelado',
                data_cancelamento = NOW()
              WHERE id = $1
            `, [antiga.id])
          }

          /*
            ATIVA NOVA
          */

          await db.query(`
            UPDATE loja_plano
            SET
              status = 'ativo',
              usados = 0,
              data_pagamento = NOW(),
              ciclo_inicio = NOW(),
              ciclo_fim = NOW() + INTERVAL '30 days'
            WHERE subscription_id = $1
          `, [subscriptionId])

          console.log(
            "✅ Novo plano ativado"
          )

          console.log(
            "🏢 Loja:",
            nova.loja_id
          )

          console.log(
            "📦 Plano:",
            nova.plano_id
          )

          console.log(
            "💳 Subscription:",
            subscriptionId
          )

        }
      }

      /* =========================
         CANCELADO
      ========================= */

      if (
        status === "cancelled" ||
        status === "canceled"
      ) {

        await db.query(`
          UPDATE loja_plano
          SET
            status = 'cancelado',
            data_cancelamento = NOW()
          WHERE subscription_id = $1
        `, [subscriptionId])

        console.log(
          "❌ Plano cancelado"
        )
      }

      /* =========================
         PENDENTE
      ========================= */

      if (
        status === "pending"
      ) {

        await db.query(`
          UPDATE loja_plano
          SET
            status = 'pendente'
          WHERE subscription_id = $1
        `, [subscriptionId])

        console.log(
          "⏳ Pagamento pendente"
        )
      }

      /* =========================
         PAUSADO
      ========================= */

      if (
        status === "paused"
      ) {

        await db.query(`
          UPDATE loja_plano
          SET
            status = 'pausado'
          WHERE subscription_id = $1
        `, [subscriptionId])

        console.log(
          "⏸️ Plano pausado"
        )
      }

      /* =========================
         REJEITADO
      ========================= */

      if (
        status === "rejected"
      ) {

      await db.query(`
        UPDATE loja_plano
        SET
          status = 'inadimplente'
        WHERE subscription_id = $1
      `, [
        subscriptionId
      ])

      console.log(
        "🚫 Pagamento rejeitado"
      )
      }
    }

    res.sendStatus(200)

  } catch (e) {

    console.error(
      "❌ ERRO WEBHOOK:",
      e
    )

    res.sendStatus(500)
  }
}