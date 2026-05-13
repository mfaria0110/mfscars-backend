const db =
  require("../../shared/database/db")

const billingService =
  require("./billing.service")

exports.testar = async (req, res) => {

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
      erro: "Erro Mercado Pago"
    })
  }
}

exports.assinar = async (req, res) => {

  try {

    const {
      loja_id,
      plano_id
    } = req.body

    if (!loja_id || !plano_id) {

      return res.status(400).json({
        erro:
          "loja_id e plano_id obrigatórios"
      })
    }

    /* =========================
       LOJA
    ========================= */

    const lojaRes = await db.query(`
      SELECT *
      FROM loja
      WHERE id = $1
    `, [loja_id])

    if (!lojaRes.rows.length) {

      return res.status(404).json({
        erro: "Loja não encontrada"
      })
    }

    const loja = lojaRes.rows[0]

    /* =========================
       PLANO
    ========================= */

    const planoRes = await db.query(`
      SELECT *
      FROM plano
      WHERE id = $1
    `, [plano_id])

    if (!planoRes.rows.length) {

      return res.status(404).json({
        erro: "Plano não encontrado"
      })
    }

    const plano = planoRes.rows[0]

    /* =========================
       ASSINATURA MP
    ========================= */

    const assinatura =
      await billingService
        .criarAssinatura({

          email: loja.email,
          plano
        })

    /* =========================
       SALVA loja_plano
    ========================= */

    await db.query(`
      INSERT INTO loja_plano (
        loja_id,
        plano_id,
	        data_inicio,
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
      JSON.stringify(assinatura)
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
      data
    } = req.body

    /* =========================
       ASSINATURA
    ========================= */

    if (
      type === "subscription_preapproval"
    ) {

      const subscriptionId =
        data.id

      console.log(
        "📦 Assinatura:",
        subscriptionId
      )

      await db.query(`
        UPDATE loja_plano
        SET
          status = 'ativo'
        WHERE subscription_id = $1
      `, [subscriptionId])

      console.log(
        "✅ Plano ativado"
      )
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
