const db = require("../../shared/database/db");
const bcrypt = require("bcrypt");

exports.cadastro = async (req, res) => {

  const client = await db.connect();

  try {

    const {
      nome,
      email,
      senha,
      telefone,
      cidade,
      estado,
      cnpj
    } = req.body;

    /* ===============================
       🔒 VALIDAÇÃO BÁSICA
    ============================== */
    if (!nome || !email || !senha || !telefone || !cidade || !estado || !cnpj) {
      return res.status(400).json({
        erro: "Todos os campos são obrigatórios"
      });
    }

    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

    if (!emailRegex.test(email)) {
      return res.status(400).json({
        erro: "Email inválido"
      });
    }

    /* ===============================
       🔒 NORMALIZA CNPJ (remove máscara)
    ============================== */
    const cnpjLimpo = cnpj.replace(/\D/g, "");

    /* ===============================
       🔒 VALIDA EMAIL DUPLICADO
    ============================== */
    const emailExiste = await client.query(
      `SELECT id FROM usuario WHERE email = $1`,
      [email]
    );

    if (emailExiste.rows.length) {
      return res.status(400).json({
        erro: "Email já cadastrado"
      });
    }

    /* ===============================
       🔒 VALIDA CNPJ DUPLICADO
    ============================== */
    const cnpjExiste = await client.query(
      `SELECT id FROM empresa WHERE cnpj = $1`,
      [cnpjLimpo]
    );

    if (cnpjExiste.rows.length) {
      return res.status(400).json({
        erro: "CNPJ já cadastrado"
      });
    }

    const senhaHash = await bcrypt.hash(senha, 10);

    await client.query("BEGIN");

    /* ===============================
       🏢 EMPRESA
    ============================== */
    const empresaRes = await client.query(`
      INSERT INTO empresa (
        nome,
        email,
        cnpj,
        telefone,
        cidade,
        estado
      )
      VALUES ($1,$2,$3,$4,$5,$6)
      RETURNING id
    `, [
      nome,
      email,
      cnpjLimpo,
      telefone,
      cidade,
      estado
    ]);

    const empresa_id = empresaRes.rows[0].id;

    /* ===============================
       👤 USUÁRIO ADMIN
    ============================== */
    const userRes = await client.query(`
      INSERT INTO usuario (
        nome,
        email,
        senha,
        empresa_id,
        tipo,
        ativo
      )
      VALUES ($1,$2,$3,$4,'admin',true)
      RETURNING id
    `, [
      nome,
      email,
      senhaHash,
      empresa_id
    ]);

    const usuario_id = userRes.rows[0].id;

    /* ===============================
       🔥 ROLE ADMIN GLOBAL
    ============================== */
    await client.query(`
      INSERT INTO usuario_role (
        usuario_id,
        role_id,
        loja_id
      )
      VALUES ($1, 2, NULL)
    `, [usuario_id]);

    /* ===============================
       🏪 LOJA PADRÃO
    ============================== */
    const lojaRes = await client.query(`
INSERT INTO loja (
  nome,
  empresa_id,
  cidade,
  estado,
  telefone,
  email,
  cnpj,
  status
)
      VALUES ($1,$2,$3,$4,$5,$6,$7,'ATIVO')
      RETURNING id
    `, 
[
  nome,
  empresa_id,
  cidade,
  estado,
  telefone,
  email,
  cnpjLimpo
]
    
    );

    const loja_id = lojaRes.rows[0].id;

    /* ===============================
   💳 PLANO FREE
============================== */
const planoRes = await client.query(`
  SELECT id
  FROM plano
  WHERE UPPER(nome) = 'FREE'
  AND ativo = true
  LIMIT 1
`);

if (!planoRes.rows.length) {
  throw new Error(
    "Plano FREE não encontrado"
  );
}

const plano_id =
  planoRes.rows[0].id;

await client.query(`
  INSERT INTO loja_plano (
    loja_id,
    plano_id,
    data_inicio,
    status,
    valor_pago,
    forma_pagamento,
    data_pagamento,
    aviso_3_dias,
    aviso_vencido,
    usados,
    criado_em
  )
  VALUES (
    $1,
    $2,
    NOW(),
    'ativo',
    0.00,
    'gratis',
    NOW(),
    false,
    false,
    0,
    NOW()
  )
`, [
  loja_id,
  plano_id
]);

    /* ===============================
       🔗 RELAÇÃO USUÁRIO-LOJA (opcional)
    ============================== */
    await client.query(`
      INSERT INTO usuario_loja (
        usuario_id,
        loja_id,
        perfil,
        ativo
      )
      VALUES ($1,$2,'admin',true)
    `, [usuario_id, loja_id]);

    await client.query("COMMIT");

    res.status(201).json({
      msg: "Conta criada com sucesso"
    });

  } catch (e) {

    await client.query("ROLLBACK");

    console.error("ERRO CADASTRO PUBLICO:", e);

    res.status(500).json({
      erro: "Erro ao cadastrar"
    });

  } finally {
    client.release();
  }
};