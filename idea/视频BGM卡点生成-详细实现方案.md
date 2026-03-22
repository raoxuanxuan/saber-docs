# 视频 BGM 卡点生成 — 详细实现方案

## 一、背景知识

### 1.1 视频基础

视频本质上是一个**有序的图片数组 + 时间轴**：

```
视频文件 (MP4)
├── 视频轨道：[Frame0, Frame1, Frame2, ..., Frame449]  // 图片序列
├── 音频轨道：[PCM 采样数据...]                         // 声波数据
└── 元信息：时长、分辨率、编码格式...                     // 类似 HTTP Header
```

关键参数：

| 概念 | 类比 | 说明 |
|------|------|------|
| **帧 (Frame)** | 数组里的一个元素 | 就是一张图片，通常是 RGB 矩阵 |
| **FPS** | QPS | 每秒多少帧。30FPS = 每秒 30 张图 |
| **分辨率** | 单条记录的大小 | 1920x1080 = 每帧是 1920x1080 个像素点 |
| **关键帧 (I-Frame)** | 数据库全量快照 | 完整存储的帧，其他帧只存与它的"差异" |
| **P/B-Frame** | 增量备份 | 只存相对于关键帧的变化，用于压缩 |

15 秒 30FPS 的视频 = **450 帧**。

### 1.2 什么是"转场"

转场就是**视频从一个镜头切到另一个镜头的瞬间**。

**硬切 (Hard Cut)** — 最常见，占 80%+
- 第 N 帧是海边，第 N+1 帧突然变成城市
- 相邻两帧画面**完全不同**
- 检测难度：低，v1 重点

**软转场 (Gradual Transition)** — 淡入淡出、擦除等
- 画面在 10-30 帧内渐变过渡
- 相邻帧差异**逐渐增大**
- 检测难度：中等，后续迭代

### 1.3 色彩空间：RGB vs HSV

```
RGB（程序员视角）          HSV（人眼视角）
├── R: 红色通道 0-255      ├── H: 色相 (Hue) 0-360°     → 什么颜色
├── G: 绿色通道 0-255      ├── S: 饱和度 (Saturation)    → 颜色鲜不鲜艳
└── B: 蓝色通道 0-255      └── V: 明度 (Value)           → 亮不亮
```

转场检测用 HSV 比 RGB 好，因为：
- 光照变化主要影响 V（亮度），H 和 S 基本不变
- 真正的场景切换会导致 H（颜色）剧变
- 可以给 H 更高权重，减少光照变化的误判

### 1.4 音频基础

#### 节拍 (Beat)

你听任何一首歌，身体会不自觉地打拍子——点头、跺脚、拍手，那个规律的时间点就是节拍。

```
一首 120 BPM 的歌：

时间轴:  0s    0.5s    1s    1.5s    2s    2.5s    3s
节拍:    ↓      ↓      ↓      ↓      ↓      ↓      ↓
         咚     咚     咚     咚     咚     咚     咚

BPM = Beats Per Minute = 每分钟多少拍
120 BPM → 每拍间隔 60/120 = 0.5 秒
```

#### Beat Tracking（节拍追踪）

从音频信号里把节拍位置找出来。核心分三步：

**第一步：音频 → 频谱（时频分析）**

音频原始数据是波形——每秒 44100 个采样点，每个点是一个振幅值。直接看波形看不出节拍，需要做**短时傅里叶变换（STFT）**——把波形切成很多小片段（通常每片 23ms），对每片做频率分析：

```
频谱图：X 轴是时间，Y 轴是频率，颜色是能量

频率(Hz)
  8000 │░░░░░░░░░░░░░░░░░░░░░░
  4000 │░░██░░░░██░░░░██░░░░██░   ← 高频：镲片、嘶声
  2000 │░███░░░███░░░███░░░███░   ← 中频：人声、吉他
   500 │████░░████░░████░░████░   ← 中低频：钢琴、贝斯
   100 │████░░████░░████░░████░   ← 低频：鼓的"咚"
       └──────────────────────→ 时间
        ↑     ↑     ↑     ↑
       这几个位置，低频能量突然增大 → 大概率是节拍
```

**第二步：计算 Onset Strength（起始强度）**

节拍的本质是**能量突然增大的瞬间**——鼓一敲，低频能量突增。

计算方法：对频谱图求**时间方向的差分**（当前帧能量 - 上一帧能量），只保留正值（能量增大的部分）。

**第三步：从 Onset Strength 提取周期性节拍**

onset 告诉你"哪些时刻有能量冲击"，但不是每个冲击都是节拍（有装饰音、滑音等）。Beat Tracking 通过**动态规划**，在 onset 的高峰里选一组**间隔最均匀、能量最高**的点作为节拍。

#### 节拍层次（4/4 拍）

```
   强拍    弱拍    次强拍   弱拍    强拍    弱拍    次强拍   弱拍
    ↓      ↓       ↓      ↓      ↓      ↓       ↓      ↓
    咚     哒      嚓     哒      咚     哒      嚓     哒
    |←──── 1小节 ────→|      |←──── 1小节 ────→|

视频转场落在「强拍」上效果最好，落在弱拍上体感差一些。
```

#### Time-Stretching（时间拉伸）

**只改变播放速度，不改变音调**的技术。

普通变速（重采样）会同时改变音调——加速听起来像花栗鼠。Time-Stretching 用 **Phase Vocoder（相位声码器）** 算法：

1. 把音频切成重叠的小片段（窗口）
2. 调整窗口间距（但不改变窗口内容）
3. 做相位修正避免杂音

核心直觉：**每个小窗口保留了原始的音色和音调信息，只是调整窗口的排列密度来改变时长。**

拉伸幅度限制：

| 幅度 | 音质 | 适用 |
|------|------|------|
| ±5% 以内 | 几乎无损 | 我们的场景 ✅ |
| ±10% | 仔细听略不自然 | 勉强可用 |
| ±20% | 明显金属感 | 不可接受 |

---

## 二、完整 Pipeline

```
用户上传 15s 视频
       │
       ▼
═══════════════════════════════════════════
 Step 1: 视频分析                    ~5s
═══════════════════════════════════════════
       │
       ├─── A. 转场检测 (PySceneDetect)
       │    输入：视频文件
       │    原理：逐帧算 HSV 差异度，突增点 = 转场
       │    输出：转场时间戳 [0.0, 3.2, 6.1, 9.5, 12.8]
       │
       │         ↓ 从时间戳推算
       │
       │    目标 BPM 计算：
       │    平均间隔 3.2s → 基础频率 60/3.2 = 18.75
       │    取倍频到 90-150 范围内 → 目标 BPM
       │
       └─── B. 内容理解 (多模态 LLM)
            输入：每个场景中间帧抽 1 张，共 5 张图
            原理：Claude/GPT-4V 看图理解内容和情绪
            输出：suno_prompt

       A 和 B 并行执行
       │
       ▼
═══════════════════════════════════════════
 Step 2: Suno 并行生成              ~30-60s
═══════════════════════════════════════════
       │
       │  同一 prompt 3 路并行 → 3 首候选
       │
       ▼
═══════════════════════════════════════════
 Step 3: 选曲 + 对齐                 ~3s
═══════════════════════════════════════════
       │
       ├─── 3.1 Beat Tracking (librosa)
       ├─── 3.2 滑动窗口找最优截取位置 + 对齐评分
       ├─── 3.3 综合评分选曲
       └─── 3.4 Time-Stretching 微调
       │
       ▼
═══════════════════════════════════════════
 Step 4: 合成输出                    ~2s
═══════════════════════════════════════════
       │
       ├─── 响度标准化 (loudnorm)
       └─── ffmpeg 合并视频 + BGM
       │
       ▼
  回调通知用户，总耗时 ~40-70s
```

---

## 三、Step 1 详细设计：视频分析

### 3.1 转场检测

#### 3.1.1 原理

核心思路：**计算相邻帧的差异度，差异度超过阈值 → 判定为转场**。

```
差异度
  ↑
  │         ╱╲              ╱╲
  │        ╱  ╲            ╱  ╲
  │───────╱────╲──────────╱────╲─── 阈值线
  │      ╱      ╲        ╱      ╲
  │─────╱────────╲──────╱────────╲───
  └──────────────────────────────────→ 时间
         ↑                ↑
       转场1             转场2
```

量化差异度的方法（递进）：

**方法一：像素差分（最直觉）**

每个像素是 RGB 值（0-255 三通道），两帧对应位置像素相减求绝对值，然后求平均。

缺点：摄像机平移、光照变化会导致误判。

**方法二：颜色直方图对比（更鲁棒）**

不逐像素比，而是比**颜色分布**。把颜色空间分成若干个"桶"，统计每个桶里有多少像素，对比两帧的分布差异。

优点：不怕镜头平移，因为整体颜色分布不会变太多。

**方法三：PySceneDetect（工程推荐）**

封装好的 Python 库，内部结合了上述方法 + 自适应阈值。`ContentDetector` 的工作原理：
1. 将每帧转换到 **HSV 色彩空间**
2. 计算相邻帧在 H、S、V 三个通道的差异
3. 加权求和得到 content_val 分数
4. 分数超过 threshold → 判定转场

#### 3.1.2 实现

```python
from scenedetect import open_video, SceneManager
from scenedetect.detectors import ContentDetector

def detect_transitions(video_path: str, threshold: float = 27.0) -> list[float]:
    """
    检测视频转场时间戳

    Args:
        video_path: 视频文件路径
        threshold: 检测阈值，默认27.0。越小越敏感，越大越保守

    Returns:
        转场时间戳列表（秒），如 [0.0, 3.2, 6.1, 9.5, 12.8]
    """
    video = open_video(video_path)
    scene_manager = SceneManager()
    scene_manager.add_detector(ContentDetector(threshold=threshold))
    scene_manager.detect_scenes(video)

    scene_list = scene_manager.get_scene_list()
    transitions = [scene[0].get_seconds() for scene in scene_list]

    return transitions
```

- `threshold=27.0` 是默认值，15 秒短视频建议从默认值开始
- 15 秒视频典型转场 3-8 个

#### 3.1.3 目标 BPM 计算

```python
def calc_target_bpm(transitions: list[float]) -> float:
    """
    从转场时间戳推算目标 BPM

    原理：计算平均转场间隔 → 取倍频到 90-150 合理 BPM 范围
    """
    if len(transitions) < 2:
        return 110.0  # 默认中等节奏

    intervals = [transitions[i+1] - transitions[i] for i in range(len(transitions)-1)]
    avg_interval = sum(intervals) / len(intervals)

    base_freq = 60.0 / avg_interval  # beats per minute

    bpm = base_freq
    while bpm < 90:
        bpm *= 2
    while bpm > 150:
        bpm /= 2

    return round(bpm)
```

### 3.2 内容理解

#### 3.2.1 抽帧策略

推荐**每个场景取 1 帧**（利用转场检测结果）：

```python
import cv2

def extract_key_frames(video_path: str, transitions: list[float]) -> list[str]:
    """
    在每个场景的中间位置抽取关键帧

    例：场景1[0-3.2s] → 取第1.6s的帧
        场景2[3.2-6.1s] → 取第4.6s的帧
    """
    cap = cv2.VideoCapture(video_path)
    fps = cap.get(cv2.CAP_PROP_FPS)

    # 计算每个场景的中间时间点
    mid_points = []
    for i in range(len(transitions)):
        if i + 1 < len(transitions):
            mid = (transitions[i] + transitions[i+1]) / 2
        else:
            # 最后一个场景，取到视频结尾的中间
            total_duration = cap.get(cv2.CAP_PROP_FRAME_COUNT) / fps
            mid = (transitions[i] + total_duration) / 2
        mid_points.append(mid)

    # 抽帧
    frame_paths = []
    for i, t in enumerate(mid_points):
        frame_no = int(t * fps)
        cap.set(cv2.CAP_PROP_POS_FRAMES, frame_no)
        ret, frame = cap.read()
        if ret:
            path = f"/tmp/frame_{i}.jpg"
            cv2.imwrite(path, frame)
            frame_paths.append(path)

    cap.release()
    return frame_paths
```

#### 3.2.2 多模态 LLM 分析

```python
# Prompt 设计
ANALYSIS_PROMPT = """
分析这组视频帧，输出JSON：
{
  "mood": "欢快/伤感/热血/治愈/酷炫",
  "scene": "户外旅行/美食/萌宠/运动健身/城市夜景/自然风光/人物情感/游戏",
  "energy_level": "low/medium/high",
  "suno_prompt": "一句话英文描述适合的BGM风格（Suno格式）"
}
"""
```

#### 3.2.3 风格映射兜底

LLM 输出有时不稳定，用预设模板库做兜底：

```python
MOOD_TO_STYLE = {
    ("欢快", "户外旅行"):   "upbeat indie pop, acoustic guitar, claps",
    ("欢快", "美食"):       "jazzy bossa nova, light percussion, warm",
    ("欢快", "萌宠"):       "playful ukulele, pizzicato strings, cheerful",
    ("热血", "运动健身"):   "energetic EDM, driving bass, powerful drops",
    ("热血", "游戏"):       "epic orchestral, intense drums, cinematic",
    ("伤感", "人物情感"):   "emotional piano ballad, soft strings, melancholy",
    ("治愈", "自然风光"):   "ambient folk, gentle pad, nature sounds",
    ("酷炫", "城市夜景"):   "dark synthwave, retro bass, neon atmosphere",
}

MOOD_FALLBACK = {
    "欢快": "upbeat pop, bright and cheerful",
    "热血": "energetic rock, powerful drums",
    "伤感": "emotional piano, gentle and sad",
    "治愈": "soft acoustic, warm and calming",
    "酷炫": "electronic, modern beat, stylish",
}
```

可以让 LLM 做分类（从预设中选），而非开放生成，输出更稳定。

---

## 四、Step 2 详细设计：Suno 生成

### 4.1 Prompt 构造

Suno 的 prompt 由两部分：**style/tags** 控制曲风 + **lyrics** 填 `[Instrumental]`。

#### 4.1.1 风格描述

要用 Suno 能理解的音乐术语：

```
❌ "好听的背景音乐"
❌ "适合海边的歌"
✅ "chill acoustic pop, gentle fingerstyle guitar"
✅ "tropical house, bright synth, summer vibes"
```

#### 4.1.2 BPM 控制

Suno 对 BPM 的遵从度：指定 "120 BPM" → 实际输出大概 105-135 BPM 范围。

提高命中率的技巧：

```
技巧1：BPM 数字 + 体感描述双重暗示

  70-90 BPM  → "slow tempo, relaxed pace"
  90-110 BPM → "moderate tempo, steady groove"
  110-130 BPM → "upbeat tempo, energetic pace"
  130-150 BPM → "fast tempo, high energy, driving rhythm"

技巧2：指定节奏型

  "four-on-the-floor" → 底鼓每拍都打，BPM 非常明确
  "boom-bap"          → 嘻哈常见节奏，BPM 相对稳定
```

#### 4.1.3 完整 Prompt 组装

```python
def build_suno_prompt(analysis_result: dict) -> dict:
    mood = analysis_result["mood"]
    scene = analysis_result["scene"]
    bpm = analysis_result["target_bpm"]

    # 1. 风格映射
    key = (mood, scene)
    style = MOOD_TO_STYLE.get(key, MOOD_FALLBACK.get(mood, "pop, instrumental"))

    # 2. BPM + 体感描述
    if bpm < 90:
        tempo_desc = "slow tempo, relaxed pace"
    elif bpm < 110:
        tempo_desc = "moderate tempo, steady groove"
    elif bpm < 130:
        tempo_desc = "upbeat tempo, energetic pace"
    else:
        tempo_desc = "fast tempo, high energy, driving rhythm"

    # 3. 组装
    style_prompt = (
        f"{style}, {bpm} BPM, {tempo_desc}, "
        f"four-on-the-floor beat, instrumental, no vocals"
    )

    return {
        "prompt": style_prompt,
        "lyrics": "[Instrumental]",
        "duration": 30,  # 生成30秒，后续截取最优15秒
    }
```

### 4.2 并行生成策略

#### 4.2.1 为什么 3 首

| 生成数量 | 至少1首在±10%内的概率 | 成本 | 耗时（并行） |
|---------|---------------------|------|------------|
| 1首 | ~85% | 1x | 不变 |
| 3首 | ~99.7% | 3x | 不变 |
| 5首 | ~99.99% | 5x | 不变 |

3 首是性价比拐点。

#### 4.2.2 Prompt 变体

除了同一 prompt 生成 3 次，还可以用略有差异的 prompt 增加多样性：

```python
def build_prompt_variants(base_style: str, bpm: float) -> list[str]:
    return [
        # 变体1：基础版
        f"{base_style}, {bpm} BPM, instrumental, no vocals",

        # 变体2：强调节奏
        f"{base_style}, {bpm} BPM, strong beat, four-on-the-floor, "
        f"punchy drums, instrumental, no vocals",

        # 变体3：BPM微调（+5）
        f"{base_style}, {bpm + 5} BPM, rhythmic, groovy, "
        f"instrumental, no vocals",
    ]
```

### 4.3 时长策略

推荐生成 30 秒，后续从中截取最优 15 秒：

- 给 beat tracking 更多数据，检测更准
- 开头可能有前奏/渐入，不适合卡点，截中段更好
- 多出的部分提供选择空间

### 4.4 兜底方案：曲库匹配

如果 3 首候选对齐率都 < 50%：

```
预先准备按 BPM + 风格分类的 BGM 曲库（几百首即可）
  ├── pop/     → 90_bpm.mp3, 100_bpm.mp3, 110_bpm.mp3 ...
  ├── rock/    → 100_bpm.mp3, 120_bpm.mp3 ...
  ├── electronic/ → 120_bpm.mp3, 128_bpm.mp3 ...
  └── ...

根据 target_bpm + style 检索最接近的
曲库 BPM 精确已知，time-stretch 微调即可
保证 100% 有结果返回
```

### 4.5 注意事项

| 坑 | 说明 | 应对 |
|---|------|------|
| Suno 偶尔生成人声 | 即使指定 instrumental | lyrics 和 style 双重指定；可加人声检测过滤 |
| 生成超时 | 高峰期可能 >60s | 设超时阈值，超时走兜底曲库 |
| BPM 偏离太大 | prompt 写 120，出来 85 | 3 首候选 + time-stretch 兜底 |
| 30s 截取位置 | 开头渐入不适合卡点 | Step 3 滑动窗口时跳过前 2-3 秒 |

---

## 五、Step 3 详细设计：选曲 + 对齐

### 5.1 Beat Tracking 实现

```python
import librosa

def get_beats_with_strength(audio_path: str) -> dict:
    """
    检测音频的节拍位置和强度

    Returns:
        {
            "tempo": 118.5,
            "beats": [
                {"time": 0.46, "strength": 0.95, "is_downbeat": true},
                {"time": 0.97, "strength": 0.42, "is_downbeat": false},
                ...
            ]
        }
    """
    y, sr = librosa.load(audio_path, sr=22050)

    tempo, beat_frames = librosa.beat.beat_track(y=y, sr=sr)
    beat_times = librosa.frames_to_time(beat_frames, sr=sr)

    # onset_strength: 每个 beat 位置的能量强度
    onset_env = librosa.onset.onset_strength(y=y, sr=sr)
    beat_strengths = onset_env[beat_frames]

    # 归一化到 0-1
    if beat_strengths.max() > 0:
        beat_strengths = beat_strengths / beat_strengths.max()

    beats = []
    for i, (t, s) in enumerate(zip(beat_times, beat_strengths)):
        beats.append({
            "time": float(t),
            "strength": float(s),
            "is_downbeat": i % 4 == 0  # 简化判断：每4拍一个强拍
        })

    return {"tempo": float(tempo), "beats": beats}
```

30 秒 120BPM 的音频，大概有 **60 个 beat**。

### 5.2 滑动窗口找最优截取位置

从 30 秒音频中截取 15 秒，**从哪里开始截直接决定卡点质量**。

```
30 秒候选音频的 beat 分布：

时间:  0   1   2   3   4   5   6   ...  25  26  27  28  29  30
beats: .●..●..●..●..●..●..●..●..●..●..●..●..●..●..●..●..●..●.

       |←── 窗口A: 0~15s ──→|
           |←── 窗口B: 1~16s ──→|
               |←── 窗口C: 2~17s ──→|
                                    ...
                              |←── 窗口N: 15~30s ──→|

每个窗口位置，转场和 beat 的对齐情况都不同
```

```python
def find_best_segment(beat_times: list[float], video_transitions: list[float],
                      audio_duration: float = 30.0, video_duration: float = 15.0,
                      step: float = 0.1, tolerance: float = 0.15) -> dict:
    """
    在 30s 音频中滑动窗口，找出和视频转场最卡点的 15s 片段

    Args:
        beat_times:        音频的所有 beat 时间戳 (30s内)
        video_transitions: 视频转场时间戳 [0.0, 3.2, 6.1, 9.5, 12.8]
        step:              窗口滑动步长(秒)，0.1s = 100ms 精度
        tolerance:         卡点容忍度(秒)

    Returns:
        {"offset": 最优截取起始点, "score": 得分, "alignment_rate": 对齐率}
    """
    best_offset = 0
    best_score = -1

    max_offset = audio_duration - video_duration  # 30-15=15

    offset = 0.0
    while offset <= max_offset:
        score = 0

        for trans_t in video_transitions:
            # 这个转场在当前窗口里对应的绝对时间
            abs_t = trans_t + offset

            # 找最近的 beat
            min_dist = min(abs(abs_t - b) for b in beat_times)

            if min_dist <= tolerance:
                # 越接近 beat 得分越高（线性衰减）
                score += 1.0 - (min_dist / tolerance)

        if score > best_score:
            best_score = score
            best_offset = offset

        offset += step

    return {
        "offset": best_offset,
        "score": best_score,
        "max_possible": len(video_transitions),
        "alignment_rate": best_score / len(video_transitions) if video_transitions else 0
    }
```

计算量很小：15s / 0.1s步长 = 150 个位置 × 5 个转场 × 60 个 beat = 45000 次比较，毫秒级完成。

### 5.3 综合评分选曲

```python
def select_best_candidate(candidates: list[str], video_transitions: list[float],
                          beats_list: list[dict], target_bpm: float) -> dict:
    """
    从 3 首候选中选出最优的一首

    评分公式：综合分 = 对齐率 × 0.6 + 强拍加分 × 0.25 - BPM偏离 × 0.15
    """
    results = []

    for i, (audio_path, beats_info) in enumerate(zip(candidates, beats_list)):
        # 找最优截取位置
        segment = find_best_segment(
            beat_times=[b["time"] for b in beats_info["beats"]],
            video_transitions=video_transitions
        )

        # 强拍加分：转场落在强拍上体感更好
        downbeat_bonus = calc_downbeat_bonus(
            beats_info["beats"], video_transitions, segment["offset"]
        )

        # BPM 偏离惩罚
        bpm_penalty = abs(beats_info["tempo"] - target_bpm) / target_bpm

        final_score = (
            segment["alignment_rate"] * 0.6 +
            downbeat_bonus * 0.25 -
            bpm_penalty * 0.15
        )

        results.append({
            "index": i,
            "audio_path": audio_path,
            "offset": segment["offset"],
            "alignment_rate": segment["alignment_rate"],
            "tempo": beats_info["tempo"],
            "final_score": final_score
        })

    results.sort(key=lambda x: x["final_score"], reverse=True)
    return results[0]


def calc_downbeat_bonus(beats: list[dict], video_transitions: list[float],
                        offset: float, tolerance: float = 0.15) -> float:
    """转场落在强拍上的比例"""
    downbeat_times = [b["time"] for b in beats if b["is_downbeat"]]
    if not downbeat_times:
        return 0.0

    hit = 0
    for trans_t in video_transitions:
        abs_t = trans_t + offset
        min_dist = min(abs(abs_t - d) for d in downbeat_times)
        if min_dist <= tolerance:
            hit += 1

    return hit / len(video_transitions) if video_transitions else 0
```

### 5.4 Time-Stretching 微调

```python
import pyrubberband
import soundfile as sf
import numpy as np

def align_with_stretch(audio_path: str, detected_bpm: float, target_bpm: float,
                       offset: float, duration: float = 15.0) -> str:
    """
    截取最优片段 + 整体 time-stretch + 淡入淡出
    """
    y, sr = librosa.load(audio_path, sr=22050)

    # 1. 截取最优片段
    start_sample = int(offset * sr)
    end_sample = int((offset + duration) * sr)
    y_segment = y[start_sample:end_sample]

    # 2. 判断是否需要 stretch
    ratio = target_bpm / detected_bpm

    if abs(ratio - 1.0) < 0.02:
        # 偏差 < 2%，不处理
        y_final = y_segment
    elif abs(ratio - 1.0) < 0.10:
        # 偏差 2%-10%，做 time-stretch
        y_final = pyrubberband.time_stretch(y_segment, sr, ratio)
    else:
        # 偏差 > 10%，stretch 效果差，标记低质量
        y_final = pyrubberband.time_stretch(y_segment, sr, ratio)

    # 3. 淡入淡出，避免截取边界突兀
    y_final = apply_fade(y_final, sr, fade_in=0.3, fade_out=0.3)

    # 4. 保存
    output_path = "/tmp/aligned_bgm.wav"
    sf.write(output_path, y_final, sr)
    return output_path


def apply_fade(y, sr, fade_in=0.3, fade_out=0.3):
    """开头淡入 + 结尾淡出"""
    fade_in_samples = int(fade_in * sr)
    fade_out_samples = int(fade_out * sr)

    y[:fade_in_samples] *= np.linspace(0, 1, fade_in_samples)
    y[-fade_out_samples:] *= np.linspace(1, 0, fade_out_samples)

    return y
```

### 5.5 完整 Step 3 串联

```python
def step3_select_and_align(candidates: list[str],
                           video_transitions: list[float],
                           target_bpm: float) -> str:
    # 3.1 Beat Tracking（3首可并行）
    beats_list = [get_beats_with_strength(path) for path in candidates]

    # 3.2 + 3.3 选曲
    best = select_best_candidate(candidates, video_transitions, beats_list, target_bpm)

    # 3.4 Time-Stretch 微调
    output = align_with_stretch(
        audio_path=best["audio_path"],
        detected_bpm=best["tempo"],
        target_bpm=target_bpm,
        offset=best["offset"],
        duration=15.0
    )

    return output
```

### 5.6 边界情况

| 情况 | 处理 |
|------|------|
| 3 首对齐率都 < 50% | 走兜底曲库方案 |
| 视频只有 1-2 个转场 | 正常处理，降低 time-stretch 激进度 |
| 视频无转场（一镜到底） | 跳过卡点逻辑，只做内容风格匹配 |
| BPM 不稳定（变速歌） | 优先选 BPM 稳定的候选 |
| 截取边界突兀 | 加 0.3s fade-in / fade-out |

---

## 六、Step 4 详细设计：合成输出

### 6.1 视频容器结构

```
MP4 文件（容器）
├── 视频轨道 (Video Track)   编码：H.264 / H.265
├── 音频轨道 (Audio Track)   编码：AAC / MP3（可能没有）
└── 元数据 (Metadata)        时长、分辨率、帧率...
```

用户上传的视频可能的情况：
- **有原始音频**（最常见）→ 替换或混合
- **无音频**（静音视频）→ 直接加 BGM
- **已有 BGM** → 替换

### 6.2 ffmpeg 关键概念

```
ffmpeg 参数        含义
-i input.mp4      输入文件
-c:v copy         视频编码：直接拷贝（不重编码，零开销）
-c:a aac          音频编码：用 AAC
-map 0:v          选流：取第1个输入的视频
-map 1:a          选流：取第2个输入的音频
-shortest         以最短的流为准截断
-y                覆盖输出文件
```

**`-c:v copy` 极其重要**：视频不重新编码，几乎瞬间完成，画质零损失。我们只换音频轨，视频轨原封不动。

### 6.3 合成命令

#### 场景 1：替换原始音频（默认）

```bash
ffmpeg -i video.mp4 -i bgm.wav \
  -map 0:v -map 1:a \
  -c:v copy -c:a aac -b:a 192k \
  -shortest -y output.mp4
```

#### 场景 2：BGM + 原始音频混合

```bash
ffmpeg -i video.mp4 -i bgm.wav \
  -filter_complex "[0:a]volume=0.3[orig]; \
                   [1:a]volume=0.8[bgm]; \
                   [orig][bgm]amix=inputs=2:duration=shortest[out]" \
  -map 0:v -map "[out]" \
  -c:v copy -c:a aac -b:a 192k \
  -y output.mp4
```

`filter_complex` 是 ffmpeg 的滤镜链：
```
[0:a] → volume=0.3 → [orig] ─┐
                              ├→ amix → [out] → 编码输出
[1:a] → volume=0.8 → [bgm] ──┘
```

### 6.4 响度标准化

不同 Suno 生成的曲子音量差异很大，需要统一。

响度单位 **LUFS** (Loudness Units Full Scale)，常见平台标准：
- YouTube/Spotify: -14 LUFS
- 短视频平台: 约 -16 LUFS

```bash
# 一步完成响度标准化
ffmpeg -i bgm.wav \
  -af loudnorm=I=-16:TP=-1.5:LRA=11 \
  -ar 44100 bgm_normalized.wav
```

参数含义：
- `I=-16`: 目标响度 -16 LUFS
- `TP=-1.5`: 真峰值不超过 -1.5 dB（防止爆音）
- `LRA=11`: 响度范围上限

### 6.5 检测视频是否有音频轨

```bash
ffprobe -v quiet -print_format json -show_streams video.mp4
# 检查 streams 中是否有 codec_type == "audio"
```

### 6.6 完整 Step 4 实现

```python
import subprocess
import json

def step4_merge(video_path: str, bgm_path: str,
                keep_original_audio: bool = False) -> str:
    output_path = "/tmp/output_final.mp4"

    # 1. BGM 响度标准化
    normalized_bgm = normalize_loudness(bgm_path, target_lufs=-16)

    # 2. 检测原始视频是否有音频轨
    has_audio = probe_has_audio(video_path)

    # 3. 合成
    if has_audio and keep_original_audio:
        cmd = [
            "ffmpeg", "-i", video_path, "-i", normalized_bgm,
            "-filter_complex",
            "[0:a]volume=0.3[orig];[1:a]volume=0.8[bgm];"
            "[orig][bgm]amix=inputs=2:duration=shortest[out]",
            "-map", "0:v", "-map", "[out]",
            "-c:v", "copy", "-c:a", "aac", "-b:a", "192k",
            "-y", output_path
        ]
    else:
        cmd = [
            "ffmpeg", "-i", video_path, "-i", normalized_bgm,
            "-map", "0:v", "-map", "1:a",
            "-c:v", "copy", "-c:a", "aac", "-b:a", "192k",
            "-shortest", "-y", output_path
        ]

    subprocess.run(cmd, check=True, capture_output=True)
    return output_path


def probe_has_audio(video_path: str) -> bool:
    cmd = [
        "ffprobe", "-v", "quiet",
        "-print_format", "json",
        "-show_streams",
        video_path
    ]
    result = subprocess.run(cmd, capture_output=True, text=True)
    info = json.loads(result.stdout)
    return any(s["codec_type"] == "audio" for s in info.get("streams", []))


def normalize_loudness(audio_path: str, target_lufs: float = -16) -> str:
    output_path = audio_path.replace(".wav", "_norm.wav")
    cmd = [
        "ffmpeg", "-i", audio_path,
        "-af", f"loudnorm=I={target_lufs}:TP=-1.5:LRA=11",
        "-ar", "44100",
        "-y", output_path
    ]
    subprocess.run(cmd, check=True, capture_output=True)
    return output_path
```

### 6.7 耗时分析

| 操作 | 耗时 | 说明 |
|------|------|------|
| 响度标准化 | ~0.5s | 15s 音频处理很快 |
| ffprobe 检测 | ~0.1s | 只读元数据 |
| 合成（-c:v copy） | ~0.3s | 视频不重编码，只拷贝流 |
| 合成（重编码） | ~5-10s | 逐帧编码，**尽量避免** |
| **总计** | **~1s** | |

### 6.8 输出格式

C 端业务直接输出 MP4 + H.264 + AAC，全平台兼容性最好。

### 6.9 注意事项

| 坑 | 应对 |
|----|------|
| 音视频时长不完全一致 | `-shortest` 自动截断 |
| 原视频竖屏/非标分辨率 | `-c:v copy` 不碰视频流，无需处理 |
| 并发处理时 ffmpeg 占 CPU | 加 `-threads 2` 限制单任务线程数 |
| 临时文件堆积 | 任务完成后清理，或用 tmpdir 自动回收 |

---

## 七、任务编排服务设计

### 7.1 服务架构

```
                         ┌─────────────┐
  用户上传视频 ──→ BFF ──→│  MQ (Kafka)  │
                         └──────┬──────┘
                                │ consume
                         ┌──────▼──────┐
                         │  编排服务     │  Go
                         │  Orchestrator│
                         └──────┬──────┘
              ┌─────────────────┼─────────────────┐
              ▼                 ▼                  ▼
      ┌───────────────┐ ┌────────────┐  ┌────────────────┐
      │ 视频分析服务    │ │ Suno代理    │  │ 音频处理服务     │
      │ Python (gRPC) │ │ Go (gRPC)  │  │ Python (gRPC)  │
      └───────────────┘ └────────────┘  └────────────────┘
```

### 7.2 任务状态机

```
                    ┌──────────────────────────────┐
                    │          超时/异常             │
                    │     ┌───────────────────┐     │
                    ▼     ▼                   │     │
  created ──→ analyzing ──→ generating ──→ aligning ──→ merging ──→ completed
    │                                                                   │
    │              任何阶段失败                                          │
    └──────────────────→ failed                                         │
                           │                                            │
                           └──→ 回调通知 ←──────────────────────────────┘
```

```go
type TaskStatus string

const (
    TaskCreated    TaskStatus = "created"
    TaskAnalyzing  TaskStatus = "analyzing"   // Step 1
    TaskGenerating TaskStatus = "generating"  // Step 2
    TaskAligning   TaskStatus = "aligning"    // Step 3
    TaskMerging    TaskStatus = "merging"     // Step 4
    TaskCompleted  TaskStatus = "completed"
    TaskFailed     TaskStatus = "failed"
)
```

### 7.3 核心数据结构

```go
type BGMTask struct {
    TaskID        string        `json:"task_id"`
    UserID        string        `json:"user_id"`
    Status        TaskStatus    `json:"status"`
    VideoURL      string        `json:"video_url"`
    VideoDuration float64       `json:"video_duration"`

    // Step 1 结果
    Transitions   []float64     `json:"transitions"`
    TargetBPM     float64       `json:"target_bpm"`
    SunoPrompt    string        `json:"suno_prompt"`

    // Step 2 结果
    Candidates    []Candidate   `json:"candidates"`

    // Step 3 结果
    SelectedIdx   int           `json:"selected_idx"`
    AlignedBGM    string        `json:"aligned_bgm"`
    AlignRate     float64       `json:"align_rate"`

    // Step 4 结果
    OutputURL     string        `json:"output_url"`

    // 控制字段
    CreatedAt     time.Time     `json:"created_at"`
    UpdatedAt     time.Time     `json:"updated_at"`
    ErrorMsg      string        `json:"error_msg"`
    RetryCount    int           `json:"retry_count"`
    CallbackURL   string        `json:"callback_url"`
}

type Candidate struct {
    AudioURL  string  `json:"audio_url"`
    Tempo     float64 `json:"tempo"`
    AlignRate float64 `json:"align_rate"`
    Score     float64 `json:"score"`
}
```

### 7.4 编排主逻辑

```go
func (s *Orchestrator) HandleTask(ctx context.Context, task *BGMTask) error {
    ctx, cancel := context.WithTimeout(ctx, 3*time.Minute)
    defer cancel()

    if err := s.stepAnalyze(ctx, task); err != nil {
        return s.failTask(ctx, task, "analyzing", err)
    }

    if err := s.stepGenerate(ctx, task); err != nil {
        return s.failTask(ctx, task, "generating", err)
    }

    if err := s.stepAlign(ctx, task); err != nil {
        return s.failTask(ctx, task, "aligning", err)
    }

    if err := s.stepMerge(ctx, task); err != nil {
        return s.failTask(ctx, task, "merging", err)
    }

    return s.completeTask(ctx, task)
}
```

### 7.5 Step 1 编排：视频分析（并行）

```go
func (s *Orchestrator) stepAnalyze(ctx context.Context, task *BGMTask) error {
    s.updateStatus(ctx, task, TaskAnalyzing)

    g, gCtx := errgroup.WithContext(ctx)

    var transitions *TransitionResult
    var content *ContentResult

    // 并行 A: 转场检测
    g.Go(func() error {
        resp, err := s.videoAnalyzer.DetectTransitions(gCtx, &DetectRequest{
            VideoURL: task.VideoURL,
        })
        if err != nil {
            return fmt.Errorf("detect transitions: %w", err)
        }
        transitions = resp
        return nil
    })

    // 并行 B: 内容理解
    g.Go(func() error {
        resp, err := s.videoAnalyzer.AnalyzeContent(gCtx, &ContentRequest{
            VideoURL:   task.VideoURL,
            FrameCount: 5,
        })
        if err != nil {
            return fmt.Errorf("analyze content: %w", err)
        }
        content = resp
        return nil
    })

    if err := g.Wait(); err != nil {
        return err
    }

    task.Transitions = transitions.Timestamps
    task.TargetBPM = calcTargetBPM(transitions.Timestamps)
    task.SunoPrompt = buildSunoPrompt(content, task.TargetBPM)

    return s.saveTask(ctx, task)
}
```

### 7.6 Step 2 编排：Suno 并行生成（允许部分失败）

```go
func (s *Orchestrator) stepGenerate(ctx context.Context, task *BGMTask) error {
    s.updateStatus(ctx, task, TaskGenerating)

    prompts := buildPromptVariants(task.SunoPrompt, task.TargetBPM)

    g, gCtx := errgroup.WithContext(ctx)
    candidates := make([]Candidate, 3)

    for i, prompt := range prompts {
        i, prompt := i, prompt
        g.Go(func() error {
            genCtx, cancel := context.WithTimeout(gCtx, 90*time.Second)
            defer cancel()

            resp, err := s.sunoProxy.Generate(genCtx, &SunoRequest{
                Prompt:   prompt,
                Duration: 30,
            })
            if err != nil {
                log.Warnf("suno candidate %d failed: %v", i, err)
                return nil // 不返回 error，允许部分失败
            }

            candidates[i] = Candidate{AudioURL: resp.AudioURL}
            return nil
        })
    }

    g.Wait()

    // 过滤有效候选
    var valid []Candidate
    for _, c := range candidates {
        if c.AudioURL != "" {
            valid = append(valid, c)
        }
    }

    if len(valid) == 0 {
        // 全部失败 → 兜底曲库
        fallback, err := s.fallbackFromLibrary(ctx, task.TargetBPM, task.SunoPrompt)
        if err != nil {
            return fmt.Errorf("all candidates and fallback failed: %w", err)
        }
        valid = []Candidate{*fallback}
    }

    task.Candidates = valid
    return s.saveTask(ctx, task)
}
```

### 7.7 Step 3 编排

```go
func (s *Orchestrator) stepAlign(ctx context.Context, task *BGMTask) error {
    s.updateStatus(ctx, task, TaskAligning)

    resp, err := s.audioProcessor.SelectAndAlign(ctx, &AlignRequest{
        CandidateURLs:    candidateURLs(task.Candidates),
        VideoTransitions: task.Transitions,
        TargetBPM:        task.TargetBPM,
        VideoDuration:    task.VideoDuration,
        Tolerance:        0.15,
    })
    if err != nil {
        return fmt.Errorf("select and align: %w", err)
    }

    task.SelectedIdx = resp.SelectedIndex
    task.AlignedBGM = resp.AlignedAudioURL
    task.AlignRate = resp.AlignmentRate

    for i, score := range resp.CandidateScores {
        if i < len(task.Candidates) {
            task.Candidates[i].Tempo = score.Tempo
            task.Candidates[i].AlignRate = score.AlignRate
            task.Candidates[i].Score = score.FinalScore
        }
    }

    return s.saveTask(ctx, task)
}
```

### 7.8 Step 4 编排

```go
func (s *Orchestrator) stepMerge(ctx context.Context, task *BGMTask) error {
    s.updateStatus(ctx, task, TaskMerging)

    resp, err := s.audioProcessor.MergeVideoAudio(ctx, &MergeRequest{
        VideoURL:          task.VideoURL,
        AudioURL:          task.AlignedBGM,
        KeepOriginalAudio: false,
        TargetLUFS:        -16,
    })
    if err != nil {
        return fmt.Errorf("merge: %w", err)
    }

    task.OutputURL = resp.OutputURL
    return s.saveTask(ctx, task)
}
```

### 7.9 完成和失败处理

```go
func (s *Orchestrator) completeTask(ctx context.Context, task *BGMTask) error {
    task.Status = TaskCompleted
    task.UpdatedAt = time.Now()

    if err := s.saveTask(ctx, task); err != nil {
        return err
    }

    s.notifyCallback(ctx, task)
    go s.cleanupIntermediateFiles(task)
    s.metrics.RecordSuccess(task.AlignRate, time.Since(task.CreatedAt))

    return nil
}

func (s *Orchestrator) failTask(ctx context.Context, task *BGMTask,
    stage string, err error) error {

    task.Status = TaskFailed
    task.ErrorMsg = fmt.Sprintf("stage=%s err=%v", stage, err)
    task.UpdatedAt = time.Now()

    _ = s.saveTask(ctx, task)
    s.notifyCallback(ctx, task)
    s.metrics.RecordFailure(stage, time.Since(task.CreatedAt))

    return fmt.Errorf("task %s failed at %s: %w", task.TaskID, stage, err)
}
```

### 7.10 gRPC 协议定义

```protobuf
// 视频分析服务
service VideoAnalyzer {
    rpc DetectTransitions(DetectRequest) returns (TransitionResult);
    rpc AnalyzeContent(ContentRequest) returns (ContentResult);
}

message DetectRequest {
    string video_url = 1;
}

message TransitionResult {
    repeated double timestamps = 1;
}

message ContentRequest {
    string video_url = 1;
    int32 frame_count = 2;
}

message ContentResult {
    string mood = 1;
    string scene = 2;
    string energy_level = 3;
    string suno_prompt = 4;
}

// Suno 代理服务
service SunoProxy {
    rpc Generate(SunoRequest) returns (SunoResult);
}

message SunoRequest {
    string prompt = 1;
    string lyrics = 2;
    int32 duration = 3;
}

message SunoResult {
    string audio_url = 1;
    string task_id = 2;
}

// 音频处理服务
service AudioProcessor {
    rpc SelectAndAlign(AlignRequest) returns (AlignResult);
    rpc MergeVideoAudio(MergeRequest) returns (MergeResult);
}

message AlignRequest {
    repeated string candidate_urls = 1;
    repeated double video_transitions = 2;
    double target_bpm = 3;
    double video_duration = 4;
    double tolerance = 5;
}

message AlignResult {
    int32 selected_index = 1;
    string aligned_audio_url = 2;
    double alignment_rate = 3;
    repeated CandidateScore candidate_scores = 4;
}

message CandidateScore {
    double tempo = 1;
    double align_rate = 2;
    double final_score = 3;
}

message MergeRequest {
    string video_url = 1;
    string audio_url = 2;
    bool keep_original_audio = 3;
    double target_lufs = 4;
}

message MergeResult {
    string output_url = 1;
}
```

---

## 八、超时控制策略

| 层级 | 超时 | 原因 |
|------|------|------|
| 全局任务超时 | 3 min | 兜底，防止任务永远卡住 |
| Step 1 整体 | 15s | 视频分析不应该太慢 |
| ├ 转场检测 | 10s | 15 秒视频处理很快 |
| └ 内容理解 | 10s | LLM 调用 |
| Step 2 整体 | 90s | Suno 是主要耗时 |
| └ 单次生成 | 90s | Suno 高峰期可能慢 |
| Step 3 整体 | 15s | 纯计算，很快 |
| Step 4 整体 | 10s | ffmpeg -c:v copy 很快 |

---

## 九、监控指标

### 业务指标

| 指标 | 说明 |
|------|------|
| task_total (by status) | 总任务数分布 |
| task_duration (P50/P95/P99) | 任务耗时分布 |
| align_rate | 对齐率分布 → 衡量卡点质量 |
| suno_fallback_rate | 走兜底曲库比例 → 衡量 Suno 可用性 |

### 技术指标

| 指标 | 说明 |
|------|------|
| step_duration (by step) | 每步耗时 |
| suno_timeout_rate | Suno 超时率 |
| candidate_success | 候选成功数分布（1/2/3） |

---

## 十、数据沉淀

每个任务完成后，沉淀以下数据：

- **视频特征**：转场数量、平均间隔、内容类型
- **生成参数**：prompt、目标 BPM
- **效果数据**：对齐率、选中候选的 BPM 偏差、是否走了兜底

积累到一定量后可以：
1. **优化 prompt 模板**：哪些风格描述 Suno 出来的 BPM 更准
2. **优化 BPM 计算策略**：当前倍频策略是否最优
3. **分析兜底率高的场景**：针对性优化

---

## 十一、迭代规划

| 阶段 | 内容 | 目标 |
|------|------|------|
| **v1（本期）** | 转场卡点 + 内容风格匹配 | 跑通 pipeline，验证效果 |
| v1.5 | 优化 prompt 模板，提升对齐率 | 基于数据沉淀优化 |
| v2 | 支持更长视频（30s/60s） | 扩展视频时长 |
| v3 | 动作卡点（起跳/转身/运镜） | 更精细的卡点体验 |
| v4 | MIDI 精确对齐 | 利用现有 MIDI 分离能力做音符级对齐 |

---

## 十二、风险和应对

| 风险 | 等级 | 应对 |
|------|------|------|
| Suno BPM 控制不精确 | 中 | 多候选 + Time-Stretch 兜底 |
| Suno API 响应慢/不稳定 | 中 | 超时 + 曲库兜底 + 允许部分失败 |
| LLM 内容理解不准 | 低 | 预设风格模板库做分类兜底 |
| 15s 音频 Beat Tracking 不稳定 | 低 | 生成 30s 截取最优 15s |
| 转场检测误判 | 低 | 阈值调优 + 后续加人工反馈 |
