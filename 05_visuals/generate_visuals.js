'use strict';

const fs = require('fs');
const path = require('path');
const crypto = require('crypto');
const childProcess = require('child_process');

if (!process.env.A8_SOURCE_PACKAGE_ROOT) {
  throw new Error('set A8_SOURCE_PACKAGE_ROOT to the complete-source package root');
}

const helper = require('./visual_generation_helpers');
const render = require('./lib/render');

const TARGET = __dirname;
const RUNTIME = path.join(TARGET, '.split_runtime');
const STAGE = path.join(RUNTIME, 'stage');
const FRAMES = path.join(RUNTIME, 'frames');
const GIF_DELAY_MS = 120;
const FRAME_COUNT = 36;
const ALGORITHM = 'RA-GCA-CGHTE';
const SAFETY_DISTANCE_M = 0.60;

// 所有生成结果先写入隔离暂存区，正式资产需经过后续准入。
const OUTPUTS = {
  typical: 'assets/static/01_典型任务.png',
  parameter: 'assets/static/02_参数鲁棒核心优势.png',
  formation: 'assets/static/03_编队PP-CBF.png',
  parameterAltitude: 'assets/gif/01_参数_高度跟踪.gif',
  parameterScale: 'assets/gif/02_参数_推力尺度.gif',
  formationTrajectory: 'assets/gif/03_编队_队形变换.gif',
  formationDistance: 'assets/gif/04_编队_最近机间距.gif',
  cbfGeometry: 'assets/gif/05_PP-CBF_队形安全.gif',
  cbfDistance: 'assets/gif/06_PP-CBF_距离曲线.gif',
  staticContact: 'qa/静态图联系表.png',
  gifContact: 'qa/GIF首中末帧联系表.png',
  qaReport: 'qa/qa_report.json',
  sourceHashes: 'source_data_sha256.json',
  manifest: 'VISUAL_MANIFEST.json',
};

function ensureDirectory(directory) {
  fs.mkdirSync(directory, { recursive: true });
}

function ensureCleanStage() {
  // 暂存区必须为空，防止旧帧或旧图混入本次结果。
  ensureDirectory(STAGE);
  ensureDirectory(FRAMES);
  if (fs.readdirSync(STAGE).length > 0 || fs.readdirSync(FRAMES).length > 0) {
    throw new Error('split staging directory is not empty; move it aside before rerunning');
  }
}

function writeJson(file, value) {
  ensureDirectory(path.dirname(file));
  fs.writeFileSync(file, `${JSON.stringify(value, null, 2)}\n`, 'utf8');
}

function sha256File(file) {
  const hash = crypto.createHash('sha256');
  hash.update(fs.readFileSync(file));
  return hash.digest('hex');
}

function stagePath(relative) {
  return path.join(STAGE, relative);
}

async function renderStatic(page, PNG, relative, svg) {
  const rendered = await helper.renderSvgBuffer(page, svg, true);
  const stats = helper.pngStats(PNG, rendered.buffer);
  const file = stagePath(relative);
  ensureDirectory(path.dirname(file));
  fs.writeFileSync(file, rendered.buffer);
  return { ...stats, text_layout: rendered.layout };
}

async function renderFrames(page, PNG, job, data) {
  // 动画统一生成36帧，并抽查首帧、中帧和末帧的文字布局。
  const frameDir = path.join(FRAMES, job.id);
  ensureDirectory(frameDir);
  const samples = [];
  const layouts = [];
  for (let frame = 0; frame < FRAME_COUNT; frame += 1) {
    const progress = frame / (FRAME_COUNT - 1);
    const checkLayout = frame === 0 || frame === Math.floor(FRAME_COUNT / 2) || frame === FRAME_COUNT - 1;
    const rendered = await helper.renderSvgBuffer(page, job.renderer(data, progress), checkLayout);
    helper.pngStats(PNG, rendered.buffer);
    fs.writeFileSync(path.join(frameDir, `frame_${String(frame).padStart(3, '0')}.png`), rendered.buffer);
    if (checkLayout) {
      samples.push({ frame, buffer: rendered.buffer });
      layouts.push({ frame, ...rendered.layout });
    }
    if ((frame + 1) % 12 === 0 || frame === FRAME_COUNT - 1) {
      process.stdout.write(`[frames] ${job.id}: ${frame + 1}/${FRAME_COUNT}\n`);
    }
  }
  return { ...job, samples, text_layout_samples: layouts };
}

function pythonProbe(candidate) {
  const result = childProcess.spawnSync(candidate, ['-B', '-c', 'import PIL'], {
    encoding: 'utf8',
    windowsHide: true,
  });
  return !result.error && result.status === 0;
}

function registrySysplorerRoots() {
  if (process.platform !== 'win32') return [];
  const roots = [];
  for (const key of [
    'HKCU\\SOFTWARE\\TongYuan\\MWORKS.Sysplorer 2026a',
    'HKLM\\SOFTWARE\\TongYuan\\MWORKS.Sysplorer 2026a',
    'HKLM\\SOFTWARE\\WOW6432Node\\TongYuan\\MWORKS.Sysplorer 2026a',
  ]) {
    const result = childProcess.spawnSync('reg.exe', ['query', key, '/v', 'InstallPath'], { encoding: 'utf8', windowsHide: true });
    if (result.status !== 0) continue;
    const match = result.stdout.match(/^\s*InstallPath\s+REG_\w+\s+(.+)$/im);
    if (match) roots.push(match[1].trim());
  }
  return roots;
}

function standardPythonCandidates() {
  if (process.platform !== 'win32') return ['python3', 'python'];
  const candidates = [];
  for (const root of registrySysplorerRoots()) candidates.push(path.join(root, 'External', 'python64', 'python.exe'));
  for (let code = 'C'.charCodeAt(0); code <= 'Z'.charCodeAt(0); code += 1) {
    const drive = `${String.fromCharCode(code)}:${path.sep}`;
    if (!fs.existsSync(drive)) continue;
    for (const relative of [
      ['MWORKS', 'Sysplorer 2026a', 'External', 'python64', 'python.exe'],
      ['Program Files', 'MWORKS', 'Sysplorer 2026a', 'External', 'python64', 'python.exe'],
      ['Program Files (x86)', 'MWORKS', 'Sysplorer 2026a', 'External', 'python64', 'python.exe'],
    ]) candidates.push(path.join(drive, ...relative));
  }
  candidates.push('python', 'python3');
  return candidates;
}

function resolvePython() {
  for (const name of ['A8_PYTHON', 'MWORKS_PYTHON']) {
    const configured = process.env[name];
    if (!configured) continue;
    if (!fs.existsSync(configured) || !pythonProbe(configured)) {
      throw new Error(`${name} does not point to a Python executable with Pillow: ${configured}`);
    }
    return configured;
  }
  const seen = new Set();
  for (const candidate of standardPythonCandidates()) {
    const key = candidate.toLowerCase();
    if (seen.has(key)) continue;
    seen.add(key);
    if (pythonProbe(candidate)) return candidate;
  }
  throw new Error('Pillow Python not found; set A8_PYTHON or MWORKS_PYTHON to a Python executable with Pillow installed');
}

function encodeGifs(jobs) {
  // GIF编码交给Pillow，Node侧只负责准备帧和核对返回状态。
  const jobMap = Object.fromEntries(jobs.map(job => [job.output, job.id]));
  const jobFile = path.join(RUNTIME, 'gif_jobs.json');
  const reportFile = path.join(RUNTIME, 'pillow_encoding_report.json');
  writeJson(jobFile, jobMap);
  const python = resolvePython();
  const result = childProcess.spawnSync(python, [
    path.join(TARGET, 'encode_gifs_pillow.py'),
    '--frames-root', FRAMES,
    '--output-root', STAGE,
    '--jobs', jobFile,
    '--delay-ms', String(GIF_DELAY_MS),
    '--report', reportFile,
  ], { stdio: 'inherit', encoding: 'utf8' });
  if (result.error) throw result.error;
  if (result.status !== 0) throw new Error(`Pillow GIF encoder exited with ${result.status}`);
  return JSON.parse(fs.readFileSync(reportFile, 'utf8'));
}

function fileMetadata(relative, kind, title, sources, metrics, extra = {}) {
  const file = stagePath(relative);
  return {
    path: relative.replaceAll(path.sep, '/'),
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
  if (!fs.existsSync(file)) throw new Error(`companion file missing: ${relative}`);
  return { path: relative.replaceAll(path.sep, '/'), size_bytes: fs.statSync(file).size, sha256: sha256File(file) };
}

async function main() {
  // 浏览器仅用于离线SVG渲染，不访问网络或启动Sysplorer。
  ensureCleanStage();
  process.stdout.write('[precheck] read-only raw source and split staging\n');
  const cases = helper.precheckSources();
  const sourceHashes = helper.sourceHashDocument(cases.hte);
  writeJson(stagePath(OUTPUTS.sourceHashes), sourceHashes);
  const datasets = helper.buildDatasets();
  const { chromium, PNG, executablePath } = helper.browserDependencies();
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
      `--disk-cache-dir=${path.join(RUNTIME, 'chrome-cache')}`,
    ],
  });

  let staticQa;
  let jobs;
  let encoding;
  try {
    const page = await browser.newPage({ viewport: { width: render.WIDTH, height: render.HEIGHT }, deviceScaleFactor: 1 });
    staticQa = {
      typical: await renderStatic(page, PNG, OUTPUTS.typical, render.typicalSvg(datasets.typical)),
      parameter: await renderStatic(page, PNG, OUTPUTS.parameter, render.parameterSvg(datasets.parameter)),
      formation: await renderStatic(page, PNG, OUTPUTS.formation, render.formationSvg(datasets.formation)),
    };
    const jobDefinitions = [
      { id: 'parameter_altitude', output: OUTPUTS.parameterAltitude, title: '参数：升力失配下的高度跟踪', sources: ['formal_main_full32/Scene05B_LiftMinus10', 'v8_accepted_full32/Scene05B_LiftMinus10'], metrics: { target_scale: datasets.parameterAnimation.targetScale }, renderer: (data, progress) => render.parameterAltitudeFrameSvg(data.parameterAnimation, progress) },
      { id: 'parameter_scale', output: OUTPUTS.parameterScale, title: '参数：置信门控推力尺度', sources: ['formal_main_full32/Scene05B_LiftMinus10'], metrics: { target_scale: datasets.parameterAnimation.targetScale, final_scale: datasets.parameterAnimation.finalScale }, renderer: (data, progress) => render.parameterScaleFrameSvg(data.parameterAnimation, progress) },
      { id: 'formation_trajectory', output: OUTPUTS.formationTrajectory, title: '编队：三机队形变换', sources: ['formal_main_full32/Scene07B'], metrics: { formation_rmse_m: datasets.formationAnimation.globalFormationRmse, minimum_distance_m: datasets.formationAnimation.minimum }, renderer: (data, progress) => render.formationTrajectoryOnlyFrameSvg(data.formationAnimation, progress) },
      { id: 'formation_distance', output: OUTPUTS.formationDistance, title: '编队：最近机间距', sources: ['formal_main_full32/Scene07B'], metrics: { minimum_distance_m: datasets.formationAnimation.minimum, violation_seconds: datasets.formationAnimation.violationSeconds }, renderer: (data, progress) => render.formationDistanceOnlyFrameSvg(data.formationAnimation, progress) },
      { id: 'cbf_geometry', output: OUTPUTS.cbfGeometry, title: 'PP-CBF：队形安全几何对照', sources: ['formal_main_full32/Scene07COff', 'formal_main_full32/Scene07COnPredictiveV5C'], metrics: { off_minimum_distance_m: datasets.formation.off.minimum, on_minimum_distance_m: datasets.formation.on.minimum }, renderer: (data, progress) => render.cbfGeometryOnlyFrameSvg(data.cbfAnimation, progress) },
      { id: 'cbf_distance', output: OUTPUTS.cbfDistance, title: 'PP-CBF：最近机间距曲线', sources: ['formal_main_full32/Scene07COff', 'formal_main_full32/Scene07COnPredictiveV5C'], metrics: { off_minimum_distance_m: datasets.formation.off.minimum, on_minimum_distance_m: datasets.formation.on.minimum, threshold_m: SAFETY_DISTANCE_M }, renderer: (data, progress) => render.cbfDistanceOnlyFrameSvg(data.cbfAnimation, progress) },
    ];
    jobs = [];
    for (const jobDefinition of jobDefinitions) {
      jobs.push(await renderFrames(page, PNG, jobDefinition, datasets));
    }
    encoding = encodeGifs(jobs);
    writeJson(stagePath('qa/pillow_encoding_report.json'), encoding);

    for (const job of jobs) {
      const file = stagePath(job.output);
      const decoded = await helper.verifyGifDecode(page, fs.readFileSync(file));
      if (!decoded.complete || decoded.width !== render.WIDTH || decoded.height !== render.HEIGHT) {
        throw new Error(`browser GIF decode failed for ${job.id}: ${JSON.stringify(decoded)}`);
      }
    }

    await helper.renderContactSheet(page, stagePath(OUTPUTS.staticContact), [[
      { label: '典型任务', buffer: fs.readFileSync(stagePath(OUTPUTS.typical)) },
      { label: '参数鲁棒核心优势', buffer: fs.readFileSync(stagePath(OUTPUTS.parameter)) },
      { label: '编队 PP-CBF', buffer: fs.readFileSync(stagePath(OUTPUTS.formation)) },
    ]], '静态图视觉QA联系表');

    const sampleRows = [];
    for (const sampleIndex of [0, 1, 2]) {
      for (let offset = 0; offset < jobs.length; offset += 3) {
        sampleRows.push(jobs.slice(offset, offset + 3).map(job => ({
          label: `${job.id} · 帧${job.samples[sampleIndex].frame + 1}`,
          buffer: job.samples[sampleIndex].buffer,
        })));
      }
    }
    await helper.renderContactSheet(page, stagePath(OUTPUTS.gifContact), sampleRows, '六个单主题GIF首帧 / 中间帧 / 末帧视觉QA联系表');
  } finally {
    await browser.close();
  }

  const gifMeta = jobs.map(job => {
    const encoded = encoding.outputs[job.output];
    return fileMetadata(job.output, 'animated_gif', job.title, job.sources, job.metrics, {
      frame_count: encoded.frame_count,
      frame_delay_cs: encoded.frame_delay_ms / 10,
      duration_s: encoded.duration_s,
      encoder: encoded.encoder,
    });
  });
  const assets = [
    fileMetadata(OUTPUTS.typical, 'static_png', '典型任务：标准阶跃、螺旋爬升与8字轨迹', ['formal_main_full32/Scene01S_Z', 'formal_main_full32/Scene02', 'formal_main_full32/Scene03'], { rmse_m: { step: datasets.typical.step.rmse, spiral: datasets.typical.spiral.rmse, figure8: datasets.typical.eight.rmse } }),
    fileMetadata(OUTPUTS.parameter, 'static_png', '参数鲁棒核心优势', datasets.parameter.cases.flatMap(item => [`formal_main_full32/${item.caseId}`, `v8_accepted_full32/${item.caseId}`]), { median_rmse_reduction_percent: datasets.parameter.medianReduction }),
    fileMetadata(OUTPUTS.formation, 'static_png', '编队PP-CBF开关对照', ['formal_main_full32/Scene07COff', 'formal_main_full32/Scene07COnPredictiveV5C'], { off_minimum_distance_m: datasets.formation.off.minimum, on_minimum_distance_m: datasets.formation.on.minimum, threshold_m: SAFETY_DISTANCE_M }),
    ...gifMeta,
  ];

  const qaReport = {
    schema_version: 2,
    generated_at: new Date().toISOString(),
    status: 'passed',
    checks: {
      exclusive_write_root: '05_visuals',
      sysplorer_started: false,
      source_sets: { formal_main_raw: cases.hte.length, v8_accepted_raw: cases.v8.length },
      source_hash_count: sourceHashes.total_file_count,
      static_asset_count: 3,
      gif_asset_count: 6,
      expected_dimensions_px: [render.WIDTH, render.HEIGHT],
      expected_frame_count: FRAME_COUNT,
      expected_frame_delay_cs: GIF_DELAY_MS / 10,
      algorithm_label: ALGORITHM,
      language: 'zh-CN',
      text_overflow_count: 0,
      text_overlap_count: 0,
      standard_encoder: true,
      pillow_report: 'pillow_encoding_report.json',
    },
    static: staticQa,
    gif: Object.fromEntries(jobs.map(job => [job.id, {
      width: render.WIDTH,
      height: render.HEIGHT,
      frame_count: FRAME_COUNT,
      frame_delay_cs: GIF_DELAY_MS / 10,
      duration_s: FRAME_COUNT * GIF_DELAY_MS / 1000,
      text_layout_samples: job.text_layout_samples,
    }])),
    metric_cross_checks: {
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
  writeJson(stagePath(OUTPUTS.qaReport), qaReport);

  const qaArtifacts = [OUTPUTS.staticContact, OUTPUTS.gifContact, OUTPUTS.qaReport, 'qa/pillow_encoding_report.json'].map(relative => ({
    path: relative,
    size_bytes: fs.statSync(stagePath(relative)).size,
    sha256: sha256File(stagePath(relative)),
  }));
  const manifest = {
    schema_version: 2,
    package_status: 'validated_formal_assets',
    generated_at: new Date().toISOString(),
    algorithm: { display_name: ALGORITHM, engineering_id: 'RA_GCA_CG_HTE', diagnostic_version_code: 914 },
    canvas: { width_px: render.WIDTH, height_px: render.HEIGHT, language: 'zh-CN' },
    generation: {
      mode: 'offline',
      sysplorer_started: false,
      script: 'generate_visuals.js',
      encoder: 'encode_gifs_pillow.py',
      source_hash_file: OUTPUTS.sourceHashes,
      source_hash_file_sha256: sha256File(stagePath(OUTPUTS.sourceHashes)),
    },
    source_sets: sourceHashes.sets.map(item => ({ id: item.id, count: item.count, aggregate_sha256: item.aggregate_sha256 })),
    asset_count: assets.length,
    assets,
    qa_artifacts: qaArtifacts,
    companion_files: [
      'generate_visuals.js', 'visual_generation_helpers.js', 'encode_gifs_pillow.py', 'verify_assets.js',
      'README_生成与独立验收.md', 'lib/render.js',
    ].map(companionMetadata),
  };
  writeJson(stagePath(OUTPUTS.manifest), manifest);
  process.stdout.write(`[complete] staged ${assets.length} assets; no final files overwritten\n`);
}

main().catch(error => {
  const rca = path.join(RUNTIME, 'RCA_SPLIT_GENERATION_FAILED.md');
  ensureDirectory(path.dirname(rca));
  fs.writeFileSync(rca, `# 分屏动画生成失败RCA\n\n- 状态：停止，未覆盖最终资产。\n- Sysplorer：未启动。\n\n## 错误\n\n\`\`\`text\n${error.stack || error}\n\`\`\`\n`, 'utf8');
  process.stderr.write(`${error.stack || error}\n`);
  process.exitCode = 1;
});
