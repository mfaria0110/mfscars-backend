const {
  MercadoPagoConfig,
  PreApproval
} = require("mercadopago")

const client =
  new MercadoPagoConfig({

    accessToken:
      process.env.MP_ACCESS_TOKEN
  })

const preApproval =
  new PreApproval(client)

module.exports = {
  preApproval
}
