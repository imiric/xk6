ARG GO_VERSION=1.20.1
ARG VARIANT=bullseye
FROM golang:${GO_VERSION}-${VARIANT} as builder

RUN addgroup --gid 1000 xk6 && \
    adduser --uid 1000 --ingroup xk6 --home /home/xk6 --shell /bin/sh --disabled-password --gecos "" xk6

ARG FIXUID_VERSION=0.5.1
RUN USER=xk6 && \
    GROUP=xk6 && \
    curl -fSsL https://github.com/boxboat/fixuid/releases/download/v${FIXUID_VERSION}/fixuid-${FIXUID_VERSION}-linux-amd64.tar.gz | tar -C /usr/local/bin -xzf - && \
    chown root:root /usr/local/bin/fixuid && \
    chmod 4755 /usr/local/bin/fixuid && \
    mkdir -p /etc/fixuid && \
    printf "user: $USER\ngroup: $GROUP\n" > /etc/fixuid/config.yml

WORKDIR /xk6
RUN chown xk6:xk6 /xk6
USER xk6

ARG XK6_VERSION=latest
RUN go install go.k6.io/xk6/cmd/xk6@${XK6_VERSION} && \
  go clean -cache -modcache && \
  rm -rf "$HOME/.cache"

COPY docker-entrypoint.sh /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
