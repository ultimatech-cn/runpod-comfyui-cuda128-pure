# 模型路径验证清单

本文档用于验证 Dockerfile 中的模型下载路径与 `extra_model_paths.yaml` 配置的一致性。

## Dockerfile 中的模型路径 vs extra_model_paths.yaml

### ✅ 已正确配置的路径

| Dockerfile 路径 | extra_model_paths.yaml 配置 | 状态 |
|----------------|---------------------------|------|
| `models/checkpoints/SDXL/` | `checkpoints: models/checkpoints/` | ✅ |
| `models/checkpoints/Wan2.2/` | `checkpoints: models/checkpoints/` | ✅ |
| `models/clip_vision/wan/` | `clip_vision: models/clip_vision/` | ✅ |
| `models/pulid/` | `pulid: models/pulid/` | ✅ |
| `models/insightface/models/` | `insightface: models/insightface/` | ✅ |
| `models/insightface/inswapper_128.onnx` | `insightface: models/insightface/` | ✅ |
| `models/reswapper/` | `reswapper: models/reswapper/` | ✅ |
| `models/hyperswap/` | `hyperswap: models/hyperswap/` | ✅ |
| `models/upscale_models/` | `upscale_models: models/upscale_models/` | ✅ |
| `models/facerestore_models/` | `facerestore_models: models/facerestore_models/` | ✅ |
| `models/loras/SDXL/` | `loras: models/loras/` | ✅ |
| `models/loras/Wan2.2/` | `loras: models/loras/` | ✅ |
| `models/blip/` | `blip: models/blip/` | ✅ |

## 路径映射说明

### 相对路径的工作原理

在 `extra_model_paths.yaml` 中：
```yaml
base_path: /runpod-volume
checkpoints: models/checkpoints/
```

实际路径计算：
- `base_path` = `/runpod-volume`
- `checkpoints` = `models/checkpoints/`
- **最终路径** = `/runpod-volume` + `models/checkpoints/` = `/runpod-volume/models/checkpoints/`

### 子目录支持

配置中的路径支持子目录：
- `checkpoints: models/checkpoints/` 会自动包含：
  - `/runpod-volume/models/checkpoints/SDXL/`
  - `/runpod-volume/models/checkpoints/Wan2.2/`
  - `/runpod-volume/models/checkpoints/` 下的所有子目录

- `clip_vision: models/clip_vision/` 会自动包含：
  - `/runpod-volume/models/clip_vision/wan/`
  - `/runpod-volume/models/clip_vision/` 下的所有子目录

- `insightface: models/insightface/` 会自动包含：
  - `/runpod-volume/models/insightface/models/`
  - `/runpod-volume/models/insightface/inswapper_128.onnx`
  - `/runpod-volume/models/insightface/` 下的所有文件和子目录

## 验证方法

### 1. 检查配置完整性

确保 Dockerfile 中使用的所有模型目录都在 `extra_model_paths.yaml` 中：

```bash
# 提取 Dockerfile 中的模型路径
grep -o "models/[^/]*" Dockerfile | sort -u

# 提取 extra_model_paths.yaml 中的配置
grep -E "^\s+\w+:" src/extra_model_paths.yaml | sed 's/://' | sed 's/^[[:space:]]*//'
```

### 2. 验证路径结构

在 Network Volume 中验证目录结构：

```bash
# 在临时 Pod 中检查
cd /runpod-volume
find models -type d | sort
```

### 3. 测试模型加载

部署 Endpoint 后，检查 ComfyUI 日志确认模型路径：

```bash
# 查看 ComfyUI 启动日志
# 应该能看到从 /runpod-volume/models/... 加载模型的日志
```

## 常见问题

### Q: 为什么有些目录在 Dockerfile 中创建了，但 extra_model_paths.yaml 中没有？

A: 不是所有目录都需要在 `extra_model_paths.yaml` 中配置。只有 ComfyUI 需要**主动搜索和加载**的模型目录才需要配置。例如：
- ✅ 需要配置：`checkpoints`, `loras`, `vae` 等（ComfyUI 会扫描这些目录）
- ❌ 不需要配置：`.cache`（缓存目录，ComfyUI 自动管理）

### Q: 子目录需要单独配置吗？

A: 不需要。配置父目录即可，ComfyUI 会递归搜索所有子目录。例如：
- `loras: models/loras/` 会自动包含 `models/loras/SDXL/` 和 `models/loras/Wan2.2/`

### Q: 如果添加了新的模型目录怎么办？

A: 在 `extra_model_paths.yaml` 中添加对应的配置项即可，无需修改 Dockerfile（如果使用 Network Volume）。

## 当前配置状态

✅ **所有 Dockerfile 中使用的模型路径都已正确配置**

配置包括：
- 标准 ComfyUI 目录（checkpoints, loras, vae 等）
- 自定义节点目录（pulid, reswapper, hyperswap）
- 扩展模型目录（所有用户目录中出现的类型）

