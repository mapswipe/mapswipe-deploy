## Setup

### pgBackRest

Create "main" stanza
```bash
docker compose exec -u postgres postgres pgbackrest --stanza=main stanza-create
```


## pgBackRest

View backup info
```bash
docker compose exec -u postgres postgres pgbackrest --stanza=main info
```
