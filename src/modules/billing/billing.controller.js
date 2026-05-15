const db =
  require("../../shared/database/db")

const billingService =
  require("./billing.service")

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
  AND criado_em < NOW() - INTERVAL '30 minutes'
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
    REUTILIZA CHECKOUT
  */

if (
  diffMinutos < 30 &&
  pendente.plano_id === plano_id
)
   {

/*
  PLANO DIFERENTE
*/

if (
  pendente.plano_id !== plano_id
) {

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

    console.log(
      "♻️ Reutilizando checkout pendente"
    )

    const webhookData =
      pendente.webhook_data || {}

    return res.json({

      ok: true,

      reutilizado: true,

      init_point:
        webhookData.init_point
    })
  }

  /*
    EXPIRA PENDENTE ANTIGA
  */

  await db.query(`
    UPDATE loja_plano
    SET
      status = 'cancelado',
      data_cancelamento = NOW()
    WHERE id = $1
  `, [pendente.id])

  console.log(
    "⏰ Pendente antiga cancelada"
  )
}
    /* =========================
       ASSINATURA MP
    ========================= */

    const assinatura =
      await billingService
        .criarAssinatura({

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
        NOW()
      )
    `, [
      loja_id,
      plano_id,
      assinatura.id,
      JSON.stringify(
        assinatura
      )
    ])

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
       ASSINATURA
    ========================= */

if (
  type === "subscription_preapproval" ||
  action === "subscription_preapproval"
)

    {

      const subscriptionId =
        data.id

      const status =
        data.status

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
        `, [subscriptionId])

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