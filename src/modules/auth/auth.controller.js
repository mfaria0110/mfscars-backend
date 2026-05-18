const db = require('../../shared/database/db');
const jwt = require("jsonwebtoken")
const bcrypt = require("bcrypt")

/* ===============================
   LOGIN
================================ */
exports.login = async (req, res) => {
  try {
    const { email, senha } = req.body;

    const r = await db.query(`
      SELECT u.*, e.nome as empresa_nome
      FROM usuario u
      JOIN empresa e ON e.id = u.empresa_id
      WHERE u.email = $1
    `, [email]);

    const user = r.rows[0];

    if (!user) {
      return res.status(401).json({ erro: "Usuário não encontrado" });
    }

    if (!user.ativo) {
      return res.status(403).json({ erro: "Usuário inativo" });
    }

    /* ===============================
   EMPRESA DESATIVADA
================================ */

const empresaStatus =
  await db.query(`

    SELECT
      ativo

    FROM empresa

    WHERE id = $1

  `, [

    user.empresa_id

  ])

if (

  empresaStatus.rows.length &&

  !empresaStatus.rows[0].ativo

) {

  return res.status(403).json({

    erro:

      "Empresa desativada. Entre em contato com o suporte."

  })
}

    const senhaValida = await bcrypt.compare(senha, user.senha);
    if (!senhaValida) {
      return res.status(401).json({ erro: "Senha inválida" });
    }

    /* 🔥 LOJAS */
let lojas = [];

/* 👑 MASTER */
if (user.master) {

  const rLojas = await db.query(`
    SELECT id, nome, cidade, estado, empresa_id
    FROM loja
    ORDER BY id
  `);

  lojas = rLojas.rows;

/* 🏢 ADMIN */
} else if (user.tipo === "admin") {

  const rLojas = await db.query(`
    SELECT id, nome, cidade, estado, empresa_id
    FROM loja
    WHERE empresa_id = $1
    ORDER BY id
  `, [user.empresa_id]);

  lojas = rLojas.rows;

/* 👤 USUÁRIO */
} else {

  const rLojas = await db.query(`
    SELECT l.id, l.nome, l.cidade, l.estado, l.empresa_id
    FROM usuario_loja ul
    JOIN loja l ON l.id = ul.loja_id
    WHERE ul.usuario_id = $1
    AND ul.ativo = true
  `, [user.id]);

  lojas = rLojas.rows;
}

    if (!user.master && lojas.length === 0) {
      return res.status(403).json({
        erro: "Usuário sem acesso a lojas"
      });
    }

    /* 🔐 TOKEN BASE */
    const payload = {
      id: user.id,
      empresa_id: user.empresa_id,
      loja_id: null,
      master: user.master,
      tipo: user.tipo,
      ativo: user.ativo,
      perfil: null,
      permissoes: []
    };

    const accessToken = jwt.sign(payload, process.env.JWT_SECRET, {
      expiresIn: "1h",
      issuer: "mfsCars"
    });

    const refreshToken = jwt.sign(payload, process.env.JWT_SECRET, {
      expiresIn: "7d"
    });

    res.json({
      accessToken,
      refreshToken,
      lojas,
      usuario: {
        id: user.id,
        nome: user.nome,
        tipo: user.tipo,
        empresa_id: user.empresa_id,
        master: user.master
      },
      empresa: {
        id: user.empresa_id,
        nome: user.empresa_nome
      }
    });

  } catch (e) {
    console.error("ERRO LOGIN:", e);
    res.status(500).json({ erro: "Erro no login" });
  }
};


/* ===============================
   SELECIONAR LOJA (COM PERFIL)
================================ */
exports.selecionarLoja = async (req, res) => {
  try {
    const { loja_id } = req.body
    const usuario = req.user

    if (!loja_id) {
      return res.status(400).json({
        erro: "Loja obrigatória"
      })
    }

    /* ===============================
       BUSCA LOJA
    ============================== */
    const lojaResult = await db.query(
      `
      SELECT id, empresa_id, status
      FROM loja
      WHERE id = $1
      `,
      [loja_id]
    )

    if (!lojaResult.rows.length) {
      return res.status(404).json({
        erro: "Loja não encontrada"
      })
    }

    const loja = lojaResult.rows[0]

    /*
      Master pode acessar qualquer loja
    */
if (!usuario.master && usuario.tipo !== "admin") {

  const acesso = await db.query(`
    SELECT perfil
    FROM usuario_loja
    WHERE usuario_id = $1
    AND loja_id = $2
    AND ativo = true
  `, [usuario.id, loja_id])

  if (!acesso.rows.length) {
    return res.status(403).json({
      erro: "Sem acesso a esta loja"
    })
  }
}

    /* ===============================
       PERFIL
    ============================== */
let perfil = null

if (usuario.master) {
  perfil = "master"
} else if (usuario.tipo === "admin") {
  perfil = "admin" // 🔥 FIXO
} else {
  const perfilResult = await db.query(`
    SELECT perfil
    FROM usuario_loja
    WHERE usuario_id = $1
    AND loja_id = $2
    AND ativo = true
    LIMIT 1
  `, [usuario.id, loja_id])

  perfil = perfilResult.rows[0]?.perfil || null
}

    /* ===============================
       PERMISSÕES
    ============================== */
let permissoes = []

if (usuario.master) {

  const perms = await db.query(`
    SELECT chave
    FROM permissoes
  `)

  permissoes = perms.rows.map(p => p.chave)

} else if (usuario.tipo === "admin") {

  // 🔥 ADMIN → pega role GLOBAL (sem loja)
  const perms = await db.query(`
    SELECT DISTINCT p.chave
    FROM usuario_role ur
    JOIN role_permissao rp ON rp.role_id = ur.role_id
    JOIN permissoes p ON p.id = rp.permissao_id
    WHERE ur.usuario_id = $1
    AND ur.loja_id IS NULL
  `, [usuario.id])

  permissoes = perms.rows.map(p => p.chave)

} else {

  // 🔥 USUÁRIO NORMAL → por loja
  const perms = await db.query(`
    SELECT DISTINCT p.chave
    FROM usuario_role ur
    JOIN role_permissao rp ON rp.role_id = ur.role_id
    JOIN permissoes p ON p.id = rp.permissao_id
    WHERE ur.usuario_id = $1
    AND ur.loja_id = $2
  `, [usuario.id, loja_id])

  permissoes = perms.rows.map(p => p.chave)
}

    /* ===============================
       TOKEN FINAL
    ============================== */
const payload = {

  id:
    usuario.id,

  empresa_id:
    loja.empresa_id,

  loja_id,

  master:
    usuario.master,

  tipo:
    usuario.tipo,

  ativo:
    usuario.ativo,

  perfil,

  permissoes
}

/* ===============================
   ACCESS TOKEN
================================ */
const accessToken = jwt.sign(
  payload,
  process.env.JWT_SECRET,
  {
    expiresIn: "1h",
    issuer: "mfsCars"
  }
)

/* ===============================
   REFRESH TOKEN
================================ */
const refreshToken = jwt.sign(
  payload,
  process.env.JWT_SECRET,
  {
    expiresIn: "7d",
    issuer: "mfsCars"
  }
)

res.json({
  accessToken,
  refreshToken,
  perfil,
  permissoes,
  loja_id
})

  } catch (e) {
    console.error(
      "ERRO selecionarLoja:",
      e
    )

    res.status(500).json({
      erro:
        "Erro ao selecionar loja"
    })
  }
}

/* ===============================
   CADASTRO
================================ */
exports.cadastro = async (req, res) => {

  const client = await db.connect()

  try {

    const {

  nome,
  email,
  senha,

  aceitou_termos,
  versao_termos

} = req.body

    const senhaHash = await bcrypt.hash(senha, 10)

      if (!aceitou_termos) {

        return res.status(400).json({

          erro:
            "Aceite dos termos obrigatório"

        })
      }

    await client.query("BEGIN")

    const empresaRes = await client.query(`
      INSERT INTO empresa (nome, email)
      VALUES ($1,$2)
      RETURNING id
    `, [nome, email])

    const empresa_id = empresaRes.rows[0].id

    const userRes = await client.query(`
      INSERT INTO usuario (nome, email, senha, empresa_id, tipo, ativo)
      VALUES ($1,$2,$3,$4,'admin',true)
      RETURNING id
    `, [nome, email, senhaHash, empresa_id])

    const usuario_id = userRes.rows[0].id

    const lojaRes = await client.query(`
      INSERT INTO loja (nome, empresa_id, status)
      VALUES ($1,$2,'ATIVO')
      RETURNING id
    `, [nome, empresa_id])

    const loja_id = lojaRes.rows[0].id

    await client.query(`
      INSERT INTO usuario_loja (usuario_id, loja_id, perfil, ativo)
      VALUES ($1,$2,'admin',true)
    `, [usuario_id, loja_id])


    await client.query(`
    INSERT INTO usuario_aceite_termo (
        usuario_id,
        versao,
        ip,
        loja_id,
        loja_nome
      )
    VALUES (
      $1,
      $2,
      $3,
      $4,
      $5
    )
  `, [
    usuario_id,
    versao_termos || "1.0",
    req.ip,
    loja_id,
    nome
  ])
 
    await client.query("COMMIT")
    res.json({ msg: "Conta criada com sucesso" })
  } catch (e) {
    await client.query("ROLLBACK")
    console.error(e)
    res.status(500).json({ erro: "Erro ao cadastrar" })

  } finally {
    client.release()
  }
};


/* ===============================
   ME (OBRIGATÓRIO PRA ROTA)
================================ */
exports.me = async (req, res) => {
  try {

    res.json({
      usuario: req.user
    })

  } catch (e) {
    console.error("ERRO /me:", e)
    res.status(500).json({ erro: "Erro ao validar usuário" })
  }
}

/* ===============================
   REFRESH TOKEN
================================ */
exports.refresh = async (req, res) => {
  try {
    const { refreshToken } = req.body

    if (!refreshToken) {
      return res.status(401).json({
        erro: "Refresh token não informado"
      })
    }

    const decoded = jwt.verify(
      refreshToken,
      process.env.JWT_SECRET
    )


    /* ===============================
   EMPRESA DESATIVADA
================================ */

const empresaStatus =
  await db.query(`

    SELECT
      ativo

    FROM empresa

    WHERE id = $1

  `, [

    decoded.empresa_id

  ])

if (

  empresaStatus.rows.length &&

  !empresaStatus.rows[0].ativo

) {

  return res.status(403).json({

    erro:

      "Empresa desativada"

  })
}


    const payload = {
      id: decoded.id,
      empresa_id: decoded.empresa_id,
      loja_id: decoded.loja_id || null,
      master: decoded.master,
      tipo: decoded.tipo,
      ativo: decoded.ativo,
      perfil: decoded.perfil || null,
      permissoes: decoded.permissoes || []
    }

    const newAccessToken = jwt.sign(
      payload,
      process.env.JWT_SECRET,
      {
        expiresIn: "1h",
        issuer: "mfsCars"
      }
    )

    res.json({
      accessToken: newAccessToken
    })

  } catch (e) {
    console.error(
      "ERRO REFRESH:",
      e
    )

    return res.status(401).json({
      erro: "Refresh token inválido"
    })
  }
}
