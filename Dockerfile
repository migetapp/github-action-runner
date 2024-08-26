FROM quay.io/podman/stable:latest

USER root
RUN dnf install -y \
    curl \
    jq \
    git \
    sudo \
    tar \
    gcc \
    glibc-devel \
    libffi-devel \
    openssl-devel \
    make \
    ruby-devel \
    && dnf clean all

RUN mkdir -p /home/podman/actions-runner && \
    cd /home/podman/actions-runner && \
    curl -o actions-runner-linux-x64.tar.gz -L https://github.com/actions/runner/releases/download/v2.319.1/actions-runner-linux-x64-2.319.1.tar.gz && \
    tar xzf actions-runner-linux-x64.tar.gz && \
    rm actions-runner-linux-x64.tar.gz

RUN mkdir -p /home/podman/runner && \
    chown -R podman:podman /home/podman

RUN cd /home/podman/actions-runner/bin && chmod 755 installdependencies.sh && ./installdependencies.sh

COPY entrypoint.sh /home/podman/entrypoint.sh
RUN chmod +x /home/podman/entrypoint.sh

COPY storage.conf /home/podman/.config/containers/storage.conf

VOLUME /home/podman/runner

USER podman
WORKDIR /home/podman

ENTRYPOINT ["/home/podman/entrypoint.sh"]
