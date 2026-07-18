'use strict';

const fs = require('fs');
const path = require('path');
const crypto = require('crypto');
const childProcess = require('child_process');

const render = require('./lib/render');

const TARGET = __dirname;
if (!process.env.A8_SOURCE_PACKAGE_ROOT) {
  throw new Error('set A8_SOURCE_PACKAGE_ROOT to the complete-source package root');
}
const WORKSPACE = path.resolve(process.env.A8_SOURCE_PACKAGE_ROOT);
const HTE_RAW = path.join(WORKSPACE, '06_supplementary_evidence', 'ra_gca_cg_hte_32_raw');
const V8_RAW = path.join(WORKSPACE, '06_supplementary_evidence', 'ra_gca_v8_32_raw');
const STATIC_DIR = path.join(TARGET, 'assets', 'static');
const GIF_DIR = path.join(TARGET, 'assets', 'gif');
const QA_DIR = path.join(TARGET, 'qa');
const RUNTIME_DIR = path.join(TARGET, '.runtime_tmp');
const STAGE = path.join(RUNTIME_DIR, 'stage');
const FRAME_COUNT = 36;
const GIF_DELAY_CS = 12;
const ALGORITHM = 'RA-GCA-CGHTE';
const EXPECTED_CASE_COUNT = 32;
const SAFETY_DISTANCE_M = 0.60;

const OUTPUTS = {
  typical: 'assets/static/01_典型任务.png',
  parameter: 'assets/static/02_参数鲁棒核心优势.png',
  formation: 'assets/static/03_编队PP-CBF.png',
  mechanismGif: 'assets/gif/01_参数机理.gif',
  formationGif: 'assets/gif/02_三机队形变换.gif',
  cbfGif: 'assets/gif/03_PP-CBF开关.gif',
  sourceHashes: 'source_data_sha256.json',
  manifest: 'VISUAL_MANIFEST.json',
  qaReport: 'qa/qa_report.json',
  staticContact: 'qa/静态图联系表.png',
  gifContact: 'qa/GIF首中末帧联系表.png',
};

function normalizeRelative(file) {
  return path.relative(WORKSPACE, file).split(path.sep).join('/');
}

function assertInsideTarget(candidate) {
  // 所有写入路径必须位于视觉目录内，避免误写工程其他区域。
  const resolved = path.resolve(candidate);
  const prefix = `${path.resolve(TARGET)}${path.sep}`;
  if (resolved !== path.resolve(TARGET) && !resolved.startsWith(prefix)) {
    throw new Error(`write path escapes exclusive target: ${resolved}`);
  }
  return resolved;
}

function ensureDirectory(directory) {
  fs.mkdirSync(assertInsideTarget(directory), { recursive: true });
}

function sha256File(file) {
  // 大文件采用分块读取，避免一次性占用过多内存。
  const hash = crypto.createHash('sha256');
  const descriptor = fs.openSync(file, 'r');
  const buffer = Buffer.allocUnsafe(1024 * 1024);
  try {
    let bytesRead;
    do {
      bytesRead = fs.readSync(descriptor, buffer, 0, buffer.length, null);
      if (bytesRead > 0) hash.update(buffer.subarray(0, bytesRead));
    } while (bytesRead > 0);
  } finally {
    fs.closeSync(descriptor);
  }
  return hash.digest('hex');
}

function sha256Buffer(buffer) {
  return crypto.createHash('sha256').update(buffer).digest('hex');
}

function parseCsvLine(line) {
  // 逐字符处理引号和转义双引号，保持原始CSV列边界。
  const values = [];
  let current = '';
  let quoted = false;
  for (let index = 0; index < line.length; index += 1) {
    const character = line[index];
    if (character === '"') {
      if (quoted && line[index + 1] === '"') {
        current += '"';
        index += 1;
      } else {
        quoted = !quoted;
      }
    } else if (character === ',' && !quoted) {
      values.push(current);
      current = '';
    } else {
      current += character;
    }
  }
  values.push(current);
  if (quoted) throw new Error('unterminated CSV quote');
  return values;
}

function loadNumericCsv(file, requiredColumns) {
  const content = fs.readFileSync(file, 'utf8').trimEnd();
  const lines = content.split(/\r?\n/);
  if (lines.length < 3) throw new Error(`CSV has insufficient rows: ${file}`);
  const header = parseCsvLine(lines[0].replace(/^\uFEFF/, ''));
  const indices = new Map(header.map((name, index) => [name, index]));
  for (const column of requiredColumns) {
    if (!indices.has(column)) throw new Error(`missing column ${column}: ${file}`);
  }
  const result = Object.fromEntries(requiredColumns.map(column => [column, new Array(lines.length - 1)]));
  for (let rowIndex = 1; rowIndex < lines.length; rowIndex += 1) {
    const cells = lines[rowIndex].includes('"') ? parseCsvLine(lines[rowIndex]) : lines[rowIndex].split(',');
    for (const column of requiredColumns) {
      const value = Number(cells[indices.get(column)]);
      if (!Number.isFinite(value)) {
        throw new Error(`non-finite ${column} at data row ${rowIndex}: ${file}`);
      }
      result[column][rowIndex - 1] = value;
    }
  }
  result.__rows = lines.length - 1;
  result.__file = file;
  return result;
}

function probeHteIdentity(file) {
  const descriptor = fs.openSync(file, 'r');
  const buffer = Buffer.allocUnsafe(256 * 1024);
  let bytesRead;
  try {
    bytesRead = fs.readSync(descriptor, buffer, 0, buffer.length, 0);
  } finally {
    fs.closeSync(descriptor);
  }
  const text = buffer.subarray(0, bytesRead).toString('utf8');
  const lines = text.split(/\r?\n/);
  if (lines.length < 2) throw new Error(`cannot probe HTE identity: ${file}`);
  const header = parseCsvLine(lines[0].replace(/^\uFEFF/, ''));
  const first = lines[1].split(',');
  const basename = path.basename(file, '.csv');
  if (basename.startsWith('Scene07')) {
    for (const vehicle of [1, 2, 3]) {
      const column = `controllerDiagnostics${vehicle}[16]`;
      const index = header.indexOf(column);
      if (index < 0 || Number(first[index]) !== 914) {
        throw new Error(`formal diagnostic identity mismatch ${column}: ${file}`);
      }
    }
  } else {
    const index = header.indexOf('controllerDiagnostics[16]');
    if (index < 0 || Number(first[index]) !== 914) {
      throw new Error(`formal diagnostic identity mismatch controllerDiagnostics[16]: ${file}`);
    }
  }
}

function listCsv(directory) {
  if (!fs.existsSync(directory)) throw new Error(`source directory missing: ${directory}`);
  return fs.readdirSync(directory)
    .filter(name => name.toLowerCase().endsWith('.csv'))
    .sort((left, right) => left.localeCompare(right, 'en'));
}

function precheckSources() {
  const hte = listCsv(HTE_RAW);
  const v8 = listCsv(V8_RAW);
  if (hte.length !== EXPECTED_CASE_COUNT || v8.length !== EXPECTED_CASE_COUNT) {
    throw new Error(`expected 32+32 raw files, got ${hte.length}+${v8.length}`);
  }
  if (JSON.stringify(hte) !== JSON.stringify(v8)) {
    throw new Error('formal-main and V8 accepted case names differ');
  }
  for (const name of hte) probeHteIdentity(path.join(HTE_RAW, name));
  return { hte, v8 };
}

function sourceHashDocument(caseNames) {
  const sets = [];
  for (const [id, directory, role] of [
    ['formal_main_full32', HTE_RAW, 'RA-GCA-CGHTE formal evidence'],
    ['v8_accepted_full32', V8_RAW, 'RA-GCA/V8 accepted comparison set'],
  ]) {
    const files = caseNames.map(name => {
      const file = path.join(directory, name);
      return {
        case_id: path.basename(name, '.csv'),
        path: normalizeRelative(file),
        size_bytes: fs.statSync(file).size,
        sha256: sha256File(file),
      };
    });
    const aggregate = crypto.createHash('sha256');
    for (const item of files) aggregate.update(`${item.path}\0${item.sha256}\n`, 'utf8');
    sets.push({ id, role, count: files.length, aggregate_sha256: aggregate.digest('hex'), files });
  }
  return {
    schema_version: 1,
    generated_at: new Date().toISOString(),
    hash_algorithm: 'SHA-256',
    algorithm: ALGORITHM,
    source_policy: 'read-only; source files are not copied or modified',
    total_file_count: sets.reduce((sum, item) => sum + item.count, 0),
    sets,
  };
}

function writeJson(file, value) {
  ensureDirectory(path.dirname(file));
  fs.writeFileSync(assertInsideTarget(file), `${JSON.stringify(value, null, 2)}\n`, 'utf8');
}

function column(data, name) {
  if (!data[name]) throw new Error(`column not loaded: ${name}`);
  return data[name];
}

const SINGLE_COLUMNS = [
  'time',
  'referenceVector[1]', 'referenceVector[2]', 'referenceVector[3]',
  'quadChassisTest17_1.body.r_0[1]',
  'quadChassisTest17_1.body.r_0[2]',
  'quadChassisTest17_1.body.r_0[3]',
];

function loadSingle(directory, caseId, extra = []) {
  return loadNumericCsv(path.join(directory, `${caseId}.csv`), [...SINGLE_COLUMNS, ...extra]);
}

function points3(data, prefix) {
  const axes = [1, 2, 3].map(index => column(data, `${prefix}[${index}]`));
  return axes[0].map((_, row) => [axes[0][row], axes[1][row], axes[2][row]]);
}

function singleReference(data) {
  return points3(data, 'referenceVector');
}

function singleActual(data) {
  const x = column(data, 'quadChassisTest17_1.body.r_0[1]');
  const y = column(data, 'quadChassisTest17_1.body.r_0[2]');
  const z = column(data, 'quadChassisTest17_1.body.r_0[3]');
  return x.map((_, row) => [x[row], y[row], z[row]]);
}

function rmse3(reference, actual) {
  if (reference.length !== actual.length || reference.length === 0) throw new Error('RMSE length mismatch');
  let squared = 0;
  for (let index = 0; index < reference.length; index += 1) {
    for (let axis = 0; axis < 3; axis += 1) {
      const error = actual[index][axis] - reference[index][axis];
      squared += error * error;
    }
  }
  return Math.sqrt(squared / reference.length);
}

function trimByTime(data, maximumTime) {
  const indices = column(data, 'time').map((time, index) => ({ time, index }))
    .filter(item => item.time <= maximumTime + 1e-9)
    .map(item => item.index);
  const result = {};
  for (const [name, values] of Object.entries(data)) {
    result[name] = Array.isArray(values) ? indices.map(index => values[index]) : values;
  }
  result.__rows = indices.length;
  return result;
}

function median(values) {
  const sorted = [...values].sort((left, right) => left - right);
  const middle = Math.floor(sorted.length / 2);
  return sorted.length % 2 ? sorted[middle] : (sorted[middle - 1] + sorted[middle]) / 2;
}

const FORMATION_COLUMNS = [
  'time',
  'quad1.body.r_0[1]', 'quad1.body.r_0[2]', 'quad1.body.r_0[3]',
  'quad2.body.r_0[1]', 'quad2.body.r_0[2]', 'quad2.body.r_0[3]',
  'quad3.body.r_0[1]', 'quad3.body.r_0[2]', 'quad3.body.r_0[3]',
  'formationReference[1]', 'formationReference[2]', 'formationReference[3]',
  'formationReference[10]', 'formationReference[11]', 'formationReference[12]',
  'formationReference[19]', 'formationReference[20]', 'formationReference[21]',
];

function loadFormation(caseId) {
  const data = loadNumericCsv(path.join(HTE_RAW, `${caseId}.csv`), FORMATION_COLUMNS);
  const vehicles = [1, 2, 3].map(vehicle => {
    const axes = [1, 2, 3].map(axis => column(data, `quad${vehicle}.body.r_0[${axis}]`));
    return axes[0].map((_, row) => [axes[0][row], axes[1][row], axes[2][row]]);
  });
  const starts = [1, 10, 19];
  const desired = starts.map(start => {
    const axes = [start, start + 1, start + 2].map(index => column(data, `formationReference[${index}]`));
    return axes[0].map((_, row) => [axes[0][row], axes[1][row], axes[2][row]]);
  });
  const distance = [];
  const currentPair = [];
  let minimum = Number.POSITIVE_INFINITY;
  let closestIndex = 0;
  let closestPair = [0, 1];
  for (let row = 0; row < data.__rows; row += 1) {
    let rowMinimum = Number.POSITIVE_INFINITY;
    let rowPair = [0, 1];
    for (const pair of [[0, 1], [0, 2], [1, 2]]) {
      const left = vehicles[pair[0]][row];
      const right = vehicles[pair[1]][row];
      const d = Math.hypot(left[0] - right[0], left[1] - right[1], left[2] - right[2]);
      if (d < rowMinimum) {
        rowMinimum = d;
        rowPair = pair;
      }
    }
    distance.push(rowMinimum);
    currentPair.push(rowPair);
    if (rowMinimum < minimum) {
      minimum = rowMinimum;
      closestIndex = row;
      closestPair = rowPair;
    }
  }
  const time = column(data, 'time');
  const dt = time.length > 1 ? time[1] - time[0] : 0;
  const violationSeconds = distance.filter(value => value < SAFETY_DISTANCE_M).length * dt;
  const formationError = time.map((_, row) => {
    let squared = 0;
    for (let vehicle = 0; vehicle < 3; vehicle += 1) {
      for (let axis = 0; axis < 3; axis += 1) {
        const error = vehicles[vehicle][row][axis] - desired[vehicle][row][axis];
        squared += error * error;
      }
    }
    return Math.sqrt(squared / 3);
  });
  const globalFormationRmse = Math.sqrt(formationError.reduce((sum, value) => sum + value * value, 0) / formationError.length);
  return {
    time,
    vehicles,
    actual: vehicles,
    desired,
    distance,
    currentPair,
    minimum,
    closestIndex,
    closestPair,
    violationSeconds,
    formationError,
    globalFormationRmse,
    source: path.join(HTE_RAW, `${caseId}.csv`),
  };
}

function xyDomain(collections, padding = 0.10) {
  const points = collections.flat().map(point => [point[0], point[1]]);
  let minX = Math.min(...points.map(point => point[0]));
  let maxX = Math.max(...points.map(point => point[0]));
  let minY = Math.min(...points.map(point => point[1]));
  let maxY = Math.max(...points.map(point => point[1]));
  if (maxX - minX < 1e-6) { minX -= 0.5; maxX += 0.5; }
  if (maxY - minY < 1e-6) { minY -= 0.5; maxY += 0.5; }
  const padX = (maxX - minX) * padding;
  const padY = (maxY - minY) * padding;
  return { minX: minX - padX, maxX: maxX + padX, minY: minY - padY, maxY: maxY + padY };
}

function buildDatasets() {
  const step = trimByTime(loadSingle(HTE_RAW, 'Scene01S_Z'), 30);
  const spiral = loadSingle(HTE_RAW, 'Scene02');
  const eight = loadSingle(HTE_RAW, 'Scene03');
  const stepReference = singleReference(step);
  const stepActual = singleActual(step);
  const spiralReference = singleReference(spiral);
  const spiralActual = singleActual(spiral);
  const eightReference = singleReference(eight);
  const eightActual = singleActual(eight);
  const typical = {
    step: {
      time: column(step, 'time'),
      reference: stepReference.map(point => point[2]),
      actual: stepActual.map(point => point[2]),
      rmse: rmse3(stepReference, stepActual),
    },
    spiral: { reference: spiralReference, actual: spiralActual, rmse: rmse3(spiralReference, spiralActual) },
    eight: { reference: eightReference, actual: eightActual, rmse: rmse3(eightReference, eightActual) },
  };

  const parameterCases = [
    ['Scene05B_C010', '旋翼惯量失配 C010'],
    ['Scene05B_C011', '组合失配 C011'],
    ['Scene05B_C100', '阻力参数失配 C100'],
    ['Scene05B_C101', '组合失配 C101'],
    ['Scene05B_LiftMinus10', '升力效率 −10%'],
    ['Scene05B_PayloadPlus10', '载荷 +10%'],
  ].map(([caseId, label]) => {
    const hte = loadSingle(HTE_RAW, caseId);
    const v8 = loadSingle(V8_RAW, caseId);
    const reference = singleReference(hte);
    const hteRmse = rmse3(reference, singleActual(hte));
    const v8Rmse = rmse3(singleReference(v8), singleActual(v8));
    return { caseId, label, hte: hteRmse, v8: v8Rmse, reduction: 100 * (1 - hteRmse / v8Rmse) };
  });

  const mechanismExtra = [
    'controllerDiagnostics[11]', 'controllerDiagnostics[12]',
    'controllerDiagnostics[13]', 'controllerDiagnostics[14]',
    'scenarioDiagnostics[1]', 'scenarioDiagnostics[2]',
  ];
  const mechanismHte = trimByTime(loadSingle(HTE_RAW, 'Scene05B_LiftMinus10', mechanismExtra), 12);
  const mechanismV8 = trimByTime(loadSingle(V8_RAW, 'Scene05B_LiftMinus10'), 12);
  const mechanismReference = singleReference(mechanismHte).map(point => point[2]);
  const mechanism = {
    time: column(mechanismHte, 'time'),
    reference: mechanismReference,
    hte: singleActual(mechanismHte).map(point => point[2]),
    v8: singleActual(mechanismV8).map(point => point[2]),
    scaleEstimate: column(mechanismHte, 'controllerDiagnostics[11]'),
    scale: column(mechanismHte, 'controllerDiagnostics[12]'),
    gate: column(mechanismHte, 'controllerDiagnostics[13]'),
    innovation: column(mechanismHte, 'controllerDiagnostics[14]'),
    targetScale: column(mechanismHte, 'scenarioDiagnostics[2]')[0] / column(mechanismHte, 'scenarioDiagnostics[1]')[0],
  };
  mechanism.finalScale = mechanism.scale[mechanism.scale.length - 1];

  const formationB = loadFormation('Scene07B');
  const formationOff = loadFormation('Scene07COff');
  const formationOn = loadFormation('Scene07COnPredictiveV5C');
  const cbfDomain = xyDomain([...formationOff.vehicles, ...formationOn.vehicles]);
  const formationDomain = xyDomain([...formationB.actual, ...formationB.desired], 0.15);

  return {
    typical,
    parameter: {
      cases: parameterCases,
      medianReduction: median(parameterCases.map(item => item.reduction)),
      mechanism,
    },
    formation: { off: formationOff, on: formationOn },
    parameterAnimation: mechanism,
    formationAnimation: { ...formationB, domain: formationDomain },
    cbfAnimation: { time: formationOff.time, off: formationOff, on: formationOn, domain: cbfDomain },
  };
}

function loadModuleAt(candidate) {
  if (!candidate) return null;
  return fs.existsSync(path.join(candidate, 'package.json')) ? require(candidate) : null;
}

function globalNodeRoots() {
  const roots = (process.env.NODE_PATH || '').split(path.delimiter).filter(Boolean);
  const command = process.platform === 'win32'
    ? [process.env.ComSpec || 'cmd.exe', ['/d', '/s', '/c', 'npm root -g']]
    : ['npm', ['root', '-g']];
  const npm = childProcess.spawnSync(command[0], command[1], { encoding: 'utf8', windowsHide: true });
  if (npm.status === 0 && npm.stdout.trim()) roots.push(npm.stdout.trim());
  return [...new Set(roots.map(root => path.resolve(root)))];
}

function resolveNodeModule(moduleName, environmentName) {
  const configured = process.env[environmentName];
  if (configured) {
    const loaded = loadModuleAt(configured);
    if (!loaded) throw new Error(`${environmentName} does not contain ${moduleName}: ${configured}`);
    return loaded;
  }
  try {
    return require(moduleName);
  } catch (error) {
    if (error.code !== 'MODULE_NOT_FOUND') throw error;
  }
  for (const root of globalNodeRoots()) {
    for (const candidate of [path.join(root, moduleName), path.join(root, 'openclaw', 'node_modules', moduleName)]) {
      const loaded = loadModuleAt(candidate);
      if (loaded) return loaded;
    }
  }
  throw new Error(`offline Node module not found: ${moduleName}; set ${environmentName} or NODE_PATH`);
}

function browserDependencies() {
  const playwright = resolveNodeModule('playwright-core', 'PLAYWRIGHT_CORE_PATH');
  const pngjs = resolveNodeModule('pngjs', 'PNGJS_PATH');
  const browsers = [
    process.env.CHROME_PATH,
    playwright.chromium.executablePath(),
    process.env.ProgramFiles && path.join(process.env.ProgramFiles, 'Google', 'Chrome', 'Application', 'chrome.exe'),
    process.env['ProgramFiles(x86)'] && path.join(process.env['ProgramFiles(x86)'], 'Microsoft', 'Edge', 'Application', 'msedge.exe'),
  ].filter(Boolean);
  const executablePath = browsers.find(candidate => fs.existsSync(candidate));
  if (!executablePath) throw new Error('offline Chromium/Chrome executable not found');
  return { chromium: playwright.chromium, PNG: pngjs.PNG, executablePath };
}

function pngStats(PNG, buffer) {
  const image = PNG.sync.read(buffer);
  if (image.width !== render.WIDTH || image.height !== render.HEIGHT) {
    throw new Error(`PNG dimension mismatch: ${image.width}x${image.height}`);
  }
  const unique = new Set();
  let count = 0;
  let sum = 0;
  let squared = 0;
  for (let pixel = 0; pixel < image.width * image.height; pixel += 19) {
    const offset = pixel * 4;
    const r = image.data[offset];
    const g = image.data[offset + 1];
    const b = image.data[offset + 2];
    const luminance = 0.2126 * r + 0.7152 * g + 0.0722 * b;
    sum += luminance;
    squared += luminance * luminance;
    count += 1;
    unique.add(`${r >> 4},${g >> 4},${b >> 4}`);
  }
  const mean = sum / count;
  const variance = squared / count - mean * mean;
  if (unique.size < 24 || variance < 80) {
    throw new Error(`PNG appears blank or low-information: colors=${unique.size}, variance=${variance}`);
  }
  return { width: image.width, height: image.height, sampled_color_bins: unique.size, luminance_variance: variance };
}

async function layoutReport(page) {
  return page.evaluate(() => {
    const width = 1280;
    const height = 720;
    const texts = [...document.querySelectorAll('svg text')].map((element, index) => {
      const box = element.getBoundingClientRect();
      return {
        index,
        value: element.textContent,
        left: box.left,
        right: box.right,
        top: box.top,
        bottom: box.bottom,
      };
    });
    const overflow = texts.filter(item => item.left < -0.5 || item.top < -0.5 || item.right > width + 0.5 || item.bottom > height + 0.5);
    const overlaps = [];
    for (let leftIndex = 0; leftIndex < texts.length; leftIndex += 1) {
      for (let rightIndex = leftIndex + 1; rightIndex < texts.length; rightIndex += 1) {
        const left = texts[leftIndex];
        const right = texts[rightIndex];
        const overlapWidth = Math.min(left.right, right.right) - Math.max(left.left, right.left);
        const overlapHeight = Math.min(left.bottom, right.bottom) - Math.max(left.top, right.top);
        if (overlapWidth > 1.5 && overlapHeight > 1.5) {
          overlaps.push({ left: left.value, right: right.value, overlapWidth, overlapHeight });
        }
      }
    }
    return { text_count: texts.length, overflow, overlaps };
  });
}

async function renderSvgBuffer(page, svg, checkLayout = false) {
  await page.setContent(`<!doctype html><html><head><meta charset="utf-8"><style>html,body{margin:0;width:1280px;height:720px;overflow:hidden;background:#f4f7f9}svg{display:block}</style></head><body>${svg}</body></html>`, { waitUntil: 'load' });
  await page.evaluate(() => document.fonts.ready);
  let layout = null;
  if (checkLayout) {
    layout = await layoutReport(page);
    if (layout.overflow.length > 0 || layout.overlaps.length > 0) {
      throw new Error(`text layout failure: overflow=${layout.overflow.length}, overlaps=${layout.overlaps.length}; ${JSON.stringify(layout.overlaps.slice(0, 4))}`);
    }
  }
  const buffer = await page.screenshot({ type: 'png', clip: { x: 0, y: 0, width: render.WIDTH, height: render.HEIGHT } });
  return { buffer, layout };
}

async function renderStatic(page, PNG, stageFile, svg) {
  const rendered = await renderSvgBuffer(page, svg, true);
  const stats = pngStats(PNG, rendered.buffer);
  ensureDirectory(path.dirname(stageFile));
  fs.writeFileSync(stageFile, rendered.buffer);
  return { ...stats, text_layout: rendered.layout };
}

async function renderGif(page, PNG, stageFile, frameRenderer, name) {
  throw new Error('legacy composite GIF generation is disabled; use generate_visuals.js and encode_gifs_pillow.py');
}

async function verifyGifDecode(page, gifBuffer) {
  const source = `data:image/gif;base64,${gifBuffer.toString('base64')}`;
  await page.setContent(`<html><body style="margin:0"><img id="asset" src="${source}"></body></html>`, { waitUntil: 'load' });
  return page.evaluate(async () => {
    const image = document.getElementById('asset');
    await image.decode();
    return { width: image.naturalWidth, height: image.naturalHeight, complete: image.complete };
  });
}

async function renderContactSheet(page, file, rows, title) {
  const cells = rows.map(row => row.map(item => `<div class="cell"><img src="data:image/png;base64,${item.buffer.toString('base64')}"><span>${item.label}</span></div>`).join('')).join('');
  const html = `<!doctype html><html><head><meta charset="utf-8"><style>
    html,body{margin:0;width:1280px;height:720px;overflow:hidden;background:#eef2f5;font-family:Microsoft YaHei,Arial,sans-serif;color:#17212b}
    h1{height:54px;margin:0;padding:14px 28px 0;font-size:24px;box-sizing:border-box;letter-spacing:0}
    .grid{display:grid;grid-template-columns:repeat(3,1fr);grid-template-rows:repeat(${rows.length},1fr);gap:8px;padding:0 12px 12px;height:666px;box-sizing:border-box}
    .cell{position:relative;overflow:hidden;background:white;border:1px solid #cfd7df}
    img{width:100%;height:100%;object-fit:contain;display:block}
    span{position:absolute;left:8px;top:8px;background:rgba(23,33,43,.86);color:#fff;padding:4px 8px;font-size:12px;border-radius:3px;letter-spacing:0}
  </style></head><body><h1>${title}</h1><div class="grid">${cells}</div></body></html>`;
  await page.setContent(html, { waitUntil: 'load' });
  await page.evaluate(() => Promise.all([...document.images].map(image => image.decode())));
  const buffer = await page.screenshot({ type: 'png', clip: { x: 0, y: 0, width: 1280, height: 720 } });
  ensureDirectory(path.dirname(file));
  fs.writeFileSync(file, buffer);
  return buffer;
}

function fileMetadata(relative, kind, title, sources, metrics, extra = {}) {
  const file = path.join(STAGE, relative);
  return {
    path: relative.split(path.sep).join('/'),
    kind,
    title,
    algorithm_label: ALGORITHM,
    language: 'zh-CN',
    width_px: render.WIDTH,
    height_px: render.HEIGHT,
    size_bytes: fs.statSync(file).size,
    sha256: sha256File(file),
    sources,
    metrics,
    ...extra,
  };
}

function companionMetadata(relative) {
  const file = path.join(TARGET, relative);
  if (!fs.existsSync(file)) throw new Error(`companion file missing before manifest: ${relative}`);
  return { path: relative.replaceAll(path.sep, '/'), size_bytes: fs.statSync(file).size, sha256: sha256File(file) };
}

function commitStage(relativeFiles) {
  const operations = [];
  for (const relative of relativeFiles) {
    const source = path.join(STAGE, relative);
    const destination = path.join(TARGET, relative);
    if (!fs.existsSync(source)) throw new Error(`staged file missing: ${relative}`);
    if (fs.existsSync(destination)) throw new Error(`destination already exists: ${relative}`);
    ensureDirectory(path.dirname(destination));
    operations.push({ source, destination });
  }
  const committed = [];
  try {
    for (const operation of operations) {
      fs.renameSync(operation.source, operation.destination);
      committed.push(operation);
    }
  } catch (error) {
    for (const operation of committed.reverse()) {
      if (fs.existsSync(operation.destination) && !fs.existsSync(operation.source)) {
        fs.renameSync(operation.destination, operation.source);
      }
    }
    throw error;
  }
}

function assertCleanDestination() {
  for (const relative of Object.values(OUTPUTS)) {
    if (fs.existsSync(path.join(TARGET, relative))) {
      throw new Error(`refusing to overwrite existing deliverable: ${relative}`);
    }
  }
  if (fs.existsSync(STAGE) && fs.readdirSync(STAGE).length > 0) {
    throw new Error(`staging directory is not empty: ${STAGE}`);
  }
}

async function main() {
  process.stdout.write('[precheck] exclusive target and source sets\n');
  if (!fs.existsSync(HTE_RAW) || !fs.existsSync(V8_RAW)) {
    throw new Error(`paired source roots are missing under ${WORKSPACE}`);
  }
  ensureDirectory(RUNTIME_DIR);
  ensureDirectory(STAGE);
  assertCleanDestination();
  const cases = precheckSources();
  const sourceHashes = sourceHashDocument(cases.hte);
  writeJson(path.join(STAGE, OUTPUTS.sourceHashes), sourceHashes);
  process.stdout.write(`[precheck] source hashes complete: ${sourceHashes.total_file_count} files\n`);

  const datasets = buildDatasets();
  const { chromium, PNG, executablePath } = browserDependencies();
  process.env.TMP = RUNTIME_DIR;
  process.env.TEMP = RUNTIME_DIR;
  const browser = await chromium.launch({
    executablePath,
    headless: true,
    args: [
      '--disable-background-networking',
      '--disable-component-update',
      '--disable-default-apps',
      '--disable-extensions',
      '--disable-sync',
      '--metrics-recording-only',
      '--no-first-run',
      `--disk-cache-dir=${path.join(RUNTIME_DIR, 'chrome-cache')}`,
    ],
  });
  let staticQa;
  let gifQa;
  try {
    const page = await browser.newPage({ viewport: { width: render.WIDTH, height: render.HEIGHT }, deviceScaleFactor: 1 });
    process.stdout.write('[render] static 1/3 typical tasks\n');
    const typicalStats = await renderStatic(page, PNG, path.join(STAGE, OUTPUTS.typical), render.typicalSvg(datasets.typical));
    process.stdout.write('[render] static 2/3 parameter robustness\n');
    const parameterStats = await renderStatic(page, PNG, path.join(STAGE, OUTPUTS.parameter), render.parameterSvg(datasets.parameter));
    process.stdout.write('[render] static 3/3 formation PP-CBF\n');
    const formationStats = await renderStatic(page, PNG, path.join(STAGE, OUTPUTS.formation), render.formationSvg(datasets.formation));

    process.stdout.write('[render] GIF 1/3 parameter mechanism\n');
    const mechanismGif = await renderGif(page, PNG, path.join(STAGE, OUTPUTS.mechanismGif), progress => render.parameterFrameSvg(datasets.parameterAnimation, progress), 'parameter mechanism');
    process.stdout.write('[render] GIF 2/3 three-vehicle transformation\n');
    const formationGif = await renderGif(page, PNG, path.join(STAGE, OUTPUTS.formationGif), progress => render.formationFrameSvg(datasets.formationAnimation, progress), 'formation transformation');
    process.stdout.write('[render] GIF 3/3 PP-CBF switch\n');
    const cbfGif = await renderGif(page, PNG, path.join(STAGE, OUTPUTS.cbfGif), progress => render.cbfFrameSvg(datasets.cbfAnimation, progress), 'PP-CBF switch');

    for (const [name, relative] of [
      ['parameter mechanism', OUTPUTS.mechanismGif],
      ['formation transformation', OUTPUTS.formationGif],
      ['PP-CBF switch', OUTPUTS.cbfGif],
    ]) {
      const decoded = await verifyGifDecode(page, fs.readFileSync(path.join(STAGE, relative)));
      if (!decoded.complete || decoded.width !== render.WIDTH || decoded.height !== render.HEIGHT) {
        throw new Error(`browser GIF decode failed for ${name}: ${JSON.stringify(decoded)}`);
      }
    }

    const staticRows = [[
      { label: '典型任务', buffer: fs.readFileSync(path.join(STAGE, OUTPUTS.typical)) },
      { label: '参数鲁棒核心优势', buffer: fs.readFileSync(path.join(STAGE, OUTPUTS.parameter)) },
      { label: '编队PP-CBF', buffer: fs.readFileSync(path.join(STAGE, OUTPUTS.formation)) },
    ]];
    await renderContactSheet(page, path.join(STAGE, OUTPUTS.staticContact), staticRows, '静态图视觉QA联系表');
    const gifRows = [
      mechanismGif.samples.map(item => ({ label: `参数机理 · 帧${item.frame + 1}`, buffer: item.buffer })),
      formationGif.samples.map(item => ({ label: `队形变换 · 帧${item.frame + 1}`, buffer: item.buffer })),
      cbfGif.samples.map(item => ({ label: `PP-CBF开关 · 帧${item.frame + 1}`, buffer: item.buffer })),
    ];
    await renderContactSheet(page, path.join(STAGE, OUTPUTS.gifContact), gifRows, 'GIF首帧 / 中间帧 / 末帧视觉QA联系表');
    staticQa = { typical: typicalStats, parameter: parameterStats, formation: formationStats };
    gifQa = { mechanism: mechanismGif, formation: formationGif, cbf: cbfGif };
  } finally {
    await browser.close();
  }

  const qaReport = {
    schema_version: 1,
    generated_at: new Date().toISOString(),
    status: 'passed',
    checks: {
    exclusive_write_root: '05_visuals',
      sysplorer_started: false,
      source_sets: { formal_main_raw: cases.hte.length, v8_accepted_raw: cases.v8.length },
      source_hash_count: sourceHashes.total_file_count,
      static_asset_count: 3,
      gif_asset_count: 3,
      expected_dimensions_px: [render.WIDTH, render.HEIGHT],
      algorithm_label: ALGORITHM,
      language: 'zh-CN',
      text_overflow_count: 0,
      text_overlap_count: 0,
    },
    static: staticQa,
    gif: Object.fromEntries(Object.entries(gifQa).map(([key, value]) => [key, {
      width: value.width,
      height: value.height,
      frame_count: value.frame_count,
      frame_delay_cs: value.frame_delay_cs,
      duration_s: value.duration_s,
      text_layout_samples: value.text_layout_samples,
    }])),
    metric_cross_checks: {
      parameter_cases: datasets.parameter.cases,
      parameter_median_rmse_reduction_percent: datasets.parameter.medianReduction,
      lift_minus_10_target_scale: datasets.parameterAnimation.targetScale,
      lift_minus_10_scale_at_12s: datasets.parameterAnimation.finalScale,
      formation_scene07b_minimum_distance_m: datasets.formationAnimation.minimum,
      formation_scene07b_global_rmse_m: datasets.formationAnimation.globalFormationRmse,
      cbf_off_minimum_distance_m: datasets.formation.off.minimum,
      cbf_on_minimum_distance_m: datasets.formation.on.minimum,
      cbf_off_violation_seconds: datasets.formation.off.violationSeconds,
      cbf_on_violation_seconds: datasets.formation.on.violationSeconds,
    },
  };
  writeJson(path.join(STAGE, OUTPUTS.qaReport), qaReport);

  const assets = [
    fileMetadata(OUTPUTS.typical, 'static_png', '典型任务：标准阶跃、螺旋爬升与8字轨迹', ['formal_main_full32/Scene01S_Z', 'formal_main_full32/Scene02', 'formal_main_full32/Scene03'], { rmse_m: { step: datasets.typical.step.rmse, spiral: datasets.typical.spiral.rmse, figure8: datasets.typical.eight.rmse } }),
    fileMetadata(OUTPUTS.parameter, 'static_png', '参数鲁棒核心优势', datasets.parameter.cases.flatMap(item => [`formal_main_full32/${item.caseId}`, `v8_accepted_full32/${item.caseId}`]), { median_rmse_reduction_percent: datasets.parameter.medianReduction }),
    fileMetadata(OUTPUTS.formation, 'static_png', '编队PP-CBF开关对照', ['formal_main_full32/Scene07COff', 'formal_main_full32/Scene07COnPredictiveV5C'], { off_minimum_distance_m: datasets.formation.off.minimum, on_minimum_distance_m: datasets.formation.on.minimum, threshold_m: SAFETY_DISTANCE_M }),
    fileMetadata(OUTPUTS.mechanismGif, 'animated_gif', '参数机理：置信门控悬停推力估计', ['formal_main_full32/Scene05B_LiftMinus10', 'v8_accepted_full32/Scene05B_LiftMinus10'], { target_scale: datasets.parameterAnimation.targetScale, scale_at_12s: datasets.parameterAnimation.finalScale }, { frame_count: FRAME_COUNT, frame_delay_cs: GIF_DELAY_CS, duration_s: FRAME_COUNT * GIF_DELAY_CS / 100 }),
    fileMetadata(OUTPUTS.formationGif, 'animated_gif', '三机队形变换', ['formal_main_full32/Scene07B'], { minimum_distance_m: datasets.formationAnimation.minimum, formation_rmse_m: datasets.formationAnimation.globalFormationRmse }, { frame_count: FRAME_COUNT, frame_delay_cs: GIF_DELAY_CS, duration_s: FRAME_COUNT * GIF_DELAY_CS / 100 }),
    fileMetadata(OUTPUTS.cbfGif, 'animated_gif', 'PP-CBF开关对照', ['formal_main_full32/Scene07COff', 'formal_main_full32/Scene07COnPredictiveV5C'], { off_minimum_distance_m: datasets.formation.off.minimum, on_minimum_distance_m: datasets.formation.on.minimum, threshold_m: SAFETY_DISTANCE_M }, { frame_count: FRAME_COUNT, frame_delay_cs: GIF_DELAY_CS, duration_s: FRAME_COUNT * GIF_DELAY_CS / 100 }),
  ];
  const qaArtifacts = [OUTPUTS.staticContact, OUTPUTS.gifContact, OUTPUTS.qaReport].map(relative => {
    const file = path.join(STAGE, relative);
    return { path: relative, size_bytes: fs.statSync(file).size, sha256: sha256File(file) };
  });
  const sourceHashFile = path.join(STAGE, OUTPUTS.sourceHashes);
  const manifest = {
    schema_version: 1,
    package_status: 'validated_formal_assets',
    generated_at: new Date().toISOString(),
    algorithm: {
      display_name: ALGORITHM,
      engineering_id: 'RA_GCA_CG_HTE',
      diagnostic_version_code: 914,
    },
    canvas: { width_px: render.WIDTH, height_px: render.HEIGHT, language: 'zh-CN' },
    generation: {
      mode: 'offline',
      sysplorer_started: false,
      script: 'generate_visuals.js',
      source_hash_file: OUTPUTS.sourceHashes,
      source_hash_file_sha256: sha256File(sourceHashFile),
    },
    source_sets: sourceHashes.sets.map(item => ({ id: item.id, count: item.count, aggregate_sha256: item.aggregate_sha256 })),
    asset_count: assets.length,
    assets,
    qa_artifacts: qaArtifacts,
    companion_files: [
      'generate_visuals.js', 'verify_assets.js', 'README_生成与独立验收.md',
      'lib/render.js', 'lib/gif.js',
    ].map(companionMetadata),
  };
  writeJson(path.join(STAGE, OUTPUTS.manifest), manifest);

  const commitFiles = [
    OUTPUTS.typical, OUTPUTS.parameter, OUTPUTS.formation,
    OUTPUTS.mechanismGif, OUTPUTS.formationGif, OUTPUTS.cbfGif,
    OUTPUTS.staticContact, OUTPUTS.gifContact, OUTPUTS.qaReport,
    OUTPUTS.sourceHashes, OUTPUTS.manifest,
  ];
  commitStage(commitFiles);
  process.stdout.write(`[complete] committed ${assets.length} assets after all validations passed\n`);
}

function writeFailureRca(error) {
  const file = path.join(TARGET, 'RCA_GENERATION_FAILED.md');
  const body = `# 生成失败RCA\n\n- 时间：${new Date().toISOString()}\n- 状态：停止；未声明最终包完成。\n- 独占目录：\`${TARGET}\`\n- Sysplorer：未启动。\n\n## 错误\n\n\`\`\`text\n${String(error && error.stack ? error.stack : error)}\n\`\`\`\n\n## 处置\n\n- 最终资产采用暂存后提交；失败时保留 \`.runtime_tmp/stage\` 供复核。\n- 不修改源 raw 或工作区其他文件。\n- 修复前不得将本目录标记为最终包。\n`;
  fs.writeFileSync(assertInsideTarget(file), body, 'utf8');
}

if (require.main === module) {
  main().catch(error => {
    try {
      writeFailureRca(error);
    } catch (rcaError) {
      process.stderr.write(`RCA write failed: ${rcaError.stack || rcaError}\n`);
    }
    process.stderr.write(`${error.stack || error}\n`);
    process.exitCode = 1;
  });
}

module.exports = {
  TARGET,
  WORKSPACE,
  RUNTIME_DIR,
  STAGE,
  FRAME_COUNT,
  GIF_DELAY_CS,
  ALGORITHM,
  EXPECTED_CASE_COUNT,
  SAFETY_DISTANCE_M,
  buildDatasets,
  browserDependencies,
  ensureDirectory,
  pngStats,
  precheckSources,
  renderContactSheet,
  renderSvgBuffer,
  sha256File,
  sourceHashDocument,
  verifyGifDecode,
  writeJson,
  render,
};
