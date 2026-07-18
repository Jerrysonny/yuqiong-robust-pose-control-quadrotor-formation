from __future__ import annotations

import csv
import hashlib
import json
import math
import re
import time
import urllib.parse
import urllib.request
from collections import Counter, defaultdict
from datetime import datetime, timezone
from itertools import combinations
from pathlib import Path

import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt
import networkx as nx
import numpy as np
from matplotlib.colors import LinearSegmentedColormap
from scipy.ndimage import gaussian_filter


ROOT = Path(__file__).resolve().parents[1]
DATA_DIR = ROOT / "data"
FIGURE_DIR = ROOT / "figures"
EVIDENCE_DIR = ROOT / "evidence"
RAW_PATH = DATA_DIR / "openalex_raw_2015_2025.jsonl"
CLEAN_PATH = DATA_DIR / "openalex_control_works_2015_2025.csv"
TERM_PATH = DATA_DIR / "canonical_term_counts.csv"
EDGE_PATH = DATA_DIR / "canonical_term_edges.csv"
THEME_PATH = DATA_DIR / "theme_year_counts.csv"
PROTOCOL_PATH = EVIDENCE_DIR / "openalex_query_protocol.json"
QUALITY_PATH = EVIDENCE_DIR / "figure_quality_metrics.json"
MANIFEST_PATH = EVIDENCE_DIR / "sha256_manifest.csv"

YEAR_START = 2015
YEAR_END = 2025
QUERY_TERMS = ("quadrotor", "quadcopter", "multirotor")
ALLOWED_TYPES = {"article", "conference-paper", "proceedings-article", "review"}
OPENALEX_FIELDS = (
    "id,doi,title,publication_year,publication_date,type,cited_by_count,"
    "primary_topic,topics,keywords"
)

SCOPE_PATTERNS = (
    r"\bcontrol\b",
    r"\btracking\b",
    r"\btrajectory\b",
    r"\battitude\b",
    r"\bstabili[sz](?:ation|ing|e|ed)\b",
    r"\bnavigation\b",
    r"\bpath planning\b",
    r"\bformation\b",
    r"\bswarm\b",
    r"\bmulti[- ]agent\b",
    r"\bobstacle avoidance\b",
    r"\bfault[- ]tolerant\b",
    r"\bcontrol allocation\b",
)

# Canonical terms are intentionally compact and domain-led. They prevent raw
# metadata variants from becoming separate nodes in the report figure.
CANONICAL_TERMS = {
    "trajectory_tracking": {
        "label": "轨迹跟踪",
        "patterns": (r"trajectory tracking", r"path tracking", r"position tracking"),
    },
    "attitude_control": {
        "label": "姿态控制",
        "patterns": (r"attitude control", r"attitude tracking", r"orientation control"),
    },
    "geometric_control": {
        "label": "几何控制",
        "patterns": (r"geometric control", r"\bso\(3\)\b", r"\bse\(3\)\b", r"lie group"),
    },
    "nonlinear_control": {
        "label": "非线性控制",
        "patterns": (r"nonlinear control", r"backstepping", r"feedback linearization"),
    },
    "pid_control": {
        "label": "PID控制",
        "patterns": (r"\bpid\b", r"proportional integral derivative"),
    },
    "sliding_mode": {
        "label": "滑模控制",
        "patterns": (r"sliding mode", r"super twisting", r"terminal sliding"),
    },
    "robust_control": {
        "label": "鲁棒控制",
        "patterns": (r"robust control", r"robust tracking", r"\bh infinity\b", r"\bh∞\b"),
    },
    "adaptive_control": {
        "label": "自适应控制",
        "patterns": (r"adaptive control", r"model reference adaptive", r"parameter adaptation"),
    },
    "disturbance_observer": {
        "label": "扰动观测",
        "patterns": (r"disturbance observer", r"disturbance estimation", r"extended state observer"),
    },
    "adrc": {
        "label": "ADRC",
        "patterns": (r"\badrc\b", r"active disturbance rejection"),
    },
    "indi": {
        "label": "INDI",
        "patterns": (r"\bindi\b", r"incremental nonlinear dynamic inversion"),
    },
    "mpc": {
        "label": "MPC",
        "patterns": (r"\bmpc\b", r"model predictive control", r"predictive control"),
    },
    "optimal_control": {
        "label": "最优控制",
        "patterns": (r"optimal control", r"trajectory optimization", r"optimal trajectory"),
    },
    "control_allocation": {
        "label": "控制分配",
        "patterns": (r"control allocation", r"actuator allocation", r"thrust allocation"),
    },
    "fault_tolerant": {
        "label": "容错控制",
        "patterns": (r"fault tolerant", r"fault-tolerant", r"actuator fault", r"rotor failure"),
    },
    "state_estimation": {
        "label": "状态估计",
        "patterns": (r"state estimation", r"kalman filter", r"state observer", r"pose estimation"),
    },
    "sensor_fusion": {
        "label": "传感器融合",
        "patterns": (r"sensor fusion", r"multi sensor", r"visual inertial", r"visual-inertial"),
    },
    "system_identification": {
        "label": "系统辨识",
        "patterns": (r"system identification", r"parameter identification", r"model identification"),
    },
    "path_planning": {
        "label": "路径规划",
        "patterns": (r"path planning", r"motion planning", r"trajectory planning"),
    },
    "obstacle_avoidance": {
        "label": "避障",
        "patterns": (r"obstacle avoidance", r"collision avoidance", r"collision-free"),
    },
    "formation_control": {
        "label": "编队控制",
        "patterns": (r"formation control", r"formation tracking", r"formation flight"),
    },
    "multi_agent": {
        "label": "多智能体协同",
        "patterns": (r"multi agent", r"multi-agent", r"cooperative control", r"consensus control", r"swarm control"),
    },
    "cbf": {
        "label": "CBF安全控制",
        "patterns": (r"control barrier function", r"\bcbf\b", r"safety critical control", r"safety-critical control"),
    },
    "reinforcement_learning": {
        "label": "强化学习",
        "patterns": (r"reinforcement learning", r"deep reinforcement", r"\bq learning\b"),
    },
    "neural_control": {
        "label": "神经网络控制",
        "patterns": (r"neural network", r"deep learning", r"learning based control", r"learning-based control"),
    },
    "wind_disturbance": {
        "label": "风扰抑制",
        "patterns": (r"wind disturbance", r"wind gust", r"aerodynamic disturbance", r"gust rejection"),
    },
}

THEMES = {
    "geometry_tracking": {
        "label": "几何与轨迹跟踪",
        "terms": {"trajectory_tracking", "attitude_control", "geometric_control", "nonlinear_control", "pid_control"},
    },
    "robust_adaptive": {
        "label": "鲁棒、自适应与扰动抑制",
        "terms": {"sliding_mode", "robust_control", "adaptive_control", "disturbance_observer", "adrc", "indi", "wind_disturbance"},
    },
    "optimization_constraints": {
        "label": "优化与约束控制",
        "terms": {"mpc", "optimal_control", "control_allocation"},
    },
    "estimation_learning": {
        "label": "估计与学习增强",
        "terms": {"state_estimation", "sensor_fusion", "system_identification", "reinforcement_learning", "neural_control"},
    },
    "formation_safety": {
        "label": "编队协同与安全",
        "terms": {"formation_control", "multi_agent", "cbf", "obstacle_avoidance", "path_planning"},
    },
    "allocation_fault": {
        "label": "分配与容错",
        "terms": {"control_allocation", "fault_tolerant"},
    },
}

PALETTE = ("#157A8A", "#D35D42", "#4F6FAE", "#4E8B62", "#A05B80", "#C49320")


def configure_matplotlib() -> None:
    plt.rcParams.update(
        {
            "font.family": ["Times New Roman", "SimSun"],
            "font.sans-serif": ["SimSun", "Microsoft YaHei", "Arial Unicode MS"],
            "axes.unicode_minus": False,
            "axes.edgecolor": "#343434",
            "axes.linewidth": 0.8,
            "axes.labelcolor": "#222222",
            "xtick.color": "#333333",
            "ytick.color": "#333333",
            "text.color": "#222222",
            "svg.fonttype": "none",
            "pdf.fonttype": 42,
            "savefig.facecolor": "white",
            "figure.facecolor": "white",
        }
    )


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for block in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(block)
    return digest.hexdigest().upper()


def request_json(params: dict[str, str], attempts: int = 5) -> dict:
    # 网络请求采用有限次数重试，并在失败后保留明确错误。
    url = "https://api.openalex.org/works?" + urllib.parse.urlencode(params)
    headers = {"User-Agent": "A8-Simulation-Report-Bibliometrics/1.0"}
    last_error: Exception | None = None
    for attempt in range(attempts):
        try:
            request = urllib.request.Request(url, headers=headers)
            with urllib.request.urlopen(request, timeout=60) as response:
                return json.load(response)
        except Exception as error:  # Network retries are recorded by progress output.
            last_error = error
            time.sleep(2**attempt)
    raise RuntimeError(f"OpenAlex request failed after {attempts} attempts: {last_error}")


def fetch_openalex() -> list[dict]:
    if RAW_PATH.exists():
        with RAW_PATH.open("r", encoding="utf-8") as handle:
            return [json.loads(line) for line in handle if line.strip()]

    works: dict[str, dict] = {}
    for query_term in QUERY_TERMS:
        cursor = "*"
        page = 0
        while cursor:
            params = {
                "filter": (
                    f"title.search:{query_term},"
                    f"from_publication_date:{YEAR_START}-01-01,"
                    f"to_publication_date:{YEAR_END}-12-31"
                ),
                "per-page": "200",
                "cursor": cursor,
                "select": OPENALEX_FIELDS,
            }
            payload = request_json(params)
            page += 1
            for work in payload.get("results", []):
                work_id = work.get("id")
                if not work_id:
                    continue
                if work_id not in works:
                    work["matched_queries"] = [query_term]
                    works[work_id] = work
                elif query_term not in works[work_id]["matched_queries"]:
                    works[work_id]["matched_queries"].append(query_term)
            cursor = payload.get("meta", {}).get("next_cursor")
            print(f"{query_term}: page {page}, unique works {len(works)}", flush=True)
            time.sleep(0.08)

    ordered = sorted(works.values(), key=lambda item: item.get("id", ""))
    with RAW_PATH.open("w", encoding="utf-8", newline="\n") as handle:
        for work in ordered:
            handle.write(json.dumps(work, ensure_ascii=False, sort_keys=True) + "\n")
    return ordered


def metadata_text(work: dict) -> str:
    pieces = [work.get("title") or ""]
    for keyword in work.get("keywords") or []:
        score = keyword.get("score")
        if score is None or float(score) >= 0.35:
            pieces.append(keyword.get("display_name") or "")
    return normalize_text(" ".join(pieces))


def normalize_text(value: str) -> str:
    value = value.lower().replace("–", "-").replace("—", "-")
    value = re.sub(r"[_/]+", " ", value)
    value = re.sub(r"\s+", " ", value)
    return value.strip()


def matched_terms(text: str) -> tuple[str, ...]:
    matched = []
    for term, spec in CANONICAL_TERMS.items():
        if any(re.search(pattern, text, flags=re.IGNORECASE) for pattern in spec["patterns"]):
            matched.append(term)
    return tuple(sorted(set(matched)))


def work_in_scope(work: dict, text: str) -> bool:
    if work.get("type") not in ALLOWED_TYPES:
        return False
    year = work.get("publication_year")
    if not isinstance(year, int) or not YEAR_START <= year <= YEAR_END:
        return False
    return any(re.search(pattern, text, flags=re.IGNORECASE) for pattern in SCOPE_PATTERNS)


def clean_works(raw_works: list[dict]) -> list[dict]:
    # 文献清洗按题名、摘要和关键词规则去重并筛选范围。
    rows = []
    seen_doi: set[str] = set()
    for work in raw_works:
        text = metadata_text(work)
        if not work_in_scope(work, text):
            continue
        terms = matched_terms(text)
        if not terms:
            continue
        doi = (work.get("doi") or "").lower().strip()
        if doi and doi in seen_doi:
            continue
        if doi:
            seen_doi.add(doi)
        themes = sorted(
            theme
            for theme, spec in THEMES.items()
            if set(terms).intersection(spec["terms"])
        )
        rows.append(
            {
                "openalex_id": work.get("id") or "",
                "doi": doi,
                "title": work.get("title") or "",
                "publication_year": work.get("publication_year"),
                "publication_date": work.get("publication_date") or "",
                "type": work.get("type") or "",
                "cited_by_count": int(work.get("cited_by_count") or 0),
                "matched_queries": ";".join(sorted(work.get("matched_queries") or [])),
                "canonical_terms": ";".join(terms),
                "themes": ";".join(themes),
            }
        )
    rows.sort(key=lambda row: (row["publication_year"], row["title"].lower()))
    return rows


def write_csv(path: Path, rows: list[dict], fieldnames: list[str]) -> None:
    with path.open("w", encoding="utf-8-sig", newline="") as handle:
        writer = csv.DictWriter(handle, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(rows)


def build_statistics(rows: list[dict]) -> dict:
    term_counts: Counter[str] = Counter()
    edge_counts: Counter[tuple[str, str]] = Counter()
    year_counts: Counter[int] = Counter()
    theme_year_counts: Counter[tuple[str, int]] = Counter()
    paper_terms: list[set[str]] = []

    for row in rows:
        year = int(row["publication_year"])
        terms = {term for term in row["canonical_terms"].split(";") if term}
        themes = {theme for theme in row["themes"].split(";") if theme}
        paper_terms.append(terms)
        year_counts[year] += 1
        term_counts.update(terms)
        for edge in combinations(sorted(terms), 2):
            edge_counts[edge] += 1
        for theme in themes:
            theme_year_counts[(theme, year)] += 1

    minimum_term_count = max(15, int(round(len(rows) * 0.004)))
    eligible = [term for term, count in term_counts.most_common() if count >= minimum_term_count]
    selected_terms = eligible[:22]
    selected_set = set(selected_terms)

    edge_rows = []
    for (source, target), count in edge_counts.items():
        if source not in selected_set or target not in selected_set:
            continue
        association = count / math.sqrt(term_counts[source] * term_counts[target])
        edge_rows.append(
            {
                "source": source,
                "target": target,
                "source_label": CANONICAL_TERMS[source]["label"],
                "target_label": CANONICAL_TERMS[target]["label"],
                "cooccurrence": count,
                "association_strength": association,
            }
        )

    edge_rows.sort(key=lambda row: row["association_strength"], reverse=True)
    strongest_by_node: defaultdict[str, list[dict]] = defaultdict(list)
    for edge in edge_rows:
        strongest_by_node[edge["source"]].append(edge)
        strongest_by_node[edge["target"]].append(edge)
    retained_keys = set()
    for term in selected_terms:
        for edge in sorted(
            strongest_by_node[term],
            key=lambda item: (item["association_strength"], item["cooccurrence"]),
            reverse=True,
        )[:4]:
            retained_keys.add(tuple(sorted((edge["source"], edge["target"]))))
    retained_edges = [
        edge
        for edge in edge_rows
        if tuple(sorted((edge["source"], edge["target"]))) in retained_keys
        or edge["association_strength"] >= 0.16
    ]

    term_rows = []
    for rank, term in enumerate(selected_terms, start=1):
        term_rows.append(
            {
                "rank": rank,
                "term": term,
                "label": CANONICAL_TERMS[term]["label"],
                "paper_count": term_counts[term],
                "paper_share": term_counts[term] / len(rows),
            }
        )

    theme_rows = []
    for year in range(YEAR_START, YEAR_END + 1):
        denominator = year_counts[year]
        for theme, spec in THEMES.items():
            count = theme_year_counts[(theme, year)]
            theme_rows.append(
                {
                    "year": year,
                    "theme": theme,
                    "theme_label": spec["label"],
                    "paper_count": count,
                    "year_total": denominator,
                    "paper_share": count / denominator if denominator else 0.0,
                }
            )

    return {
        "term_counts": term_counts,
        "edge_counts": edge_counts,
        "year_counts": year_counts,
        "theme_year_counts": theme_year_counts,
        "selected_terms": selected_terms,
        "term_rows": term_rows,
        "edge_rows": retained_edges,
        "theme_rows": theme_rows,
        "minimum_term_count": minimum_term_count,
    }


def build_graph(stats: dict) -> tuple[nx.Graph, dict[str, np.ndarray], dict[str, int]]:
    # 关键词共现网络使用固定随机种子生成可重复布局。
    graph = nx.Graph()
    counts = stats["term_counts"]
    for term in stats["selected_terms"]:
        graph.add_node(term, count=counts[term], label=CANONICAL_TERMS[term]["label"])
    for edge in stats["edge_rows"]:
        graph.add_edge(
            edge["source"],
            edge["target"],
            weight=float(edge["association_strength"]),
            cooccurrence=int(edge["cooccurrence"]),
        )

    if graph.number_of_edges() == 0:
        raise RuntimeError("No co-occurrence edges survived filtering")
    communities = list(nx.algorithms.community.greedy_modularity_communities(graph, weight="weight"))
    community_id = {}
    for index, community in enumerate(sorted(communities, key=len, reverse=True)):
        for node in community:
            community_id[node] = index
    positions = nx.spring_layout(graph, seed=42, weight="weight", k=0.72, iterations=400)
    return graph, positions, community_id


def normalize_positions(positions: dict[str, np.ndarray]) -> dict[str, np.ndarray]:
    keys = list(positions)
    values = np.array([positions[key] for key in keys], dtype=float)
    for axis in range(2):
        span = np.ptp(values[:, axis])
        if span:
            values[:, axis] = 2.0 * (values[:, axis] - values[:, axis].min()) / span - 1.0
    return {key: values[index] for index, key in enumerate(keys)}


def repel_label_positions(points: dict[str, np.ndarray]) -> dict[str, np.ndarray]:
    labels = {key: np.array(value, dtype=float) * 1.08 for key, value in points.items()}
    keys = list(labels)
    for _ in range(450):
        delta = {key: np.zeros(2) for key in keys}
        for left, right in combinations(keys, 2):
            diff = labels[left] - labels[right]
            distance_x = abs(diff[0])
            distance_y = abs(diff[1])
            if distance_x < 0.27 and distance_y < 0.105:
                direction = diff / (np.linalg.norm(diff) + 1e-6)
                strength = 0.008 * (1.0 - distance_x / 0.27) * (1.0 - distance_y / 0.105)
                delta[left] += direction * strength
                delta[right] -= direction * strength
        for key in keys:
            delta[key] += (points[key] - labels[key]) * 0.0018
            labels[key] += delta[key]
            labels[key][0] = np.clip(labels[key][0], -1.22, 1.22)
            labels[key][1] = np.clip(labels[key][1], -1.12, 1.12)
    return labels


def add_network_to_axis(
    axis: plt.Axes,
    graph: nx.Graph,
    positions: dict[str, np.ndarray],
    community_id: dict[str, int],
    compact: bool = False,
) -> int:
    positions = normalize_positions(positions)
    labels = repel_label_positions(positions)
    counts = nx.get_node_attributes(graph, "count")
    max_count = max(counts.values())
    edges = list(graph.edges(data=True))
    edge_weights = [edge[2]["weight"] for edge in edges]
    maximum_edge = max(edge_weights)
    for source, target, data in sorted(edges, key=lambda edge: edge[2]["weight"]):
        weight = data["weight"] / maximum_edge
        axis.plot(
            [positions[source][0], positions[target][0]],
            [positions[source][1], positions[target][1]],
            color="#8A9298",
            alpha=0.10 + 0.32 * weight,
            linewidth=0.35 + 1.5 * weight,
            zorder=1,
        )

    for node in graph.nodes:
        count = counts[node]
        size = 110 + 1080 * math.sqrt(count / max_count)
        color = PALETTE[community_id[node] % len(PALETTE)]
        axis.scatter(
            positions[node][0],
            positions[node][1],
            s=size * (0.72 if compact else 1.0),
            color=color,
            edgecolor="white",
            linewidth=1.0,
            alpha=0.93,
            zorder=3,
        )
        if np.linalg.norm(labels[node] - positions[node]) > 0.035:
            axis.plot(
                [positions[node][0], labels[node][0]],
                [positions[node][1], labels[node][1]],
                color="#777777",
                linewidth=0.45,
                alpha=0.7,
                zorder=2,
            )
        axis.text(
            labels[node][0],
            labels[node][1],
            graph.nodes[node]["label"],
            ha="center",
            va="center",
            fontsize=7.0 if compact else 8.2,
            bbox={"boxstyle": "round,pad=0.16", "facecolor": "white", "edgecolor": "none", "alpha": 0.82},
            zorder=4,
        )
    axis.set_xlim(-1.34, 1.34)
    axis.set_ylim(-1.23, 1.23)
    axis.set_aspect("equal")
    axis.axis("off")

    overlap_count = 0
    values = list(labels.values())
    for left, right in combinations(values, 2):
        if abs(left[0] - right[0]) < 0.18 and abs(left[1] - right[1]) < 0.075:
            overlap_count += 1
    return overlap_count


def save_figure(figure: plt.Figure, stem: str) -> list[Path]:
    outputs = []
    for suffix, kwargs in (
        (".png", {"dpi": 320}),
        (".svg", {}),
        (".pdf", {}),
    ):
        path = FIGURE_DIR / f"{stem}{suffix}"
        figure.savefig(path, bbox_inches="tight", pad_inches=0.08, **kwargs)
        outputs.append(path)
    plt.close(figure)
    return outputs


def plot_keyword_network(graph: nx.Graph, positions: dict, community_id: dict) -> tuple[list[Path], int]:
    figure, axis = plt.subplots(figsize=(11.8, 7.2))
    overlap_count = add_network_to_axis(axis, graph, positions, community_id)
    axis.text(0.01, 0.985, "a", transform=axis.transAxes, fontsize=12, fontweight="bold", va="top")
    return save_figure(figure, "candidate_A_keyword_cooccurrence_network"), overlap_count


def density_grid(graph: nx.Graph, positions: dict[str, np.ndarray]) -> tuple[np.ndarray, np.ndarray, np.ndarray]:
    positions = normalize_positions(positions)
    grid_x = np.linspace(-1.25, 1.25, 420)
    grid_y = np.linspace(-1.15, 1.15, 360)
    xx, yy = np.meshgrid(grid_x, grid_y)
    zz = np.zeros_like(xx)
    counts = nx.get_node_attributes(graph, "count")
    maximum = max(counts.values())
    for node, point in positions.items():
        weight = math.sqrt(counts[node] / maximum)
        sigma_x = 0.16 + 0.045 * weight
        sigma_y = 0.14 + 0.04 * weight
        zz += weight * np.exp(
            -0.5 * (((xx - point[0]) / sigma_x) ** 2 + ((yy - point[1]) / sigma_y) ** 2)
        )
    zz = gaussian_filter(zz, sigma=2.0)
    return xx, yy, zz


def plot_density_map(graph: nx.Graph, positions: dict) -> list[Path]:
    positions = normalize_positions(positions)
    xx, yy, zz = density_grid(graph, positions)
    cmap = LinearSegmentedColormap.from_list(
        "report_density",
        ("#F8FAFA", "#D8ECE4", "#73B8A2", "#F1C75B", "#C44E3B"),
    )
    figure, axis = plt.subplots(figsize=(11.8, 7.2))
    image = axis.contourf(xx, yy, zz, levels=24, cmap=cmap)
    counts = nx.get_node_attributes(graph, "count")
    top_nodes = sorted(graph.nodes, key=lambda node: counts[node], reverse=True)[:16]
    for node in top_nodes:
        axis.text(
            positions[node][0],
            positions[node][1],
            graph.nodes[node]["label"],
            fontsize=8.0,
            ha="center",
            va="center",
            bbox={"boxstyle": "round,pad=0.12", "facecolor": "white", "edgecolor": "none", "alpha": 0.64},
        )
    axis.set_xlim(-1.25, 1.25)
    axis.set_ylim(-1.15, 1.15)
    axis.set_aspect("equal")
    axis.axis("off")
    colorbar = figure.colorbar(image, ax=axis, fraction=0.035, pad=0.015)
    colorbar.set_label("相对研究密度", fontsize=9)
    colorbar.ax.tick_params(labelsize=7)
    axis.text(0.01, 0.985, "a", transform=axis.transAxes, fontsize=12, fontweight="bold", va="top")
    return save_figure(figure, "candidate_B_keyword_density_map")


def theme_matrix(stats: dict) -> tuple[list[int], list[str], np.ndarray]:
    years = list(range(YEAR_START, YEAR_END + 1))
    theme_keys = list(THEMES)
    matrix = np.zeros((len(theme_keys), len(years)))
    year_totals = stats["year_counts"]
    for row_index, theme in enumerate(theme_keys):
        for column_index, year in enumerate(years):
            denominator = year_totals[year]
            matrix[row_index, column_index] = (
                100.0 * stats["theme_year_counts"][(theme, year)] / denominator
                if denominator
                else 0.0
            )
    return years, theme_keys, matrix


def plot_topic_evolution(stats: dict) -> list[Path]:
    years, theme_keys, matrix = theme_matrix(stats)
    counts = [stats["year_counts"][year] for year in years]
    figure, (axis_top, axis_bottom) = plt.subplots(
        2,
        1,
        figsize=(11.8, 7.6),
        gridspec_kw={"height_ratios": [1.0, 1.55], "hspace": 0.30},
    )
    axis_top.bar(years, counts, color="#397C89", width=0.68, edgecolor="white", linewidth=0.5)
    axis_top.plot(years, counts, color="#C6533E", linewidth=1.5, marker="o", markersize=3.5)
    axis_top.set_ylabel("论文数量")
    axis_top.set_xticks(years)
    axis_top.grid(axis="y", color="#D8D8D8", linewidth=0.55, alpha=0.75)
    axis_top.spines[["top", "right"]].set_visible(False)
    axis_top.text(-0.055, 1.02, "a", transform=axis_top.transAxes, fontsize=12, fontweight="bold")

    image = axis_bottom.imshow(matrix, aspect="auto", cmap="YlGnBu", vmin=0.0)
    axis_bottom.set_xticks(range(len(years)), years)
    axis_bottom.set_yticks(range(len(theme_keys)), [THEMES[key]["label"] for key in theme_keys])
    axis_bottom.set_xlabel("发表年份")
    axis_bottom.tick_params(axis="y", labelsize=8.5)
    for row in range(matrix.shape[0]):
        for column in range(matrix.shape[1]):
            value = matrix[row, column]
            axis_bottom.text(
                column,
                row,
                f"{value:.0f}",
                ha="center",
                va="center",
                fontsize=6.4,
                color="white" if value > 0.62 * matrix.max() else "#222222",
            )
    colorbar = figure.colorbar(image, ax=axis_bottom, fraction=0.025, pad=0.02)
    colorbar.set_label("当年相关论文占比 (%)", fontsize=9)
    colorbar.ax.tick_params(labelsize=7)
    axis_bottom.text(-0.055, 1.02, "b", transform=axis_bottom.transAxes, fontsize=12, fontweight="bold")
    return save_figure(figure, "candidate_C_publication_and_theme_evolution")


def plot_thematic_map(stats: dict) -> list[Path]:
    term_counts = stats["term_counts"]
    edge_counts = stats["edge_counts"]
    theme_keys = list(THEMES)
    points = []
    for theme in theme_keys:
        terms = [term for term in THEMES[theme]["terms"] if term_counts[term] > 0]
        internal = 0.0
        external = 0.0
        for left, right in combinations(terms, 2):
            internal += edge_counts[tuple(sorted((left, right)))]
        for term in terms:
            for other in CANONICAL_TERMS:
                if other in terms:
                    continue
                external += edge_counts[tuple(sorted((term, other)))]
        frequency = sum(term_counts[term] for term in terms)
        possible_internal = max(1, len(terms) * (len(terms) - 1) / 2)
        density = internal / possible_internal
        centrality = external / max(1, len(terms))
        points.append((theme, centrality, density, frequency))

    centralities = np.array([point[1] for point in points], dtype=float)
    densities = np.array([point[2] for point in points], dtype=float)
    frequencies = np.array([point[3] for point in points], dtype=float)
    centralities = (centralities - centralities.min()) / (np.ptp(centralities) or 1.0)
    densities = (densities - densities.min()) / (np.ptp(densities) or 1.0)

    figure, axis = plt.subplots(figsize=(10.0, 7.2))
    axis.axvline(np.median(centralities), color="#8A8A8A", linewidth=0.8, linestyle="--")
    axis.axhline(np.median(densities), color="#8A8A8A", linewidth=0.8, linestyle="--")
    for index, ((theme, _, _, _), x_value, y_value, frequency) in enumerate(
        zip(points, centralities, densities, frequencies)
    ):
        size = 700 + 2400 * math.sqrt(frequency / frequencies.max())
        axis.scatter(
            x_value,
            y_value,
            s=size,
            color=PALETTE[index % len(PALETTE)],
            alpha=0.78,
            edgecolor="white",
            linewidth=1.2,
        )
        axis.text(x_value, y_value, THEMES[theme]["label"], ha="center", va="center", fontsize=8.5)
    axis.set_xlabel("跨主题关联度")
    axis.set_ylabel("主题内部凝聚度")
    axis.set_xlim(-0.13, 1.13)
    axis.set_ylim(-0.13, 1.13)
    axis.grid(color="#E2E2E2", linewidth=0.55, alpha=0.75)
    axis.spines[["top", "right"]].set_visible(False)
    axis.text(0.02, 0.97, "专门化主题", transform=axis.transAxes, fontsize=8, color="#666666", va="top")
    axis.text(0.98, 0.97, "核心驱动主题", transform=axis.transAxes, fontsize=8, color="#666666", va="top", ha="right")
    axis.text(0.02, 0.03, "新兴或衰退主题", transform=axis.transAxes, fontsize=8, color="#666666", va="bottom")
    axis.text(0.98, 0.03, "基础横向主题", transform=axis.transAxes, fontsize=8, color="#666666", va="bottom", ha="right")
    axis.text(-0.08, 1.02, "a", transform=axis.transAxes, fontsize=12, fontweight="bold")
    return save_figure(figure, "candidate_D_thematic_strategic_map")


def plot_recommended_composite(graph: nx.Graph, positions: dict, community_id: dict, stats: dict) -> tuple[list[Path], int]:
    years, theme_keys, matrix = theme_matrix(stats)
    figure, (axis_left, axis_right) = plt.subplots(
        1,
        2,
        figsize=(15.6, 6.8),
        gridspec_kw={"width_ratios": [1.18, 1.0], "wspace": 0.12},
    )
    overlap_count = add_network_to_axis(axis_left, graph, positions, community_id, compact=True)
    axis_left.text(0.01, 0.985, "a", transform=axis_left.transAxes, fontsize=12, fontweight="bold", va="top")
    image = axis_right.imshow(matrix, aspect="auto", cmap="YlGnBu", vmin=0.0)
    axis_right.set_xticks(range(len(years)), years, rotation=45, ha="right")
    axis_right.set_yticks(range(len(theme_keys)), [THEMES[key]["label"] for key in theme_keys])
    axis_right.set_xlabel("发表年份")
    axis_right.tick_params(axis="both", labelsize=8)
    colorbar = figure.colorbar(image, ax=axis_right, fraction=0.036, pad=0.025)
    colorbar.set_label("当年相关论文占比 (%)", fontsize=9)
    colorbar.ax.tick_params(labelsize=7)
    axis_right.text(-0.07, 1.02, "b", transform=axis_right.transAxes, fontsize=12, fontweight="bold")
    return save_figure(figure, "candidate_E_recommended_network_and_evolution"), overlap_count


def write_protocol(raw_count: int, clean_count: int, stats: dict) -> None:
    protocol = {
        "title": "OpenAlex quadrotor-control research landscape protocol",
        "retrieved_at_utc": datetime.now(timezone.utc).isoformat(),
        "source": "OpenAlex Works API",
        "endpoint": "https://api.openalex.org/works",
        "year_start": YEAR_START,
        "year_end": YEAR_END,
        "title_search_terms": list(QUERY_TERMS),
        "included_types": sorted(ALLOWED_TYPES),
        "scope_rule": "vehicle term in title plus control-related term in title or OpenAlex keyword with score >= 0.35",
        "deduplication": "OpenAlex ID union followed by DOI deduplication",
        "raw_unique_works": raw_count,
        "clean_in_scope_works": clean_count,
        "canonical_term_count": len(CANONICAL_TERMS),
        "selected_network_terms": stats["selected_terms"],
        "minimum_term_count": stats["minimum_term_count"],
        "limitations": [
            "High-precision title search may omit relevant works that mention the vehicle only in abstracts.",
            "OpenAlex coverage and keyword assignment vary by venue and language.",
            "Broad OpenAlex topics and primary topics are excluded from term extraction to reduce thematic inflation.",
            "Canonical synonym mapping is domain-led and is archived in the plotting script.",
            "Counts describe the indexed corpus and are not an official census of all publications.",
        ],
    }
    PROTOCOL_PATH.write_text(json.dumps(protocol, ensure_ascii=False, indent=2), encoding="utf-8")


def write_manifest() -> None:
    # 输出清单绑定检索协议、数据表和全部图件。
    files = sorted(
        path
        for directory in (DATA_DIR, FIGURE_DIR, EVIDENCE_DIR, ROOT / "scripts")
        for path in directory.glob("*")
        if path.is_file() and path != MANIFEST_PATH
    )
    rows = [
        {
            "relative_path": path.relative_to(ROOT).as_posix(),
            "bytes": path.stat().st_size,
            "sha256": sha256(path),
        }
        for path in files
    ]
    write_csv(MANIFEST_PATH, rows, ["relative_path", "bytes", "sha256"])


def main() -> None:
    for directory in (DATA_DIR, FIGURE_DIR, EVIDENCE_DIR):
        directory.mkdir(parents=True, exist_ok=True)
    configure_matplotlib()

    raw_works = fetch_openalex()
    clean_rows = clean_works(raw_works)
    if len(clean_rows) < 500:
        raise RuntimeError(f"Scope filter retained only {len(clean_rows)} works; expected at least 500")
    write_csv(
        CLEAN_PATH,
        clean_rows,
        [
            "openalex_id",
            "doi",
            "title",
            "publication_year",
            "publication_date",
            "type",
            "cited_by_count",
            "matched_queries",
            "canonical_terms",
            "themes",
        ],
    )
    stats = build_statistics(clean_rows)
    write_csv(
        TERM_PATH,
        stats["term_rows"],
        ["rank", "term", "label", "paper_count", "paper_share"],
    )
    write_csv(
        EDGE_PATH,
        stats["edge_rows"],
        ["source", "target", "source_label", "target_label", "cooccurrence", "association_strength"],
    )
    write_csv(
        THEME_PATH,
        stats["theme_rows"],
        ["year", "theme", "theme_label", "paper_count", "year_total", "paper_share"],
    )

    graph, positions, community_id = build_graph(stats)
    generated = []
    network_files, network_overlap = plot_keyword_network(graph, positions, community_id)
    generated.extend(network_files)
    generated.extend(plot_density_map(graph, positions))
    generated.extend(plot_topic_evolution(stats))
    generated.extend(plot_thematic_map(stats))
    composite_files, composite_overlap = plot_recommended_composite(
        graph, positions, community_id, stats
    )
    generated.extend(composite_files)

    quality = {
        "generated_at_utc": datetime.now(timezone.utc).isoformat(),
        "raw_unique_works": len(raw_works),
        "clean_in_scope_works": len(clean_rows),
        "selected_network_terms": len(stats["selected_terms"]),
        "retained_network_edges": len(stats["edge_rows"]),
        "network_approximate_label_overlap_pairs": network_overlap,
        "composite_approximate_label_overlap_pairs": composite_overlap,
        "figure_files": [path.relative_to(ROOT).as_posix() for path in generated],
        "png_dpi": 320,
        "vector_exports": ["SVG", "PDF"],
        "full_internal_titles": False,
    }
    QUALITY_PATH.write_text(json.dumps(quality, ensure_ascii=False, indent=2), encoding="utf-8")
    write_protocol(len(raw_works), len(clean_rows), stats)
    write_manifest()

    print(json.dumps(quality, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
