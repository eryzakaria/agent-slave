FROM jenkins/inbound-agent:alpine

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
    openssl

# create a virtualenv and activate it globally so pip works without --break-system-packages
RUN python3 -m venv /opt/venv \
    && /opt/venv/bin/pip install --upgrade pip \
    && /opt/venv/bin/pip install "PyGithub>=2.0" "requests>=2.28" "urllib3>=2.0" \
    && rm -f /usr/lib/python3*/EXTERNALLY-MANAGED \
    && printf 'PyGithub>=2.0\nrequests>=2.28\nurllib3>=2.0\n' > /opt/venv/constraints.txt
ENV PATH="/opt/venv/bin:$PATH"
ENV VIRTUAL_ENV="/opt/venv"
ENV PIP_CONSTRAINT="/opt/venv/constraints.txt"

# install kubectl
RUN curl -LO https://dl.k8s.io/release/$(curl -LS https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl \
    && chmod +x kubectl \
    && mv kubectl /usr/local/bin/

# install helm
RUN curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
