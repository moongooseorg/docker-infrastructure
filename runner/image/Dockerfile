# syntax=docker/dockerfile:1

FROM --platform=linux/arm64 ubuntu:22.04 AS builder

RUN apt-get update \
 && apt-get install -y --no-install-recommends ca-certificates curl jq \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /opt/runner

# Resolve latest + download share one RUN: the version is a shell variable
# that would not survive into a separate RUN layer.
RUN RUNNER_VERSION="$(curl -fsSL https://api.github.com/repos/actions/runner/releases/latest | jq -r '.tag_name')" \
 && curl -fsSL -o runner.tar.gz "https://github.com/actions/runner/releases/download/${RUNNER_VERSION}/actions-runner-linux-arm64-${RUNNER_VERSION#v}.tar.gz"
RUN tar xzf runner.tar.gz
RUN rm runner.tar.gz


FROM --platform=linux/arm64 ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV RUNNER_ALLOW_RUNASROOT=1

# apt cache is deleted in the same layer, else it ships in the image.
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      ca-certificates curl git sudo \
 && install -m 0755 -d /etc/apt/keyrings \
 && curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc \
 && echo "deb [arch=arm64 signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu jammy stable" > /etc/apt/sources.list.d/docker.list \
 && apt-get update \
 && apt-get install -y --no-install-recommends docker-ce-cli \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /home/runner/actions-runner

COPY --from=builder /opt/runner/ ./
RUN ./bin/installdependencies.sh

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
