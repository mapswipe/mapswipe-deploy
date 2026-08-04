#!/bin/bash

# Run pgbackrest with the given arguments, retrying on failure.
#
# Ofelia has no retry support, so a failed scheduled job is simply skipped
# until the next window -- a missed monthly full or weekly diff backup.
# Transient repository errors (eg. GCS 429 on object mutation) are common
# enough that they should not cost us a whole backup cycle.

set -u

RETRY_MAX=${PGBACKREST_RETRY_MAX:-3}
RETRY_DELAY=${PGBACKREST_RETRY_DELAY:-300}

for attempt in $(seq 1 "$RETRY_MAX"); do
  if pgbackrest "$@"; then
    exit 0
  fi

  if [[ "$attempt" -lt "$RETRY_MAX" ]]; then
    echo "pgbackrest $* failed (attempt $attempt/$RETRY_MAX), retrying in ${RETRY_DELAY}s" >&2
    sleep "$RETRY_DELAY"
  fi
done

echo "pgbackrest $* failed after $RETRY_MAX attempts" >&2
exit 1
