FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        git \
        openssh-server \
        tzdata \
        vim \
        rsync \
        htop \
        python3 \
    && rm -rf /var/lib/apt/lists/*

COPY --from=ghcr.io/astral-sh/uv:0.12.3 /uv /uvx /usr/local/bin/

ENV UV_CACHE_DIR=/workspace/.uv_cache \
    UV_PYTHON_INSTALL_DIR=/workspace/.uv_python \
    UV_MANAGED_PYTHON=1 \
    UV_LINK_MODE=hardlink

ENV XLA_PYTHON_CLIENT_PREALLOCATE=false

WORKDIR /workspace

COPY start.sh /usr/local/bin/start.sh
RUN chmod +x /usr/local/bin/start.sh

CMD ["/usr/local/bin/start.sh"]
