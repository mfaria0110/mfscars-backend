const express = require("express");
const router = express.Router();

const multer = require("multer");

const empresaController = require("./empresa.controller");
const auth = require("../../shared/middlewares/auth");

/* ===============================
   CONFIG UPLOAD
================================ */
const storage = multer.diskStorage({
  destination: "uploads/",
  filename: (req, file, cb) => {
    cb(null, Date.now() + "-" + file.originalname);
  }
});

const upload = multer({ storage });

/* ===============================
   ROTAS EMPRESA
================================ */

/* criar empresa */
router.post("/", empresaController.criar);

/* empresa logada */
router.get("/me", auth, empresaController.me);

/* 🔥 CORRIGIDO AQUI */
router.get("/loja/:id", empresaController.lojaPublica);

/* detalhes empresa */
router.get("/:id", empresaController.detalhes);

/* veículos da empresa */
router.get("/:id/veiculos", empresaController.veiculos);

/* ===============================
   UPLOAD BANNER LOJA
================================ */
router.post(
  "/upload-banner/:id",
  upload.single("banner"),
 empresaController.uploadBanner
);

module.exports = router;