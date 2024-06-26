ARG MOLLYSOCKET_VERSION=1.4.0
ARG RUST_VERSION=1.79
ARG HARDENED_MALLOC_VERSION=2024061200

### Build Hardened Malloc
FROM alpine:latest as hmalloc-builder

ARG HARDENED_MALLOC_VERSION
ARG CONFIG_NATIVE=false
ARG VARIANT=default

RUN apk -U upgrade \
    && apk --no-cache add build-base git gnupg openssh-keygen
    
RUN cd /tmp \
    && git clone --depth 1 --branch ${HARDENED_MALLOC_VERSION} https://github.com/GrapheneOS/hardened_malloc \
    && cd hardened_malloc \
    && wget -q https://grapheneos.org/allowed_signers -O grapheneos_allowed_signers \
    && git config gpg.ssh.allowedSignersFile grapheneos_allowed_signers \
    && git verify-tag $(git describe --tags) \
    && make CONFIG_NATIVE=${CONFIG_NATIVE} VARIANT=${VARIANT}

### Build Mollysocket
FROM docker.io/rust:${RUST_VERSION}-alpine AS mollysocket-builder

ARG MOLLYSOCKET_VERSION

WORKDIR app

RUN apk -U upgrade \
    && apk --no-cache add musl-dev openssl-dev openssl-libs-static sqlite-dev sqlite-static git
    
RUN git clone --depth 1 --branch ${MOLLYSOCKET_VERSION} https://github.com/mollyim/mollysocket.git

WORKDIR mollysocket

RUN cargo build --release --bin mollysocket

### Build Production
FROM alpine:latest AS runtime

WORKDIR app/mollysocket

ENV MOLLY_HOST=127.0.0.1
ENV MOLLY_PORT=8020

RUN apk -U upgrade \
    && apk --no-cache add ca-certificates \
    && rm -rf /var/cache/apk/*

COPY --from=hmalloc-builder /tmp/hardened_malloc/out/libhardened_malloc.so /usr/local/lib/
COPY --from=mollysocket-builder /app/mollysocket/target/release/mollysocket /usr/local/bin/

ENV LD_PRELOAD="/usr/local/lib/libhardened_malloc.so"

HEALTHCHECK --interval=1m --timeout=3s \
    CMD wget -q --tries=1 "http://$MOLLY_HOST:$MOLLY_PORT/" -O - | grep '"mollysocket":{"version":'
    
ENTRYPOINT ["/usr/local/bin/mollysocket"]
