This guide provides step-by-step instructions for deploying a ComfyUI Serverless Endpoint on RunPod using Network Volume for model storage. This optimized approach significantly reduces Docker image build time and provides greater flexibility for model management.

## **Project Introduction**

This project packages [ComfyUI](https://github.com/comfyanonymous/ComfyUI) into a Serverless Endpoint that can be deployed on RunPod, providing a standardized REST API interface. Through this service, you can:

* ✅ Generate images and videos using ComfyUI's powerful workflow capabilities
* ✅ Call via HTTP API, no local deployment required
* ✅ Supports image URL and Base64 input
* ✅ Automatically process video output (MP4, WebM, etc.)
* ✅ Supports S3 storage or Base64 return

### **Built-in Features**

\* ​**Model Support**​: SDXL, Wan2.2

\* ​**Custom Nodes**​: Integrates commonly used custom nodes

\* ​**Error Handling**​: Complete error handling and reconnection mechanism

\* ​**Network Volume Support**​: Models stored in Network Volume for faster deployments and flexible model management

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

---

## **Prerequisites**

Before you begin, please ensure that you meet the following conditions:

### **Required Items**

✅ ​**RunPod Account**​: Register and log in at [RunPod](https://www.runpod.io/)

✅ **API**​​**​ Call Tools**​: Postman, curl, Python requests, etc.

✅ **ComfyUI ​**​​**Workflow**​: Workflow JSON file exported from ComfyUI

✅ ​**Network Volume**​: A RunPod Network Volume for storing models (we'll create this in Step 1)

### **Recommended Items**

✅ **ComfyUI Local ​**​​**Environment**​: Used for testing and exporting workflows

✅ ​**S3 Storage Account**​: Used to store generated images/videos (optional)

✅ **Python ​**​​**Environment**​: Used for writing test scripts

---

## **Step 1: Create Network Volume**

Network Volume is a persistent storage solution that allows you to store models separately from the Docker image. This enables faster builds and flexible model management.

### **1.1 Access RunPod Console**

1. Navigate to [RunPod Console](https://www.runpod.io/console)
2. Log in using your account

![](https://vcn9g31upjvz.feishu.cn/space/api/box/stream/download/asynccode/?code=ZWUzZWYyZjE0MTU4NzU2YTRhNTlmMmEzZWM0ZDU1MTdfZ2g3UVlRdzZTSDZuU0tUWm5kY3hHbkF3QW94RFlmNGxfVG9rZW46TXBVQWJ5dzF5b3pTMmt4UFJVWmN0aUtSbjNkXzE3NjI1OTY0NjQ6MTc2MjYwMDA2NF9WNA)![](https://vcn9g31upjvz.feishu.cn/space/api/box/stream/download/asynccode/?code=ODhjYzZjYjJlYWYzMmY0MDNlMzI1MTI5NmVmNTNhNmFfQjZhYVlJaVJrZHVWclN6TEl4bDczRVRkbENMUTBPSWxfVG9rZW46UEowb2JnSmxVb0VqV094UDQ4eGNPaGN3bnhiXzE3NjI1OTY0NjQ6MTc2MjYwMDA2NF9WNA)

### **1.2 Create Network Volume**

3. In the left navigation bar, click **"Storage"** → **"Network Volumes"**
4. Click the **"New Network Volume"** button

![](https://vcn9g31upjvz.feishu.cn/space/api/box/stream/download/asynccode/?code=MjQwODNhMGY2Y2Q4NDU4OWEwN2Y5ZThhNDVjYWVjZTVfZlY5ZG40NFRhQ1VpT3FndmM2bktwTWxGVnNCaGJqczFfVG9rZW46UFFscmJpODBNb3hLMFV4eUc1bWM1aWNUbnVoXzE3NjI1OTY0NjQ6MTc2MjYwMDA2NF9WNA)

5. In the Create Network Volume dialog, configure:
   
   - ​**Volume Name**​: \`comfyui-models\` (or your preferred name)
   - ​**Size**​: Recommended **100GB** or larger (depending on your model collection)
   - ​**Region**​: Select the same region where you plan to deploy your endpoint
6. Click **"Create"** to create the Network Volume

![](https://vcn9g31upjvz.feishu.cn/space/api/box/stream/download/asynccode/?code=ZDQ5ZGZjZWQ4YjNhMjE0MzFlMDhkMjExYTk1MTNlMjJfMTI2a25lSVN0WnZFRGQ2RnZHc3VkWlFHWGZJMFk1bHFfVG9rZW46VU4ycGJpcVgwbzRLdmV4TkN2V2NCbERobmZoXzE3NjI1OTY0NjQ6MTc2MjYwMDA2NF9WNA)

---

## **Step 2: Download Models to Network Volume**

Now we'll download all required models to the Network Volume using a temporary Pod.

### **2.1 Create Temporary Pod**

1. In RunPod Console, click **"Pods"**
2. Create a new Pod with:
   
   - ​**GPU Type**​: Any GPU type (CPU-only is sufficient for downloading)
   - ​**Network Volume**​: Attach the Network Volume you created in Step 1

![](https://vcn9g31upjvz.feishu.cn/space/api/box/stream/download/asynccode/?code=OWJkZDBmZWUyNTYwNDIxZTg0Y2RiZmIzYWE0MzI4ZjlfMmN2UTJEM2tGckFEc3RrVWRBNFU5WHlDQkJNdEI4YUNfVG9rZW46V1lFTGJxSkIxb2hORmp4Um5laGNxbEo2bmJoXzE3NjI1OTY0NjQ6MTc2MjYwMDA2NF9WNA)

- ​**Pod Template**​: \`runpod/pytorch:1.0.2-cu1281-torch280-ubuntu2404\`

![](https://vcn9g31upjvz.feishu.cn/space/api/box/stream/download/asynccode/?code=YmUwMDJiZmExNjI5Y2IzZDY2OGFkODAyNWRmZWI5MGJfQlpHd0JVUlVnbHJyMTljWG1HbWVDUUdrSFNObzhIMVpfVG9rZW46T1ZRcWJWSDZvb3pHQUZ4VjluQmNKV1JybjhDXzE3NjI1OTY0NjQ6MTc2MjYwMDA2NF9WNA)

3. Click **"Deploy On-Demand"** and wait for the Pod to start

### **2.2 Clone Repository and Checkout Branch**

3. Once the Pod is running, open a terminal/SSH session

![](https://vcn9g31upjvz.feishu.cn/space/api/box/stream/download/asynccode/?code=NDZlMWZhMzZjYzYyZGY5MzUzMDJiOTM4OTEyMzY5NTVfMDFEOTFoVDhWNmRweGF3UDdsdjJlVkVZbkp1Wm1zakpfVG9rZW46QzR5dGJNZ3VNb1VBVFZ4RmFKZ2N3ckJQbm9nXzE3NjI1OTY0NjQ6MTc2MjYwMDA2NF9WNA)

4. Clone the repository:

```Bash
cd /workspace
rm -rf runpod-comfyui-cuda128-pure
git clone https://github.com/ultimatech-cn/runpod-comfyui-cuda128-pure.git
cd runpod-comfyui-cuda128-pure
```

![](https://vcn9g31upjvz.feishu.cn/space/api/box/stream/download/asynccode/?code=MGRkMjdkNWEyN2UwMzQ0YTliNmY5OGEyOWZhZjYzMWFfR0ZpMmpCUFFMWXJUYnhTYzcxMmNQUW9qdU1OOGs4ZENfVG9rZW46SjNhRGJVUFROb3NjYU14bVdISmNYd0VMbmxoXzE3NjI1OTY0NjQ6MTc2MjYwMDA2NF9WNA)

### **2.3 Run Model Download Script**

5. Run the download script:

```Bash
# If Network Volume is mounted at /workspace (default)
bash scripts/download-models-to-volume.sh
```

6. The script will:
   1. Create the required directory structure
   2. Download all models to the Network Volume
   3. Show progress for each download
   4. Display a summary when complete
7. Wait for all downloads to complete (this may take several hours depending on your internet connection and model sizes)

### **2.4 Stop Temporary Pod**

Once all models are downloaded, you can terminate the temporary Pod to save costs. The models will remain in the Network Volume.

![](https://vcn9g31upjvz.feishu.cn/space/api/box/stream/download/asynccode/?code=NzRmNmFhOWUxNjk2OGU0ZmVkYWIxZmJiMTU3YzczZDVfSExiUTgwQUVmdnB3ZnVqRTQ0V3hYbWs2MmFVaGk3bm9fVG9rZW46UDQxWmJXQXBkb3dTekt4OGRYcWM1SGJ1bkNjXzE3NjI1OTY0NjQ6MTc2MjYwMDA2NF9WNA)

---

## **Step 3: Deploy Endpoint on RunPod**

Now we'll create and configure the Serverless Endpoint.

### **3.1 Access Endpoints Section**

1. In RunPod Console, click **"Serverless"** → **"Endpoints"**
2. Click the **"New Endpoint"** button

![](https://vcn9g31upjvz.feishu.cn/space/api/box/stream/download/asynccode/?code=MTQ2OWFkY2Y1YTNkMWQyZGUyNWVjOWI3NjZjZjRkNTJfWTNUMHY1ZGNLS25pc2JQVm1CNFJCOEJsS2pSRjJvVkFfVG9rZW46UWJJbmJCWkgyb0s5alR4bFdLUmM3Wlk4bnFmXzE3NjI1OTY0NjQ6MTc2MjYwMDA2NF9WNA)

![](https://vcn9g31upjvz.feishu.cn/space/api/box/stream/download/asynccode/?code=ZGU3OWZkMjUzYTgwNWZiMTljMGU3OTA5MWEzZWE0MTJfaEhvc3ZESjZja2VoZEMxcUtoemY1MnJWSjJ1OUw1S01fVG9rZW46TkRGbWJuNDM5bzZyd3F4MkZOaGNIamtHbktnXzE3NjI1OTY0NjQ6MTc2MjYwMDA2NF9WNA)

![](https://vcn9g31upjvz.feishu.cn/space/api/box/stream/download/asynccode/?code=ZmUwYWUzZTY4NDQ2OTVlYWE3Y2NiNThlYTRhNDE4MTlfdjRoUVFvR29TV2I5QW5ld21Za3ZFdUNIV1lza2tMWG5fVG9rZW46RU1YUGJFSlh0b0tOeFR4TENUTmNmblcybjJjXzE3NjI1OTY0NjQ6MTc2MjYwMDA2NF9WNA)

### **3.2 Configure Endpoint**

3. In the Create Endpoint dialog, configure:

​**Basic Information**​:

- ​**Endpoint Name**​: \`runpod-comfyui-cuda128-pure\` (or your preferred name)
- ​**Endpoint Type**​: Queue
- ​**Worker Type**​: GPU
- ​**GPU Configuration**​: Select **"32GB\_pro"**

![](https://vcn9g31upjvz.feishu.cn/space/api/box/stream/download/asynccode/?code=YmJlODZkMjQ5ZTcxMTA4ZWNkMTUyYjc0ZjIzNzQyYjVfbWg3SFk1UkYxWUM0ajRxd0N4RjFDeHpiNG9DaGlKR0ZfVG9rZW46SjZ0ZmJJRnpOb1Q1QTZ4bWxnZGNyalFDbk1jXzE3NjI1OTY0NjQ6MTc2MjYwMDA2NF9WNA)

![](https://vcn9g31upjvz.feishu.cn/space/api/box/stream/download/asynccode/?code=NDZjMWQ0NDYzYmE4MWNmYWU1MWI5MzVmMDRiNGZkYWJfUnFKNkNaWG56OUVKeHVlVmlqMEVqUldaRTY3TmNaVFpfVG9rZW46S2gzUmJQcVVzb0xMM3h4ckhRVmNxUlE1bnhnXzE3NjI1OTY0NjQ6MTc2MjYwMDA2NF9WNA)

4. Click the **"Deploy Endpoint"** button to create an Endpoint
5. Click in the upper right corner**​"Manager"​**to select**​"Edit Endpoint",​**adjust**​"Max Workers"​**to an appropriate number

![](https://vcn9g31upjvz.feishu.cn/space/api/box/stream/download/asynccode/?code=MjFmOTVmYTM2MGM3YTM0NzAyYWRhZWI1MWMwMmM3MmFfOHNoelhHdVlNR09wRnpISFBHU3FWeVlCQ1ZyUEJETGhfVG9rZW46Q2l5cGJxU2s1b2V2RXp4ckx3UWNDQjR1bm9jXzE3NjI1OTY0NjQ6MTc2MjYwMDA2NF9WNA)

![](https://vcn9g31upjvz.feishu.cn/space/api/box/stream/download/asynccode/?code=OTgyZDExZjMzN2Q5NDVmY2U5OTk3N2NhYTcwNGNmMDhfM2ttWG1OdUJoRk5TbWZQbnhwOGxDekxJMGd2SlJqWXlfVG9rZW46TVBuOGJKeU1Pb2FETUh4SVo4bGNwRVpPbmdjXzE3NjI1OTY0NjQ6MTc2MjYwMDA2NF9WNA)

Click the ​**"Advanced"**​, Select the **"Network Volume"** you created in Step 1, Select the **"Allowed CUDA Versions"** to 12.8. Then Click the ​**"Save Endpoint"**​.

![](https://vcn9g31upjvz.feishu.cn/space/api/box/stream/download/asynccode/?code=NTdjYWQ1MzE1ZjAwM2I5ODZhYzkwODE2ZjQ5YzE3ZGJfT01HQTVCMUdyQTFSMXI2bHE0NzZpdm1qUG16TW54bmFfVG9rZW46T3RTTWJqOUxsbzdiQkp4RXo3bGN5ZkVjbkRnXzE3NjI1OTY0NjQ6MTc2MjYwMDA2NF9WNA)

### **3.3 Wait for Build**

The Endpoint will start building. With the optimized Dockerfile (no models in image), build time should be **25-30 minutes** instead of 2-3 hours.

6. On the Endpoint Details page, view the **"Workers"** status
7. Wait for the Worker state to change to **"idle"**

![](https://vcn9g31upjvz.feishu.cn/space/api/box/stream/download/asynccode/?code=ZTIyYTMwNzVkMzY3ZTUwMzRmZjJjYjcxMjZhYjNlYTlfNWU4VTYyVmNGNFVUSWF2WGxJOVd1ellQRzdySWZUM2ZfVG9rZW46THpnUWI0allCb2RGRXp4cEZIUGNaOEdibjhkXzE3NjI1OTY0NjQ6MTc2MjYwMDA2NF9WNA)

---

## **Step 4: Obtain Endpoint Information**

After deployment is complete, you need to obtain information about the Endpoint.

### **4.1 Get Endpoint ID and API URL**

1. On the Endpoint Overview page, you'll see:
   
   - ​**Endpoint ID**​: A string similar to \`sjzwzoz7bqylpv\`
   - ​**API Base URL**​: Similar to \`https://api.runpod.ai/v2/sjzwzoz7bqylpv/run\`

![](https://vcn9g31upjvz.feishu.cn/space/api/box/stream/download/asynccode/?code=MmNkZTc0OWQzMzVmMTVlYTRkNDJhMGMwYzEwYWI0YTJfekdaelg5S2ZCY1RVYUdxbkE5Z1NEeXc0NDVOdklQRVVfVG9rZW46QWlJT2I1Y3hYbzNDM0V4WnJrbGN1OUJlbkFiXzE3NjI1OTY0NjQ6MTc2MjYwMDA2NF9WNA)

2. Record this information, which will be needed for subsequent API calls

### **4.2 Obtain API Keys**

3. In the left navigation bar, click **"Settings"** → **"API Keys"**
4. Click the **"Create API Key"** button, then click **"Create"**

![](https://vcn9g31upjvz.feishu.cn/space/api/box/stream/download/asynccode/?code=NjU3YmZkMmE5NDNjZWUzMDRjNjI3YTllZTc1ZGJiZGRfYXBEVm1zVms0R1N0NmxUS0h6ZU4ySTRzUkhyaktvRDdfVG9rZW46Q2hndWJDNDlBb2Y2MFJ4b2pHY2NXU1FLblNlXzE3NjI1OTY0NjQ6MTc2MjYwMDA2NF9WNA)

![](https://vcn9g31upjvz.feishu.cn/space/api/box/stream/download/asynccode/?code=ZjhjMzQwNWYxYzQ5ZDYxMjI4OTIyMWE3MWI1MTJhYmRfeVZHdDFCR1ZNYklEeFp2Q0pFdTNhNTM0VjJyaDRtZmlfVG9rZW46STc5UWIyN0Vlb2hyT3d4SE56bWN5WVdlbmdmXzE3NjI1OTY0NjQ6MTc2MjYwMDA2NF9WNA)

![](https://vcn9g31upjvz.feishu.cn/space/api/box/stream/download/asynccode/?code=YTBjNzhjY2FkYjViM2NjNTFhMTZmZjI3ZmFkYmM5YzhfTEVTT1JYdGpYVUNKNEZ4S244aDBLeTBjcnVSOGNVcFFfVG9rZW46UzNLTWJ1VjFFbzVJNXJ4QlRsWGNGOUh5bmhjXzE3NjI1OTY0NjQ6MTc2MjYwMDA2NF9WNA)

5. Record your API Key （rpa\_XA2CW5BEHQE794NDZ0FKXAJBXOUW2LLP4I6ZV21Xykgopf)

---

## **Step 5: API Usage Examples**

### **5.1 Create a Task Request (Using Postman)**

1. ​**Create New Request**​:

* Method: `POST`
* URL: `https://api.runpod.io/v2/YOUR_ENDPOINT_ID/run`

2. ​**Configure Headers**​:

* `Content-Type`: `application/json`
* `Authorization`: `Bearer YOUR_API_KEY`

3. ​**Configure Body**​:

* Select `raw` and `JSON`
* Paste your request JSON

4. **Send Request**

![](https://vcn9g31upjvz.feishu.cn/space/api/box/stream/download/asynccode/?code=NDE5NzI0N2VlMjllMTNjNzUyYTI3MjI0ODUxYWNjNjlfaFRWbTVJQ0Q4QmVSRnNuMU9JcjhDaTl2VEwwZ2hEN2pfVG9rZW46R092TmI3SzNwb3lCUmp4OWptN2NPT05ZbjVMXzE3NjI1OTY0NjQ6MTc2MjYwMDA2NF9WNA)

![](https://vcn9g31upjvz.feishu.cn/space/api/box/stream/download/asynccode/?code=NDRmN2RmZjcwZDA5NTRiOTZhNjE2ZDY3NDM0NTE1YTRfTXRmZkdjaWpIaHpUeW0zZHNTTUJMR3cyNDk5aWNwc2RfVG9rZW46UTBhMGJ2aXZvb1FMdEt4QVBGMmNHMEVVbndiXzE3NjI1OTY0NjQ6MTc2MjYwMDA2NF9WNA)

### **5.2 Check Task Status**

5. ​**Create New Request**​:

* Method: `GET`
* URL: `https://api.runpod.ai/v2/YOUR_ENDPOINT_ID/status/JOB_ID`

6. ​**Configure Headers**​:

* `Authorization`: `Bearer YOUR_API_KEY`

7. **Send Request**

![](https://vcn9g31upjvz.feishu.cn/space/api/box/stream/download/asynccode/?code=ZmIxMTY1NGRjMTk5NmU1YTMyYWY2YWRhMWFhZjEwYTVfZ3lPaGlrbVM4bWlUalV5U3hlTFhxQ29JcGIzSXV4UGpfVG9rZW46V2dXYmJvVlRvb24zelJ4eU1xVGNJTG8ybkFlXzE3NjI1OTY0NjQ6MTc2MjYwMDA2NF9WNA)

### **5.3 Process Results**

8. **Save the response after the result returns**​**`200 OK`**

![](https://vcn9g31upjvz.feishu.cn/space/api/box/stream/download/asynccode/?code=ZWQ5MDM2MTJjM2VmZjk0MzhkOGFmZGU5ZjlmMjcwM2RfcGlsUFE2VFZSQ2NlQlVnSk5aRUFpdnppR2J1Rk4wOXNfVG9rZW46Qk1JTGJtR3Q4b2J3bjF4dHNMTGMwczZOblNoXzE3NjI1OTY0NjQ6MTc2MjYwMDA2NF9WNA)

9. **Process files using base64\_gui.py**

```Plain
python base64_gui.py
```

![](https://vcn9g31upjvz.feishu.cn/space/api/box/stream/download/asynccode/?code=NDllNGEzZGE1NmUxNDgwNDNiYmNkNWI5NTcyYjUxN2RfVk52YlBqVmdUa1d2YmlBSGk2ME15Z0txN3dlZUFETUtfVG9rZW46SmpzV2IzQ0FhbzJhZGF4ZmJFVWM3WFlLbjZmXzE3NjI1OTY0NjQ6MTc2MjYwMDA2NF9WNA)

---

## **Frequently Asked Questions**

### **Q1: How to export a workflow from ComfyUI?**

​**Answer**​:

1. Open your workflow in ComfyUI
2. Click the top menu **"Workflow"** → **"Export (API)"**
3. Save JSON File
4. Use JSON content as the value of `input.workflow` in your API request

![](https://vcn9g31upjvz.feishu.cn/space/api/box/stream/download/asynccode/?code=ZmZkZjY2NjRiYzBjYzY2YjQzYTdjMmVjZTA0OGUzM2JfREtQaFcxZlJERUZFOFRaQnVnQXF2Qm0wVnlxYUdzWkxfVG9rZW46WVM1TmJHTzhQb2lGT214NlhuamNwbjF2blRoXzE3NjI1OTY0NjQ6MTc2MjYwMDA2NF9WNA)

### **Q2: What should I do if the worker fails to start?**

​**Possible Reasons**​:

* Network Volume not attached or incorrectly mounted
* Container image pull failed
* Insufficient disk space in the container
* Insufficient GPU resources

​**Solution**​:

1. Check Endpoint logs (viewable in the RunPod Console)
2. Verify Network Volume is attached and mounted at `/runpod-volume`
3. Confirm that the container image name and tag are correct
4. Increase Container Disk Size if needed
5. Try using different GPU types

### **Q3: What should I do if models are not found?**

​**Possible Reasons**​:

* Models not downloaded to Network Volume
* Network Volume not attached to endpoint
* Incorrect mount path

​**Solution**​:

1. Verify Network Volume is attached to the endpoint (mount path: `/runpod-volume`)
2. Check that models exist in the Network Volume:
   ```Bash
   # In a temporary Pod with Network Volume attached
   ls -lh /workspace/models/
   ```
3. Re-run the download script if models are missing
4. Check endpoint logs for model loading errors

### **Q4: How to add or update models?**

​**Answer**​:

1. Create a temporary Pod with the Network Volume attached
2. Manually download models to `/workspace/models/` (or use the download script)
3. Models will be immediately available to all endpoints using the same Network Volume
4. **No need to rebuild the Docker image!**

### **Q5: How to configure S3 storage?**

​**Answer**​: When editing the Endpoint, set the following environment variables:

* `BUCKET_ENDPOINT_URL`: Your S3 bucket endpoint URL
* `BUCKET_ACCESS_KEY_ID`: Your S3 Access Key ID
* `BUCKET_SECRET_ACCESS_KEY`: Your S3 Secret Access Key

After configuration, the output will be automatically uploaded to S3, and the S3 URL will be returned instead of Base64.

​**Note**​: For RunPod S3, the region is automatically detected from the endpoint URL. For AWS S3, ensure the region matches your bucket region.

### **Q6: How to view worker logs?**

​**Answer**​:

1. On the Endpoint Details page, click the **"Workers"** tab
2. Click Worker ID
3. View **"Logs"** tab

![](https://vcn9g31upjvz.feishu.cn/space/api/box/stream/download/asynccode/?code=NzVhMDBjZTMxNzZkZDBlYzVjZjhkOGNhYzg2MjA4YTVfQ29WUW9YNktRbkY0cTQ2eHlXR25IV2w2YTFBTHdNM3BfVG9rZW46Tklod2JtNDZubzZLQ1V4ZWtObGNBQ2Q0blJlXzE3NjI1OTY0NjQ6MTc2MjYwMDA2NF9WNA)

### **Q7: What if the task times out?**

​**Possible Reasons**​:

* Workflow execution time is too long
* Model loading time is too long (first load may be slower)
* Network issue

​**Solution**​:

1. Optimize workflows and reduce unnecessary steps
2. Use a faster GPU
3. Check the stability of the network connection
4. Consider using `REFRESH_WORKER=false` to keep models loaded in memory

### **Q8: Can I share the same Network Volume across multiple endpoints?**

​**Answer**​: Yes! You can attach the same Network Volume to multiple endpoints. This allows you to:

* Share models across endpoints
* Update models once and use everywhere
* Reduce storage costs

---

## **Document Version**

\* ​**Version**​: 2.0.0

\* ​**Last Updated**​: 2025-11-08

\* ​**Author**​: Robin

\* ​**Changes from v1.0.0**​:

* Migrated to Network Volume model storage
* Added Network Volume creation and configuration steps
* Updated build time and deployment instructions
* Added model management flexibility documentation

---

