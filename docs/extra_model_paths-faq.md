# extra_model_paths.yaml 常见问题

## ❓ 没写的路径会自动加载吗？

**答案：不会自动加载。**

### 详细说明

1. **只有配置的路径才会被搜索**
   - ComfyUI 只会搜索 `extra_model_paths.yaml` 中明确配置的目录
   - 未配置的目录**不会**被自动扫描和加载

2. **工作原理**
   ```yaml
   runpod_worker_comfy:
     base_path: /runpod-volume
     checkpoints: models/checkpoints/  # ✅ 会被搜索
     loras: models/loras/            # ✅ 会被搜索
     # some_other_dir: models/xxx/   # ❌ 未配置，不会被搜索
   ```

3. **实际影响**
   - ✅ **配置的目录**：ComfyUI 会在这些目录中搜索模型，在工作流中可以直接使用文件名
   - ❌ **未配置的目录**：即使文件存在，ComfyUI 也不会自动发现它们

### 示例

假设您的 Network Volume 中有以下结构：
```
/runpod-volume/models/
├── checkpoints/          # ✅ 已配置，会被搜索
├── loras/                # ✅ 已配置，会被搜索
├── my_custom_models/     # ❌ 未配置，不会被搜索
└── another_folder/      # ❌ 未配置，不会被搜索
```

**结果**：
- `checkpoints/` 和 `loras/` 中的模型可以在工作流中直接使用文件名
- `my_custom_models/` 和 `another_folder/` 中的模型**无法**通过 ComfyUI 的标准加载器访问

### 如何添加新路径？

如果您的模型目录不在配置中，有两种方法：

#### 方法 1: 添加到 extra_model_paths.yaml（推荐）

```yaml
runpod_worker_comfy:
  base_path: /runpod-volume
  checkpoints: models/checkpoints/
  loras: models/loras/
  my_custom_models: models/my_custom_models/  # 添加新路径
```

然后重新构建镜像或更新配置。

#### 方法 2: 使用绝对路径（不推荐）

在工作流中直接使用完整路径：
```json
{
  "inputs": {
    "ckpt_name": "/runpod-volume/models/my_custom_models/my_model.safetensors"
  }
}
```

> ⚠️ **注意**：这种方法不推荐，因为：
> - 路径硬编码，不灵活
> - 不同环境路径可能不同
> - 不符合 ComfyUI 的最佳实践

## 📋 配置检查清单

在添加模型到 Network Volume 之前，请确认：

- [ ] 模型目录已在 `extra_model_paths.yaml` 中配置
- [ ] 目录名称与配置中的键名匹配（或符合 ComfyUI 标准）
- [ ] 文件放在正确的子目录中
- [ ] 文件名与工作流中引用的名称一致

## 🔍 如何验证配置是否生效？

### 方法 1: 检查 ComfyUI 日志

启动 Endpoint 后，查看日志中是否有模型路径加载信息：
```
Loading models from /runpod-volume/models/checkpoints/
Loading models from /runpod-volume/models/loras/
```

### 方法 2: 使用 ComfyUI API

访问 `/object_info` 端点查看可用模型：
```bash
curl http://localhost:8188/object_info | jq '.CheckpointLoaderSimple.input.required.ckpt_name[0]'
```

### 方法 3: 检查文件系统

在容器中检查文件是否存在：
```bash
ls -la /runpod-volume/models/checkpoints/
ls -la /runpod-volume/models/loras/
```

## 💡 最佳实践

1. **预先配置所有需要的目录**
   - 在创建 Network Volume 之前，先规划好需要的模型类型
   - 在 `extra_model_paths.yaml` 中一次性配置所有目录

2. **使用标准目录名**
   - 优先使用 ComfyUI 标准目录名（如 `checkpoints`, `loras`, `vae`）
   - 自定义目录名要清晰明确

3. **保持配置同步**
   - 如果添加了新目录，记得更新 `extra_model_paths.yaml`
   - 重新构建镜像或更新配置

4. **文档化自定义目录**
   - 在配置文件中添加注释说明自定义目录的用途
   - 例如：`my_custom_models: models/my_custom_models/  # 用于特定工作流`

## 📚 相关文档

- [Network Volume 配置指南](network-volume-setup.md)
- [模型路径验证清单](model-path-verification.md)
- [ComfyUI 官方文档 - 模型路径](https://docs.comfy.org/zh-CN/development/core-concepts/models)

