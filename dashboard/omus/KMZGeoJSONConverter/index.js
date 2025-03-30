const fs = require('fs');
const path = require('path');
const AdmZip = require('adm-zip');
const tj = require('@tmcw/togeojson');
const { JSDOM } = require('jsdom');

const kmzFolder = './data';
const outputFilePath = './rutas.json';

function kmzToGeoJSON(kmzPath) {
  const zip = new AdmZip(kmzPath);
  const kmlEntry = zip.getEntries().find(e => e.entryName.endsWith('.kml'));

  if (!kmlEntry) {
    throw new Error(`No KML found in ${kmzPath}`);
  }

  const kmlData = kmlEntry.getData().toString('utf8');
  const dom = new JSDOM(kmlData, { contentType: 'text/xml' });

  return tj.kml(dom.window.document);
}

function main() {
  const files = fs.readdirSync(kmzFolder).filter(f => f.endsWith('.kmz'));

  const result = {};

  for (const file of files) {
    const geojson = kmzToGeoJSON(path.join(kmzFolder, file));

    const name = file
      .replace('Ruta ', '')
      .replace('.kmz', '')
      .trim()
      .toUpperCase();

    result[name] = {
      type: 'FeatureCollection',
      name,
      features: geojson.features,
    };
  }

  fs.writeFileSync(outputFilePath, JSON.stringify(result, null, 2));
  console.log(`✅ JSON creado en: ${outputFilePath}`);
}

main();
