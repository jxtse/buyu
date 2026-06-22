import fs from "node:fs/promises";
import path from "node:path";
import { Presentation, PresentationFile } from "@oai/artifact-tool";

const [slidesDir, outPptx, widthArg = "1600", heightArg = "900"] = process.argv.slice(2);

if (!slidesDir || !outPptx) {
  console.error("Usage: node html_screenshot_pptx.mjs <slidesDir> <outPptx> [width] [height]");
  process.exit(2);
}

const width = Number(widthArg);
const height = Number(heightArg);

const files = (await fs.readdir(slidesDir))
  .filter((file) => /^slide-\d+\.png$/i.test(file))
  .sort((a, b) => a.localeCompare(b, undefined, { numeric: true }));

if (files.length === 0) {
  throw new Error(`No slide screenshots found in ${slidesDir}`);
}

await fs.mkdir(path.dirname(outPptx), { recursive: true });

const presentation = Presentation.create({
  slideSize: { width, height },
});

for (const [index, file] of files.entries()) {
  const slide = presentation.slides.add();
  slide.images.add({
    blob: await fs.readFile(path.join(slidesDir, file)),
    contentType: "image/png",
    alt: `Slide ${index + 1}`,
    fit: "cover",
    position: { left: 0, top: 0, width, height },
  });
}

const pptx = await PresentationFile.exportPptx(presentation);
await pptx.save(outPptx);

console.log(`slides=${files.length}`);
console.log(`pptx=${outPptx}`);
