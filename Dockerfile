FROM jenkins/inbound-agent:alpine3.19-jdk17

USER root

# install basic tools
RUN apk add --no-cache \
    bash \
    curl \
    git \
    jq \
    docker-cli \
    python3 \
    py3-pip \
    py3-virtualenv \
    openssl \
    gcc \
    musl-dev \
    python3-dev \
    libffi-dev \
    libsodium-dev

# create a virtualenv and activate it globally so pip works without --break-system-packages
# do not preinstall PyGithub/requests here; the pipeline installs its own versions at runtime
RUN python3 -m venv /opt/venv \
    && /opt/venv/bin/pip install --upgrade pip \
    && rm -f /usr/lib/python3*/EXTERNALLY-MANAGED \
    && mkdir -p /home/jenkins/.config/pip \
    && chown -R jenkins:jenkins /home/jenkins/.config
ENV PATH="/opt/venv/bin:$PATH"
ENV VIRTUAL_ENV="/opt/venv"

# install kubectl
RUN curl -LO https://dl.k8s.io/release/$(curl -LS https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl \
    && chmod +x kubectl \
    && mv kubectl /usr/local/bin/

# install helm
RUN curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
