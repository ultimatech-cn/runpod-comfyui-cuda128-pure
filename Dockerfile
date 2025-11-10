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
    # Install ComfyUI-Logic
    rm -rf ComfyUI-Logic && \
    git clone --depth 1 https://github.com/theUpsider/ComfyUI-Logic.git ComfyUI-Logic && \
    (cd ComfyUI-Logic && [ ! -f requirements.txt ] || python3 -m pip install --no-cache-dir -r requirements.txt || true) && \
    \
    cd $COMFYUI_PATH

# Support for Network Volume - Copy extra_model_paths.yaml to configure model loading
# This file tells ComfyUI where to look for models in the Network Volume
# Models should be placed in /runpod-volume/models/... according to this configuration
WORKDIR $COMFYUI_PATH
COPY src/extra_model_paths.yaml ./
WORKDIR /

# Download ReActor inswapper_128.onnx to ComfyUI default path
# This ensures ReActor nodes can find the model even if extra_model_paths.yaml or symlinks fail
# ReActor swap_model parameter expects inswapper_128.onnx in /comfyui/models/insightface/
RUN mkdir -p $COMFYUI_PATH/models/insightface && \
    wget -q --show-progress -O $COMFYUI_PATH/models/insightface/inswapper_128.onnx \
    "https://huggingface.co/datasets/Gourieff/ReActor/resolve/main/models/inswapper_128.onnx" || \
    (echo "Warning: Failed to download inswapper_128.onnx" && exit 0)

# Pre-download InsightFace AntelopeV2 model for PuLID_ComfyUI
# PuLID_ComfyUI expects /comfyui/models/insightface/models/antelopev2/
# This provides a fallback if Network Volume doesn't have the model
RUN mkdir -p $COMFYUI_PATH/models/insightface/models && \
    wget -q -O /tmp/antelopev2.zip "https://huggingface.co/MonsterMMORPG/tools/resolve/main/antelopev2.zip" && \
    test -f /tmp/antelopev2.zip || (echo "Error: Failed to download antelopev2.zip" && exit 1) && \
    unzip -q /tmp/antelopev2.zip -d $COMFYUI_PATH/models/insightface/models/ && \
    rm /tmp/antelopev2.zip

# Pre-download BLIP models to avoid runtime download failures
# BLIP models are used by was-node-suite-comfyui for image captioning and VQA
# According to was-node-suite-comfyui, it uses /comfyui/models/blip as cache_dir
# We download models using transformers library which will place them correctly
# This provides a fallback if Network Volume doesn't have BLIP models
RUN mkdir -p $COMFYUI_PATH/models/blip && \
    python3 -c "from transformers import BlipProcessor, BlipForConditionalGeneration, BlipForQuestionAnswering; \
    import os; \
    blip_cache = '/comfyui/models/blip'; \
    os.environ['HF_HUB_CACHE'] = blip_cache; \
    os.environ['TRANSFORMERS_CACHE'] = blip_cache; \
    os.environ['HF_HOME'] = blip_cache; \
    print('Downloading BLIP image captioning model...'); \
    BlipProcessor.from_pretrained('Salesforce/blip-image-captioning-base', cache_dir=blip_cache); \
    BlipForConditionalGeneration.from_pretrained('Salesforce/blip-image-captioning-base', cache_dir=blip_cache); \
    print('Downloading BLIP VQA model...'); \
    BlipProcessor.from_pretrained('Salesforce/blip-vqa-base', cache_dir=blip_cache); \
    BlipForQuestionAnswering.from_pretrained('Salesforce/blip-vqa-base', cache_dir=blip_cache); \
    print('BLIP models downloaded successfully')" || \
    (echo "Warning: Failed to download BLIP models" && exit 0)

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

