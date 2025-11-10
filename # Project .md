# Project Introduction

This project will [ package ComfyUI ](https://github.com/comfyanonymous/ComfyUI) into a Serverless Endpoint that can be deployed on RunPod, providing a standardized REST API interface. Through this service, you can:

* ✅ Generate images and videos using ComfyUI's powerful workflow capabilities
* ✅ Call via HTTP API, no local deployment required
* ✅ Supports image URL and Base64 input
* ✅ Automatically process video output (MP4, WebM, etc.)
* ✅ Supports S3 storage or Base64 return

## Built-in Function

* ​**Model Support**​: SDXL, Wan2.2
* ​**Custom Nodes**​: Integrate commonly used custom nodes and LoRA
* ​**Error handling ​**​: Complete error handling and reconnection mechanism

---

# Prerequisites

Before you begin, please ensure that you meet the following conditions:

## Required Item

* ✅ \*\*RunPod Account\*\*: Register and log in [RunPod](https://www.runpod.io/)
* ✅ \*\*API Call Tools\*\*: Postman, curl, Python requests, etc.
* ✅ \*\*ComfyUI Workflow\*\*: Workflow JSON file exported from ComfyUI

## Recommended Item

* ✅ \*\*ComfyUI Local Environment\*\*: Used for testing and exporting workflows
* ✅ \*\*S3 Storage Account\*\*: Used to store generated images/videos (optional)
* ✅ \*\*Python Environment\*\*: Used for writing test scripts

---

# Deploy Endpoint on RunPod

This section will provide a detailed introduction on how to create and configure a Serverless Endpoint on RunPod.

## Step 1: Log in to the RunPod Console

1. Access[ RunPod Console ](https://www.runpod.io/console)
2. Log in using your account

![](https://vcn9g31upjvz.feishu.cn/space/api/box/stream/download/asynccode/?code=NjNmODRkNmNjZjAwMDM0MTY0NWI0MGU2YjJhYjUwMGJfSlBwSWl3ZW01c2NxcUtQazRzTDZOWTRMdjgySGIwV3RfVG9rZW46UWhBMGJPNEFBb3VEQVJ4TmdyN2NRc2ZTblkwXzE3NjI1Mjc1Njc6MTc2MjUzMTE2N19WNA)![](https://vcn9g31upjvz.feishu.cn/space/api/box/stream/download/asynccode/?code=NTliNmM0OGMyZDc1ZDZkNzQ1Y2UyNTkwNWRiOTM3OTNfRTk2NGE1UGpaRzNkY2U2OFlYUEthMFZ5S0VwcmVldXVfVG9rZW46Qks5dGJvUlV2bzloRHF4UnhuV2NueEZPbmpjXzE3NjI1Mjc1Njc6MTc2MjUzMTE2N19WNA)

---

## Step 2: Create a Serverless Endpoint

3. On the left navigation bar, click **"Serverless"** → **"Endpoints"**
4. Click the **"New Endpoint"** button

> ![](https://vcn9g31upjvz.feishu.cn/space/api/box/stream/download/asynccode/?code=MjgwYTk5NjFkNTIzZmVjMmJlYjBmOTQ1MzAyYzU0YjFfWVRBcnM4aUVUUGpud2ZZc3QxOHd6QmNJUkRicUpWRTRfVG9rZW46WUE3emJ6dlpDb2xBeWp4bEp3ZWNUcU16blZjXzE3NjI1Mjc1Njc6MTc2MjUzMTE2N19WNA)
> 
> ![](https://vcn9g31upjvz.feishu.cn/space/api/box/stream/download/asynccode/?code=MzhmYTU3Y2JmNTIzMzdlMzQxOWYxMzMzMTBlMzFkZjNfTTdEZUpGM0x6RnVZcGJramNpaEd5RVNwbUc1c1JHZ3FfVG9rZW46V2VTRWJUeXdpb05nTGt4N0VtWGNLTWQ4bnliXzE3NjI1Mjc1Njc6MTc2MjUzMTE2N19WNA)

5. In the Create Endpoint dialog box, configure the following information:
   ​**Basic Information**​:
   
   1. ​**Endpoint Name**​: `runpod-comfyui-cuda128` (or your preferred name)
   2. ​**Endpoint Type**​: Queue
   3. ​**Worker Type**​: GPU
   4. ​**GPU Configuration**​: 选择 **"32GB\_pro"**

> ![](https://vcn9g31upjvz.feishu.cn/space/api/box/stream/download/asynccode/?code=ODdiM2Q0MTZhZDM5NjhiNjEwNGY4M2JhNDY2ZTJiOTZfcFdzbk1tVFZsMnp4RkVhTTgyVGY2UE9BQnZVM0lwenVfVG9rZW46VDJyaGJld1FYbzlmTmp4ODNUM2NPdUpFbnRmXzE3NjI1Mjc1Njc6MTc2MjUzMTE2N19WNA)![](https://vcn9g31upjvz.feishu.cn/space/api/box/stream/download/asynccode/?code=NjJmOTI3N2VlNWI0Y2VjOGIyODA0ZDgxYTg0M2Y5MmVfU3BUZjRXNkRabmRMT3ppR1B3RHBTakpQWGVCc25mY0FfVG9rZW46VUllbGJvRjlUbzdLWWN4MHdpQ2NrcmxSblpiXzE3NjI1Mjc1Njc6MTc2MjUzMTE2N19WNA)

6. Click the **"Deploy"** button to create an Endpoint
7. Waiting for **"Build"**

> ![](https://vcn9g31upjvz.feishu.cn/space/api/box/stream/download/asynccode/?code=MjVlY2JiNjNjMDU1MDc5NDUwOTBiYTZhYTQ4NmRkYzZfd3FzdmlFTmV0RDd2TmRlS1IyOERBSHZBVVR1b0pPWldfVG9rZW46SFRrY2JMNkVjb21STTB4RUpZMmNvaTljbm1oXzE3NjI1Mjc1Njc6MTc2MjUzMTE2N19WNA)

---

## Step 3: Obtain the Endpoint ID and API Address

After the deployment is completed, you need to obtain information about the Endpoint:

8. On the Endpoint Details page, you will see:
   1. ​**Endpoint ID**​: A string similar to `gajfoofo237uua`
   2. ​**API Base URL**​: Similar to https://api.runpod.ai/v2/gajfoofo237uua/run

> ![](https://vcn9g31upjvz.feishu.cn/space/api/box/stream/download/asynccode/?code=M2VhMzRkZjZjZjJkZmMwYjgyMzBmZjBiNmE2NDdkMzJfOWlUVnpuU1NFUFZkcGRZUGdsNnlaTVVORjB5SzRyR2dfVG9rZW46SHFLNmI4M2pKb21pYUt4VXJ3MGNqT0w5bnZiXzE3NjI1Mjc1Njc6MTc2MjUzMTE2N19WNA)

9. Record this information, which will be needed for subsequent API calls

---

## Step 4: Verify Endpoint Status

Before starting to call the API, ensure that the Endpoint is in an available state:

10. Click in the upper right corner**​"Manager"​**to select**​"Edit Endpoint",​**adjust**​"Max Workers"​**to an appropriate number
11. On the Endpoint Details page, view the **"Workers"** status
12. When called for the first time, the Worker will automatically start
13. Wait for the Worker state to change to **"idle"**

> ![](https://vcn9g31upjvz.feishu.cn/space/api/box/stream/download/asynccode/?code=OTMwOTVkZDFjYmIxNjVlNmMzOTI0YjY5NzIwMmZmZDJfbVVhZWhGTWlQYkVKT3VmUDhYdEg4ODRjYWxuN25LOWxfVG9rZW46TFBDSmJrMFZIb29MWEZ4V3JhTGNBYW0ybml4XzE3NjI1Mjc1Njc6MTc2MjUzMTE2N19WNA)
> 
> ![](https://vcn9g31upjvz.feishu.cn/space/api/box/stream/download/asynccode/?code=NDUyM2VhMTAzM2E1MmNhYzY5Y2Y0YjBlOGUxNTI2NTZfVFBibWM3VXlXQjRVbTVReTRFVlAyWTZ2OFVYdGJ3MExfVG9rZW46UUF0YmJEMk5Hb0pBSFN4VjhuQ2NveHE2bnFmXzE3NjI1Mjc1Njc6MTc2MjUzMTE2N19WNA)
> 
> ![](https://vcn9g31upjvz.feishu.cn/space/api/box/stream/download/asynccode/?code=MWZjMWFkYmZiNzhkNjIwMGVmYWY4MjZkYThjNWVjYzBfRFRTYjNkZjVrN2ZrZTlMdnRJU0twT3JaQUJ1c2NHVnJfVG9rZW46Q1BEN2IxYXRnb1NPUjZ4czN5b2NxR0o1bk1iXzE3NjI1Mjc1Njc6MTc2MjUzMTE2N19WNA)

## Step 5: Obtain API Keys

14. In the left navigation bar, click **"Settings"** → **"API Keys"**
15. Click the **"Create API Key"** button, then click **"Create"**

> ![](https://vcn9g31upjvz.feishu.cn/space/api/box/stream/download/asynccode/?code=OGE3ZGFmZTYxNTY0ZDI5OTA4Nzg1NDg3MGVlZjk1M2VfREJOTEpPeUV1S25MS0NTQ3lkNmJ5eXZkMGpieGd0Uk5fVG9rZW46UUpKemJxVjZXb3E2SHp4ZE9LR2Nrbkw4bnplXzE3NjI1Mjc1Njc6MTc2MjUzMTE2N19WNA)
> 
> ![](https://vcn9g31upjvz.feishu.cn/space/api/box/stream/download/asynccode/?code=ZTMzZGYwZjQwZjZmNjI3Y2ZmMTFjY2Q5YzI1MTU1M2FfSVZmTVFXazRJSXhVSHdIb08zMXF2ZTdlWEVpUGVXOEJfVG9rZW46RnNkTGJLUHpUbzN1enV4a1dPUWNiM2JabnVkXzE3NjI1Mjc1Njc6MTc2MjUzMTE2N19WNA)
> 
> ![](https://vcn9g31upjvz.feishu.cn/space/api/box/stream/download/asynccode/?code=YWJmZGUzNTc4ZjU4NjllNTA0ZTYxNDhmNTc3MjljMGJfSUJ3ZEJ2OUhHQmc4a1NhaGVNTjh2dGdMb0cyUXNKaHBfVG9rZW46VmxYeGJEV2RGb3RBYTV4dFJta2NiZ2hvbkJnXzE3NjI1Mjc1Njc6MTc2MjUzMTE2N19WNA)

16. Remember your API Key （rpa\_XA2CW5BEHQE794NDZ0FKXAJBXOUW2LLP4I6ZV21Xykgopf)

---

# API Usage Example (Taking Postman as an Example)

## Initiate a create task request

1. ​**Create New Request**​:
   1. Method: `POST`
   2. URL: `https://api.runpod.io/v2/YOUR_ENDPOINT_ID/run`
2. ​**Configure Headers**​:
   1. `Content-Type`: `application/json`
   2. `Authorization`: `Bearer YOUR_API_KEY`
3. ​**Configuration Body**​:
   1. Select `raw` and `JSON`
   2. Paste your request JSON

For SDXL image-to-image, please refer to this json file: **SDXL\_input\_example.json**

For Wan's image-to-video, please refer to this JSON file: **Wan\_input\_example.json**

4. **Send Request**

> ![](https://vcn9g31upjvz.feishu.cn/space/api/box/stream/download/asynccode/?code=ZjQ4MzkyZjNjZGYyNWRiNGQwMDU0MmM2ODc5OGExNWNfUnJ2Nmg4cUtmVVgxZnN6YlhndTgzZjBLTlh2RXkwY3JfVG9rZW46Q3diV2JUZ1NLb3cxM2F4YWRRY2NBYVlLbmdlXzE3NjI1Mjc1Njc6MTc2MjUzMTE2N19WNA)
> 
> ![](https://vcn9g31upjvz.feishu.cn/space/api/box/stream/download/asynccode/?code=ZmIzMTg4Y2QyNTM2MjNhYTIzN2IyYjFjNGU3NTE5OWFfc0Jqckhwc0JHa0FoQzBTeklSWUNXYm5VbjEwOTYxUGtfVG9rZW46TzQ5RmJRaUJmb0xISTF4ajhZOWN5Mk05bk5mXzE3NjI1Mjc1Njc6MTc2MjUzMTE2N19WNA)

## Result Request

1. ​**Create New Request**​:
   1. Method: `GET`
   2. URL: `https://api.runpod.ai/v2/`​`YOUR_ENDPOINT_ID`​`/status/`​`JOB_ID`
2. ​**Configure Headers**​:
   1. `Authorization`: `Bearer YOUR_API_KEY`
3. **Send Request**

> ![](https://vcn9g31upjvz.feishu.cn/space/api/box/stream/download/asynccode/?code=OGYxYzhjMTY1NTQ0ODI2MTcwMzZlZmQyZWNlYzNkYzZfQThDZzBacUhQUUdZVTBSY01GUUZEMWc3aUhIODE4andfVG9rZW46TEE1aWJZWUxJb0FaWUt4VWVvMWNCZU1kblRiXzE3NjI1Mjc1Njc6MTc2MjUzMTE2N19WNA)

## Process base64 result

1. **Save the response after the result returns**​**`200 OK`**

> ![](https://vcn9g31upjvz.feishu.cn/space/api/box/stream/download/asynccode/?code=ZDMxYzcwMWEzYWZlZGNlMTk2M2UwZjk5MzRjMGRkODdfUWRMMWE2SXFGWndXNjhPQUQ4a0loTm1WVVNVa05hUWNfVG9rZW46SGVWQ2JMWDVLb2xPZ1h4S2VYOGMxbXlPbmtkXzE3NjI1Mjc1Njc6MTc2MjUzMTE2N19WNA)

2. **Process files using base64\_gui.py**

```Plain
python base64_gui.py
```

> ![](https://vcn9g31upjvz.feishu.cn/space/api/box/stream/download/asynccode/?code=ZmYwNTQ3OTNmNzUxZTg3NjE5MzJhM2QwMGE0MjQyNTdfQTh3RXZJeHhWeUtuUzVVTjVkTEVjdFcxWDBlRWRkSFhfVG9rZW46V2lDRmIwRFdObzhzVWl4aDczM2NPN1JVbnhmXzE3NjI1Mjc1Njc6MTc2MjUzMTE2N19WNA)

---

# Frequently Asked Questions and Troubleshooting

## Q1: How to export a workflow from ComfyUI?

​**Answer**​:

1. Open your workflow in ComfyUI
2. Click the top menu **"Workflow"** → **"Export (API)"**
3. Save JSON File
4. Use JSON content as the value of `input.workflow`

![](https://vcn9g31upjvz.feishu.cn/space/api/box/stream/download/asynccode/?code=YjEwNmNkZjlkYTNmOTUxMWE4YzgyYzg0MTdkOGMwZTlfM255b0lMMlZBVDlZTjg0VjJQUFJrUHF6bXFWaWNiODdfVG9rZW46RUJ4ZWJuM2pPb284VnV4T0RabmNLbzVJbkNjXzE3NjI1Mjc1Njc6MTc2MjUzMTE2N19WNA)

---

## Q2: What should I do if the Worker fails to start?

​**Possible Reasons ​**​:

* Mirroring pull failed
* Insufficient disk space in the container
* Insufficient GPU resources

​**Solution ​**​:

1. Check Endpoint logs (viewable in the RunPod Console)
2. Confirm that the mirroring name and label are correct
3. Increase Container Disk Size
4. Try using different GPU types

---

## Q3: What should I do if the image upload fails?

​**Possible Reasons ​**​:

* URL is inaccessible
* Base64 format error
* Image file is too large

​**Solution ​**​:

1. Confirm that the URL is publicly accessible (do not use URLs that require authentication)
2. Check if the Base64 format is correct
3. Compress the image size (recommended < 10MB)
4. Check the `errors` field in the response to obtain detailed error information

---

## Q4: How to configure S3 storage?

​**Answer**​: When creating a Template or Endpoint, set the following environment variables:

* `BUCKET_ENDPOINT_URL`: `https://your-bucket.s3.region.amazonaws.com`
* `BUCKET_ACCESS_KEY_ID`: 您的 AWS Access Key ID
* `BUCKET_SECRET_ACCESS_KEY`: 您的 AWS Secret Access Key

After configuration, the output will be automatically uploaded to S3, and the S3 URL will be returned instead of Base64.

---

## Q5: How to view Worker logs?

​**Answer**​:

1. On the Endpoint Details page, click the **"Workers"** tab
2. Click Worker ID
3. View **"Logs"** tab

![](https://vcn9g31upjvz.feishu.cn/space/api/box/stream/download/asynccode/?code=NThhNTA4YjVhMzYyOTZmN2ZlMTNmZTFjNmY3ZjU5NDJfTU8wV3UyWVdaNXdHSk1KNFZ0QzRWT0IzWExNbU9yZ1RfVG9rZW46QlBaU2Iwd09Ob0Z5TjF4a3ZpaWMwMkllbjhjXzE3NjI1Mjc1Njc6MTc2MjUzMTE2N19WNA)

---

## Q6: What if the task times out?

​**Possible Reasons ​**​:

* Workflow execution time is too long
* Model loading time is too long
* Network issue

​**Solution ​**​:

1. Optimize workflows and reduce unnecessary steps
2. Use a faster GPU
3. Check the stability of the network connection

---

# Document Version

* ​**Version**​: 1.0.0
* ​**Last Updated**​: 2025-11-05
* ​**Author**​: Robin

---

