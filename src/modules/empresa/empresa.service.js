const db = require("../../shared/database/db");
const empresaRepository = require("./empresa.repository");

/* ============================= */
/* CRIAR */
/* ============================= */
exports.criar = async (dados) => {

  const slug = dados.nome
    .toLowerCase()
    .replace(/\s+/g,"-")
    .replace(/[^\w-]+/g,"");

  return await empresaRepository.criar({
    ...dados,
    slug
  });

};

/* ============================= */
/* ME */
/* ============================= */
exports.me = async (empresaId) => {
  return await empresaRepository.buscarPorId(empresaId);
};

/* ============================= */
/* DETALHES */
/* ============================= */
exports.detalhes = async (id) => {
  return await empresaRepository.buscarPorId(id);
};

/* ============================= */
/* VEÍCULOS EMPRESA */
/* ============================= */
exports.veiculos = async (id) => {
  return await empresaRepository.listarVeiculos(id);
};

/* ============================= */
/* LOJA PÚBLICA */
/* ============================= */
exports.lojaPublica = async (id) => {

  const loja = await db.query(`
    SELECT *
    FROM loja
    WHERE id=$1
  `,[id]);

  if(!loja.rows.length){
    throw new Error("Loja não encontrada");
  }

  const veiculos = await db.query(`
    SELECT
      v.*,
      (
        SELECT url
        FROM veiculo_foto
        WHERE veiculo_id=v.id
        LIMIT 1
      ) foto
    FROM veiculo v
    WHERE v.loja_id=$1
    AND v.status='disponivel'
  `,[id]);

  return {
    loja: loja.rows[0],
    veiculos: veiculos.rows
  };
};

/* ============================= */
/* LISTAR LOJAS */
/* ============================= */
exports.listarLojas = async () => {
  return await empresaRepository.listarLojas();
};