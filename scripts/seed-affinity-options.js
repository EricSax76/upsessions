#!/usr/bin/env node

const fs = require('fs');
const path = require('path');

function loadFirebaseAdmin() {
  try {
    return require('firebase-admin');
  } catch (_) {
    try {
      return require(path.resolve(__dirname, '../functions/node_modules/firebase-admin'));
    } catch (error) {
      console.error(
        'No pude cargar firebase-admin. Ejecuta `npm install` en `functions/` o instala firebase-admin en la raíz.',
      );
      throw error;
    }
  }
}

const admin = loadFirebaseAdmin();

const args = process.argv.slice(2);
const hasFlag = (flag) => args.includes(flag);
const getArgValue = (name, fallback) => {
  const index = args.findIndex((arg) => arg === name);
  if (index === -1) return fallback;
  const next = args[index + 1];
  if (!next || next.startsWith('--')) return fallback;
  return next;
};

const dryRun = hasFlag('--dry-run');
const sourcePath = getArgValue(
  '--source',
  path.resolve(__dirname, '../lib/core/constants/affinity_artist_options.dart'),
);
const targetDocPath = getArgValue('--doc', 'affinity_options/catalog');

const usage = () => {
  console.log(`
Uso:
  node scripts/seed-affinity-options.js [--dry-run] [--source <ruta_dart>] [--doc affinity_options/catalog]

Opciones:
  --dry-run      No escribe en Firestore; solo muestra resumen.
  --source       Ruta al archivo Dart con el catálogo local.
  --doc          Documento destino en Firestore (por defecto: affinity_options/catalog).
`);
};

if (hasFlag('--help') || hasFlag('-h')) {
  usage();
  process.exit(0);
}

if (!fs.existsSync(sourcePath)) {
  console.error(`No se encontró el archivo fuente: ${sourcePath}`);
  process.exit(1);
}

const source = fs.readFileSync(sourcePath, 'utf8');

const extractMapBody = (sourceText, mapName) => {
  const marker = `const Map<String, String> ${mapName} = {`;
  const start = sourceText.indexOf(marker);
  if (start === -1) {
    throw new Error(`No encontré el mapa ${mapName} en ${sourcePath}`);
  }

  const bodyStart = start + marker.length;
  const end = sourceText.indexOf('\n};', bodyStart);
  if (end === -1) {
    throw new Error(`No encontré el cierre del mapa ${mapName}`);
  }

  return sourceText.slice(bodyStart, end);
};

const parseArtists = (raw) => {
  const parsed = [];
  const seen = new Set();

  for (const token of raw.split('|')) {
    let artist = token.trim();
    if (!artist) continue;

    artist = artist.replace(/^\d+\.\s*/, '').trim();
    artist = artist.replace(/^[•·-]\s*/, '').trim();
    if (artist.endsWith('.')) {
      artist = artist.slice(0, -1).trim();
    }

    if (!artist) continue;

    const key = artist.toLowerCase();
    if (!seen.has(key)) {
      seen.add(key);
      parsed.push(artist);
    }
  }

  return parsed;
};

const parseBucketArtists = (mapBody) => {
  const result = {};
  const regex = /'([^']+)'\s*:\s*"""([\s\S]*?)"""\s*,/g;
  let match;
  while ((match = regex.exec(mapBody)) !== null) {
    const bucket = match[1];
    const raw = match[2];
    result[bucket] = parseArtists(raw);
  }
  return result;
};

const parseStyleToBucket = (mapBody) => {
  const result = {};
  const regex = /'([^']+)'\s*:\s*'([^']+)'\s*,/g;
  let match;
  while ((match = regex.exec(mapBody)) !== null) {
    result[match[1]] = match[2];
  }
  return result;
};

const bucketMapBody = extractMapBody(source, '_bucketArtistsRaw');
const styleMapBody = extractMapBody(source, '_styleToBucket');

const artistsByBucket = parseBucketArtists(bucketMapBody);
const styleToBucket = parseStyleToBucket(styleMapBody);

const artistsByStyle = {};
for (const [style, bucket] of Object.entries(styleToBucket)) {
  artistsByStyle[style] = artistsByBucket[bucket] || [];
}

const styles = Object.keys(artistsByStyle);
const totalArtists = styles.reduce(
  (sum, style) => sum + (artistsByStyle[style]?.length || 0),
  0,
);

console.log(`Fuente: ${sourcePath}`);
console.log(`Estilos detectados: ${styles.length}`);
console.log(`Opciones totales (sumadas por estilo): ${totalArtists}`);

if (dryRun) {
  const previewStyles = styles.slice(0, 3);
  for (const style of previewStyles) {
    console.log(`- ${style}: ${artistsByStyle[style].slice(0, 5).join(', ')} ...`);
  }
  console.log('Dry run completado. No se escribió en Firestore.');
  process.exit(0);
}

if (!admin.apps.length) {
  admin.initializeApp();
}

const db = admin.firestore();
const [collection, docId] = targetDocPath.split('/');

if (!collection || !docId || targetDocPath.split('/').length !== 2) {
  console.error(`--doc inválido: ${targetDocPath}. Debe ser "coleccion/documento"`);
  process.exit(1);
}

const payload = {
  artistsByStyle,
  source: 'seed-affinity-options.js',
  updatedAt: admin.firestore.FieldValue.serverTimestamp(),
};

(async () => {
  await db.collection(collection).doc(docId).set(payload, { merge: true });
  console.log(`Seed completado en Firestore: ${collection}/${docId}`);
})()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error('Seed fallido:', error);
    process.exit(1);
  });
