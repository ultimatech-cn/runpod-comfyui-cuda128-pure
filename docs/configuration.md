# Configuration

This document outlines the environment variables available for configuring the `worker-comfyui`.

## General Configuration

| Environment Variable | Description                                                                                                                                                                                                                  | Default |
| -------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------- |
| `REFRESH_WORKER`     | When `true`, the worker pod will stop after each completed job to ensure a clean state for the next job. See the [RunPod documentation](https://docs.runpod.io/docs/handler-additional-controls#refresh-worker) for details. | `false` |
| `SERVE_API_LOCALLY`  | When `true`, enables a local HTTP server simulating the RunPod environment for development and testing. See the [Development Guide](development.md#local-api) for more details.                                              | `false` |
| `COMFY_ORG_API_KEY`  | Comfy.org API key to enable ComfyUI API Nodes. If set, it is sent with each workflow; clients can override per request via `input.api_key_comfy_org`.                                                                        | –       |

## Logging Configuration

| Environment Variable | Description                                                                                                                                                      | Default |
| -------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------- |
| `COMFY_LOG_LEVEL`    | Controls ComfyUI's internal logging verbosity. Options: `DEBUG`, `INFO`, `WARNING`, `ERROR`, `CRITICAL`. Use `DEBUG` for troubleshooting, `INFO` for production. | `DEBUG` |

## Debugging Configuration

| Environment Variable           | Description                                                                                                            | Default |
| ------------------------------ | ---------------------------------------------------------------------------------------------------------------------- | ------- |
| `WEBSOCKET_RECONNECT_ATTEMPTS` | Number of websocket reconnection attempts when connection drops during job execution.                                  | `5`     |
| `WEBSOCKET_RECONNECT_DELAY_S`  | Delay in seconds between websocket reconnection attempts.                                                              | `3`     |
| `WEBSOCKET_TRACE`              | Enable low-level websocket frame tracing for protocol debugging. Set to `true` only when diagnosing connection issues. | `false` |

> [!TIP] > **For troubleshooting:** Set `COMFY_LOG_LEVEL=DEBUG` to get detailed logs when ComfyUI crashes or behaves unexpectedly. This helps identify the exact point of failure in your workflows.

## AWS S3 Upload Configuration

Configure these variables **only** if you want the worker to upload generated images directly to an AWS S3 bucket. If these are not set, images will be returned as base64-encoded strings in the API response.

- **Prerequisites:**
  - An AWS S3 bucket in your desired region.
  - An AWS IAM user with programmatic access (Access Key ID and Secret Access Key).
  - Permissions attached to the IAM user allowing `s3:PutObject` (and potentially `s3:PutObjectAcl` if you need specific ACLs) on the target bucket.

| Environment Variable       | Description                                                                                                                             | Example                                                    |
| -------------------------- | --------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------- |
| `BUCKET_ENDPOINT_URL`      | The full endpoint URL of your S3 bucket. **Must be set to enable S3 upload.** For RunPod S3, include bucket name in URL.                | `https://s3api-eu-ro-1.runpod.io/your-bucket-name`<br>`https://<bucket>.s3.<region>.amazonaws.com` |
| `BUCKET_ACCESS_KEY_ID`     | Your AWS access key ID associated with the IAM user that has write permissions to the bucket. Required if `BUCKET_ENDPOINT_URL` is set. | `AKIAIOSFODNN7EXAMPLE`                                     |
| `BUCKET_SECRET_ACCESS_KEY` | Your AWS secret access key associated with the IAM user. Required if `BUCKET_ENDPOINT_URL` is set.                                      | `wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY`                 |

**Note for RunPod S3:** The handler automatically detects the region from `BUCKET_ENDPOINT_URL` (e.g., `eu-ro-1` from `https://s3api-eu-ro-1.runpod.io/bucket-name`). If auto-detection fails, you can manually set `AWS_DEFAULT_REGION` environment variable.

**Note:** Upload uses the `runpod` Python library helper `rp_upload.upload_image`, which handles creating a unique path within the bucket based on the `job_id`.

**Important:** RunPod's S3-compatible API **does NOT support presigned URLs**. The returned URL requires S3 API Key authentication to access. See [Accessing S3 Files](#accessing-s3-files) below for details.

### Example S3 Response

If the S3 environment variables (`BUCKET_ENDPOINT_URL`, `BUCKET_ACCESS_KEY_ID`, `BUCKET_SECRET_ACCESS_KEY`) are correctly configured, a successful job response will look similar to this:

```json
{
  "id": "sync-uuid-string",
  "status": "COMPLETED",
  "output": {
    "images": [
      {
        "filename": "ComfyUI_00001_.png",
        "type": "s3_url",
        "data": "https://s3api-eu-ro-1.runpod.io/your-bucket-name/2025-01-07/sync-uuid-string/ComfyUI_00001_.png"
      }
    ]
  },
  "delayTime": 123,
  "executionTime": 4567
}
```

The `data` field contains the S3 URL to the uploaded image file. The path usually includes the date prefix and job ID.

### Accessing S3 Files

Since RunPod's S3-compatible API does not support presigned URLs, you need to use S3 API Key credentials to access the files. Here are the recommended methods:

#### Method 1: Using AWS CLI

```bash
# Set your S3 API Key credentials
export AWS_ACCESS_KEY_ID="your-s3-api-key-access-key"
export AWS_SECRET_ACCESS_KEY="your-s3-api-key-secret"

# Download the file
aws s3 cp \
  --region eu-ro-1 \
  --endpoint-url https://s3api-eu-ro-1.runpod.io/ \
  s3://your-bucket-name/path/to/file.png \
  ./local-file.png
```

#### Method 2: Using Boto3 (Python)

```python
import boto3
import os

# Set credentials (or use environment variables)
s3_client = boto3.client(
    's3',
    aws_access_key_id=os.environ.get('AWS_ACCESS_KEY_ID'),
    aws_secret_access_key=os.environ.get('AWS_SECRET_ACCESS_KEY'),
    region_name='eu-ro-1',
    endpoint_url='https://s3api-eu-ro-1.runpod.io/'
)

# Download the file
s3_client.download_file('your-bucket-name', 'path/to/file.png', 'local-file.png')
```

#### Method 3: Using requests with S3 API Key

For programmatic access, you can use the S3 API Key to sign requests. However, this requires implementing AWS Signature Version 4, which is complex. It's recommended to use AWS CLI or Boto3 instead.

**Note:** To get your S3 API Key:
1. Go to [RunPod Settings](https://www.console.runpod.io/user/settings)
2. Expand **S3 API Keys** section
3. Create a new S3 API key if you don't have one
4. Save the **access key** and **secret** (shown only once)
