## Project ID

**live/secrets.auto.tfvars**
```hcl
project_id_map = {
    stage = "project-id-not-number"
    prod  = "project-id-not-number"
}
```

## Apply changes

### Stage

```bash
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
