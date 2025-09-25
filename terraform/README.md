## Project ID

```hcl
project_id_map = {
    stage = "project-id-not-number"
    prod  = "project-id-not-number"
}
```

## Apply changes

```bash
cd live/stage

terragrunt plan

terragrunt apply
```
