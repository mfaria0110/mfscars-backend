require("dotenv").config()

const express = require("express")
const cors = require("cors")
const path = require("path")
const fs = require("fs")
const http = require("http")

const cron =
  require("node-cron")

const {
  verificarPlanos
} = require("./jobs/verificarPlanos.job")

const app = express()

/* =========================
   GARANTIR PASTA UPLOADS
========================= */
const uploadsPath = path.join(
  __dirname,
  "../uploads"
)

if (!fs.existsSync(uploadsPath)) {
  fs.mkdirSync(
    uploadsPath,
    { recursive: true }
  )
}

/* =========================
   CORS
========================= */
app.use(cors({
  origin: [
    "https://mfscars.com.br",
    "https://www.mfscars.com.br",
    "https://app.mfscars.com.br",
    "https://www.app.mfscars.com.br",
    "http://localhost:5173"
  ],
  credentials: true
}))

/* =========================
   JSON
========================= */
app.use(express.json())

/* =========================
   LOGGER GLOBAL
========================= */
app.use((req, res, next) => {

  console.log("=================================")

  console.log(
    `➡️ ${req.method} ${req.originalUrl}`
  )

  console.log(
    "AUTH:",
    req.headers.authorization
      ? "TOKEN OK"
      : "SEM TOKEN"
  )

  console.log(
    "LOJA:",
    req.headers["x-loja-id"] || "SEM LOJA"
  )

  console.log("=================================")

  next()
})

/* =========================
   ARQUIVOS ESTÁTICOS
========================= */
app.use(
  "/uploads",
  express.static(
    path.join(
      __dirname,
      "../uploads"
    ),
    {
      maxAge: "7d",
      etag: true,
      dotfiles: "deny",
      index: false
    }
  )
)

app.use(
  "/assets",
  express.static(
    path.join(
      __dirname,
      "../assets"
    )
  )
)

/* =========================
   IMPORT ROTAS
========================= */
const authRoutes =
  require("./modules/auth/auth.routes")

const empresaRoutes =
  require("./modules/empresa/empresa.routes")

const veiculoRoutes =
  require("./modules/veiculo/veiculo.routes")

const vendaRoutes =
  require("./modules/venda/vendas.routes")

const planoRoutes =
  require("./modules/plano/plano.routes")

const permissoesRoutes =
  require("./modules/permissao/permissoes.routes")

const leadsRoutes =
  require("./modules/lead/leads.routes")

const dashboardRoutes =
  require("./modules/dashboard/dashboard.routes")

const publicRoutes =
  require("./modules/public/public.routes")

const favoritosRoutes =
  require("./modules/favorito/favorito.routes")

const lojasRoutes =
  require("./modules/loja/lojas.routes")

const usuarioRoutes =
  require("./modules/usuario/usuario.routes")

const catalogoRoutes =
  require("./modules/catalogo/catalogo.routes")

const veiculoProprietarioRoutes =
  require("./modules/veiculo/veiculo.proprietario.routes")

const veiculoDocumentoRoutes =
  require("./modules/veiculo/veiculo.documento.routes")

const billingRoutes =
  require("./modules/billing/billing.routes")

const financeiroRoutes =
  require(
    "./modules/financeiro/financeiro.routes"
  )

const menuRoutes =
  require("./modules/menu/menu.routes")

const juridicoRoutes =
  require(
    "./modules/juridico/juridico.routes"
  )

const empresaAdminRoutes =
  require(
    "./modules/empresa-admin/empresa-admin.routes"
  )

/* =========================
   ROTAS API
========================= */
app.use("/auth", authRoutes)

app.use("/public", publicRoutes)

app.use("/empresas", empresaRoutes)

app.use("/veiculos", veiculoRoutes)

app.use("/vendas", vendaRoutes)

app.use("/planos", planoRoutes)

app.use("/permissoes", permissoesRoutes)

app.use("/leads", leadsRoutes)

app.use("/dashboard", dashboardRoutes)

app.use("/favoritos", favoritosRoutes)

app.use("/usuarios", usuarioRoutes)

app.use("/lojas", lojasRoutes)

app.use("/catalogos", catalogoRoutes)

app.use(
  "/veiculo-proprietario",
  veiculoProprietarioRoutes
)

app.use(
  "/veiculo-documento",
  veiculoDocumentoRoutes
)

app.use("/billing", billingRoutes)

app.use(
  "/financeiro",
  financeiroRoutes
)

app.use("/menus", menuRoutes)

app.use(
  "/juridico",
  juridicoRoutes
)

app.use(
  "/empresa-admin",
  empresaAdminRoutes
)

/* =========================
   ROTA TESTE
========================= */
app.get("/", (req, res) => {

  res.send(
    "API MFS Cars rodando 🚀"
  )
})

/* =========================
   404
========================= */
app.use((req, res) => {

  res.status(404).json({
    erro: "Rota não encontrada"
  })
})

/* =========================
   ERRO GLOBAL
========================= */
app.use((
  err,
  req,
  res,
  next
) => {

  console.error(
    "🔥 ERRO GLOBAL"
  )

  console.error({
    rota:
      req.originalUrl,

    metodo:
      req.method,

    erro:
      err.message,

    stack:
      err.stack
  })

  res.status(500).json({
    erro:
      err.message ||
      "Erro interno no servidor"
  })
})

/* =========================
   START SERVER
========================= */
const PORT =
  process.env.PORT || 3001

const server =
  http.createServer(app)

/* =========================
   PERFORMANCE
========================= */
server.maxConnections = 1000

server.keepAliveTimeout = 65000

server.headersTimeout = 66000

/* =========================
   JOB SaaS
========================= */
cron.schedule(
  "0 2 * * *",
  async () => {

    console.log(
      "⏰ Executando JOB SaaS..."
    )

    await verificarPlanos()
  }
)

/* =========================
   START
========================= */
server.listen(
  PORT,
  "0.0.0.0",
  () => {

    console.log(
      `🚀 API MFS Cars rodando na porta ${PORT}`
    )
  }
)