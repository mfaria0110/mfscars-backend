require("dotenv").config()

const express = require("express")
const cors = require("cors")
const path = require("path")
const fs = require("fs")
const http = require("http") // 🔥 NOVO

const app = express()

/* =========================
   GARANTIR PASTA UPLOADS
========================= */
const uploadsPath = path.join(__dirname, "../uploads")

if (!fs.existsSync(uploadsPath)) {
  fs.mkdirSync(uploadsPath, { recursive: true })
}

/* =========================
   IMPORT ROTAS
========================= */
const authRoutes = require("./modules/auth/auth.routes")
const empresaRoutes = require("./modules/empresa/empresa.routes")
const veiculoRoutes = require("./modules/veiculo/veiculo.routes")
const vendaRoutes = require("./modules/venda/vendas.routes")
const planoRoutes = require("./modules/plano/plano.routes")
const permissoesRoutes = require("./modules/permissao/permissoes.routes")
const leadsRoutes = require("./modules/lead/leads.routes")
const dashboardRoutes = require("./modules/dashboard/dashboard.routes")
const publicRoutes = require("./modules/public/public.routes")
const favoritosRoutes = require("./modules/favorito/favorito.routes")
const lojasRoutes = require("./modules/loja/lojas.routes")
const usuarioRoutes = require("./modules/usuario/usuario.routes")
const catalogoRoutes = require("./modules/catalogo/catalogo.routes")

const veiculoProprietarioRoutes = require("./modules/veiculo/veiculo.proprietario.routes")
const veiculoDocumentoRoutes = require("./modules/veiculo/veiculo.documento.routes")
const billingRoutes =
  require("./modules/billing/billing.routes")

/* =========================
   MIDDLEWARES GLOBAIS
========================= */
app.use(cors({
  origin: [
    "https://mfscars.com.br",
    "https://app.mfscars.com.br"
  ],
  credentials: true
}))

app.use(express.json())

/* =========================
   ARQUIVOS ESTÁTICOS
========================= */
app.use("/uploads", express.static(
  path.join(__dirname, "../uploads"),
  {
    maxAge: "7d",
    etag: true,
    dotfiles: "deny",
    index: false
  }
))

app.use("/assets", express.static(
  path.join(__dirname, "../assets")
))

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
app.use("/veiculo-proprietario", veiculoProprietarioRoutes)
app.use("/veiculo-documento", veiculoDocumentoRoutes)

app.use("/billing", billingRoutes)

app.use("/menus", require("./modules/menu/menu.routes"))

/* =========================
   ROTA RAIZ (TESTE)
========================= */
app.get("/", (req, res) => {
  res.send("API MFS Cars rodando 🚀");
});

/* =========================
   ERROS
========================= */
app.use((err, req, res, next) => {
  console.error("🔥 ERRO GLOBAL:", err)

  res.status(500).json({
    erro: "Erro interno no servidor"
  })
})

app.use((req, res, next) => {
  console.log(`${req.method} ${req.url}`);
  next();
});

/* =========================
   START (🔥 MELHORADO)
========================= */
const PORT = process.env.PORT || 3001

const server = http.createServer(app)

/* 🔥 AUMENTA LIMITE DE CONEXÕES */
server.maxConnections = 1000

/* 🔥 TIMEOUT AJUSTADO */
server.keepAliveTimeout = 65000
server.headersTimeout = 66000

server.listen(PORT, "0.0.0.0", () => {
  console.log(`🚀 API MFS Cars rodando na porta ${PORT}`)
})
