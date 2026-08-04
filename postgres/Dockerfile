ARG POSTGIS_VERSION=17-3.5  # postgresqlVersion-postgisVersion

FROM postgis/postgis:${POSTGIS_VERSION} AS pgbackrest-build

ARG PGBACKREST_VERSION=2.59.0

WORKDIR /build

RUN apt-get update -y && \
    apt-get install -y --no-install-recommends \
        wget \
        python3-distutils \
        meson \
        gcc \
        libpq-dev \
        libssl-dev \
        libxml2-dev \
        pkg-config \
        liblz4-dev \
        libzstd-dev \
        libbz2-dev \
        libz-dev \
        libyaml-dev \
        libssh2-1-dev

RUN wget -q -O - \
    "https://github.com/pgbackrest/pgbackrest/releases/download/release/${PGBACKREST_VERSION}/pgbackrest-${PGBACKREST_VERSION}.tar.gz" | \
    tar zx -C ./

RUN meson setup pgbackrest "pgbackrest-${PGBACKREST_VERSION}" && \
    ninja -C pgbackrest

# ---------------- Final image ------
FROM postgis/postgis:$POSTGIS_VERSION AS postgis

COPY pgbackrest/setup.sh /pgbackrest-setup.sh
COPY pgbackrest/run-with-retry.sh /usr/local/bin/pgbackrest-with-retry

COPY --from=pgbackrest-build /build/pgbackrest/src/pgbackrest /usr/bin

RUN chmod +x /usr/bin/pgbackrest /usr/local/bin/pgbackrest-with-retry && \
    pgbackrest version

CMD ["postgres"]
