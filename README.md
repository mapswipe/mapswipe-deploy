## Setup

### Cloning the Repository

Most submodules use SSH URLs. To avoid setting up SSH keys, run this command to use HTTPS instead:

```bash
git config --global url."https://github.com/".insteadOf "git@github.com:"
```

Clone and pull all submodules
```bash
git clone git@github.com:mapswipe/mapswipe-deploy.git --branch feat/pre-deployment-setup
cd mapswipe-deploy
git submodule update --init --recursive
```

### Environment Variables

Make sure these environment files are in place:

- .env (based on `.env.sample`)
- env/backend.env
- env/community-dashboard.env
- env/manager-dashboard.env
- secrets/pgbackrest_gc_service_account_key.json

```bash
cp .env.sample .env
touch env/backend.env
touch env/community-dashboard.env
touch env/manager-dashboard.env
touch secrets/pgbackrest_gc_service_account_key.json
```

## Apply changes

```bash
task --list-all

# Deploy all
task deploy

# Deploy web apps
task web-builds

# Deploy backend resources
task backend-deploy

# Deploy caddy
task caddy-deploy
```

### pgBackRest

Create "main" stanza
```bash
docker compose exec -u postgres postgres pgbackrest --stanza=main stanza-create
```

View backup info
```bash
docker compose exec -u postgres postgres pgbackrest --stanza=main info
```
