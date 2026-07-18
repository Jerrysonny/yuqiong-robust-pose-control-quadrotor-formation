'use strict';

const fs = require('fs');
const path = require('path');
const crypto = require('crypto');

const ROOT = __dirname;
if (!process.env.A8_SOURCE_PACKAGE_ROOT) {
  throw new Error('set A8_SOURCE_PACKAGE_ROOT to the complete-source package root');
}
const WORKSPACE = path.resolve(process.env.A8_SOURCE_PACKAGE_ROOT);
const MANIFEST_FILE = path.join(ROOT, 'VISUAL_MANIFEST.json');
const SOURCE_HASH_FILE = path.join(ROOT, 'source_data_sha256.json');
const QA_FILE = path.join(ROOT, 'qa', 'qa_report.json');

function fail(message) {
  throw new Error(message);
}

function sha256(file) {
  const hash = crypto.createHash('sha256');
  const descriptor = fs.openSync(file, 'r');
  const buffer = Buffer.allocUnsafe(1024 * 1024);
  try {
    let count;
    do {
      count = fs.readSync(descriptor, buffer, 0, buffer.length, null);
      if (count) hash.update(buffer.subarray(0, count));
    } while (count);
  } finally {
    fs.closeSync(descriptor);
  }
  return hash.digest('hex');
}

function readJson(file) {
  if (!fs.existsSync(file)) fail(`missing JSON: ${file}`);
  return JSON.parse(fs.readFileSync(file, 'utf8'));
}

function verifyHash(file, expected, label) {
  if (!fs.existsSync(file)) fail(`missing ${label}: ${file}`);
  const actual = sha256(file);
  if (actual.toLowerCase() !== expected.toLowerCase()) {
    fail(`${label} hash mismatch: expected ${expected}, got ${actual}`);
  }
}

function pngDimensions(file) {
  // 直接读取PNG头部尺寸，避免验收阶段重新编码图像。
  const buffer = fs.readFileSync(file);
  const signature = '89504e470d0a1a0a';
  if (buffer.subarray(0, 8).toString('hex') !== signature) fail(`invalid PNG signature: ${file}`);
  return { width: buffer.readUInt32BE(16), height: buffer.readUInt32BE(20) };
}

function skipSubBlocks(buffer, offset) {
  while (offset < buffer.length) {
    const size = buffer[offset];
    offset += 1;
    if (size === 0) return offset;
    offset += size;
  }
  fail('unterminated GIF sub-block stream');
}

function gifInfo(file) {
  // 顺序解析GIF数据块，核对帧数和每帧播放间隔。
  const buffer = fs.readFileSync(file);
  const signature = buffer.subarray(0, 6).toString('ascii');
  if (signature !== 'GIF89a' && signature !== 'GIF87a') fail(`invalid GIF signature: ${file}`);
  const width = buffer.readUInt16LE(6);
  const height = buffer.readUInt16LE(8);
  const packed = buffer[10];
  let offset = 13;
  if (packed & 0x80) offset += 3 * (1 << ((packed & 0x07) + 1));
  let frameCount = 0;
  const delays = [];
  let pendingDelay = null;
  while (offset < buffer.length) {
    const marker = buffer[offset];
    offset += 1;
    if (marker === 0x3b) break;
    if (marker === 0x21) {
      const label = buffer[offset];
      offset += 1;
      if (label === 0xf9) {
        const size = buffer[offset];
        if (size !== 4) fail(`unexpected GIF graphic-control size: ${file}`);
        pendingDelay = buffer.readUInt16LE(offset + 2);
      }
      offset = skipSubBlocks(buffer, offset);
      continue;
    }
    if (marker === 0x2c) {
      if (offset + 9 > buffer.length) fail(`truncated GIF image descriptor: ${file}`);
      const imagePacked = buffer[offset + 8];
      offset += 9;
      if (imagePacked & 0x80) offset += 3 * (1 << ((imagePacked & 0x07) + 1));
      offset += 1;
      offset = skipSubBlocks(buffer, offset);
      frameCount += 1;
      delays.push(pendingDelay ?? 0);
      pendingDelay = null;
      continue;
    }
    fail(`unknown GIF marker 0x${marker.toString(16)} at ${offset - 1}: ${file}`);
  }
  return { width, height, frameCount, delays };
}

function main() {
  // 发布图、报告图、GIF和64份源数据在同一入口交叉验收。
  const manifest = readJson(MANIFEST_FILE);
  const sourceHashes = readJson(SOURCE_HASH_FILE);
  const qa = readJson(QA_FILE);

  if (manifest.package_status !== 'validated_formal_and_final_report_assets') fail('manifest is not a validated final asset set');
  if (manifest.algorithm.display_name !== 'RA-GCA-CGHTE') fail('formal algorithm label mismatch');
  if (manifest.asset_count !== 37 || manifest.release_asset_count !== 9 || manifest.assets.length !== 9) fail('release asset count mismatch');
  if (manifest.final_report_static_asset_count !== 28 || manifest.final_report_static_assets.length !== 28) fail('final report asset count mismatch');
  if (manifest.canvas.width_px !== 1280 || manifest.canvas.height_px !== 720) fail('canvas contract mismatch');
  if (manifest.generation.sysplorer_started !== false) fail('Sysplorer boundary mismatch');
  if (sourceHashes.total_file_count !== 64) fail('expected 64 source hashes');
  verifyHash(SOURCE_HASH_FILE, manifest.generation.source_hash_file_sha256, 'source hash document');

  for (const set of sourceHashes.sets) {
    // 聚合哈希同时绑定相对路径和单文件哈希，防止顺序变化。
    if (set.count !== 32 || set.files.length !== 32) fail(`source set count mismatch: ${set.id}`);
    const aggregate = crypto.createHash('sha256');
    for (const item of set.files) {
      const file = path.join(WORKSPACE, ...item.path.split('/'));
      verifyHash(file, item.sha256, `source raw ${set.id}/${item.case_id}`);
      aggregate.update(`${item.path}\0${item.sha256}\n`, 'utf8');
    }
    if (aggregate.digest('hex') !== set.aggregate_sha256) fail(`source aggregate mismatch: ${set.id}`);
  }

  let pngCount = 0;
  let gifCount = 0;
  for (const asset of manifest.assets) {
    const file = path.join(ROOT, ...asset.path.split('/'));
    verifyHash(file, asset.sha256, `asset ${asset.path}`);
    if (asset.algorithm_label !== 'RA-GCA-CGHTE') fail(`asset label mismatch: ${asset.path}`);
    if (asset.width_px !== 1280 || asset.height_px !== 720) fail(`asset dimensions in manifest mismatch: ${asset.path}`);
    if (asset.kind === 'static_png') {
      const dimensions = pngDimensions(file);
      if (dimensions.width !== 1280 || dimensions.height !== 720) fail(`PNG dimensions mismatch: ${asset.path}`);
      pngCount += 1;
    } else if (asset.kind === 'animated_gif') {
      const info = gifInfo(file);
      if (info.width !== 1280 || info.height !== 720) fail(`GIF dimensions mismatch: ${asset.path}`);
      if (info.frameCount !== asset.frame_count || info.frameCount < 30) fail(`GIF frame count mismatch: ${asset.path}`);
      if (info.delays.some(delay => delay !== asset.frame_delay_cs)) fail(`GIF frame delay mismatch: ${asset.path}`);
      gifCount += 1;
    } else {
      fail(`unknown asset kind: ${asset.kind}`);
    }
  }
  if (pngCount !== 3 || gifCount !== 6) fail(`asset type count mismatch: ${pngCount} PNG, ${gifCount} GIF`);

  for (const asset of manifest.final_report_static_assets) {
    const file = path.join(WORKSPACE, ...asset.path.split('/'));
    verifyHash(file, asset.sha256, `final report asset ${asset.asset_id}`);
    if (asset.algorithm_label !== 'RA-GCA-CGHTE') fail(`final report label mismatch: ${asset.asset_id}`);
    if (asset.kind !== 'final_report_static_png') fail(`final report kind mismatch: ${asset.asset_id}`);
    const dimensions = pngDimensions(file);
    if (dimensions.width !== asset.width_px || dimensions.height !== asset.height_px) fail(`final report dimensions mismatch: ${asset.asset_id}`);
  }

  for (const item of [...manifest.qa_artifacts, ...manifest.companion_files]) {
    verifyHash(path.join(ROOT, ...item.path.split('/')), item.sha256, `companion ${item.path}`);
  }
  if (qa.status !== 'passed') fail('QA report is not passed');
  if (qa.checks.text_overlap_count !== 0 || qa.checks.text_overflow_count !== 0) fail('QA text layout check failed');
  if (qa.checks.source_hash_count !== 64) fail('QA source hash count mismatch');
  if (qa.checks.gif_asset_count !== 6 || qa.checks.standard_encoder !== true) fail('split GIF QA contract mismatch');
  if (manifest.generation.encoder !== 'encode_gifs_pillow.py') fail('standard GIF encoder is not declared');
  const legacyAssets = [
    'assets/gif/01_参数机理.gif',
    'assets/gif/02_三机队形变换.gif',
    'assets/gif/03_PP-CBF开关.gif',
  ];
  for (const legacy of legacyAssets) {
    if (fs.existsSync(path.join(ROOT, ...legacy.split('/')))) fail(`legacy composite GIF must not remain in final asset directory: ${legacy}`);
  }

  process.stdout.write(JSON.stringify({
    status: 'passed',
    algorithm: manifest.algorithm.display_name,
    assets: manifest.asset_count,
    release_static_png: pngCount,
    final_report_static_png: manifest.final_report_static_asset_count,
    animated_gif: gifCount,
    source_hashes: sourceHashes.total_file_count,
    dimensions: '1280x720',
    sysplorer_started: false,
  }, null, 2) + '\n');
}

try {
  main();
} catch (error) {
  process.stderr.write(`${error.stack || error}\n`);
  process.exitCode = 1;
}
