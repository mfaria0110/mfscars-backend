const puppeteer =
  require("puppeteer-core");

async function gerarPDF(
  html,
  dados
) {

  const browser =
    await puppeteer.launch({

      executablePath:
        process.env
          .PUPPETEER_EXECUTABLE_PATH ||
        "/usr/bin/chromium-browser",

      headless: true,

      args: [
        "--no-sandbox",
        "--disable-setuid-sandbox",
        "--disable-dev-shm-usage",
        "--disable-gpu"
      ]
    });

  const page =
    await browser.newPage();

  await page.setContent(
    html,
    {
      waitUntil: "networkidle0"
    }
  );

  const pdf =
    await page.pdf({

      format: "A4",

      printBackground: true,

      margin: {
        top: "15mm",
        bottom: "20mm",
        left: "12mm",
        right: "12mm"
      },

      displayHeaderFooter: true,

      headerTemplate:
        `<div></div>`,

      footerTemplate: `
        <div style="
          width:100%;
          font-size:9px;
          text-align:center;
          color:#555;
        ">

          ${dados.loja_nome || ""}
          •
          ${dados.loja_cidade || ""}/${dados.loja_estado || ""}

          <br/>

          Página
          <span class="pageNumber"></span>
          de
          <span class="totalPages"></span>

        </div>
      `
    });

  await browser.close();

  return pdf;
}

module.exports =
  gerarPDF;