# 优化版 Dockerfile - 使用 Network Volume 存储模型
# 此版本移除了所有模型下载，构建时间从 1.5-5 小时缩短到 10-30 分钟
# 模型将通过 Network Volume 加载，详见 docs/network-volume-setup.md

FROM runpod/worker-comfyui:5.5.0-base-cuda12.8.1

# Set environment variables for better maintainability
ENV COMFYUI_PATH=/comfyui
ENV DEBIAN_FRONTEND=noninteractive

# Copy custom handler.py to override the base image's handler
# This allows you to use your enhanced handler with URL image support and path normalization
COPY handler.py /handler.py

# Ensure required tools are installed (wget, git, unzip should already be in base image, but verify)
# Note: build-essential, g++, and python3-dev are needed to compile insightface (Cython/C++ extensions)
# python3-dev provides Python.h header files needed for compiling Python extensions
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        wget \
        git \
        unzip \
        ffmpeg \
        curl \
        ca-certificates \
        build-essential \
        g++ \
        python3-dev \
    && rm -rf /var/lib/apt/lists/*

# 注意：不再创建模型目录，因为模型将存储在 Network Volume 中
# Network Volume 挂载到 /runpod-volume，ComfyUI 会自动从 /runpod-volume/models/... 加载模型
# 详见 src/extra_model_paths.yaml 配置

# Install all custom nodes in a single RUN block (optimizes Docker layers)
# Each node installs its requirements.txt if it exists
# Note: Using python3 instead of /venv/bin/python as the base image may not have /venv
# Remove existing directories before cloning to avoid "already exists" errors
# Configure git to avoid credential prompts and handle network issues
RUN git config --global --add safe.directory '*' && \
    git config --global credential.helper '' && \
    git config --global url."https://github.com/".insteadOf git@github.com: && \
    git config --global http.sslVerify true && \
    git config --global http.postBuffer 524288000 && \
    cd $COMFYUI_PATH/custom_nodes && \
    # Install ComfyUI-ReActor (ReActor Face Swap)
    rm -rf ComfyUI-ReActor && \
    git clone --depth 1 https://github.com/Gourieff/ComfyUI-ReActor.git ComfyUI-ReActor && \
    (cd ComfyUI-ReActor && [ ! -f requirements.txt ] || python3 -m pip install --no-cache-dir -r requirements.txt || true) && \
    # Disable NSFW detection in ReActor by modifying reactor_sfw.py to always return False
    (python3 -c "import re; f=open('$COMFYUI_PATH/custom_nodes/ComfyUI-ReActor/scripts/reactor_sfw.py','r',encoding='utf-8'); c=f.read(); f.close(); c=re.sub(r'def nsfw_image\([^)]+\):.*?(?=\n\ndef |\nclass |\Z)', 'def nsfw_image(img_data, model_path: str):\n    return False', c, flags=re.DOTALL); f=open('$COMFYUI_PATH/custom_nodes/ComfyUI-ReActor/scripts/reactor_sfw.py','w',encoding='utf-8'); f.write(c); f.close()" 2>/dev/null || true) && \
    \
    # Install rgthree-comfy
    rm -rf rgthree-comfy && \
    git clone --depth 1 https://github.com/rgthree/rgthree-comfy.git rgthree-comfy && \
    (cd rgthree-comfy && [ ! -f requirements.txt ] || python3 -m pip install --no-cache-dir -r requirements.txt || true) && \
    \
    # Install ComfyUI-Manager
    rm -rf ComfyUI-Manager && \
    git clone --depth 1 https://github.com/Comfy-Org/ComfyUI-Manager.git ComfyUI-Manager && \
    (cd ComfyUI-Manager && [ ! -f requirements.txt ] || python3 -m pip install --no-cache-dir -r requirements.txt || true) && \
    \
    # Install was-node-suite-comfyui
    rm -rf was-node-suite-comfyui && \
    git clone --depth 1 https://github.com/WASasquatch/was-node-suite-comfyui.git was-node-suite-comfyui && \
    (cd was-node-suite-comfyui && [ ! -f requirements.txt ] || python3 -m pip install --no-cache-dir -r requirements.txt || true) && \
    \
    # Install ComfyUI-Crystools
    rm -rf ComfyUI-Crystools && \
    (git clone --depth 1 https://github.com/crystian/ComfyUI-Crystools.git ComfyUI-Crystools || \
     (sleep 2 && git clone --depth 1 https://github.com/crystian/ComfyUI-Crystools.git ComfyUI-Crystools)) && \
    (cd ComfyUI-Crystools && [ ! -f requirements.txt ] || python3 -m pip install --no-cache-dir -r requirements.txt || true) && \
    # Fix SyntaxWarning: invalid escape sequence in ComfyUI-Crystools (fix \/ to / in all Python files)
    (find $COMFYUI_PATH/custom_nodes/ComfyUI-Crystools -name "*.py" -type f -exec sed -i 's|\\/|/|g' {} \; 2>/dev/null || true) && \
    \
    # Install ComfyUI-KJNodes
    rm -rf comfyui-kjnodes && \
    git clone --depth 1 https://github.com/kijai/ComfyUI-KJNodes.git comfyui-kjnodes && \
    (cd comfyui-kjnodes && [ ! -f requirements.txt ] || python3 -m pip install --no-cache-dir -r requirements.txt || true) && \
    \
    # Install ComfyUI-VideoHelperSuite
    rm -rf comfyui-videohelpersuite && \
    git clone --depth 1 https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite.git comfyui-videohelpersuite && \
    (cd comfyui-videohelpersuite && [ ! -f requirements.txt ] || python3 -m pip install --no-cache-dir -r requirements.txt || true) && \
    \
    # Install PuLID_ComfyUI
    rm -rf PuLID_ComfyUI && \
    git clone --depth 1 https://github.com/cubiq/PuLID_ComfyUI.git PuLID_ComfyUI && \
    (cd PuLID_ComfyUI && \
     ([ ! -f requirements.txt ] || python3 -m pip install --no-cache-dir -r requirements.txt || true) && \
     python3 -m pip install --no-cache-dir facexlib || true) && \
    \
    # Install comfyui-mixlab-nodes
    rm -rf comfyui-mixlab-nodes && \
    git clone --depth 1 https://github.com/MixLabPro/comfyui-mixlab-nodes.git comfyui-mixlab-nodes && \
    (cd comfyui-mixlab-nodes && [ ! -f requirements.txt ] || python3 -m pip install --no-cache-dir -r requirements.txt || true) && \
    \
    # Install ComfyUI-Frame-Interpolation
    rm -rf ComfyUI-Frame-Interpolation && \
    git clone --depth 1 https://github.com/Fannovel16/ComfyUI-Frame-Interpolation.git ComfyUI-Frame-Interpolation && \
    (cd ComfyUI-Frame-Interpolation && [ ! -f requirements.txt ] || python3 -m pip install --no-cache-dir -r requirements.txt || true) && \
    \
    # Install ComfyUI_tinyterraNodes
    rm -rf ComfyUI_tinyterraNodes && \
    git clone --depth 1 https://github.com/TinyTerra/ComfyUI_tinyterraNodes.git ComfyUI_tinyterraNodes && \
    (cd ComfyUI_tinyterraNodes && [ ! -f requirements.txt ] || python3 -m pip install --no-cache-dir -r requirements.txt || true) && \
    \
    # Install ComfyUI-FSampler
    rm -rf ComfyUI-FSampler && \
    git clone --depth 1 https://github.com/obisin/ComfyUI-FSampler.git ComfyUI-FSampler && \
    (cd ComfyUI-FSampler && [ ! -f requirements.txt ] || python3 -m pip install --no-cache-dir -r requirements.txt || true) && \
    \
    # Install cg-use-everywhere
    rm -rf cg-use-everywhere && \
    git clone --depth 1 https://github.com/chrisgoringe/cg-use-everywhere.git cg-use-everywhere && \
    (cd cg-use-everywhere && [ ! -f requirements.txt ] || python3 -m pip install --no-cache-dir -r requirements.txt || true) && \
    \
    # Install ComfyUI-segment-anything-2
    rm -rf ComfyUI-segment-anything-2 && \
    git clone --depth 1 https://github.com/kijai/ComfyUI-segment-anything-2.git ComfyUI-segment-anything-2 && \
    (cd ComfyUI-segment-anything-2 && [ ! -f requirements.txt ] || python3 -m pip install --no-cache-dir -r requirements.txt || true) && \
    \
    # Install ComfyUI-WanAnimatePreprocess
    rm -rf ComfyUI-WanAnimatePreprocess && \
    git clone --depth 1 https://github.com/kijai/ComfyUI-WanAnimatePreprocess.git ComfyUI-WanAnimatePreprocess && \
    (cd ComfyUI-WanAnimatePreprocess && [ ! -f requirements.txt ] || python3 -m pip install --no-cache-dir -r requirements.txt || true) && \
    \
    # Install ComfyUI-Easy-Use
    rm -rf ComfyUI-Easy-Use && \
    git clone --depth 1 https://github.com/yolain/ComfyUI-Easy-Use.git ComfyUI-Easy-Use && \
    (cd ComfyUI-Easy-Use && [ ! -f requirements.txt ] || python3 -m pip install --no-cache-dir -r requirements.txt || true) && \
    \
    # Install RES4LYF (provides res_2s sampler and beta57 scheduler for Wan2.2)
    rm -rf RES4LYF && \
    git clone --depth 1 https://github.com/ClownsharkBatwing/RES4LYF.git RES4LYF && \
    (cd RES4LYF && [ ! -f requirements.txt ] || python3 -m pip install --no-cache-dir -r requirements.txt || true) && \
    \
    cd $COMFYUI_PATH

# Support for Network Volume - Copy extra_model_paths.yaml to configure model loading
# This file tells ComfyUI where to look for models in the Network Volume
# Models should be placed in /runpod-volume/models/... according to this configuration
WORKDIR $COMFYUI_PATH
COPY src/extra_model_paths.yaml ./
WORKDIR /



# ============================================
# 模型下载已移除 - 使用 Network Volume 存储模型
# ============================================
# 所有模型（checkpoints、LoRAs、VAE、ControlNet 等）应存储在 Network Volume 中
# Network Volume 挂载路径: /runpod-volume
# 模型目录结构: /runpod-volume/models/checkpoints/, /runpod-volume/models/loras/, 等
# 
# extra_model_paths.yaml 已复制到 /comfyui/ 目录，ComfyUI 会自动读取此配置
# 配置内容：base_path: /runpod-volume
# 
# 配置步骤：
# 1. 在 RunPod 控制台创建 Network Volume
# 2. 将模型上传到 Network Volume（使用临时 Pod 或直接上传）
# 3. 在 Endpoint 配置中附加 Network Volume
# 
# 详细说明请参考: docs/network-volume-setup.md
# ============================================

