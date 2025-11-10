# ComfyUI Wan2.2 Serverless Endpoint Deployment Guide

This guide provides step-by-step instructions for deploying a ComfyUI Serverless Endpoint on RunPod using Network Volume for model storage. This optimized approach significantly reduces Docker image build time and provides greater flexibility for model management. The endpoint supports Wan2.2 models for text-to-video, image-to-video, and video animation workflows, with integrated S3 storage support.

## **Project Introduction**

This project packages [ComfyUI](https://github.com/comfyanonymous/ComfyUI) into a Serverless Endpoint that can be deployed on RunPod, providing a standardized REST API interface. Through this service, you can:

* ✅ Generate images and videos using Wan2.2 models (T2V, I2V, Animate)
* ✅ Call via HTTP API, no local deployment required
* ✅ Supports image/video URL and Base64 input
* ✅ Automatically process video output (MP4, WebM, etc.)
* ✅ Integrated S3 storage support (RunPod S3 and AWS S3)
* ✅ Automatic Base64 encoding/decoding for media files

### **Built-in Features**

* **Model Support**: Wan2.2 T2V, I2V, Animate models (fp8 and fp16/bf16 versions)
* **Custom Nodes**: ComfyUI-WanVideoWrapper, ComfyUI-WanAnimatePreprocess, ComfyUI-KJNodes, and more
* **S3 Integration**: Automatic upload to S3 with URL return (supports RunPod S3 and AWS S3)
* **Error Handling**: Complete error handling and reconnection mechanism
* **Network Volume Support**: Models stored in Network Volume for faster deployments and flexible model management
* **Video Support**: Full support for video input (including m3u8 streaming format)

---

## **Key Improvements**

### **Previous Approach (Deprecated)**

❌ Models downloaded during Docker image build

❌ Build time: **1.5-5 hours**

❌ Models baked into image, difficult to update

❌ Requires rebuilding Image to add/remove models

### **Current Approach (Optimized)**

✅ Models stored in Network Volume (separate from image)

✅ Build time: **10-30 minutes** (90% reduction)

✅ Models can be updated without rebuilding image

✅ Flexible model management - add/remove models anytime

✅ Share models across multiple endpoints

✅ Faster endpoint scaling and deployment

✅ S3 storage integration for output files

---

## **Prerequisites**

Before you begin, please ensure that you meet the following conditions:

### **Required Items**

✅ **RunPod Account**: Register and log in at [RunPod](https://www.runpod.io/)

✅ **API Call Tools**: Postman, curl, Python requests, etc.

✅ **ComfyUI Workflow**: Workflow JSON file exported from ComfyUI (Wan2.2 compatible)

✅ **Network Volume**: A RunPod Network Volume for storing models (we'll create this in Step 1)

### **Recommended Items**

✅ **ComfyUI Local Environment**: Used for testing and exporting workflows

✅ **S3 Storage Account**: RunPod S3 or AWS S3 for storing generated images/videos (optional but recommended)

✅ **Python Environment**: Used for writing test scripts

---

## **Step 1: Create Network Volume**

Network Volume is a persistent storage solution that allows you to store models separately from the Docker image. This enables faster builds and flexible model management.

### **1.1 Access RunPod Console**

1. Navigate to [RunPod Console](https://www.runpod.io/console)
2. Log in using your account

<!-- Screenshot: RunPod Console Login Page -->
![RunPod Console Login](screenshots/01-runpod-console-login.png)

### **1.2 Create Network Volume**

3. In the left navigation bar, click **"Storage"** → **"Network Volumes"**
4. Click the **"New Network Volume"** button

<!-- Screenshot: Network Volumes Page -->
![Network Volumes Page](screenshots/02-network-volumes-page.png)

5. In the Create Network Volume dialog, configure:
   
   - **Volume Name**: `comfyui-wan22-models` (or your preferred name)
   - **Size**: Recommended **200GB** or larger (Wan2.2 models are large, ~100GB+ for full set)
   - **Region**: Select the same region where you plan to deploy your endpoint
6. Click **"Create"** to create the Network Volume

<!-- Screenshot: Create Network Volume Dialog -->
![Create Network Volume](screenshots/03-create-network-volume.png)

---

## **Step 2: Download Models to Network Volume**

Now we'll download all required Wan2.2 models to the Network Volume using a temporary Pod.

### **2.1 Create Temporary Pod**

1. In RunPod Console, click **"Pods"**
2. Create a new Pod with:
   
   - **GPU Type**: Any GPU type (CPU-only is sufficient for downloading)
   - **Network Volume**: Attach the Network Volume you created in Step 1

<!-- Screenshot: Create Pod with Network Volume -->
![Create Pod](screenshots/04-create-pod.png)

- **Pod Template**: `runpod/pytorch:1.0.2-cu1281-torch280-ubuntu2404`

<!-- Screenshot: Pod Template Selection -->
![Pod Template](screenshots/05-pod-template.png)

3. Click **"Deploy On-Demand"** and wait for the Pod to start

### **2.2 Clone Repository and Checkout Branch**

4. Once the Pod is running, open a terminal/SSH session

<!-- Screenshot: Pod Terminal -->
![Pod Terminal](screenshots/06-pod-terminal.png)

5. Clone the repository and checkout the correct branch:

```Bash
cd /workspace
rm -rf runpod-comfyui-cuda128-pure
git clone https://github.com/ultimatech-cn/runpod-comfyui-cuda128-pure.git
cd runpod-comfyui-cuda128-pure
git checkout mwmedia  # Checkout the branch with Wan2.2 support
```

<!-- Screenshot: Git Clone -->
![Git Clone](screenshots/07-git-clone.png)

### **2.3 Run Model Download Script**

6. Run the download script:

```Bash
# If Network Volume is mounted at /workspace (default)
bash scripts/download-models-to-volume.sh

# Or if Network Volume is mounted at /runpod-volume
bash scripts/download-models-to-volume.sh /runpod-volume
```

7. The script will:
   1. Create the required directory structure
   2. Download all Wan2.2 models to the Network Volume:
      - Wan2.2 T2V models (fp8 and fp16)
      - Wan2.2 I2V models (fp8 and fp16)
      - Wan2.2 Animate models (bf16 and fp8 scaled)
      - Text encoders (UMT5)
      - VAE models
      - CLIP Vision models
      - LoRA models
      - SAM2 models
      - Detection models (YOLO, ViTPose)
      - ControlNet Aux models (DWPose)
   3. Show progress for each download
   4. Display a summary when complete

8. Wait for all downloads to complete (this may take several hours depending on your internet connection and model sizes)

<!-- Screenshot: Download Script Running -->
![Download Script](screenshots/08-download-script.png)

### **2.4 Stop Temporary Pod**

Once all models are downloaded, you can terminate the temporary Pod to save costs. The models will remain in the Network Volume.

<!-- Screenshot: Stop Pod -->
![Stop Pod](screenshots/09-stop-pod.png)

---

## **Step 3: Deploy Endpoint on RunPod**

Now we'll create and configure the Serverless Endpoint.

### **3.1 Access Endpoints Section**

1. In RunPod Console, click **"Serverless"** → **"Endpoints"**
2. Click the **"New Endpoint"** button

<!-- Screenshot: Endpoints Page -->
![Endpoints Page](screenshots/10-endpoints-page.png)

<!-- Screenshot: New Endpoint Button -->
![New Endpoint](screenshots/11-new-endpoint.png)

### **3.2 Configure Endpoint**

3. In the Create Endpoint dialog, configure:

**Basic Information**:

- **Endpoint Name**: `runpod-comfyui-wan22` (or your preferred name)
- **Endpoint Type**: Queue
- **Worker Type**: GPU
- **GPU Configuration**: Select **"32GB_pro"** or **"48GB_pro"** (Wan2.2 14B models require significant memory)

<!-- Screenshot: Endpoint Basic Configuration -->
![Endpoint Configuration](screenshots/12-endpoint-config.png)

4. Click the **"Deploy Endpoint"** button to create an Endpoint
5. Click in the upper right corner **"Manager"** to select **"Edit Endpoint"**, adjust **"Max Workers"** to an appropriate number

<!-- Screenshot: Edit Endpoint -->
![Edit Endpoint](screenshots/13-edit-endpoint.png)

Click the **"Advanced"** tab, then:

- Select the **"Network Volume"** you created in Step 1
- Select the **"Allowed CUDA Versions"** to **12.8**
- Configure **S3 Storage** (optional but recommended):

  **For RunPod S3**:
  - `BUCKET_ENDPOINT_URL`: `https://s3api-REGION.runpod.io/BUCKET_NAME`
    - Replace `REGION` with your region (e.g., `eu-ro-1`, `us-east-1`)
    - Replace `BUCKET_NAME` with your bucket name
  - `BUCKET_ACCESS_KEY_ID`: Your RunPod S3 Access Key
  - `BUCKET_SECRET_ACCESS_KEY`: Your RunPod S3 Secret Key

  **For AWS S3**:
  - `BUCKET_ENDPOINT_URL`: `https://BUCKET_NAME.s3.REGION.amazonaws.com`
  - `BUCKET_ACCESS_KEY_ID`: Your AWS Access Key ID
  - `BUCKET_SECRET_ACCESS_KEY`: Your AWS Secret Access Key

<!-- Screenshot: Advanced Configuration -->
![Advanced Configuration](screenshots/14-advanced-config.png)

Then Click the **"Save Endpoint"** button.

### **3.3 Wait for Build**

The Endpoint will start building. With the optimized Dockerfile (no models in image), build time should be **25-30 minutes** instead of 2-3 hours.

6. On the Endpoint Details page, view the **"Workers"** status
7. Wait for the Worker state to change to **"idle"**

<!-- Screenshot: Worker Status -->
![Worker Status](screenshots/15-worker-status.png)

---

## **Step 4: Obtain Endpoint Information**

After deployment is complete, you need to obtain information about the Endpoint.

### **4.1 Get Endpoint ID and API URL**

1. On the Endpoint Overview page, you'll see:
   
   - **Endpoint ID**: A string similar to `sjzwzoz7bqylpv`
   - **API Base URL**: Similar to `https://api.runpod.ai/v2/sjzwzoz7bqylpv/run`

<!-- Screenshot: Endpoint Overview -->
![Endpoint Overview](screenshots/16-endpoint-overview.png)

2. Record this information, which will be needed for subsequent API calls

### **4.2 Obtain API Keys**

3. In the left navigation bar, click **"Settings"** → **"API Keys"**
4. Click the **"Create API Key"** button, then click **"Create"**

<!-- Screenshot: API Keys Page -->
![API Keys](screenshots/17-api-keys.png)

<!-- Screenshot: Create API Key -->
![Create API Key](screenshots/18-create-api-key.png)

5. Record your API Key (it will only be shown once)

---

## **Step 5: API Usage Examples**

### **5.1 Create a Task Request (Using Postman)**

1. **Create New Request**:

* Method: `POST`
* URL: `https://api.runpod.io/v2/YOUR_ENDPOINT_ID/run`

2. **Configure Headers**:

* `Content-Type`: `application/json`
* `Authorization`: `Bearer YOUR_API_KEY`

3. **Configure Body**:

* Select `raw` and `JSON`
* Paste your request JSON (see example below)

**Example Request for Wan2.2 I2V (Image-to-Video)**:

```json
{
  "input": {
    "images": [
      {
        "name": "input_image.jpg",
        "image": "https://example.com/image.jpg"
      }
    ],
    "workflow": {
      "224": {
        "inputs": {
          "clip_name": "umt5_xxl_fp8_e4m3fn_scaled.safetensors",
          "type": "wan",
          "device": "default"
        },
        "class_type": "CLIPLoader"
      },
      ...
    }
  }
}
```

**Example Request for Wan2.2 T2V (Text-to-Video)**:

```json
{
  "input": {
    "workflow": {
      "224": {
        "inputs": {
          "clip_name": "umt5_xxl_fp8_e4m3fn_scaled.safetensors",
          "type": "wan",
          "device": "default"
        },
        "class_type": "CLIPLoader"
      },
      ...
    }
  }
}
```

**Example Request with Video Input (Wan2.2 Animate)**:

```json
{
  "input": {
    "images": [
      {
        "name": "reference.jpg",
        "image": "https://example.com/reference.jpg"
      }
    ],
    "videos": [
      {
        "name": "input_video.mp4",
        "video": "https://example.com/video.mp4"
      }
    ],
    "workflow": {
      ...
    }
  }
}
```

4. **Send Request**

<!-- Screenshot: Postman Request -->
![Postman Request](screenshots/19-postman-request.png)

### **5.2 Check Task Status**

5. **Create New Request**:

* Method: `GET`
* URL: `https://api.runpod.ai/v2/YOUR_ENDPOINT_ID/status/JOB_ID`

6. **Configure Headers**:

* `Authorization`: `Bearer YOUR_API_KEY`

7. **Send Request**

<!-- Screenshot: Check Status -->
![Check Status](screenshots/20-check-status.png)

### **5.3 Process Results**

8. **Save the response after the result returns `200 OK`**

The response will contain output files in one of two formats:

**If S3 is configured**:
```json
{
  "output": {
    "images": [
      {
        "filename": "output_001.png",
        "type": "s3_url",
        "data": "https://s3api-eu-ro-1.runpod.io/bucket-name/path/output_001.png"
      }
    ],
    "videos": [
      {
        "filename": "output.mp4",
        "type": "s3_url",
        "data": "https://s3api-eu-ro-1.runpod.io/bucket-name/path/output.mp4"
      }
    ]
  }
}
```

**If S3 is not configured**:
```json
{
  "output": {
    "images": [
      {
        "filename": "output_001.png",
        "type": "base64",
        "data": "iVBORw0KGgoAAAANSUhEUgAA..."
      }
    ],
    "videos": [
      {
        "filename": "output.mp4",
        "type": "base64",
        "data": "AAAAIGZ0eXBpc29tAAACAGlzb21pc28yYXZjMW1wNDEAAAAIZnJlZQAA..."
      }
    ]
  }
}
```

9. **Process files**:

- **For S3 URLs**: Download directly using the URL or AWS CLI
- **For Base64**: Decode and save to file (see example script below)

**Python Example - Decode Base64 Output**:

```python
import base64
import json

# Load response JSON
with open('response.json', 'r') as f:
    response = json.load(f)

# Decode images
for img in response['output']['images']:
    if img['type'] == 'base64':
        image_data = base64.b64decode(img['data'])
        with open(img['filename'], 'wb') as f:
            f.write(image_data)

# Decode videos
for vid in response['output']['videos']:
    if vid['type'] == 'base64':
        video_data = base64.b64decode(vid['data'])
        with open(vid['filename'], 'wb') as f:
            f.write(video_data)
```

<!-- Screenshot: Process Results -->
![Process Results](screenshots/21-process-results.png)

---

## **Frequently Asked Questions**

### **Q1: How to export a workflow from ComfyUI?**

**Answer**:

1. Open your workflow in ComfyUI
2. Click the top menu **"Workflow"** → **"Export (API)"**
3. Save JSON File
4. Use JSON content as the value of `input.workflow` in your API request

<!-- Screenshot: Export Workflow -->
![Export Workflow](screenshots/22-export-workflow.png)

### **Q2: What should I do if the worker fails to start?**

**Possible Reasons**:

* Network Volume not attached or incorrectly mounted
* Container image pull failed
* Insufficient disk space in the container
* Insufficient GPU resources or memory

**Solution**:

1. Check Endpoint logs (viewable in the RunPod Console)
2. Verify Network Volume is attached and mounted at `/runpod-volume`
3. Confirm that the container image name and tag are correct
4. Increase Container Disk Size if needed
5. Try using different GPU types (32GB_pro or 48GB_pro for Wan2.2 models)
6. Check memory usage - Wan2.2 14B models require significant RAM (80GB+)

### **Q3: What should I do if models are not found?**

**Possible Reasons**:

* Models not downloaded to Network Volume
* Network Volume not attached to endpoint
* Incorrect mount path
* Wrong branch checked out (should be `mwmedia`)

**Solution**:

1. Verify Network Volume is attached to the endpoint (mount path: `/runpod-volume`)
2. Check that models exist in the Network Volume:
   ```Bash
   # In a temporary Pod with Network Volume attached
   ls -lh /workspace/models/diffusion_models/Wan2.2/
   ```
3. Re-run the download script if models are missing
4. Check endpoint logs for model loading errors
5. Verify you're using the `mwmedia` branch

### **Q4: How to add or update models?**

**Answer**:

1. Create a temporary Pod with the Network Volume attached
2. Manually download models to `/workspace/models/` (or use the download script)
3. Models will be immediately available to all endpoints using the same Network Volume
4. **No need to rebuild the Docker image!**

### **Q5: How to configure S3 storage?**

**Answer**: When editing the Endpoint, set the following environment variables:

**For RunPod S3**:
* `BUCKET_ENDPOINT_URL`: `https://s3api-REGION.runpod.io/BUCKET_NAME`
* `BUCKET_ACCESS_KEY_ID`: Your RunPod S3 Access Key ID
* `BUCKET_SECRET_ACCESS_KEY`: Your RunPod S3 Secret Access Key

**For AWS S3**:
* `BUCKET_ENDPOINT_URL`: `https://BUCKET_NAME.s3.REGION.amazonaws.com`
* `BUCKET_ACCESS_KEY_ID`: Your AWS Access Key ID
* `BUCKET_SECRET_ACCESS_KEY`: Your AWS Secret Access Key

After configuration, the output will be automatically uploaded to S3, and the S3 URL will be returned instead of Base64.

**Note**: The region is automatically detected from the endpoint URL for both RunPod S3 and AWS S3.

### **Q6: How to view worker logs?**

**Answer**:

1. On the Endpoint Details page, click the **"Workers"** tab
2. Click Worker ID
3. View **"Logs"** tab

<!-- Screenshot: Worker Logs -->
![Worker Logs](screenshots/23-worker-logs.png)

### **Q7: What if the task times out or runs out of memory?**

**Possible Reasons**:

* Workflow execution time is too long
* Model loading time is too long (first load may be slower)
* Memory usage too high (Wan2.2 14B models are memory-intensive)
* Video processing requires significant memory

**Solution**:

1. Use fp8 scaled models instead of fp16/bf16 (smaller memory footprint)
2. Reduce video length (`length` parameter in workflow)
3. Optimize workflows and reduce unnecessary steps
4. Use a faster GPU with more memory (48GB_pro)
5. Check the stability of the network connection
6. Consider using `REFRESH_WORKER=false` to keep models loaded in memory

### **Q8: Can I share the same Network Volume across multiple endpoints?**

**Answer**: Yes! You can attach the same Network Volume to multiple endpoints. This allows you to:

* Share models across endpoints
* Update models once and use everywhere
* Reduce storage costs

### **Q9: What's the difference between fp8 and fp16/bf16 models?**

**Answer**:

* **fp8 scaled models**: Smaller file size (~50% reduction), lower memory usage, slightly lower quality
* **fp16/bf16 models**: Larger file size, higher memory usage, better quality

For memory-constrained environments, use fp8 scaled models. For best quality, use fp16/bf16 models.

### **Q10: How to handle m3u8 video URLs?**

**Answer**: The handler automatically detects m3u8 URLs and converts them using FFmpeg. Simply provide the m3u8 URL in the `videos` array:

```json
{
  "input": {
    "videos": [
      {
        "name": "input.m3u8",
        "video": "https://example.com/video.m3u8"
      }
    ]
  }
}
```

The handler will download and merge the m3u8 stream before processing.

---

## **Document Version**

* **Version**: 1.0.0

* **Last Updated**: 2025-01-08

* **Author**: ComfyUI Wan2.2 Team

* **Changes from Initial Version**:

* Migrated to Network Volume model storage
* Added Wan2.2 model support (T2V, I2V, Animate)
* Integrated S3 storage support
* Added video input support (including m3u8)
* Optimized for memory efficiency with fp8 models

---
