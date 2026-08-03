## Project ID

**live/secrets.auto.tfvars**
> NOTE: Sample is available here (./live/secrets-sample.auto.tfvars)[./live/secrets-sample.auto.tfvars]

## Apply changes

### Google Auth

Using profile
```bash
gcloud config configurations activate <profile>

export GOOGLE_OAUTH_ACCESS_TOKEN=$(gcloud auth print-access-token)
```

Using ADC
```bash
gcloud auth application-default login
```

### Stage

```bash
# Enable some api if not already
gcloud services enable storage.googleapis.com --project=YOUR_PROJECT_ID
gcloud services enable cloudresourcemanager.googleapis.com --project=YOUR_PROJECT_ID
gcloud services enable billingbudgets.googleapis.com --project=YOUR_PROJECT_ID
gcloud services enable iam.googleapis.com --project=YOUR_PROJECT_ID

# List all enabled apis
gcloud services list --enabled --project=YOUR_PROJECT_ID

# Terragrunt
cd live/stage

terragrunt plan

terragrunt apply
```

### Prod

```bash
cd live/prod

terragrunt plan

terragrunt apply
```
