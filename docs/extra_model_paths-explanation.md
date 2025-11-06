# extra_model_paths.yaml 配置格式说明

## 两种写法的对比

### 写法 1: 项目当前配置（RunPod Worker 标准格式）

```yaml
runpod_worker_comfy:
  base_path: /runpod-volume
  checkpoints: models/checkpoints/
  loras: models/loras/
  vae: models/vae/
  # ...
```

### 写法 2: 示例配置（多路径混合格式）

```yaml
comfyui:
  base_path: /ComfyUI/
  is_default: true
  checkpoints: models/checkpoints/
  loras: |
    models/loras/
    /runpod-volume/loras/
  diffusion_models: |
    models/diffusion_models
    models/unet
    /runpod-volume/models/
```

## 主要差异说明

### 1. 顶层键名（Section Name）

**写法 1**：`runpod_worker_comfy`
- 这是 RunPod Worker 的标准命名
- 用于标识这是 RunPod Worker 的配置

**写法 2**：`comfyui`
- 这是 ComfyUI 的通用命名
- 更通用，适用于各种部署场景

> **注意**：顶层键名可以是任意字符串，ComfyUI 会读取所有配置节。但 RunPod Worker 通常使用 `runpod_worker_comfy`。

### 2. base_path 的作用

**写法 1**：
```yaml
base_path: /runpod-volume
checkpoints: models/checkpoints/
```
- 实际路径 = `/runpod-volume` + `models/checkpoints/` = `/runpod-volume/models/checkpoints/`
- 所有路径都相对于 `base_path`

**写法 2**：
```yaml
base_path: /ComfyUI/
checkpoints: models/checkpoints/
```
- 实际路径 = `/ComfyUI/` + `models/checkpoints/` = `/ComfyUI/models/checkpoints/`
- 这是 ComfyUI 的默认安装路径

### 3. is_default 标志

**写法 2 特有**：
```yaml
is_default: true
```

**作用**：
- 标记这个配置为默认配置
- 在 ComfyUI 界面中，这些路径会优先显示
- 下载模型时，默认保存到这些路径

**写法 1 没有这个标志**：
- 因为 RunPod Worker 通常只需要一个配置源
- Network Volume 路径不需要设置为默认

### 4. 多路径支持（使用 `|` 多行格式）

**写法 2 示例**：
```yaml
loras: |
  models/loras/
  /runpod-volume/loras/
```

**作用**：
- 可以指定多个搜索路径
- ComfyUI 会按顺序在这些路径中查找模型
- 第一个找到的模型会被使用

**写法 1 的特点**：
- 只指定一个路径（相对于 base_path）
- 更简洁，适合单一存储位置

### 5. 绝对路径 vs 相对路径

**写法 2 示例**：
```yaml
loras: |
  models/loras/              # 相对路径（相对于 base_path）
  /runpod-volume/loras/      # 绝对路径
```

**写法 1**：
```yaml
base_path: /runpod-volume
loras: models/loras/         # 相对路径，最终 = /runpod-volume/models/loras/
```

## 哪种写法更适合？

### 使用写法 1（当前项目）的场景：

✅ **推荐用于**：
- RunPod Serverless 部署
- 模型完全存储在 Network Volume 中
- 单一存储位置
- 需要清晰的路径结构

**优点**：
- 配置简洁明了
- 路径统一管理
- 符合 RunPod Worker 标准

### 使用写法 2（示例）的场景：

✅ **适合用于**：
- 本地部署或混合存储
- 需要从多个位置加载模型
- 同时使用镜像内置模型和 Network Volume 模型
- 需要设置默认下载路径

**优点**：
- 灵活性高，支持多路径
- 可以混合使用不同存储位置
- 适合复杂部署场景

## 混合使用示例

如果您想同时支持镜像内置模型和 Network Volume 模型，可以这样配置：

```yaml
# 镜像内置模型（默认）
comfyui:
  base_path: /comfyui
  is_default: true
  checkpoints: models/checkpoints/
  loras: models/loras/
  vae: models/vae/

# Network Volume 模型（额外路径）
runpod_worker_comfy:
  base_path: /runpod-volume
  checkpoints: models/checkpoints/
  loras: models/loras/
  vae: models/vae/
```

这样配置后：
- ComfyUI 会先在 `/comfyui/models/` 中查找
- 如果找不到，会在 `/runpod-volume/models/` 中查找
- 下载新模型时，默认保存到 `/comfyui/models/`（因为 `is_default: true`）

## 项目当前配置分析

当前项目的配置（写法 1）是**正确的**，因为：

1. ✅ **符合 RunPod Worker 标准**：使用 `runpod_worker_comfy` 作为配置节名
2. ✅ **路径清晰**：所有模型都在 `/runpod-volume/models/...` 下
3. ✅ **适合优化版 Dockerfile**：镜像中不包含模型，所有模型都在 Network Volume
4. ✅ **配置简洁**：不需要多路径，单一存储位置更易管理

## 是否需要修改？

**不需要修改**，当前配置已经足够：

- ✅ 如果所有模型都在 Network Volume 中，当前配置完美
- ✅ 如果将来需要混合存储，可以添加第二个配置节
- ✅ 当前配置符合 RunPod Worker 的最佳实践

## 参考链接

- [ComfyUI 官方文档 - 模型路径配置](https://docs.comfy.org/zh-CN/development/core-concepts/models)
- [RunPod Worker ComfyUI 官方 Dockerfile](https://github.com/runpod-workers/worker-comfyui/blob/main/Dockerfile)
- [示例配置](https://github.com/wlsdml1114/generate_video/blob/main/extra_model_paths.yaml)

