# Network Volume 使用重要注意事项

根据 [官方文档](https://github.com/runpod-workers/worker-comfyui/blob/main/docs/customization.md) 和项目配置，以下是使用 Network Volume 时需要特别注意的事项。

## 🔍 关键差异说明

### 官方文档 vs 本项目配置

**官方文档说明**：
- Network Volume 挂载到容器内的 `/workspace`
- 模型应放在 `/workspace/models/...` 目录下

**本项目配置**（`src/extra_model_paths.yaml`）：
- Network Volume 挂载到容器内的 `/runpod-volume`
- 模型应放在 `/runpod-volume/models/...` 目录下

> ⚠️ **重要**：本项目使用了自定义的模型路径配置，与官方默认配置不同。请按照本项目的配置方式操作。

## 📁 模型目录结构

### 正确的目录结构

在 Network Volume 中，模型应该按照以下结构存放：

```
Network Volume 根目录 (/runpod-volume 或 /workspace)
└── models/
    ├── checkpoints/          # 主模型（.safetensors, .ckpt）
    │   ├── SDXL/
    │   │   └── ultraRealisticByStable_v20FP16.safetensors
    │   └── Wan2.2/
    │       └── wan2.2-i2v-rapid-aio-v10-nsfw.safetensors
    ├── loras/                # LoRA 模型
    │   ├── SDXL/
    │   │   └── subtle-analsex-xl3.safetensors
    │   └── Wan2.2/
    │       └── DR34MJOB_I2V_14b_HighNoise.safetensors
    ├── clip_vision/          # CLIP Vision 模型
    │   └── wan/
    │       └── clip_vision_h.safetensors
    ├── pulid/                # PuLID 模型
    │   └── ip-adapter_pulid_sdxl_fp16.safetensors
    ├── insightface/          # InsightFace 模型
    │   └── models/
    │       └── antelopev2/
    │           ├── 1k3d68.onnx
    │           ├── 2d106det.onnx
    │           ├── buffalo_l.zip
    │           ├── det_10g.onnx
    │           ├── genderage.onnx
    │           └── w600k_r50.onnx
    ├── reswapper/            # ReActor 模型
    │   └── reswapper_128.onnx
    ├── hyperswap/            # HyperSwap 模型
    │   ├── hyperswap_1a_256.onnx
    │   ├── hyperswap_1b_256.onnx
    │   └── hyperswap_1c_256.onnx
    ├── facerestore_models/   # 面部修复模型
    │   ├── GFPGANv1.4.pth
    │   └── GPEN-BFR-512.onnx
    ├── upscale_models/       # 超分辨率模型
    │   └── RealESRGAN_x2.pth
    ├── vae/                  # VAE 模型
    ├── controlnet/           # ControlNet 模型
    ├── clip/                 # CLIP 模型
    ├── configs/              # 配置文件
    ├── embeddings/           # Embeddings
    └── blip/                 # BLIP 模型（用于图像描述）
```

## ⚠️ 重要注意事项

### 1. 路径映射配置

本项目使用 `src/extra_model_paths.yaml` 配置模型路径：

```yaml
runpod_worker_comfy:
  base_path: /runpod-volume
  checkpoints: models/checkpoints/
  clip: models/clip/
  clip_vision: models/clip_vision/
  # ... 其他路径
```

这意味着：
- ✅ 模型必须放在 `/runpod-volume/models/...` 下
- ✅ 目录结构必须严格按照 ComfyUI 的标准结构
- ❌ 不能放在其他位置（如 `/workspace/models/...`）

### 2. 目录结构必须正确

**关键点**：
- ✅ 所有模型必须放在 `models/` 目录下
- ✅ 子目录名称必须与 ComfyUI 标准目录名完全匹配
- ✅ 文件名必须与工作流中引用的文件名完全一致（包括大小写）

**常见错误**：
- ❌ 将模型直接放在 Volume 根目录
- ❌ 目录名拼写错误（如 `checkpoint` 而不是 `checkpoints`）
- ❌ 文件名大小写不匹配

### 3. 区域一致性

**必须确保**：
- ✅ Network Volume 和 Endpoint 必须在**同一区域**
- ❌ 跨区域的 Volume 会导致高延迟和性能问题

### 4. 自定义节点不能通过 Network Volume 安装

**重要限制**：
- ✅ Network Volume **只能存储模型**
- ❌ **不能**用于安装自定义节点
- ✅ 自定义节点必须通过 Dockerfile 安装

### 5. 模型文件完整性

**注意事项**：
- ✅ 确保模型文件完整下载（检查文件大小）
- ✅ 大文件下载时使用 `wget` 的 `-c` 参数支持断点续传
- ✅ 下载后验证文件完整性

### 6. 权限问题

**确保**：
- ✅ 模型文件有正确的读取权限
- ✅ 目录有执行权限（用于遍历）

## 📝 实际操作步骤

### 步骤 1: 创建临时 Pod 并挂载 Volume

1. 在 RunPod 控制台创建临时 Pod
2. **重要**：在 Pod 配置中选择您的 Network Volume
3. 连接到 Pod（Jupyter Lab 或 SSH）

### 步骤 2: 确认挂载路径

```bash
# 检查挂载点
df -h | grep -E "workspace|runpod-volume"

# 或者直接查看
ls -la /workspace
ls -la /runpod-volume  # 如果存在
```

> **注意**：根据 RunPod 的配置，Volume 可能挂载到 `/workspace` 或 `/runpod-volume`。请根据实际情况调整路径。

### 步骤 3: 创建目录结构

```bash
# 如果挂载到 /workspace
cd /workspace
mkdir -p models/{checkpoints/{SDXL,Wan2.2},loras/{SDXL,Wan2.2},clip_vision/wan,pulid,insightface/models,reswapper,hyperswap,facerestore_models,upscale_models,vae,controlnet}

# 如果挂载到 /runpod-volume（根据项目配置）
cd /runpod-volume
mkdir -p models/{checkpoints/{SDXL,Wan2.2},loras/{SDXL,Wan2.2},clip_vision/wan,pulid,insightface/models,reswapper,hyperswap,facerestore_models,upscale_models,vae,controlnet}
```

### 步骤 4: 下载模型

使用项目提供的脚本或手动下载：

```bash
# 使用项目脚本（需要先确认挂载路径）
bash scripts/upload-models-to-volume.sh /workspace
# 或
bash scripts/upload-models-to-volume.sh /runpod-volume

# 手动下载示例
cd /workspace/models/checkpoints/SDXL
wget -O ultraRealisticByStable_v20FP16.safetensors \
  "https://huggingface.co/datasets/Robin9527/LoRA/resolve/main/SDXL/ultraRealisticByStable_v20FP16.safetensors"
```

### 步骤 5: 验证模型位置

```bash
# 检查模型是否在正确位置
ls -lh /workspace/models/checkpoints/SDXL/
ls -lh /workspace/models/loras/SDXL/

# 验证目录结构
tree -L 3 /workspace/models/  # 如果 tree 命令可用
# 或
find /workspace/models -type f | head -20
```

## 🔧 故障排除

### 问题 1: 模型无法加载

**可能原因**：
- 模型不在正确的目录下
- 目录结构不正确
- 文件名不匹配

**解决方法**：
```bash
# 检查模型路径
ls -la /runpod-volume/models/checkpoints/

# 检查 ComfyUI 日志中的模型加载信息
# 查看 Endpoint 日志确认模型路径
```

### 问题 2: 工作流找不到模型

**可能原因**：
- 工作流中使用的文件名与实际文件名不匹配
- 路径格式错误（Windows vs Unix）

**解决方法**：
- 确保工作流中的文件名与实际文件名完全一致
- 使用 Unix 风格路径（`SDXL/model.safetensors` 而不是 `SDXL\model.safetensors`）
- 本项目会自动转换 Windows 路径，但最好使用 Unix 风格

### 问题 3: 性能问题

**可能原因**：
- Volume 和 Endpoint 不在同一区域
- Volume 容量不足

**解决方法**：
- 确保 Volume 和 Endpoint 在同一区域
- 检查 Volume 使用情况：`df -h /workspace`

## 📚 参考文档

- [官方 Customization 文档](https://github.com/runpod-workers/worker-comfyui/blob/main/docs/customization.md)
- [RunPod Network Volumes 指南](https://docs.runpod.io/pods/storage/create-network-volumes)
- [项目 Network Volume 配置指南](network-volume-setup.md)
- [ComfyUI 模型目录结构](https://github.com/comfyanonymous/ComfyUI/wiki/Model-Directories)

## ✅ 检查清单

使用 Network Volume 前，请确认：

- [ ] Network Volume 已创建
- [ ] Volume 和 Endpoint 在同一区域
- [ ] 目录结构已正确创建（`models/checkpoints/`, `models/loras/` 等）
- [ ] 模型文件已下载到正确位置
- [ ] 文件名与工作流中引用的名称一致
- [ ] 文件权限正确（可读）
- [ ] 在 Endpoint 配置中已附加 Network Volume
- [ ] 已测试模型加载是否正常

