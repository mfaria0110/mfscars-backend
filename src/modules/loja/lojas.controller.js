const service = require("./lojas.service");

const cloudinary =
  require("../../shared/cloudinary");

const fs =
  require("fs");

function getPublicId(url) {

  try {

    if (
      !url ||
      !url.includes("cloudinary")
    ) {
      return null;
    }

    const partes =
      url.split("/upload/")[1];

    const semVersao =
      partes.replace(
        /^v\d+\//,
        ""
      );

    return semVersao.replace(
      /\.[^/.]+$/,
      ""
    );

  } catch {

    return null;
  }
}

/* ===============================
   LISTAR
================================ */
exports.listar = async (req, res) => {

try {


console.log("HEADER LOJA:", req.headers["x-loja-id"]);

const lojaId = req.headers["x-loja-id"]
  ? Number(req.headers["x-loja-id"])
  : null;

    const data = await service.listar(
      req.user,
      lojaId
    );

    res.json(data);

  } catch (e) {
    tratarErro(res, e);
  }
};

/* ===============================
   DETALHES
================================ */
exports.detalhes = async (req, res) => {
  try {

    const empresaId = req.user.empresa_id;

    const data = await service.detalhes(
      req.params.id,
      empresaId
    );

    res.json(data);

  } catch (e) {
    tratarErro(res, e);
  }
};

/* ===============================
   TODAS (HEADER)
================================ */
exports.todas = async (req, res) => {
  try {
    const data = await service.todas(req.user)

    res.json(data)

  } catch (e) {
    tratarErro(res, e)
  }
}

/* ===============================
   CRIAR
================================ */
exports.criar = async (req, res) => {

  try {

    const empresaId =
      req.user.empresa_id;

    const lojaId =
      req.headers["x-loja-id"]
        ? Number(
            req.headers["x-loja-id"]
          )
        : null;

    console.log(
      "REQ BODY CREATE:",
      req.body
    );

    console.log(
      "REQ FILE CREATE:",
      req.file
    );

    const dados = {
      ...req.body
    };

    if (req.file) {

      const upload =
        await cloudinary
          .uploader
          .upload(
            req.file.path,
            {
              folder:
                "mfscars/logos"
            }
          );

      dados.logo =
        upload.secure_url;

      try {

        fs.unlinkSync(
          req.file.path
        );

      } catch {}
    }

    console.log(
      "DADOS FINAL CREATE:",
      dados
    );

    const data =
      await service.criar(
        empresaId,
        req.user.id,
        lojaId,
        dados
      );

    res.json(data);

  } catch (e) {

    tratarErro(res, e);

  }
};


/* ===============================
   ATUALIZAR
================================ */
exports.atualizar = async (req, res) => {

  try {

    const empresaId =
      req.user.empresa_id;

    console.log(
      "REQ BODY UPDATE:",
      req.body
    );

    console.log(
      "REQ FILE UPDATE:",
      req.file
    );

    const dados = {
      ...req.body
    };

    if (req.file) {

      try {

        const atual =
          await service.detalhes(
            req.params.id,
            empresaId
          );

        if (
          atual?.logo &&
          atual.logo.includes(
            "cloudinary"
          )
        ) {

          const publicId =
            getPublicId(
              atual.logo
            );

          if (publicId) {

            console.log(
              "☁️ REMOVENDO LOGO:",
              publicId
            );

            await cloudinary
              .uploader
              .destroy(
                publicId
              );
          }
        }

      } catch (err) {

        console.error(
          "Erro removendo logo antiga:",
          err
        );
      }

      const upload =
        await cloudinary
          .uploader
          .upload(
            req.file.path,
            {
              folder:
                "mfscars/logos"
            }
          );

      dados.logo =
        upload.secure_url;

      try {

        fs.unlinkSync(
          req.file.path
        );

      } catch {}
    }

    const data =
      await service.atualizar(
        req.params.id,
        empresaId,
        dados
      );

    res.json(data);

  } catch (e) {

    tratarErro(res, e);

  }
};


/* ===============================
   EXCLUIR
================================ */
exports.excluir = async (req, res) => {
  try {

    const empresaId = req.user.empresa_id;

    await service.excluir(
      req.params.id,
      empresaId,
      req.user,
      req.body.senha
    );

    res.json({ msg: "Loja excluída com sucesso" });

  } catch (e) {
    tratarErro(res, e);
  }
};

/* ===============================
   TRATAMENTO DE ERROS
================================ */
function tratarErro(res, e) {

  console.error("ERRO LOJA:", e);

  let status = 500;

  if (e.message === "Loja não encontrada") {
    status = 404;
  }

  if (
    e.message.includes("obrigatório") ||
    e.message.includes("CNPJ") ||
    e.message.includes("Senha inválida")
  ) {
    status = 400;
  }

  res.status(status).json({
    erro: e.message
  });
}