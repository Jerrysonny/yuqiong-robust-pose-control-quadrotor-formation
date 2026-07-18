'use strict';

const WIDTH = 1280;
const HEIGHT = 720;
const BRAND = 'RA-GCA-CGHTE';
const COLORS = {
  ink: '#17212b',
  muted: '#5f6b76',
  faint: '#8d98a3',
  grid: '#dce2e8',
  panel: '#ffffff',
  bg: '#f4f7f9',
  blue: '#1772b8',
  red: '#d84a3a',
  teal: '#16877b',
  amber: '#d99a24',
  green: '#2d8a56',
  purple: '#7b5aa6',
  dangerFill: '#fae4df',
  safeFill: '#e2f3ea',
};

function esc(value) {
  return String(value)
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;');
}

function fmt(value, digits = 3) {
  return Number(value).toFixed(digits);
}

function text(x, y, value, options = {}) {
  const size = options.size ?? 16;
  const weight = options.weight ?? 400;
  const fill = options.fill ?? COLORS.ink;
  const anchor = options.anchor ?? 'start';
  const family = options.family ?? 'Microsoft YaHei, Noto Sans CJK SC, Arial, sans-serif';
  const opacity = options.opacity ?? 1;
  const extra = options.className ? ` class="${esc(options.className)}"` : '';
  return `<text x="${x}" y="${y}" font-family="${family}" font-size="${size}" font-weight="${weight}" fill="${fill}" text-anchor="${anchor}" opacity="${opacity}" letter-spacing="0"${extra}>${esc(value)}</text>`;
}

function line(x1, y1, x2, y2, options = {}) {
  const stroke = options.stroke ?? COLORS.grid;
  const width = options.width ?? 1;
  const dash = options.dash ? ` stroke-dasharray="${options.dash}"` : '';
  const opacity = options.opacity ?? 1;
  return `<line x1="${x1}" y1="${y1}" x2="${x2}" y2="${y2}" stroke="${stroke}" stroke-width="${width}" opacity="${opacity}"${dash}/>`;
}

function rect(x, y, width, height, options = {}) {
  const fill = options.fill ?? 'none';
  const stroke = options.stroke ?? 'none';
  const radius = options.radius ?? 0;
  const strokeWidth = options.strokeWidth ?? 1;
  const opacity = options.opacity ?? 1;
  return `<rect x="${x}" y="${y}" width="${width}" height="${height}" rx="${radius}" fill="${fill}" stroke="${stroke}" stroke-width="${strokeWidth}" opacity="${opacity}"/>`;
}

function circle(cx, cy, radius, options = {}) {
  const fill = options.fill ?? COLORS.ink;
  const stroke = options.stroke ?? '#ffffff';
  const strokeWidth = options.strokeWidth ?? 0;
  const opacity = options.opacity ?? 1;
  return `<circle cx="${cx}" cy="${cy}" r="${radius}" fill="${fill}" stroke="${stroke}" stroke-width="${strokeWidth}" opacity="${opacity}"/>`;
}

function svgPath(points, options = {}) {
  if (!points || points.length < 2) return '';
  const stroke = options.stroke ?? COLORS.blue;
  const width = options.width ?? 2;
  const opacity = options.opacity ?? 1;
  const dash = options.dash ? ` stroke-dasharray="${options.dash}"` : '';
  const d = points.map((point, index) => `${index === 0 ? 'M' : 'L'}${point[0].toFixed(2)},${point[1].toFixed(2)}`).join(' ');
  return `<path d="${d}" fill="none" stroke="${stroke}" stroke-width="${width}" stroke-linecap="round" stroke-linejoin="round" opacity="${opacity}"${dash}/>`;
}

function samplePoints(points, maximum = 900) {
  // 等步长降采样并强制保留末点，降低SVG体积且保持终态准确。
  if (points.length <= maximum) return points;
  const stride = Math.ceil(points.length / maximum);
  const sampled = [];
  for (let index = 0; index < points.length; index += stride) sampled.push(points[index]);
  if (sampled[sampled.length - 1] !== points[points.length - 1]) sampled.push(points[points.length - 1]);
  return sampled;
}

function bounds(points, padding = 0.06) {
  // 数据范围增加固定比例留白，常值序列使用最小显示跨度。
  let minX = Number.POSITIVE_INFINITY;
  let maxX = Number.NEGATIVE_INFINITY;
  let minY = Number.POSITIVE_INFINITY;
  let maxY = Number.NEGATIVE_INFINITY;
  for (const point of points) {
    minX = Math.min(minX, point[0]);
    maxX = Math.max(maxX, point[0]);
    minY = Math.min(minY, point[1]);
    maxY = Math.max(maxY, point[1]);
  }
  if (!Number.isFinite(minX + maxX + minY + maxY)) throw new Error('Non-finite plot bounds');
  if (Math.abs(maxX - minX) < 1e-9) {
    minX -= 0.5;
    maxX += 0.5;
  }
  if (Math.abs(maxY - minY) < 1e-9) {
    minY -= 0.5;
    maxY += 0.5;
  }
  const padX = (maxX - minX) * padding;
  const padY = (maxY - minY) * padding;
  return { minX: minX - padX, maxX: maxX + padX, minY: minY - padY, maxY: maxY + padY };
}

function mapper(domain, box) {
  // 将数据坐标映射到SVG画布坐标，纵轴方向需反转。
  return point => [
    box.x + ((point[0] - domain.minX) / (domain.maxX - domain.minX)) * box.w,
    box.y + box.h - ((point[1] - domain.minY) / (domain.maxY - domain.minY)) * box.h,
  ];
}

function plotFrame(box, options = {}) {
  let result = '';
  const horizontal = options.horizontal ?? 4;
  const vertical = options.vertical ?? 4;
  for (let index = 0; index <= horizontal; index += 1) {
    const y = box.y + (box.h * index) / horizontal;
    result += line(box.x, y, box.x + box.w, y, { stroke: COLORS.grid, width: 1 });
  }
  for (let index = 0; index <= vertical; index += 1) {
    const x = box.x + (box.w * index) / vertical;
    result += line(x, box.y, x, box.y + box.h, { stroke: COLORS.grid, width: 1 });
  }
  result += line(box.x, box.y + box.h, box.x + box.w, box.y + box.h, { stroke: COLORS.ink, width: 1.2 });
  result += line(box.x, box.y, box.x, box.y + box.h, { stroke: COLORS.ink, width: 1.2 });
  return result;
}

function panel(x, y, width, height, titleValue, index, accent = COLORS.blue) {
  return [
    rect(x, y, width, height, { fill: COLORS.panel, stroke: '#d7dee5', radius: 6 }),
    rect(x, y, 6, height, { fill: accent, radius: 3 }),
    text(x + 20, y + 34, index, { size: 13, weight: 700, fill: accent }),
    text(x + 50, y + 35, titleValue, { size: 19, weight: 700 }),
  ].join('');
}

function base(titleValue, eyebrow, subtitle, body, footer) {
  return `<svg xmlns="http://www.w3.org/2000/svg" width="${WIDTH}" height="${HEIGHT}" viewBox="0 0 ${WIDTH} ${HEIGHT}">
    <rect width="${WIDTH}" height="${HEIGHT}" fill="${COLORS.bg}"/>
    <rect x="0" y="0" width="12" height="720" fill="${COLORS.ink}"/>
    ${text(42, 35, eyebrow, { size: 13, weight: 700, fill: COLORS.teal })}
    ${text(42, 72, titleValue, { size: 31, weight: 700 })}
    ${text(42, 101, subtitle, { size: 15, fill: COLORS.muted })}
    ${text(1236, 44, BRAND, { size: 17, weight: 700, anchor: 'end' })}
    ${line(42, 113, 1238, 113, { stroke: '#cfd7df', width: 1 })}
    ${body}
    ${line(42, 681, 1238, 681, { stroke: '#cfd7df', width: 1 })}
    ${text(42, 704, footer, { size: 12, fill: COLORS.muted })}
    ${text(1238, 704, '正式仿真 raw · 离线生成 · 1280 × 720', { size: 12, fill: COLORS.faint, anchor: 'end' })}
  </svg>`;
}

function chartTicks(box, xValues, yValues, xDomain, yDomain, options = {}) {
  let result = '';
  for (const tick of xValues) {
    const x = box.x + ((tick - xDomain[0]) / (xDomain[1] - xDomain[0])) * box.w;
    result += line(x, box.y, x, box.y + box.h, { stroke: COLORS.grid });
    result += text(x, box.y + box.h + 20, options.xFormat ? options.xFormat(tick) : tick, { size: 11, fill: COLORS.muted, anchor: 'middle' });
  }
  for (const tick of yValues) {
    const y = box.y + box.h - ((tick - yDomain[0]) / (yDomain[1] - yDomain[0])) * box.h;
    result += line(box.x, y, box.x + box.w, y, { stroke: COLORS.grid });
    result += text(box.x - 9, y + 4, options.yFormat ? options.yFormat(tick) : tick, { size: 11, fill: COLORS.muted, anchor: 'end' });
  }
  result += line(box.x, box.y + box.h, box.x + box.w, box.y + box.h, { stroke: COLORS.ink, width: 1.1 });
  result += line(box.x, box.y, box.x, box.y + box.h, { stroke: COLORS.ink, width: 1.1 });
  return result;
}

function typicalSvg(data) {
  const body = [];
  const panels = [
    { x: 42, title: 'Z轴标准阶跃', index: '01', accent: COLORS.blue },
    { x: 449, title: '螺旋爬升', index: '02', accent: COLORS.teal },
    { x: 856, title: '8字轨迹', index: '03', accent: COLORS.amber },
  ];
  for (const item of panels) body.push(panel(item.x, 128, 382, 526, item.title, item.index, item.accent));

  const stepBox = { x: 83, y: 198, w: 314, h: 332 };
  body.push(chartTicks(stepBox, [0, 5, 10, 15, 20, 25, 30], [0, 0.5, 1, 1.5, 2.0], [0, 30], [0, 2.10], { xFormat: value => value, yFormat: value => fmt(value, 1) }));
  const stepMap = mapper({ minX: 0, maxX: 30, minY: 0, maxY: 2.10 }, stepBox);
  body.push(svgPath(samplePoints(data.step.reference.map((value, index) => stepMap([data.step.time[index], value]))), { stroke: COLORS.ink, width: 2, dash: '7 5' }));
  body.push(svgPath(samplePoints(data.step.actual.map((value, index) => stepMap([data.step.time[index], value]))), { stroke: COLORS.blue, width: 3 }));
  body.push(text(91, 190, '高度 / m', { size: 12, fill: COLORS.muted }));
  body.push(text(398, 578, '时间 / s', { size: 12, fill: COLORS.muted, anchor: 'end' }));
  body.push(line(86, 571, 112, 571, { stroke: COLORS.ink, width: 2, dash: '7 5' }));
  body.push(text(120, 576, '参考', { size: 12, fill: COLORS.muted }));
  body.push(line(176, 571, 202, 571, { stroke: COLORS.blue, width: 3 }));
  body.push(text(210, 576, '实测', { size: 12, fill: COLORS.muted }));
  body.push(text(83, 621, `RMSE  ${fmt(data.step.rmse)} m`, { size: 18, weight: 700, fill: COLORS.blue }));

  const spiralProjectedReference = data.spiral.reference.map(point => [point[0] + 0.42 * point[2], point[1] + 0.24 * point[2]]);
  const spiralProjectedActual = data.spiral.actual.map(point => [point[0] + 0.42 * point[2], point[1] + 0.24 * point[2]]);
  const spiralDomain = bounds([...spiralProjectedReference, ...spiralProjectedActual], 0.08);
  const spiralBox = { x: 485, y: 194, w: 319, h: 350 };
  body.push(plotFrame(spiralBox, { horizontal: 5, vertical: 5 }));
  const spiralMap = mapper(spiralDomain, spiralBox);
  body.push(svgPath(samplePoints(spiralProjectedReference.map(spiralMap)), { stroke: COLORS.ink, width: 2, dash: '7 5' }));
  body.push(svgPath(samplePoints(spiralProjectedActual.map(spiralMap)), { stroke: COLORS.teal, width: 3 }));
  const spiralEnd = spiralMap(spiralProjectedActual[spiralProjectedActual.length - 1]);
  body.push(circle(spiralEnd[0], spiralEnd[1], 5, { fill: COLORS.teal, stroke: '#fff', strokeWidth: 2 }));
  body.push(text(494, 190, '等轴投影：X–Y–Z', { size: 12, fill: COLORS.muted }));
  body.push(line(494, 571, 520, 571, { stroke: COLORS.ink, width: 2, dash: '7 5' }));
  body.push(text(528, 576, '参考', { size: 12, fill: COLORS.muted }));
  body.push(line(584, 571, 610, 571, { stroke: COLORS.teal, width: 3 }));
  body.push(text(618, 576, '实测', { size: 12, fill: COLORS.muted }));
  body.push(text(490, 621, `RMSE  ${fmt(data.spiral.rmse)} m`, { size: 18, weight: 700, fill: COLORS.teal }));

  const eightReference = data.eight.reference.map(point => [point[0], point[1]]);
  const eightActual = data.eight.actual.map(point => [point[0], point[1]]);
  const eightDomain = bounds([...eightReference, ...eightActual], 0.08);
  const eightBox = { x: 892, y: 194, w: 319, h: 350 };
  body.push(plotFrame(eightBox, { horizontal: 5, vertical: 5 }));
  const eightMap = mapper(eightDomain, eightBox);
  body.push(svgPath(samplePoints(eightReference.map(eightMap)), { stroke: COLORS.ink, width: 2, dash: '7 5' }));
  body.push(svgPath(samplePoints(eightActual.map(eightMap)), { stroke: COLORS.amber, width: 3 }));
  const eightEnd = eightMap(eightActual[eightActual.length - 1]);
  body.push(circle(eightEnd[0], eightEnd[1], 5, { fill: COLORS.amber, stroke: '#fff', strokeWidth: 2 }));
  body.push(text(901, 190, '水平面轨迹：X–Y', { size: 12, fill: COLORS.muted }));
  body.push(line(901, 571, 927, 571, { stroke: COLORS.ink, width: 2, dash: '7 5' }));
  body.push(text(935, 576, '参考', { size: 12, fill: COLORS.muted }));
  body.push(line(991, 571, 1017, 571, { stroke: COLORS.amber, width: 3 }));
  body.push(text(1025, 576, '实测', { size: 12, fill: COLORS.muted }));
  body.push(text(897, 621, `RMSE  ${fmt(data.eight.rmse)} m`, { size: 18, weight: 700, fill: '#a66d08' }));

  return base(
    '典型任务：从标准阶跃到空间轨迹',
    '评委速览 · 典型任务组',
    '同一正式控制器覆盖高度跟踪、螺旋爬升与8字机动；虚线为参考，实线为仿真状态。',
    body.join(''),
    '数据：RA-GCA-CGHTE 完整32项 raw · Scene01S_Z / Scene02 / Scene03',
  );
}

function parameterSvg(data) {
  const body = [];
  body.push(panel(42, 128, 758, 526, '六类强参数失配：位置RMSE', '01', COLORS.red));
  body.push(panel(824, 128, 414, 526, '升力效率 −10%：估计闭环', '02', COLORS.teal));

  const chart = { x: 265, y: 196, w: 495, h: 347 };
  const logMin = Math.log10(0.01);
  const logMax = Math.log10(1.0);
  const xMap = value => chart.x + ((Math.log10(value) - logMin) / (logMax - logMin)) * chart.w;
  for (const tick of [0.01, 0.03, 0.1, 0.3, 1.0]) {
    const x = xMap(tick);
    body.push(line(x, chart.y - 10, x, chart.y + chart.h, { stroke: COLORS.grid }));
    body.push(text(x, chart.y + chart.h + 23, tick < 1 ? tick.toFixed(2).replace(/0$/, '') : '1.0', { size: 11, fill: COLORS.muted, anchor: 'middle' }));
  }
  body.push(text(760, 586, '位置RMSE / m（对数坐标）', { size: 12, fill: COLORS.muted, anchor: 'end' }));
  data.cases.forEach((item, index) => {
    const y = 218 + index * 52;
    const xV8 = xMap(item.v8);
    const xHte = xMap(item.hte);
    body.push(text(66, y + 5, item.label, { size: 14, weight: 600 }));
    body.push(line(xHte, y, xV8, y, { stroke: '#aeb8c2', width: 4 }));
    body.push(circle(xV8, y, 7, { fill: COLORS.red, stroke: '#fff', strokeWidth: 2 }));
    body.push(circle(xHte, y, 7, { fill: COLORS.teal, stroke: '#fff', strokeWidth: 2 }));
    body.push(text(xHte + 11, y - 9, `${fmt(item.hte)} m`, { size: 11, weight: 700, fill: COLORS.teal }));
    body.push(text(775, y + 5, `↓ ${fmt(item.reduction, 1)}%`, { size: 12, weight: 700, fill: COLORS.teal, anchor: 'end' }));
  });
  body.push(circle(72, 607, 6, { fill: COLORS.red }));
  body.push(text(86, 612, 'RA-GCA/V8 对照', { size: 12, fill: COLORS.muted }));
  body.push(circle(236, 607, 6, { fill: COLORS.teal }));
  body.push(text(250, 612, BRAND, { size: 12, fill: COLORS.muted }));
  body.push(text(775, 612, `中位RMSE下降 ${fmt(data.medianReduction, 1)}%`, { size: 15, weight: 700, fill: COLORS.teal, anchor: 'end' }));

  const altitudeBox = { x: 862, y: 199, w: 338, h: 171 };
  body.push(chartTicks(altitudeBox, [0, 3, 6, 9, 12], [0, 0.5, 1.0, 1.5], [0, 12], [0, 1.65], { yFormat: value => fmt(value, 1) }));
  const altitudeMap = mapper({ minX: 0, maxX: 12, minY: 0, maxY: 1.65 }, altitudeBox);
  body.push(svgPath(samplePoints(data.mechanism.reference.map((value, index) => altitudeMap([data.mechanism.time[index], value]))), { stroke: COLORS.ink, width: 1.8, dash: '6 4' }));
  body.push(svgPath(samplePoints(data.mechanism.v8.map((value, index) => altitudeMap([data.mechanism.time[index], value]))), { stroke: COLORS.red, width: 2.4 }));
  body.push(svgPath(samplePoints(data.mechanism.hte.map((value, index) => altitudeMap([data.mechanism.time[index], value]))), { stroke: COLORS.teal, width: 2.8 }));
  body.push(text(868, 190, '高度 / m', { size: 11, fill: COLORS.muted }));

  const scaleBox = { x: 862, y: 430, w: 338, h: 125 };
  body.push(chartTicks(scaleBox, [0, 3, 6, 9, 12], [1.00, 1.06, 1.12], [0, 12], [0.99, 1.125], { yFormat: value => fmt(value, 2) }));
  const scaleMap = mapper({ minX: 0, maxX: 12, minY: 0.99, maxY: 1.125 }, scaleBox);
  body.push(line(scaleBox.x, scaleMap([0, data.mechanism.targetScale])[1], scaleBox.x + scaleBox.w, scaleMap([0, data.mechanism.targetScale])[1], { stroke: COLORS.ink, width: 1.5, dash: '6 4' }));
  body.push(svgPath(samplePoints(data.mechanism.scale.map((value, index) => scaleMap([data.mechanism.time[index], value]))), { stroke: COLORS.teal, width: 3 }));
  body.push(text(868, 416, '补偿尺度', { size: 11, fill: COLORS.muted }));
  body.push(text(1200, 600, `目标 ${fmt(data.mechanism.targetScale, 3)} · 终值 ${fmt(data.mechanism.finalScale, 3)}`, { size: 13, weight: 700, fill: COLORS.teal, anchor: 'end' }));
  body.push(text(862, 631, '置信门通过后，悬停推力尺度平滑收敛；V8仅作冻结对照。', { size: 12, fill: COLORS.muted }));

  return base(
    '参数鲁棒核心优势：失配工况平均误差显著压低',
    '评委速览 · 参数鲁棒组',
    '32项正式配对证据中，名义任务保持透明；对升力、载荷与模型参数失配启用置信门控推力估计。',
    body.join(''),
    '数据：RA-GCA-CGHTE 完整32项 raw 与 RA-GCA/V8 接受集 · Scene05B 参数族',
  );
}

function formationTrajectoryPlot(body, item, box, titleValue, accent, domain) {
  body.push(rect(box.x - 12, box.y - 47, box.w + 24, box.h + 79, { fill: '#fbfcfd', stroke: '#dde3e8', radius: 4 }));
  body.push(text(box.x, box.y - 20, titleValue, { size: 16, weight: 700, fill: accent }));
  body.push(plotFrame(box, { horizontal: 5, vertical: 5 }));
  const map = mapper(domain, box);
  const colors = [COLORS.blue, COLORS.amber, COLORS.purple];
  item.vehicles.forEach((vehicle, index) => {
    body.push(svgPath(samplePoints(vehicle.map(map)), { stroke: colors[index], width: 2.4 }));
    const closest = map(vehicle[item.closestIndex]);
    body.push(circle(closest[0], closest[1], 5.5, { fill: colors[index], stroke: '#fff', strokeWidth: 2 }));
  });
  const pair = item.closestPair.map(vehicleIndex => map(item.vehicles[vehicleIndex][item.closestIndex]));
  body.push(line(pair[0][0], pair[0][1], pair[1][0], pair[1][1], { stroke: accent, width: 2.5, dash: '6 4' }));
  body.push(text(box.x + box.w, box.y + box.h + 22, `最小间距 ${fmt(item.minimum)} m`, { size: 13, weight: 700, fill: accent, anchor: 'end' }));
}

function formationSvg(data) {
  const body = [];
  body.push(panel(42, 128, 566, 526, '三机轨迹与最近接状态', '01', COLORS.purple));
  body.push(panel(630, 128, 608, 526, 'PP-CBF开关：最小机间距', '02', COLORS.green));
  const allPoints = [...data.off.vehicles.flat(), ...data.on.vehicles.flat()];
  const domain = bounds(allPoints, 0.1);
  formationTrajectoryPlot(body, data.off, { x: 72, y: 217, w: 232, h: 305 }, '关闭安全监督', COLORS.red, domain);
  formationTrajectoryPlot(body, data.on, { x: 348, y: 217, w: 232, h: 305 }, '开启预测PP-CBF', COLORS.green, domain);

  const distanceBox = { x: 680, y: 204, w: 518, h: 318 };
  const maxDistance = Math.max(...data.off.distance, ...data.on.distance, 1.3);
  const distanceMap = mapper({ minX: 0, maxX: 40, minY: 0.3, maxY: maxDistance * 1.03 }, distanceBox);
  const unsafeY = distanceMap([0, 0.6])[1];
  body.push(rect(distanceBox.x, unsafeY, distanceBox.w, distanceBox.y + distanceBox.h - unsafeY, { fill: COLORS.dangerFill, opacity: 0.75 }));
  body.push(chartTicks(distanceBox, [0, 10, 20, 30, 40], [0.4, 0.6, 0.8, 1.0, 1.2], [0, 40], [0.3, maxDistance * 1.03], { yFormat: value => fmt(value, 1) }));
  body.push(line(distanceBox.x, unsafeY, distanceBox.x + distanceBox.w, unsafeY, { stroke: COLORS.ink, width: 2, dash: '7 5' }));
  body.push(text(distanceBox.x + distanceBox.w - 5, unsafeY - 8, '安全阈值 0.60 m', { size: 12, weight: 700, fill: COLORS.ink, anchor: 'end' }));
  body.push(svgPath(samplePoints(data.off.distance.map((value, index) => distanceMap([data.off.time[index], value]))), { stroke: COLORS.red, width: 2.8 }));
  body.push(svgPath(samplePoints(data.on.distance.map((value, index) => distanceMap([data.on.time[index], value]))), { stroke: COLORS.green, width: 3.2 }));
  body.push(text(686, 191, '三维最小机间距 / m', { size: 12, fill: COLORS.muted }));
  body.push(text(1198, 562, '时间 / s', { size: 12, fill: COLORS.muted, anchor: 'end' }));
  body.push(line(686, 573, 712, 573, { stroke: COLORS.red, width: 3 }));
  body.push(text(720, 578, `关闭：${fmt(data.off.minimum)} m`, { size: 13, weight: 700, fill: COLORS.red }));
  body.push(line(874, 573, 900, 573, { stroke: COLORS.green, width: 3 }));
  body.push(text(908, 578, `开启：${fmt(data.on.minimum)} m`, { size: 13, weight: 700, fill: COLORS.green }));
  body.push(text(1198, 612, `阈值以下持续：关闭 ${fmt(data.off.violationSeconds, 2)} s · 开启 ${fmt(data.on.violationSeconds, 2)} s`, { size: 15, weight: 700, fill: COLORS.ink, anchor: 'end' }));

  return base(
    '编队安全监督：PP-CBF把最近接距离推回安全侧',
    '评委速览 · 三机编队组',
    '同一轨迹指令下进行反事实开关对照；彩色圆点和虚线标出全程最近接时刻。',
    body.join(''),
    '数据：RA-GCA-CGHTE 完整32项 raw · Scene07COff / Scene07COnPredictiveV5C · 安全阈值 0.60 m',
  );
}

function progressIndex(length, progress) {
  return Math.max(1, Math.min(length - 1, Math.round(progress * (length - 1))));
}

function parameterFrameSvg(data, progress) {
  const index = progressIndex(data.time.length, progress);
  const currentTime = data.time[index];
  const body = [];
  body.push(panel(42, 128, 790, 526, '高度跟踪：冻结V8与CG-HTE对照', '01', COLORS.teal));
  body.push(panel(856, 128, 382, 526, '置信门控推力尺度', '02', COLORS.amber));
  const chart = { x: 86, y: 197, w: 706, h: 358 };
  body.push(chartTicks(chart, [0, 2, 4, 6, 8, 10, 12], [0, 0.5, 1.0, 1.5], [0, 12], [0, 1.7], { yFormat: value => fmt(value, 1) }));
  const map = mapper({ minX: 0, maxX: 12, minY: 0, maxY: 1.7 }, chart);
  body.push(svgPath(samplePoints(data.reference.map((value, i) => map([data.time[i], value]))), { stroke: COLORS.ink, width: 1.8, dash: '7 5', opacity: 0.8 }));
  body.push(svgPath(samplePoints(data.v8.slice(0, index + 1).map((value, i) => map([data.time[i], value]))), { stroke: COLORS.red, width: 3 }));
  body.push(svgPath(samplePoints(data.hte.slice(0, index + 1).map((value, i) => map([data.time[i], value]))), { stroke: COLORS.teal, width: 3.4 }));
  const currentHte = map([currentTime, data.hte[index]]);
  body.push(line(currentHte[0], chart.y, currentHte[0], chart.y + chart.h, { stroke: '#8b949d', width: 1.5, dash: '5 5' }));
  body.push(circle(currentHte[0], currentHte[1], 6, { fill: COLORS.teal, stroke: '#fff', strokeWidth: 2 }));
  body.push(text(92, 187, '高度 / m', { size: 12, fill: COLORS.muted }));
  body.push(line(92, 590, 118, 590, { stroke: COLORS.red, width: 3 }));
  body.push(text(126, 595, 'RA-GCA/V8', { size: 12, fill: COLORS.muted }));
  body.push(line(245, 590, 271, 590, { stroke: COLORS.teal, width: 3 }));
  body.push(text(279, 595, BRAND, { size: 12, fill: COLORS.muted }));
  body.push(text(792, 620, `t = ${fmt(currentTime, 2)} s`, { size: 19, weight: 700, fill: COLORS.ink, anchor: 'end' }));

  const gaugeX = 1047;
  const gaugeY = 286;
  const gaugeR = 92;
  const scale = data.scale[index];
  const gate = data.gate[index] >= 0.5;
  const angle = Math.PI * (0.78 + 1.44 * ((scale - 0.99) / (1.125 - 0.99)));
  body.push(`<path d="M${gaugeX - 75},${gaugeY + 45} A${gaugeR},${gaugeR} 0 1 1 ${gaugeX + 75},${gaugeY + 45}" fill="none" stroke="#dce2e8" stroke-width="17" stroke-linecap="round"/>`);
  const needleX = gaugeX + Math.cos(angle) * 72;
  const needleY = gaugeY + Math.sin(angle) * 72;
  body.push(line(gaugeX, gaugeY, needleX, needleY, { stroke: COLORS.amber, width: 5 }));
  body.push(circle(gaugeX, gaugeY, 9, { fill: COLORS.amber }));
  body.push(text(gaugeX, gaugeY + 92, fmt(scale, 4), { size: 29, weight: 700, fill: COLORS.teal, anchor: 'middle' }));
  body.push(text(gaugeX, gaugeY + 118, '实时补偿尺度', { size: 13, fill: COLORS.muted, anchor: 'middle' }));
  body.push(rect(895, 438, 304, 54, { fill: gate ? COLORS.safeFill : '#eef1f4', stroke: gate ? '#9bc9ae' : '#ccd3da', radius: 5 }));
  body.push(circle(920, 465, 8, { fill: gate ? COLORS.green : COLORS.faint }));
  body.push(text(940, 471, gate ? '置信门：通过' : '置信门：等待', { size: 17, weight: 700, fill: gate ? COLORS.green : COLORS.muted }));
  body.push(text(1047, 530, `目标尺度 ${fmt(data.targetScale, 4)}`, { size: 15, weight: 700, anchor: 'middle' }));
  body.push(text(1047, 560, `归一化创新 ${fmt(data.innovation[index], 3)}`, { size: 13, fill: COLORS.muted, anchor: 'middle' }));
  body.push(text(1047, 602, '估计 → 门控 → 限速施加', { size: 15, weight: 700, fill: COLORS.amber, anchor: 'middle' }));

  return base(
    '参数机理：置信门控悬停推力估计如何消除升力失配',
    '动态证据 · 参数机理',
    '场景：升力效率降低10%；参考高度与冻结V8用于同场对照。',
    body.join(''),
    '数据：Scene05B_LiftMinus10 · controllerDiagnostics[11:14] · 正式诊断码 914',
  );
}

function droneGlyph(x, y, color, label, opacity = 1) {
  return [
    line(x - 16, y - 16, x + 16, y + 16, { stroke: color, width: 3, opacity }),
    line(x - 16, y + 16, x + 16, y - 16, { stroke: color, width: 3, opacity }),
    circle(x, y, 7, { fill: color, stroke: '#fff', strokeWidth: 2, opacity }),
    circle(x - 17, y - 17, 4, { fill: '#fff', stroke: color, strokeWidth: 2, opacity }),
    circle(x + 17, y - 17, 4, { fill: '#fff', stroke: color, strokeWidth: 2, opacity }),
    circle(x - 17, y + 17, 4, { fill: '#fff', stroke: color, strokeWidth: 2, opacity }),
    circle(x + 17, y + 17, 4, { fill: '#fff', stroke: color, strokeWidth: 2, opacity }),
    text(x, y - 27, label, { size: 12, weight: 700, fill: color, anchor: 'middle', opacity }),
  ].join('');
}

function formationFrameSvg(data, progress) {
  const index = progressIndex(data.time.length, progress);
  const body = [];
  body.push(panel(42, 128, 824, 526, '三机队形变换：实际位置与指令队形', '01', COLORS.purple));
  body.push(panel(890, 128, 348, 526, '阶段与队形误差', '02', COLORS.blue));
  const plot = { x: 85, y: 192, w: 735, h: 390 };
  body.push(plotFrame(plot, { horizontal: 6, vertical: 6 }));
  const map = mapper(data.domain, plot);
  const colors = [COLORS.blue, COLORS.amber, COLORS.purple];
  for (let vehicleIndex = 0; vehicleIndex < 3; vehicleIndex += 1) {
    const trace = data.actual[vehicleIndex].slice(0, index + 1).map(map);
    body.push(svgPath(samplePoints(trace), { stroke: colors[vehicleIndex], width: 2, opacity: 0.5 }));
  }
  const actualNow = data.actual.map(vehicle => map(vehicle[index]));
  const desiredNow = data.desired.map(vehicle => map(vehicle[index]));
  body.push(`<polygon points="${desiredNow.map(point => point.join(',')).join(' ')}" fill="none" stroke="#9ba5af" stroke-width="2" stroke-dasharray="7 5"/>`);
  body.push(`<polygon points="${actualNow.map(point => point.join(',')).join(' ')}" fill="${COLORS.safeFill}" fill-opacity="0.4" stroke="${COLORS.ink}" stroke-width="2.5"/>`);
  desiredNow.forEach(point => {
    body.push(circle(point[0], point[1], 11, { fill: '#ffffff', stroke: '#9ba5af', strokeWidth: 2, opacity: 0.7 }));
    body.push(line(point[0] - 7, point[1], point[0] + 7, point[1], { stroke: '#9ba5af', width: 2, opacity: 0.7 }));
    body.push(line(point[0], point[1] - 7, point[0], point[1] + 7, { stroke: '#9ba5af', width: 2, opacity: 0.7 }));
  });
  actualNow.forEach((point, vehicleIndex) => body.push(droneGlyph(point[0], point[1], colors[vehicleIndex], `${vehicleIndex + 1}`)));
  body.push(text(94, 184, '水平面 X–Y / m', { size: 12, fill: COLORS.muted }));
  body.push(text(820, 609, `t = ${fmt(data.time[index], 2)} s`, { size: 19, weight: 700, anchor: 'end' }));

  const stage = data.time[index] < 20 ? '列队保持' : data.time[index] < 40 ? '队形过渡' : '新队形稳定';
  body.push(text(1064, 216, stage, { size: 25, weight: 700, fill: COLORS.purple, anchor: 'middle' }));
  body.push(text(1064, 248, data.time[index] < 20 ? '线列队形' : data.time[index] < 40 ? '连续变换' : '三角队形', { size: 15, fill: COLORS.muted, anchor: 'middle' }));
  const error = data.formationError[index];
  body.push(text(1064, 329, fmt(error, 3), { size: 54, weight: 700, fill: COLORS.blue, anchor: 'middle' }));
  body.push(text(1064, 356, '队形位置RMSE / m', { size: 13, fill: COLORS.muted, anchor: 'middle' }));
  body.push(rect(930, 410, 268, 18, { fill: '#e3e8ed', radius: 4 }));
  const timelineProgress = Math.min(1, data.time[index] / data.time[data.time.length - 1]);
  body.push(rect(930, 410, 268 * timelineProgress, 18, { fill: COLORS.purple, radius: 4 }));
  body.push(line(1019, 398, 1019, 442, { stroke: '#fff', width: 2 }));
  body.push(line(1109, 398, 1109, 442, { stroke: '#fff', width: 2 }));
  body.push(text(930, 461, '0 s', { size: 11, fill: COLORS.muted }));
  body.push(text(1019, 461, '20 s', { size: 11, fill: COLORS.muted, anchor: 'middle' }));
  body.push(text(1109, 461, '40 s', { size: 11, fill: COLORS.muted, anchor: 'middle' }));
  body.push(text(1198, 461, '60 s', { size: 11, fill: COLORS.muted, anchor: 'end' }));
  body.push(text(1064, 520, `全程最小机间距 ${fmt(data.minimumDistance, 3)} m`, { size: 16, weight: 700, fill: COLORS.green, anchor: 'middle' }));
  body.push(text(1064, 555, `全程队形RMSE ${fmt(data.globalFormationRmse, 3)} m`, { size: 16, weight: 700, fill: COLORS.blue, anchor: 'middle' }));
  body.push(text(1064, 606, '三机均使用正式主控制器', { size: 13, fill: COLORS.muted, anchor: 'middle' }));

  return base(
    '三机队形变换：平滑过渡、稳定保持',
    '动态证据 · 编队变换',
    '虚线为上层队形指令，实线多边形为三机实际队形；轨迹尾迹显示连续过渡过程。',
    body.join(''),
    '数据：Scene07B · 三机 controllerDiagnostics1:3[16] = 914',
  );
}

function cbfSide(body, item, box, titleValue, accent, index, domain) {
  body.push(rect(box.x - 14, box.y - 48, box.w + 28, box.h + 94, { fill: COLORS.panel, stroke: '#d7dee5', radius: 6 }));
  body.push(text(box.x, box.y - 18, titleValue, { size: 18, weight: 700, fill: accent }));
  body.push(plotFrame(box, { horizontal: 5, vertical: 5 }));
  const map = mapper(domain, box);
  const colors = [COLORS.blue, COLORS.amber, COLORS.purple];
  item.vehicles.forEach((vehicle, vehicleIndex) => {
    body.push(svgPath(samplePoints(vehicle.slice(0, index + 1).map(map)), { stroke: colors[vehicleIndex], width: 2, opacity: 0.55 }));
  });
  const current = item.vehicles.map(vehicle => map(vehicle[index]));
  const pair = item.currentPair[index];
  const distance = item.distance[index];
  const pairColor = distance < 0.6 ? COLORS.red : COLORS.green;
  body.push(`<polygon points="${current.map(point => point.join(',')).join(' ')}" fill="none" stroke="${COLORS.ink}" stroke-width="2"/>`);
  body.push(line(current[pair[0]][0], current[pair[0]][1], current[pair[1]][0], current[pair[1]][1], { stroke: pairColor, width: 4, dash: '6 4' }));
  current.forEach((point, vehicleIndex) => body.push(droneGlyph(point[0], point[1], colors[vehicleIndex], `${vehicleIndex + 1}`)));
  body.push(rect(box.x, box.y + box.h + 16, box.w, 34, { fill: distance < 0.6 ? COLORS.dangerFill : COLORS.safeFill, radius: 4 }));
  body.push(text(box.x + box.w / 2, box.y + box.h + 40, `当前最小间距 ${fmt(distance, 3)} m`, { size: 15, weight: 700, fill: pairColor, anchor: 'middle' }));
}

function cbfFrameSvg(data, progress) {
  const index = progressIndex(data.time.length, progress);
  const body = [];
  cbfSide(body, data.off, { x: 70, y: 190, w: 500, h: 365 }, 'PP-CBF 关闭：反事实风险', COLORS.red, index, data.domain);
  cbfSide(body, data.on, { x: 710, y: 190, w: 500, h: 365 }, 'PP-CBF 开启：预测安全监督', COLORS.green, index, data.domain);
  body.push(rect(574, 220, 132, 286, { fill: '#eef2f5', stroke: '#d8dfe6', radius: 6 }));
  body.push(text(640, 267, '同一', { size: 15, weight: 700, anchor: 'middle' }));
  body.push(text(640, 294, '轨迹指令', { size: 15, weight: 700, anchor: 'middle' }));
  body.push(text(640, 347, '仅切换', { size: 13, fill: COLORS.muted, anchor: 'middle' }));
  body.push(text(640, 374, '安全监督器', { size: 13, fill: COLORS.muted, anchor: 'middle' }));
  body.push(line(603, 414, 677, 414, { stroke: COLORS.ink, width: 2 }));
  body.push(`<path d="M677 414 L664 406 L664 422 Z" fill="${COLORS.ink}"/>`);
  body.push(text(640, 471, `t = ${fmt(data.time[index], 2)} s`, { size: 16, weight: 700, anchor: 'middle' }));
  const offUnsafe = data.off.distance[index] < 0.6;
  body.push(text(640, 614, offUnsafe ? '关闭侧进入阈值以下，开启侧保持安全' : '两侧尚未进入最近接阶段', { size: 17, weight: 700, fill: offUnsafe ? COLORS.red : COLORS.muted, anchor: 'middle' }));

  return base(
    'PP-CBF开关对照：相同任务下的最近接安全差异',
    '动态证据 · 安全监督开关',
    '彩色连线实时标识最近机对；绿色表示 ≥ 0.60 m，红色表示进入阈值以下。',
    body.join(''),
    `数据：Scene07COff / Scene07COnPredictiveV5C · 全程最小间距 ${fmt(data.off.minimum)} m → ${fmt(data.on.minimum)} m`,
  );
}

// Split animation views keep each GIF focused on one measurable claim.
function parameterAltitudeFrameSvg(data, progress) {
  const index = progressIndex(data.time.length, progress);
  const currentTime = data.time[index];
  const body = [];
  body.push(panel(42, 128, 1196, 526, '升力效率降低 10%：高度恢复过程', '01', COLORS.teal));
  const chart = { x: 108, y: 202, w: 1030, h: 350 };
  body.push(chartTicks(chart, [0, 2, 4, 6, 8, 10, 12], [0, 0.5, 1.0, 1.5], [0, 12], [0, 1.7], { yFormat: value => fmt(value, 1) }));
  const map = mapper({ minX: 0, maxX: 12, minY: 0, maxY: 1.7 }, chart);
  body.push(svgPath(samplePoints(data.reference.map((value, itemIndex) => map([data.time[itemIndex], value]))), { stroke: COLORS.ink, width: 2, dash: '7 5' }));
  body.push(svgPath(samplePoints(data.v8.slice(0, index + 1).map((value, itemIndex) => map([data.time[itemIndex], value]))), { stroke: COLORS.red, width: 3 }));
  body.push(svgPath(samplePoints(data.hte.slice(0, index + 1).map((value, itemIndex) => map([data.time[itemIndex], value]))), { stroke: COLORS.teal, width: 3.5 }));
  const current = map([currentTime, data.hte[index]]);
  body.push(line(current[0], chart.y, current[0], chart.y + chart.h, { stroke: '#8b949d', width: 1.5, dash: '5 5' }));
  body.push(circle(current[0], current[1], 7, { fill: COLORS.teal, stroke: '#fff', strokeWidth: 2 }));
  body.push(text(112, 190, '高度 / m', { size: 13, fill: COLORS.muted }));
  body.push(text(1138, 588, '时间 / s', { size: 13, fill: COLORS.muted, anchor: 'end' }));
  body.push(line(120, 602, 151, 602, { stroke: COLORS.ink, width: 2, dash: '7 5' }));
  body.push(text(160, 607, '参考高度', { size: 13, fill: COLORS.muted }));
  body.push(line(285, 602, 316, 602, { stroke: COLORS.red, width: 3 }));
  body.push(text(325, 607, 'RA-GCA/V8', { size: 13, fill: COLORS.muted }));
  body.push(line(470, 602, 501, 602, { stroke: COLORS.teal, width: 3.5 }));
  body.push(text(510, 607, BRAND, { size: 13, fill: COLORS.muted }));
  body.push(text(1138, 607, `当前时刻 ${fmt(currentTime, 2)} s · 当前高度 ${fmt(data.hte[index], 3)} m`, { size: 16, weight: 700, fill: COLORS.teal, anchor: 'end' }));
  return base(
    '参数鲁棒性：升力失配下的高度跟踪',
    '动态证据 · 单一指标：高度跟踪',
    '实线表示仿真高度，虚线表示参考；红色为冻结 V8 对照，青绿色为当前主算法。',
    body.join(''),
    '数据：Scene05B_LiftMinus10 · 正式主算法与冻结 V8 配对 raw · 仅展示高度跟踪结果',
  );
}

function parameterScaleFrameSvg(data, progress) {
  const index = progressIndex(data.time.length, progress);
  const currentTime = data.time[index];
  const body = [];
  body.push(panel(42, 128, 1196, 526, '置信门控推力尺度：估计、判定与平滑施加', '01', COLORS.amber));
  const chart = { x: 108, y: 202, w: 1030, h: 350 };
  body.push(chartTicks(chart, [0, 2, 4, 6, 8, 10, 12], [1.00, 1.04, 1.08, 1.12], [0, 12], [0.99, 1.125], { yFormat: value => fmt(value, 2) }));
  const map = mapper({ minX: 0, maxX: 12, minY: 0.99, maxY: 1.125 }, chart);
  const targetY = map([0, data.targetScale])[1];
  body.push(line(chart.x, targetY, chart.x + chart.w, targetY, { stroke: COLORS.ink, width: 2, dash: '7 5' }));
  body.push(svgPath(samplePoints(data.scaleEstimate.slice(0, index + 1).map((value, itemIndex) => map([data.time[itemIndex], value]))), { stroke: COLORS.amber, width: 2.5, dash: '6 4' }));
  body.push(svgPath(samplePoints(data.scale.slice(0, index + 1).map((value, itemIndex) => map([data.time[itemIndex], value]))), { stroke: COLORS.teal, width: 4 }));
  const current = map([currentTime, data.scale[index]]);
  body.push(line(current[0], chart.y, current[0], chart.y + chart.h, { stroke: '#8b949d', width: 1.5, dash: '5 5' }));
  body.push(circle(current[0], current[1], 7, { fill: COLORS.teal, stroke: '#fff', strokeWidth: 2 }));
  body.push(text(112, 190, '推力补偿尺度', { size: 13, fill: COLORS.muted }));
  body.push(text(1138, 588, '时间 / s', { size: 13, fill: COLORS.muted, anchor: 'end' }));
  body.push(line(120, 602, 151, 602, { stroke: COLORS.ink, width: 2, dash: '7 5' }));
  body.push(text(160, 607, `目标尺度 ${fmt(data.targetScale, 3)}`, { size: 13, fill: COLORS.muted }));
  body.push(line(390, 602, 421, 602, { stroke: COLORS.amber, width: 2.5, dash: '6 4' }));
  body.push(text(430, 607, '估计尺度', { size: 13, fill: COLORS.muted }));
  body.push(line(560, 602, 591, 602, { stroke: COLORS.teal, width: 4 }));
  body.push(text(600, 607, '实际施加尺度', { size: 13, fill: COLORS.muted }));
  const gate = data.gate[index] >= 0.5;
  body.push(rect(838, 580, 300, 42, { fill: gate ? COLORS.safeFill : '#eef1f4', stroke: gate ? '#9bc9ae' : '#ccd3da', radius: 5 }));
  body.push(text(988, 607, gate ? '置信门：通过' : '置信门：等待', { size: 16, weight: 700, fill: gate ? COLORS.green : COLORS.muted, anchor: 'middle' }));
  body.push(text(1138, 633, `t = ${fmt(currentTime, 2)} s · 当前尺度 ${fmt(data.scale[index], 4)}`, { size: 16, weight: 700, fill: COLORS.teal, anchor: 'end' }));
  return base(
    '参数鲁棒性：置信门控推力尺度',
    '动态证据 · 单一指标：尺度估计',
    '虚线为目标与估计尺度，青绿色实线为实际施加尺度；门控状态随工况演化。',
    body.join(''),
    '数据：Scene05B_LiftMinus10 · controllerDiagnostics[11:14] · 正式诊断码 914',
  );
}

function formationTrajectoryOnlyFrameSvg(data, progress) {
  const index = progressIndex(data.time.length, progress);
  const body = [];
  body.push(panel(42, 128, 1196, 526, '三机队形变换：实际位置与指令队形', '01', COLORS.purple));
  const plot = { x: 95, y: 194, w: 820, h: 395 };
  body.push(plotFrame(plot, { horizontal: 6, vertical: 6 }));
  const map = mapper(data.domain, plot);
  const colors = [COLORS.blue, COLORS.amber, COLORS.purple];
  for (let vehicleIndex = 0; vehicleIndex < 3; vehicleIndex += 1) {
    const trace = data.actual[vehicleIndex].slice(0, index + 1).map(map);
    body.push(svgPath(samplePoints(trace), { stroke: colors[vehicleIndex], width: 2.5, opacity: 0.6 }));
  }
  const actualNow = data.actual.map(vehicle => map(vehicle[index]));
  const desiredNow = data.desired.map(vehicle => map(vehicle[index]));
  body.push(`<polygon points="${desiredNow.map(point => point.join(',')).join(' ')}" fill="none" stroke="#9ba5af" stroke-width="2" stroke-dasharray="7 5"/>`);
  body.push(`<polygon points="${actualNow.map(point => point.join(',')).join(' ')}" fill="${COLORS.safeFill}" fill-opacity="0.4" stroke="${COLORS.ink}" stroke-width="2.5"/>`);
  desiredNow.forEach(point => {
    body.push(circle(point[0], point[1], 10, { fill: '#ffffff', stroke: '#9ba5af', strokeWidth: 2, opacity: 0.8 }));
  });
  actualNow.forEach((point, vehicleIndex) => body.push(droneGlyph(point[0], point[1], colors[vehicleIndex], `${vehicleIndex + 1}`)));
  body.push(text(104, 185, '水平面 X–Y / m', { size: 13, fill: COLORS.muted }));
  body.push(text(915, 616, `t = ${fmt(data.time[index], 2)} s`, { size: 18, weight: 700, anchor: 'end' }));
  const stage = data.time[index] < 20 ? '线列保持' : data.time[index] < 40 ? '连续变换' : '三角队形稳定';
  body.push(rect(975, 212, 212, 72, { fill: '#f1ebf7', stroke: '#d7c8e8', radius: 5 }));
  body.push(text(1081, 257, stage, { size: 21, weight: 700, fill: COLORS.purple, anchor: 'middle' }));
  body.push(text(1081, 345, fmt(data.formationError[index], 3), { size: 48, weight: 700, fill: COLORS.blue, anchor: 'middle' }));
  body.push(text(1081, 374, '当前队形位置RMSE / m', { size: 13, fill: COLORS.muted, anchor: 'middle' }));
  body.push(text(1081, 470, `全程队形RMSE ${fmt(data.globalFormationRmse, 3)} m`, { size: 16, weight: 700, fill: COLORS.blue, anchor: 'middle' }));
  body.push(text(1081, 505, `全程最小机间距 ${fmt(data.minimum, 3)} m`, { size: 16, weight: 700, fill: COLORS.green, anchor: 'middle' }));
  body.push(text(1081, 560, '三机均使用正式主控制器', { size: 13, fill: COLORS.muted, anchor: 'middle' }));
  return base(
    '三机编队：连续队形变换',
    '动态证据 · 单一指标：队形轨迹',
    '虚线三角形表示指令队形，实线多边形表示实际队形；尾迹显示变换过程。',
    body.join(''),
    '数据：Scene07B · 三机 controllerDiagnostics1:3[16] = 914 · 队形变换 raw',
  );
}

function formationDistanceOnlyFrameSvg(data, progress) {
  const index = progressIndex(data.time.length, progress);
  const body = [];
  body.push(panel(42, 128, 1196, 526, '三机队形变换：最近机间距', '01', COLORS.green));
  const chart = { x: 108, y: 202, w: 1030, h: 350 };
  const maxDistance = Math.max(...data.distance, 1.3);
  const yMax = Math.max(1.3, maxDistance * 1.05);
  body.push(rect(chart.x, chart.y + chart.h - ((0.6 - 0.3) / (yMax - 0.3)) * chart.h, chart.w, ((0.6 - 0.3) / (yMax - 0.3)) * chart.h, { fill: COLORS.dangerFill, opacity: 0.72 }));
  body.push(chartTicks(chart, [0, 10, 20, 30, 40, 50, 60], [0.4, 0.6, 0.8, 1.0, 1.2], [0, 60], [0.3, yMax], { yFormat: value => fmt(value, 1) }));
  const map = mapper({ minX: 0, maxX: 60, minY: 0.3, maxY: yMax }, chart);
  const threshold = map([0, 0.6])[1];
  body.push(line(chart.x, threshold, chart.x + chart.w, threshold, { stroke: COLORS.ink, width: 2, dash: '7 5' }));
  body.push(svgPath(samplePoints(data.distance.slice(0, index + 1).map((value, itemIndex) => map([data.time[itemIndex], value]))), { stroke: COLORS.green, width: 4 }));
  const current = map([data.time[index], data.distance[index]]);
  body.push(line(current[0], chart.y, current[0], chart.y + chart.h, { stroke: '#8b949d', width: 1.5, dash: '5 5' }));
  body.push(circle(current[0], current[1], 7, { fill: COLORS.green, stroke: '#fff', strokeWidth: 2 }));
  body.push(text(112, 190, '三维最近机间距 / m', { size: 13, fill: COLORS.muted }));
  body.push(text(1138, 588, '时间 / s', { size: 13, fill: COLORS.muted, anchor: 'end' }));
  body.push(text(112, 607, '红色区域：低于 0.60 m 的风险区间', { size: 13, fill: COLORS.red }));
  body.push(text(1138, 607, `全程最小 ${fmt(data.minimum, 3)} m · 当前 ${fmt(data.distance[index], 3)} m`, { size: 16, weight: 700, fill: COLORS.green, anchor: 'end' }));
  body.push(text(1138, 635, `队形RMSE ${fmt(data.globalFormationRmse, 3)} m · 阈值以下 ${fmt(data.violationSeconds, 2)} s`, { size: 15, weight: 700, fill: COLORS.ink, anchor: 'end' }));
  return base(
    '三机编队：最近机间距随时间变化',
    '动态证据 · 单一指标：编队安全距离',
    '绿色曲线表示全程最近机间距；黑色虚线为 0.60 m 安全阈值。',
    body.join(''),
    '数据：Scene07B · 三机队形变换 · 安全距离与队形误差由正式 raw 独立计算',
  );
}

function cbfGeometryOnlyFrameSvg(data, progress) {
  const index = progressIndex(data.time.length, progress);
  const body = [];
  body.push(panel(42, 128, 1196, 526, 'PP-CBF开关：同一轨迹指令下的队形安全对照', '01', COLORS.green));
  cbfSide(body, data.off, { x: 88, y: 255, w: 480, h: 260 }, '关闭 PP-CBF', COLORS.red, index, data.domain);
  cbfSide(body, data.on, { x: 712, y: 255, w: 480, h: 260 }, '开启预测 PP-CBF', COLORS.green, index, data.domain);
  body.push(text(640, 608, `同一时刻 t = ${fmt(data.time[index], 2)} s · 仅切换安全监督器`, { size: 17, weight: 700, anchor: 'middle' }));
  return base(
    'PP-CBF：队形几何安全对照',
    '动态证据 · 单一指标：安全监督效果',
    '左右两侧使用相同队形指令；彩色连线标出当前最近机对。',
    body.join(''),
    `数据：Scene07COff / Scene07COnPredictiveV5C · 关闭 ${fmt(data.off.minimum, 3)} m · 开启 ${fmt(data.on.minimum, 3)} m`,
  );
}

function cbfDistanceOnlyFrameSvg(data, progress) {
  const index = progressIndex(data.time.length, progress);
  const body = [];
  body.push(panel(42, 128, 1196, 526, 'PP-CBF开关：最近机间距曲线对照', '01', COLORS.green));
  const chart = { x: 108, y: 202, w: 1030, h: 350 };
  const maxDistance = Math.max(...data.off.distance, ...data.on.distance, 1.3);
  const yMax = Math.max(1.3, maxDistance * 1.05);
  body.push(rect(chart.x, chart.y + chart.h - ((0.6 - 0.3) / (yMax - 0.3)) * chart.h, chart.w, ((0.6 - 0.3) / (yMax - 0.3)) * chart.h, { fill: COLORS.dangerFill, opacity: 0.72 }));
  body.push(chartTicks(chart, [0, 10, 20, 30, 40, 50, 60], [0.4, 0.6, 0.8, 1.0, 1.2], [0, 60], [0.3, yMax], { yFormat: value => fmt(value, 1) }));
  const map = mapper({ minX: 0, maxX: 60, minY: 0.3, maxY: yMax }, chart);
  const threshold = map([0, 0.6])[1];
  body.push(line(chart.x, threshold, chart.x + chart.w, threshold, { stroke: COLORS.ink, width: 2, dash: '7 5' }));
  body.push(svgPath(samplePoints(data.off.distance.slice(0, index + 1).map((value, itemIndex) => map([data.off.time[itemIndex], value]))), { stroke: COLORS.red, width: 3.5 }));
  body.push(svgPath(samplePoints(data.on.distance.slice(0, index + 1).map((value, itemIndex) => map([data.on.time[itemIndex], value]))), { stroke: COLORS.green, width: 4 }));
  const currentOff = map([data.off.time[index], data.off.distance[index]]);
  const currentOn = map([data.on.time[index], data.on.distance[index]]);
  body.push(circle(currentOff[0], currentOff[1], 7, { fill: COLORS.red, stroke: '#fff', strokeWidth: 2 }));
  body.push(circle(currentOn[0], currentOn[1], 7, { fill: COLORS.green, stroke: '#fff', strokeWidth: 2 }));
  body.push(text(112, 190, '三维最近机间距 / m', { size: 13, fill: COLORS.muted }));
  body.push(text(1138, 588, '时间 / s', { size: 13, fill: COLORS.muted, anchor: 'end' }));
  body.push(line(120, 602, 151, 602, { stroke: COLORS.red, width: 3.5 }));
  body.push(text(160, 607, `关闭：最小 ${fmt(data.off.minimum, 3)} m`, { size: 13, fill: COLORS.red }));
  body.push(line(410, 602, 441, 602, { stroke: COLORS.green, width: 4 }));
  body.push(text(450, 607, `开启：最小 ${fmt(data.on.minimum, 3)} m`, { size: 13, fill: COLORS.green }));
  body.push(text(1138, 607, `阈值以下：关闭 ${fmt(data.off.violationSeconds, 2)} s · 开启 ${fmt(data.on.violationSeconds, 2)} s`, { size: 16, weight: 700, fill: COLORS.ink, anchor: 'end' }));
  return base(
    'PP-CBF：最近机间距曲线对照',
    '动态证据 · 单一指标：安全距离曲线',
    '红色为关闭安全监督器，绿色为开启预测 PP-CBF；黑色虚线为 0.60 m 阈值。',
    body.join(''),
    '数据：Scene07COff / Scene07COnPredictiveV5C · 同一任务指令下的反事实配对 raw',
  );
}

module.exports = {
  WIDTH,
  HEIGHT,
  BRAND,
  typicalSvg,
  parameterSvg,
  formationSvg,
  parameterFrameSvg,
  formationFrameSvg,
  cbfFrameSvg,
  parameterAltitudeFrameSvg,
  parameterScaleFrameSvg,
  formationTrajectoryOnlyFrameSvg,
  formationDistanceOnlyFrameSvg,
  cbfGeometryOnlyFrameSvg,
  cbfDistanceOnlyFrameSvg,
};
